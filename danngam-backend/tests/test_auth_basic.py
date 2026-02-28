"""
인증 API 기본 단위 테스트

테스트 항목:
- OTP 생성 및 검증
- JWT 토큰 생성 및 검증
- 레이트 리미팅
"""

import pytest
from app.utils.otp import (
    generate_otp,
    save_otp,
    verify_otp,
    get_otp_expires_in,
    is_rate_limited,
    increment_rate_limit,
    get_otp_id,
    clear_otp,
    cleanup_expired_otps,
)
from app.utils.auth import (
    create_access_token,
    verify_token,
    extract_token_from_header,
    get_token_expire_time,
)
from fastapi import HTTPException


class TestOTP:
    """OTP 유틸리티 테스트"""

    def test_generate_otp(self):
        """OTP 코드 생성 테스트"""
        otp = generate_otp()
        assert len(otp) == 6
        assert otp.isdigit()

    def test_save_and_verify_otp(self):
        """OTP 저장 및 검증 테스트"""
        phone = "010-1234-5678"
        otp_code = "123456"

        # OTP 저장
        expires_at = save_otp(phone, otp_code)
        assert expires_at > 0

        # OTP 검증 (성공)
        is_valid, message = verify_otp(phone, otp_code)
        assert is_valid is True
        assert message == "OTP 검증 성공"

    def test_verify_otp_wrong_code(self):
        """잘못된 OTP 코드 검증 테스트"""
        phone = "010-9999-9999"
        otp_code = "123456"

        save_otp(phone, otp_code)

        # 잘못된 코드 검증
        is_valid, message = verify_otp(phone, "654321")
        assert is_valid is False
        assert message == "OTP 코드 불일치"

    def test_verify_otp_not_exists(self):
        """존재하지 않는 OTP 검증 테스트"""
        is_valid, message = verify_otp("010-0000-0000", "123456")
        assert is_valid is False
        assert message == "존재하지 않는 OTP"

    def test_get_otp_expires_in(self):
        """OTP 남은 유효 시간 조회 테스트"""
        phone = "010-1111-1111"
        save_otp(phone, "123456")

        expires_in = get_otp_expires_in(phone)
        assert expires_in is not None
        assert 0 < expires_in <= 180

    def test_get_otp_id(self):
        """OTP ID 조회 테스트"""
        phone = "010-2222-2222"
        otp_code = "654321"

        save_otp(phone, otp_code)
        retrieved_code = get_otp_id(phone)

        assert retrieved_code == otp_code

    def test_rate_limiting(self):
        """레이트 리미팅 테스트"""
        phone = "010-3333-3333"

        # 5회 요청
        for i in range(5):
            assert is_rate_limited(phone) is False
            increment_rate_limit(phone)

        # 6번째 요청 제한
        assert is_rate_limited(phone) is True


class TestJWT:
    """JWT 토큰 유틸리티 테스트"""

    def test_create_access_token(self):
        """JWT 토큰 생성 테스트"""
        data = {"sub": "user123", "phone": "010-1234-5678"}
        token = create_access_token(data)

        assert isinstance(token, str)
        assert len(token) > 0

    def test_verify_token(self):
        """JWT 토큰 검증 테스트"""
        data = {"sub": "user123", "phone": "010-1234-5678"}
        token = create_access_token(data)

        payload = verify_token(token)
        assert payload["sub"] == "user123"
        assert payload["phone"] == "010-1234-5678"

    def test_verify_invalid_token(self):
        """유효하지 않은 토큰 검증 테스트"""
        invalid_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.invalid.signature"

        with pytest.raises(HTTPException):
            verify_token(invalid_token)

    def test_extract_token_from_header(self):
        """Authorization 헤더에서 토큰 추출 테스트"""
        token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.payload.signature"
        auth_header = f"Bearer {token}"

        extracted = extract_token_from_header(auth_header)
        assert extracted == token

    def test_extract_token_invalid_format(self):
        """유효하지 않은 헤더 형식 테스트"""
        with pytest.raises(HTTPException):
            extract_token_from_header("Invalid header")

    def test_extract_token_missing_bearer(self):
        """Bearer 없는 헤더 테스트"""
        with pytest.raises(HTTPException):
            extract_token_from_header("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9")

    def test_get_token_expire_time(self):
        """토큰 만료 시간 조회 테스트"""
        expire_time = get_token_expire_time()
        assert expire_time == 86400  # 24시간


class TestIntegration:
    """통합 테스트"""

    def test_otp_to_jwt_flow(self):
        """OTP -> JWT 전체 흐름 테스트"""
        phone = "010-4444-4444"

        # 1. OTP 생성
        otp_code = generate_otp()
        save_otp(phone, otp_code)

        # 2. OTP 검증
        is_valid, _ = verify_otp(phone, otp_code)
        assert is_valid is True

        # 3. JWT 토큰 생성
        token = create_access_token({"sub": "user_id", "phone": phone})
        assert token is not None

        # 4. JWT 토큰 검증
        payload = verify_token(token)
        assert payload["phone"] == phone

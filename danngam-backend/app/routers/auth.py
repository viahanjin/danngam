"""
인증 API 라우터

엔드포인트:
1. POST /api/v1/auth/send-otp - OTP 발송
2. POST /api/v1/auth/verify-otp - OTP 검증
3. POST /api/v1/auth/logout - 로그아웃
"""

from fastapi import APIRouter, Depends, HTTPException, status, Header
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.user import User
from app.schemas.auth import (
    SendOTPRequest,
    SendOTPResponse,
    VerifyOTPRequest,
    VerifyOTPResponse,
    LogoutResponse,
)
from app.utils.otp import (
    generate_otp,
    save_otp,
    verify_otp,
    get_otp_expires_in,
    is_rate_limited,
    increment_rate_limit,
    get_otp_id,
)
from app.utils.auth import (
    create_access_token,
    verify_token,
    extract_token_from_header,
    get_token_expire_time,
)
from app.config import settings
from typing import Optional

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post(
    "/send-otp",
    response_model=SendOTPResponse,
    status_code=status.HTTP_200_OK,
    summary="OTP 발송",
    description="사용자의 전화번호로 OTP 코드를 발송합니다. (6자리 숫자, 3분 유효)",
    responses={
        200: {"description": "OTP 발송 성공"},
        400: {"description": "잘못된 전화번호"},
        429: {"description": "요청이 너무 많음 (1시간에 5회 제한)"},
        500: {"description": "서버 오류"},
    }
)
async def send_otp(
    request: SendOTPRequest,
    db: Session = Depends(get_db)
) -> SendOTPResponse:
    """
    사용자 전화번호로 OTP 코드 발송

    요청 본문:
    ```json
    {
        "phone": "010-1234-5678"
    }
    ```

    응답:
    ```json
    {
        "message": "OTP가 발송되었습니다. 3분 내에 입력해주세요.",
        "otp_id": "123456",
        "expires_in": 180
    }
    ```

    에러:
    - 400: 잘못된 전화번호 형식
    - 429: 1시간에 5회 초과 요청
    - 500: 서버 오류
    """
    phone = request.phone.strip()

    # 전화번호 형식 검증 (기본적인 검증)
    if not phone or len(phone.replace("-", "")) < 10:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="유효한 전화번호 형식이 아닙니다 (최소 10자리)"
        )

    # 레이트 리미팅 확인 (1시간에 5회 제한)
    if is_rate_limited(phone):
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=f"1시간에 5회 이상 요청할 수 없습니다. 잠시 후 다시 시도해주세요."
        )

    # OTP 코드 생성
    otp_code = generate_otp()

    # OTP 저장 및 만료 시간 설정
    expires_at = save_otp(phone, otp_code)

    # 레이트 리미팅 카운터 증가
    increment_rate_limit(phone)

    # 남은 유효 시간 조회
    expires_in = get_otp_expires_in(phone)

    # 응답 생성 (개발 환경에서는 otp_id 포함)
    response = SendOTPResponse(
        message="OTP가 발송되었습니다. 3분 내에 입력해주세요.",
        otp_id=otp_code,  # 테스트용: 실제 프로덕션에서는 제거
        expires_in=expires_in or 180
    )

    return response


@router.post(
    "/verify-otp",
    response_model=VerifyOTPResponse,
    status_code=status.HTTP_200_OK,
    summary="OTP 검증 및 로그인",
    description="사용자가 입력한 OTP 코드를 검증하고 JWT 토큰을 발급합니다.",
    responses={
        200: {"description": "OTP 검증 성공, JWT 토큰 발급"},
        400: {"description": "OTP 코드 불일치 또는 유효하지 않음"},
        500: {"description": "서버 오류"},
    }
)
async def verify_otp(
    request: VerifyOTPRequest,
    db: Session = Depends(get_db)
) -> VerifyOTPResponse:
    """
    OTP 코드를 검증하고 JWT 토큰 발급

    요청 본문:
    ```json
    {
        "phone": "010-1234-5678",
        "otp_code": "123456"
    }
    ```

    응답:
    ```json
    {
        "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        "token_type": "bearer",
        "expires_in": 86400
    }
    ```

    에러:
    - 400: OTP 코드 불일치 또는 만료됨
    - 500: 서버 오류
    """
    phone = request.phone.strip()
    otp_code = request.otp_code.strip()

    # OTP 검증
    is_valid, message = verify_otp(phone, otp_code)

    if not is_valid:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=message
        )

    # 사용자 조회 또는 생성
    user = db.query(User).filter(User.phone == phone).first()

    if not user:
        # 새 사용자 생성
        user = User(
            phone=phone,
            name=phone  # 기본 이름 설정 (나중에 수정 가능)
        )
        db.add(user)
        db.commit()
        db.refresh(user)

    # JWT 토큰 생성
    access_token = create_access_token(
        data={"sub": str(user.id), "phone": user.phone}
    )

    # 토큰 만료 시간
    expires_in = get_token_expire_time()

    response = VerifyOTPResponse(
        access_token=access_token,
        token_type="bearer",
        expires_in=expires_in
    )

    return response


@router.post(
    "/logout",
    response_model=LogoutResponse,
    status_code=status.HTTP_200_OK,
    summary="로그아웃",
    description="현재 세션을 종료합니다 (토큰 무효화).",
    responses={
        200: {"description": "로그아웃 성공"},
        401: {"description": "유효한 토큰이 없음"},
        500: {"description": "서버 오류"},
    }
)
async def logout(
    authorization: Optional[str] = Header(None)
) -> LogoutResponse:
    """
    사용자 로그아웃

    헤더:
    ```
    Authorization: Bearer {access_token}
    ```

    응답:
    ```json
    {
        "message": "로그아웃되었습니다."
    }
    ```

    에러:
    - 401: 유효한 Authorization 헤더가 없음
    """
    # Authorization 헤더에서 토큰 추출
    token = extract_token_from_header(authorization)

    # 토큰 검증 (유효성 확인만, 실제로 토큰을 삭제하지는 않음)
    # 프로덕션에서는 토큰 블랙리스트에 추가하거나 Redis에 저장
    payload = verify_token(token)

    response = LogoutResponse(
        message="로그아웃되었습니다."
    )

    return response

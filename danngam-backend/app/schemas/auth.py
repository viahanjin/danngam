"""
인증 API 요청/응답 스키마 (Pydantic)

스키마:
- SendOTPRequest: OTP 발송 요청
- SendOTPResponse: OTP 발송 응답
- VerifyOTPRequest: OTP 검증 요청
- VerifyOTPResponse: OTP 검증 응답
- LogoutRequest: 로그아웃 요청
- LogoutResponse: 로그아웃 응답
"""

from pydantic import BaseModel, Field
from typing import Optional


class SendOTPRequest(BaseModel):
    """
    OTP 발송 요청 스키마

    필드:
    - phone: 전화번호 (예: "010-1234-5678" 또는 "01012345678")
    """
    phone: str = Field(
        ...,
        min_length=10,
        max_length=20,
        description="사용자 전화번호 (하이픈 포함/제외 모두 가능)"
    )

    class Config:
        examples = [
            {
                "phone": "010-1234-5678"
            },
            {
                "phone": "01012345678"
            }
        ]


class SendOTPResponse(BaseModel):
    """
    OTP 발송 응답 스키마

    필드:
    - message: 응답 메시지
    - otp_id: OTP 코드 (테스트용, 개발 환경에서만 반환)
    - expires_in: OTP 만료 시간 (초 단위)
    """
    message: str = Field(
        default="OTP가 발송되었습니다. 3분 내에 입력해주세요.",
        description="응답 메시지"
    )
    otp_id: Optional[str] = Field(
        default=None,
        description="OTP 코드 (테스트용, 개발 환경에서만 반환)"
    )
    expires_in: int = Field(
        default=180,
        description="OTP 만료 시간 (초 단위)"
    )

    class Config:
        examples = [
            {
                "message": "OTP가 발송되었습니다. 3분 내에 입력해주세요.",
                "otp_id": "123456",
                "expires_in": 180
            }
        ]


class VerifyOTPRequest(BaseModel):
    """
    OTP 검증 요청 스키마

    필드:
    - phone: 전화번호
    - otp_code: 사용자가 입력한 OTP 코드 (6자리 숫자)
    """
    phone: str = Field(
        ...,
        min_length=10,
        max_length=20,
        description="사용자 전화번호"
    )
    otp_code: str = Field(
        ...,
        min_length=6,
        max_length=6,
        description="OTP 코드 (6자리 숫자)"
    )

    class Config:
        examples = [
            {
                "phone": "010-1234-5678",
                "otp_code": "123456"
            }
        ]


class VerifyOTPResponse(BaseModel):
    """
    OTP 검증 응답 스키마 (로그인 성공)

    필드:
    - access_token: JWT 액세스 토큰
    - token_type: 토큰 타입 (항상 "bearer")
    - expires_in: 토큰 만료 시간 (초 단위)
    """
    access_token: str = Field(
        ...,
        description="JWT 액세스 토큰"
    )
    token_type: str = Field(
        default="bearer",
        description="토큰 타입 (항상 'bearer')"
    )
    expires_in: int = Field(
        default=86400,
        description="토큰 만료 시간 (초 단위, 24시간)"
    )

    class Config:
        examples = [
            {
                "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "token_type": "bearer",
                "expires_in": 86400
            }
        ]


class LogoutRequest(BaseModel):
    """
    로그아웃 요청 스키마
    (Authorization 헤더에 토큰이 포함되므로 본문은 비움)
    """
    pass

    class Config:
        examples = [{}]


class LogoutResponse(BaseModel):
    """
    로그아웃 응답 스키마

    필드:
    - message: 응답 메시지
    """
    message: str = Field(
        default="로그아웃되었습니다.",
        description="응답 메시지"
    )

    class Config:
        examples = [
            {
                "message": "로그아웃되었습니다."
            }
        ]


class ErrorResponse(BaseModel):
    """
    에러 응답 스키마 (공통)

    필드:
    - detail: 에러 메시지
    - status_code: HTTP 상태 코드
    """
    detail: str = Field(
        ...,
        description="에러 메시지"
    )
    status_code: int = Field(
        ...,
        description="HTTP 상태 코드"
    )

    class Config:
        examples = [
            {
                "detail": "OTP 코드 불일치",
                "status_code": 400
            },
            {
                "detail": "1시간에 5회 이상 시도할 수 없습니다",
                "status_code": 429
            }
        ]

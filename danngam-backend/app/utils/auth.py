"""
JWT (JSON Web Token) 인증 로직

기능:
- JWT 토큰 생성
- JWT 토큰 검증
- 토큰 만료 시간 관리
"""

from datetime import datetime, timedelta
from typing import Optional
import jwt
from fastapi import HTTPException, status
from app.config import settings


def create_access_token(
    data: dict,
    expires_delta: Optional[timedelta] = None
) -> str:
    """
    JWT 액세스 토큰 생성

    Args:
        data: 토큰에 포함할 데이터 (예: {"sub": "user_id"})
        expires_delta: 토큰 만료 시간 (기본값: 24시간)

    Returns:
        JWT 토큰 문자열
    """
    to_encode = data.copy()

    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(
            hours=settings.ACCESS_TOKEN_EXPIRE_HOURS
        )

    to_encode.update({"exp": expire})

    encoded_jwt = jwt.encode(
        to_encode,
        settings.SECRET_KEY,
        algorithm=settings.ALGORITHM
    )

    return encoded_jwt


def verify_token(token: str) -> dict:
    """
    JWT 토큰 검증 및 페이로드 추출

    Args:
        token: JWT 토큰 문자열 (Bearer 제거됨)

    Returns:
        토큰 페이로드 (딕셔너리)

    Raises:
        HTTPException: 토큰이 유효하지 않거나 만료된 경우
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="토큰이 유효하지 않습니다",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )
        user_id: str = payload.get("sub")

        if user_id is None:
            raise credentials_exception

        return payload

    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="토큰이 만료되었습니다",
            headers={"WWW-Authenticate": "Bearer"},
        )

    except jwt.InvalidTokenError:
        raise credentials_exception


def extract_token_from_header(authorization: str) -> str:
    """
    Authorization 헤더에서 Bearer 토큰 추출

    Args:
        authorization: Authorization 헤더 값 (예: "Bearer eyJhbGc...")

    Returns:
        토큰 문자열

    Raises:
        HTTPException: 토큰 형식이 잘못된 경우
    """
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authorization 헤더가 없습니다",
            headers={"WWW-Authenticate": "Bearer"},
        )

    parts = authorization.split()

    if len(parts) != 2 or parts[0].lower() != "bearer":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="유효한 Bearer 토큰이 아닙니다",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return parts[1]


def get_token_expire_time() -> int:
    """
    토큰 만료 시간 반환 (초 단위)

    Returns:
        토큰 만료 시간 (초)
    """
    return settings.ACCESS_TOKEN_EXPIRE_HOURS * 3600

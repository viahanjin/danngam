"""
OTP (One-Time Password) 생성 및 검증 로직

기능:
- OTP 코드 생성 (6자리 숫자)
- OTP 저장 및 검증
- OTP 만료 시간 관리
- 레이트 리미팅
"""

import random
import time
from typing import Optional, Tuple, Dict
from app.config import settings


# OTP 저장소 (메모리 기반, 프로덕션에서는 Redis로 대체)
# 구조: {phone: {"code": "123456", "expires_at": 1234567890, "attempts": 3}}
OTP_STORAGE: Dict[str, dict] = {}

# 레이트 리미팅 저장소
# 구조: {phone: {"attempts": 5, "reset_at": 1234567890}}
RATE_LIMIT_STORAGE: Dict[str, dict] = {}


def generate_otp(length: int = None) -> str:
    """
    OTP 코드 생성 (6자리 숫자)

    Args:
        length: OTP 길이 (기본값: config.OTP_LENGTH)

    Returns:
        6자리 숫자 문자열 (예: "123456")
    """
    if length is None:
        length = settings.OTP_LENGTH

    return "".join([str(random.randint(0, 9)) for _ in range(length)])


def save_otp(phone: str, otp_code: str) -> float:
    """
    OTP 코드 저장 및 만료 시간 설정

    Args:
        phone: 사용자 전화번호
        otp_code: 생성된 OTP 코드

    Returns:
        OTP 만료 시간 (Unix timestamp)
    """
    current_time = time.time()
    expires_at = current_time + settings.OTP_EXPIRE_SECONDS

    OTP_STORAGE[phone] = {
        "code": otp_code,
        "expires_at": expires_at,
        "created_at": current_time,
        "attempts": 0  # 검증 시도 횟수
    }

    return expires_at


def verify_otp(phone: str, otp_code: str) -> Tuple[bool, str]:
    """
    OTP 코드 검증

    Args:
        phone: 사용자 전화번호
        otp_code: 사용자가 입력한 OTP 코드

    Returns:
        (성공 여부, 메시지)
        - (True, "OTP 검증 성공"): 유효한 OTP
        - (False, "OTP 만료됨"): 만료된 OTP
        - (False, "OTP 코드 불일치"): 잘못된 코드
        - (False, "존재하지 않는 OTP"): 발송된 OTP 없음
    """
    if phone not in OTP_STORAGE:
        return False, "존재하지 않는 OTP"

    otp_data = OTP_STORAGE[phone]
    current_time = time.time()

    # 만료 시간 확인
    if current_time > otp_data["expires_at"]:
        del OTP_STORAGE[phone]
        return False, "OTP 만료됨"

    # 코드 확인
    if otp_data["code"] != otp_code:
        otp_data["attempts"] += 1
        return False, "OTP 코드 불일치"

    # 검증 성공
    del OTP_STORAGE[phone]
    return True, "OTP 검증 성공"


def get_otp_expires_in(phone: str) -> Optional[int]:
    """
    OTP 남은 유효 시간 조회 (초 단위)

    Args:
        phone: 사용자 전화번호

    Returns:
        남은 시간 (초), 없으면 None
    """
    if phone not in OTP_STORAGE:
        return None

    otp_data = OTP_STORAGE[phone]
    current_time = time.time()
    remaining = int(otp_data["expires_at"] - current_time)

    return max(0, remaining)


def is_rate_limited(phone: str) -> bool:
    """
    레이트 리미팅 확인 (동일 번호 1시간당 최대 5회)

    Args:
        phone: 사용자 전화번호

    Returns:
        제한 중이면 True
    """
    current_time = time.time()

    if phone not in RATE_LIMIT_STORAGE:
        return False

    limit_data = RATE_LIMIT_STORAGE[phone]

    # 1시간(3600초) 이상 경과하면 리셋
    if current_time > limit_data["reset_at"]:
        del RATE_LIMIT_STORAGE[phone]
        return False

    # 5회 이상 시도했으면 제한
    return limit_data["attempts"] >= settings.MAX_OTP_ATTEMPTS_PER_HOUR


def increment_rate_limit(phone: str) -> None:
    """
    레이트 리미팅 카운터 증가

    Args:
        phone: 사용자 전화번호
    """
    current_time = time.time()

    if phone not in RATE_LIMIT_STORAGE:
        RATE_LIMIT_STORAGE[phone] = {
            "attempts": 1,
            "reset_at": current_time + 3600  # 1시간 후 리셋
        }
    else:
        RATE_LIMIT_STORAGE[phone]["attempts"] += 1


def get_otp_id(phone: str) -> Optional[str]:
    """
    OTP ID 조회 (테스트용)
    개발 환경에서 OTP를 검증 없이 사용할 수 있도록 함

    Args:
        phone: 사용자 전화번호

    Returns:
        OTP 코드 (테스트용), 없으면 None
    """
    if phone not in OTP_STORAGE:
        return None
    return OTP_STORAGE[phone]["code"]


def clear_otp(phone: str) -> None:
    """
    OTP 삭제 (테스트/초기화용)

    Args:
        phone: 사용자 전화번호
    """
    if phone in OTP_STORAGE:
        del OTP_STORAGE[phone]


def cleanup_expired_otps() -> None:
    """
    만료된 OTP 정리 (메모리 누수 방지)
    주기적으로 호출되어야 함
    """
    current_time = time.time()
    expired_phones = [
        phone for phone, data in OTP_STORAGE.items()
        if current_time > data["expires_at"]
    ]
    for phone in expired_phones:
        del OTP_STORAGE[phone]

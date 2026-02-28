"""
데이터베이스 초기화 및 샘플 데이터 입력 스크립트

실행 방법:
    python -m app.init_db

또는:
    cd danngam-backend
    python app/init_db.py
"""

from sqlalchemy import text
from datetime import datetime, timedelta
from app.database import engine, SessionLocal
from app.models.base import Base
from app.models.user import User, UserRole
from app.models.equipment import Equipment, EquipmentImage, EquipmentType, EquipmentStatus
from app.models.booking import Booking, BookingStatus, Payment, PaymentMethod, PaymentStatus
from app.models.review import Review
from app.models.chat import Chat, Message
from uuid import uuid4
import json


def init_db():
    """테이블 생성 및 샘플 데이터 입력"""

    print("=" * 80)
    print("🚀 Danngam 데이터베이스 초기화 시작")
    print("=" * 80)

    # 1. 모든 테이블 생성
    print("\n1️⃣  테이블 생성 중...")
    Base.metadata.create_all(bind=engine)
    print("✅ 모든 테이블 생성 완료")

    # 2. 샘플 데이터 입력
    db = SessionLocal()

    try:
        # GIS 확장 활성화
        print("\n2️⃣  PostGIS 확장 활성화 중...")
        db.execute(text("CREATE EXTENSION IF NOT EXISTS postgis"))
        db.commit()
        print("✅ PostGIS 확장 활성화 완료")

        # 3. 샘플 사용자 데이터
        print("\n3️⃣  샘플 사용자 데이터 입력 중...")

        users = [
            User(
                phone="010-1111-1111",
                name="김공급자",
                email="supplier1@danngam.com",
                profile_image_url="https://example.com/user1.jpg",
                location=text("ST_GeomFromText('POINT(126.9780 37.5665)', 4326)"),  # 서울 시청
                rating=4.8,
                review_count=42,
                role=UserRole.SUPPLIER,
            ),
            User(
                phone="010-2222-2222",
                name="이공급자",
                email="supplier2@danngam.com",
                profile_image_url="https://example.com/user2.jpg",
                location=text("ST_GeomFromText('POINT(127.0276 37.4979)', 4326)"),  # 강남역
                rating=4.6,
                review_count=28,
                role=UserRole.SUPPLIER,
            ),
            User(
                phone="010-3333-3333",
                name="박공급자",
                email="supplier3@danngam.com",
                profile_image_url="https://example.com/user3.jpg",
                location=text("ST_GeomFromText('POINT(127.1086 37.5100)', 4326)"),  # 홍대입구
                rating=4.9,
                review_count=56,
                role=UserRole.SUPPLIER,
            ),
            User(
                phone="010-4444-4444",
                name="최차용자",
                email="renter1@danngam.com",
                profile_image_url="https://example.com/user4.jpg",
                location=text("ST_GeomFromText('POINT(126.9870 37.5200)', 4326)"),
                rating=4.7,
                review_count=18,
                role=UserRole.RENTER,
            ),
            User(
                phone="010-5555-5555",
                name="정차용자",
                email="renter2@danngam.com",
                profile_image_url="https://example.com/user5.jpg",
                location=text("ST_GeomFromText('POINT(127.0850 37.4850)', 4326)"),
                rating=4.5,
                review_count=12,
                role=UserRole.RENTER,
            ),
        ]

        db.add_all(users)
        db.flush()  # ID 생성을 위해 flush
        print(f"✅ {len(users)}명의 샘플 사용자 생성 완료")

        # 사용자 ID 저장
        supplier_ids = [users[0].id, users[1].id, users[2].id]
        renter_ids = [users[3].id, users[4].id]

        # 4. 샘플 장비 데이터
        print("\n4️⃣  샘플 장비 데이터 입력 중...")

        equipments = [
            # 공급자 1의 장비
            Equipment(
                name="지게차 - 최신형",
                category="지게차",
                type=EquipmentType.MOBILE,
                description="최신형 지게차, 안정적인 성능, 정기 정비 완료",
                price_per_hour=50000,
                location=text("ST_GeomFromText('POINT(126.9780 37.5665)', 4326)"),
                status=EquipmentStatus.AVAILABLE,
                average_rating=4.8,
                review_count=15,
                supplier_id=supplier_ids[0],
            ),
            Equipment(
                name="포크리프트 2톤",
                category="포크리프트",
                type=EquipmentType.MOBILE,
                description="2톤 용량, 프론트 휠 드라이브, 날씨에 강함",
                price_per_hour=45000,
                location=text("ST_GeomFromText('POINT(126.9850 37.5700)', 4326)"),
                status=EquipmentStatus.AVAILABLE,
                average_rating=4.6,
                review_count=12,
                supplier_id=supplier_ids[0],
            ),

            # 공급자 2의 장비
            Equipment(
                name="크레인 - 20톤",
                category="크레인",
                type=EquipmentType.FIXED,
                description="20톤 용량 크레인, 높이 조절 가능",
                price_per_hour=150000,
                location=text("ST_GeomFromText('POINT(127.0276 37.4979)', 4326)"),
                status=EquipmentStatus.AVAILABLE,
                average_rating=4.9,
                review_count=25,
                supplier_id=supplier_ids[1],
            ),
            Equipment(
                name="굴착기 - 중형",
                category="굴착기",
                type=EquipmentType.MOBILE,
                description="중형 굴착기, 버킷 포함",
                price_per_hour=80000,
                location=text("ST_GeomFromText('POINT(127.0350 37.5000)', 4326)"),
                status=EquipmentStatus.RENTED,
                average_rating=4.7,
                review_count=18,
                supplier_id=supplier_ids[1],
            ),

            # 공급자 3의 장비
            Equipment(
                name="불도저",
                category="불도저",
                type=EquipmentType.MOBILE,
                description="신형 불도저, 연료 절약형",
                price_per_hour=95000,
                location=text("ST_GeomFromText('POINT(127.1086 37.5100)', 4326)"),
                status=EquipmentStatus.AVAILABLE,
                average_rating=4.8,
                review_count=22,
                supplier_id=supplier_ids[2],
            ),
            Equipment(
                name="로더 - 휠 로더",
                category="로더",
                type=EquipmentType.MOBILE,
                description="휠 로더, 빠른 작업 속도",
                price_per_hour=65000,
                location=text("ST_GeomFromText('POINT(127.1150 37.5050)', 4326)"),
                status=EquipmentStatus.MAINTENANCE,
                average_rating=4.5,
                review_count=10,
                supplier_id=supplier_ids[2],
            ),
            Equipment(
                name="타워 크레인",
                category="크레인",
                type=EquipmentType.FIXED,
                description="타워 크레인, 건설현장용",
                price_per_hour=200000,
                location=text("ST_GeomFromText('POINT(127.1000 37.5000)', 4326)"),
                status=EquipmentStatus.AVAILABLE,
                average_rating=4.9,
                review_count=30,
                supplier_id=supplier_ids[2],
            ),
            Equipment(
                name="스키드 스티어 로더",
                category="로더",
                type=EquipmentType.MOBILE,
                description="소형 로더, 좁은 공간 작업용",
                price_per_hour=55000,
                location=text("ST_GeomFromText('POINT(126.9780 37.5750)', 4326)"),
                status=EquipmentStatus.AVAILABLE,
                average_rating=4.4,
                review_count=8,
                supplier_id=supplier_ids[0],
            ),
            Equipment(
                name="롤러 - 아스팔트",
                category="롤러",
                type=EquipmentType.MOBILE,
                description="아스팔트 포장용 롤러",
                price_per_hour=70000,
                location=text("ST_GeomFromText('POINT(127.0400 37.4900)', 4326)"),
                status=EquipmentStatus.AVAILABLE,
                average_rating=4.6,
                review_count=14,
                supplier_id=supplier_ids[1],
            ),
            Equipment(
                name="덤프 트럭",
                category="트럭",
                type=EquipmentType.MOBILE,
                description="덤프 트럭, 대량 운반용",
                price_per_hour=60000,
                location=text("ST_GeomFromText('POINT(127.1200 37.5200)', 4326)"),
                status=EquipmentStatus.AVAILABLE,
                average_rating=4.7,
                review_count=20,
                supplier_id=supplier_ids[2],
            ),
        ]

        db.add_all(equipments)
        db.flush()
        print(f"✅ {len(equipments)}개의 샘플 장비 생성 완료")

        # 5. 샘플 장비 이미지
        print("\n5️⃣  샘플 장비 이미지 데이터 입력 중...")

        images = []
        for idx, equipment in enumerate(equipments):
            for img_order in range(1, 4):
                image = EquipmentImage(
                    equipment_id=equipment.id,
                    image_url=f"https://example.com/equipment/{equipment.id}/image{img_order}.jpg",
                    display_order=img_order,
                )
                images.append(image)

        db.add_all(images)
        db.flush()
        print(f"✅ {len(images)}개의 샘플 이미지 생성 완료")

        # 6. 샘플 예약 데이터
        print("\n6️⃣  샘플 예약 데이터 입력 중...")

        now = datetime.utcnow()
        bookings = [
            Booking(
                equipment_id=equipments[0].id,
                renter_id=renter_ids[0],
                supplier_id=supplier_ids[0],
                start_time=now + timedelta(hours=1),
                end_time=now + timedelta(hours=5),
                status=BookingStatus.APPROVED,
                total_amount=216000,  # 50000 * 4 * 1.08
                platform_fee=17280,
            ),
            Booking(
                equipment_id=equipments[2].id,
                renter_id=renter_ids[1],
                supplier_id=supplier_ids[1],
                start_time=now + timedelta(days=1),
                end_time=now + timedelta(days=1, hours=8),
                status=BookingStatus.PENDING,
                total_amount=1296000,  # 150000 * 8 * 1.08
                platform_fee=103680,
            ),
            Booking(
                equipment_id=equipments[1].id,
                renter_id=renter_ids[0],
                supplier_id=supplier_ids[0],
                start_time=now + timedelta(days=2),
                end_time=now + timedelta(days=2, hours=6),
                status=BookingStatus.COMPLETED,
                total_amount=291600,  # 45000 * 6 * 1.08
                platform_fee=23328,
            ),
        ]

        db.add_all(bookings)
        db.flush()
        print(f"✅ {len(bookings)}개의 샘플 예약 생성 완료")

        # 7. 샘플 결제 데이터
        print("\n7️⃣  샘플 결제 데이터 입력 중...")

        payments = [
            Payment(
                booking_id=bookings[0].id,
                amount=216000,
                method=PaymentMethod.CREDIT_CARD,
                status=PaymentStatus.SUCCESS,
                transaction_id=f"TXN_{uuid4().hex[:16].upper()}",
            ),
            Payment(
                booking_id=bookings[1].id,
                amount=1296000,
                method=PaymentMethod.BANK_TRANSFER,
                status=PaymentStatus.PENDING,
                transaction_id=None,
            ),
            Payment(
                booking_id=bookings[2].id,
                amount=291600,
                method=PaymentMethod.MOBILE_PAYMENT,
                status=PaymentStatus.SUCCESS,
                transaction_id=f"TXN_{uuid4().hex[:16].upper()}",
            ),
        ]

        db.add_all(payments)
        db.flush()
        print(f"✅ {len(payments)}개의 샘플 결제 생성 완료")

        # 8. 샘플 리뷰 데이터
        print("\n8️⃣  샘플 리뷰 데이터 입력 중...")

        reviews = [
            Review(
                booking_id=bookings[2].id,
                equipment_id=equipments[1].id,
                reviewer_id=renter_ids[0],
                rating=5,
                comment="매우 만족합니다. 장비 상태가 좋고 공급자분도 친절해요!",
            ),
        ]

        db.add_all(reviews)
        db.flush()
        print(f"✅ {len(reviews)}개의 샘플 리뷰 생성 완료")

        # 9. 샘플 채팅 데이터
        print("\n9️⃣  샘플 채팅 데이터 입력 중...")

        chats = [
            Chat(
                sender_id=supplier_ids[0],
                receiver_id=renter_ids[0],
            ),
            Chat(
                sender_id=renter_ids[0],
                receiver_id=supplier_ids[1],
            ),
        ]

        db.add_all(chats)
        db.flush()
        print(f"✅ {len(chats)}개의 샘플 채팅 생성 완료")

        # 10. 샘플 메시지 데이터
        print("\n🔟 샘플 메시지 데이터 입력 중...")

        messages = [
            Message(
                chat_id=chats[0].id,
                sender_id=supplier_ids[0],
                content="안녕하세요. 지게차를 렌트 가능한가요?",
                image_url=None,
                is_read=True,
            ),
            Message(
                chat_id=chats[0].id,
                sender_id=renter_ids[0],
                content="네, 가능합니다. 언제 필요하신가요?",
                image_url=None,
                is_read=True,
            ),
            Message(
                chat_id=chats[0].id,
                sender_id=supplier_ids[0],
                content="내일 오후 2시부터 6시까지 부탁드립니다.",
                image_url=None,
                is_read=False,
            ),
            Message(
                chat_id=chats[1].id,
                sender_id=renter_ids[0],
                content="크레인 가격이 얼마인가요?",
                image_url=None,
                is_read=True,
            ),
            Message(
                chat_id=chats[1].id,
                sender_id=supplier_ids[1],
                content="시간당 150,000원입니다. 장시간 렌트면 할인 가능합니다.",
                image_url=None,
                is_read=True,
            ),
        ]

        db.add_all(messages)
        db.flush()
        print(f"✅ {len(messages)}개의 샘플 메시지 생성 완료")

        # 모든 데이터 커밋
        db.commit()
        print("\n" + "=" * 80)
        print("✅ 데이터베이스 초기화 완료!")
        print("=" * 80)
        print("\n📊 생성된 데이터 통계:")
        print(f"  - 사용자: {len(users)}명")
        print(f"  - 장비: {len(equipments)}개")
        print(f"  - 장비 이미지: {len(images)}개")
        print(f"  - 예약: {len(bookings)}개")
        print(f"  - 결제: {len(payments)}개")
        print(f"  - 리뷰: {len(reviews)}개")
        print(f"  - 채팅: {len(chats)}개")
        print(f"  - 메시지: {len(messages)}개")
        print("\n💡 다음 명령으로 데이터 확인 가능:")
        print("  - PgAdmin: http://localhost:5050")
        print("  - 기본 계정: admin@danngam.com / admin")
        print("=" * 80)

    except Exception as e:
        db.rollback()
        print(f"\n❌ 오류 발생: {e}")
        raise
    finally:
        db.close()


if __name__ == "__main__":
    init_db()

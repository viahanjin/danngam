# DANGAM 개발 컨벤션 가이드

**Development Convention & Code Style Guide v1.0**

---

## 📁 폴더 구조 & 파일 네이밍

### 백엔드 폴더 구조 (Node.js/TypeScript)

```
backend/
├── src/
│   ├── services/
│   │   ├── auth/
│   │   │   ├── auth.service.ts          # 비즈니스 로직
│   │   │   ├── auth.controller.ts       # HTTP 핸들러
│   │   │   ├── auth.route.ts            # 라우트 정의
│   │   │   ├── auth.dto.ts              # Request/Response DTO
│   │   │   ├── auth.validator.ts        # 입력값 검증
│   │   │   ├── auth.error.ts            # 커스텀 에러
│   │   │   └── __tests__/
│   │   │       ├── auth.service.test.ts
│   │   │       └── auth.controller.test.ts
│   │   ├── user/
│   │   ├── work-order/
│   │   ├── matching/
│   │   ├── chat/
│   │   ├── review/
│   │   ├── invoice/
│   │   ├── notification/
│   │   └── search/
│   │
│   ├── models/
│   │   ├── User.ts                      # DB 모델/타입
│   │   ├── WorkOrder.ts
│   │   ├── Equipment.ts
│   │   └── ...
│   │
│   ├── middlewares/
│   │   ├── auth.middleware.ts           # JWT 검증
│   │   ├── error.middleware.ts          # 에러 처리
│   │   ├── validation.middleware.ts     # 입력값 검증
│   │   ├── rate-limit.middleware.ts     # Rate limiting
│   │   ├── cors.middleware.ts
│   │   └── logging.middleware.ts
│   │
│   ├── utils/
│   │   ├── errors.ts                    # 커스텀 에러 클래스
│   │   ├── validators.ts                # 검증 함수
│   │   ├── transformers.ts              # 데이터 변환
│   │   ├── logger.ts                    # 로깅 유틸
│   │   ├── jwt.ts                       # JWT 생성/검증
│   │   ├── encryption.ts                # 암호화
│   │   ├── sms.ts                       # SMS 전송
│   │   └── constants.ts                 # 상수 정의
│   │
│   ├── config/
│   │   ├── database.ts                  # DB 설정
│   │   ├── redis.ts                     # Redis 설정
│   │   ├── env.ts                       # 환경변수 로드
│   │   └── app.config.ts                # 앱 설정
│   │
│   ├── lib/
│   │   ├── postgres.ts                  # PostgreSQL 클라이언트
│   │   ├── mongodb.ts                   # MongoDB 클라이언트
│   │   ├── redis.ts                     # Redis 클라이언트
│   │   ├── s3.ts                        # AWS S3 클라이언트
│   │   └── firebase.ts                  # Firebase 클라이언트
│   │
│   ├── app.ts                           # Express 앱 설정
│   ├── server.ts                        # 서버 시작
│   └── index.ts                         # 진입점
│
├── db/
│   ├── migrations/
│   │   ├── 001_initial_schema.sql
│   │   ├── 002_add_indexes.sql
│   │   └── ...
│   ├── seeds/
│   │   ├── seed.work-types.sql
│   │   ├── seed.equipment-categories.sql
│   │   └── ...
│   ├── schema.sql                       # 전체 스키마
│   └── backup/
│
├── tests/
│   ├── integration/                     # 통합 테스트
│   │   ├── auth.integration.test.ts
│   │   └── work-order.integration.test.ts
│   └── performance/                     # 성능 테스트
│       └── load.test.js
│
├── .env.example
├── .env.test
├── package.json
├── tsconfig.json
├── jest.config.js
├── .eslintrc.json
├── .prettierrc
└── README.md
```

### 모바일 폴더 구조 (Flutter/Dart)

```
mobile/
├── lib/
│   ├── main.dart                        # 앱 진입점
│   ├── app/
│   │   ├── app.dart                     # 앱 설정
│   │   ├── routes.dart                  # 라우팅
│   │   └── theme.dart                   # 테마
│   │
│   ├── core/
│   │   ├── network/
│   │   │   ├── api_client.dart          # API 클라이언트
│   │   │   ├── dio_config.dart
│   │   │   └── interceptors.dart
│   │   ├── storage/
│   │   │   ├── secure_storage.dart      # 보안 저장소
│   │   │   └── local_storage.dart
│   │   ├── services/
│   │   │   ├── location_service.dart
│   │   │   ├── permission_service.dart
│   │   │   └── notification_service.dart
│   │   ├── errors/
│   │   │   ├── app_error.dart
│   │   │   └── error_handler.dart
│   │   └── extensions/
│   │       ├── context_extension.dart
│   │       ├── string_extension.dart
│   │       └── datetime_extension.dart
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── user_model.dart
│   │   │   │   │   └── auth_response.dart
│   │   │   │   ├── datasources/
│   │   │   │   │   └── auth_remote_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── phone_login_usecase.dart
│   │   │   │       └── verify_sms_usecase.dart
│   │   │   ├── presentation/
│   │   │   │   ├── notifiers/
│   │   │   │   │   └── auth_notifier.dart
│   │   │   │   ├── screens/
│   │   │   │   │   ├── login_screen.dart
│   │   │   │   │   └── phone_verify_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── phone_input_field.dart
│   │   │   │       └── sms_code_input.dart
│   │   │   └── __tests__/
│   │   │       ├── auth_notifier_test.dart
│   │   │       └── auth_repository_test.dart
│   │   ├── work_order/
│   │   ├── matching/
│   │   ├── chat/
│   │   ├── profile/
│   │   └── home/
│   │
│   ├── models/                          # 공유 모델
│   │   └── ...
│   │
│   ├── providers/                       # Riverpod 상태관리
│   │   ├── auth_provider.dart
│   │   ├── user_provider.dart
│   │   └── ...
│   │
│   └── widgets/                         # 공유 컴포넌트
│       ├── custom_app_bar.dart
│       ├── custom_button.dart
│       └── ...
│
├── test/                                # 위젯/유닛 테스트
│   └── ...
│
├── integration_test/                    # E2E 테스트
│   └── app_test.dart
│
├── pubspec.yaml
├── .env.example
├── analysis_options.yaml
├── .gitignore
└── README.md
```

---

## 🔤 파일 네이밍 규칙

### 백엔드 (TypeScript)

| 파일 타입 | 규칙 | 예시 |
|----------|------|------|
| 서비스 | `*.service.ts` | `user.service.ts` |
| 컨트롤러 | `*.controller.ts` | `user.controller.ts` |
| 라우트 | `*.route.ts` 또는 `*.routes.ts` | `auth.route.ts` |
| DTO | `*.dto.ts` | `create-user.dto.ts`, `user-response.dto.ts` |
| 모델 | `PascalCase.ts` | `User.ts`, `WorkOrder.ts` |
| 인터페이스 | `I + PascalCase.ts` 또는 `.interface.ts` | `IUser.ts` 또는 `user.interface.ts` |
| 에러 | `*.error.ts` | `auth.error.ts` |
| 검증 | `*.validator.ts` | `user.validator.ts` |
| 미들웨어 | `*.middleware.ts` | `auth.middleware.ts` |
| 유틸 | `*.ts` (폴더 내) | `utils/encryption.ts` |
| 테스트 | `*.test.ts` 또는 `*.spec.ts` | `user.service.test.ts` |

### 모바일 (Dart)

| 파일 타입 | 규칙 | 예시 |
|----------|------|------|
| 스크린 | `*_screen.dart` | `login_screen.dart` |
| 위젯 | `*_widget.dart` 또는 `*_field.dart` | `custom_button.dart` |
| 모델 | `*_model.dart` | `user_model.dart` |
| 엔티티 | `*_entity.dart` | `user_entity.dart` |
| Repository | `*_repository.dart` 또는 `*_repository_impl.dart` | `auth_repository_impl.dart` |
| DataSource | `*_datasource.dart` | `auth_remote_datasource.dart` |
| UseCase | `*_usecase.dart` | `phone_login_usecase.dart` |
| Notifier (상태관리) | `*_notifier.dart` | `auth_notifier.dart` |
| Provider | `*_provider.dart` | `auth_provider.dart` |
| Service | `*_service.dart` | `location_service.dart` |
| 테스트 | `*_test.dart` | `auth_notifier_test.dart` |

---

## 💬 변수/함수/클래스 네이밍

### 규칙 (언어별)

#### TypeScript/JavaScript
```typescript
// 상수 (UPPER_SNAKE_CASE)
const MAX_RETRY_COUNT = 3;
const DEFAULT_PAGE_SIZE = 20;

// 변수/함수 (camelCase)
const userId = 'user_123';
const isActive = true;
const fetchUserData = () => {};

// 클래스/인터페이스 (PascalCase)
class UserService {}
interface IUserRepository {}

// Private 멤버 (_prefix)
private _db: Database;
private _password: string;

// 상수 객체
const STATUS = {
  ACTIVE: 'active',
  INACTIVE: 'inactive'
} as const;
```

#### Dart/Flutter
```dart
// 상수 (camelCase with const)
const maxRetryCount = 3;
const defaultPageSize = 20;

// 변수 (camelCase)
String userId = 'user_123';
bool isActive = true;

// 함수 (camelCase)
void fetchUserData() {}
Future<User> getUserById() async {}

// 클래스 (PascalCase)
class UserService {}
class LoginScreen extends StatelessWidget {}

// Private 멤버 (_prefix)
final String _password;
final Database _db;

// 상수 enum
enum UserStatus {
  active,
  inactive,
  suspended
}
```

### 특수 명명

```typescript
// Boolean 변수
isValid, isActive, hasError, shouldRefresh
canAccess, didMount, wasSuccessful

// 핸들러/콜백
onPressed(), handleClick(), onSuccess(), onError()
onClick(), onChange(), onSubmit()

// Getter
get userId() {}, get totalCount() {}

// Setter
set status(value) {}, set isActive(value) {}

// 단수/복수
user (단일), users (배열)
item (단일), items (배열)
```

---

## 📝 코드 스타일 & 포맷팅

### ESLint & Prettier 설정 (백엔드)

#### `.eslintrc.json`
```json
{
  "root": true,
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaVersion": 2020,
    "sourceType": "module",
    "project": "./tsconfig.json"
  },
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:@typescript-eslint/recommended-requiring-type-checking"
  ],
  "plugins": ["@typescript-eslint"],
  "rules": {
    "@typescript-eslint/explicit-function-return-types": "warn",
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/no-unused-vars": "error",
    "no-console": ["warn", { "allow": ["warn", "error"] }],
    "eqeqeq": ["error", "always"],
    "quotes": ["error", "single", { "avoidEscape": true }],
    "semi": ["error", "always"],
    "indent": ["error", 2],
    "max-line-length": ["warn", 100]
  }
}
```

#### `.prettierrc`
```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "endOfLine": "lf"
}
```

### 코드 스타일 (일반)

#### 들여쓰기
- **백엔드/모바일**: 2칸 (스페이스)
- **절대금지**: 탭 문자

#### 한 줄 길이
- **권장**: 80자 이하
- **최대**: 100자

#### 중괄호 위치
```typescript
// ✅ 올바른 방식
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}

if (isValid) {
  // 처리
} else {
  // 처리
}

// ❌ 금지
function calculateTotal(items: Item[]): number
{
  return items.reduce((sum, item) => sum + item.price, 0);
}
```

#### 공백 규칙
```typescript
// ✅ 올바름
const user: User = { name: 'John', age: 30 };
const result = sum(a, b);
if (isValid === true) {
  // ...
}

// ❌ 금지
const user:User={name:'John',age:30};
const result=sum(a,b);
if(isValid===true){
  // ...
}
```

---

## 📚 주석 & 문서화

### JSDoc/Dartdoc 규칙

#### TypeScript (JSDoc)
```typescript
/**
 * 사용자 정보 조회
 *
 * @param userId - 조회할 사용자 ID
 * @param options - 조회 옵션
 * @returns 사용자 정보 객체
 * @throws {NotFoundError} 사용자를 찾을 수 없을 때
 *
 * @example
 * const user = await userService.getUserById('user_123');
 */
async getUserById(userId: string, options?: QueryOptions): Promise<User> {
  // ...
}

/**
 * 작업 의뢰 생성
 *
 * @deprecated v2.0 부터는 createWorkOrderV2 사용
 * @param workOrderData - 의뢰 데이터
 */
async createWorkOrder(workOrderData: CreateWorkOrderDto): Promise<WorkOrder> {
  // ...
}
```

#### Dart (Dartdoc)
```dart
/// 사용자 정보 조회
///
/// [userId]로 사용자 정보를 조회합니다.
///
/// Throws [UserNotFoundException] 사용자를 찾을 수 없을 때
///
/// Example:
/// ```dart
/// final user = await userRepository.getUserById('user_123');
/// ```
Future<User> getUserById(String userId) async {
  // ...
}

/// 작업 의뢰 생성
///
/// @deprecated v2.0 부터는 [createWorkOrderV2] 사용
Future<WorkOrder> createWorkOrder(CreateWorkOrderRequest request) async {
  // ...
}
```

### 인라인 주석

```typescript
// ✅ 좋은 주석
// 중복 의뢰 방지: 30초 내 같은 필드에 대한 의뢰는 1개만 허용
if (shouldPreventDuplicate(fieldId, 30000)) {
  throw new ConflictError('이미 진행 중인 의뢰가 있습니다');
}

// ❌ 나쁜 주석
// userId 가져오기
const userId = req.user.id;

// ❌ 중복 주석
// userId 설정
userId = getUserId(); // userId를 구한다

// ❌ 오래된 주석
// TODO: v1.5에서 제거하기
// 이것은 2023년 이후에 필요 없음
```

### 함수/파일 헤더

```typescript
/**
 * 사용자 인증 서비스
 *
 * 전화번호 기반 SMS 인증, JWT 토큰 발급/갱신을 담당합니다.
 *
 * @module AuthService
 */

/**
 * 농작업 의뢰 검증 로직
 *
 * - 날짜 유효성 (과거 날짜 방지)
 * - 규모 유효성 (0 초과)
 * - 우선순위 값 검증
 */
```

---

## 🔄 Import 규칙

### 순서 및 그룹화 (백엔드)

```typescript
// 1. 표준 라이브러리
import path from 'path';
import fs from 'fs';

// 2. 외부 라이브러리
import express, { Request, Response } from 'express';
import { injectable } from 'tsyringe';

// 3. 타입/인터페이스
import type { IUserRepository } from './user.repository.interface';

// 4. 로컬 임포트 (src/)
import { UserService } from '../services/user.service';
import { validateEmail } from '../utils/validators';

// 5. 환경/설정
import { config } from '../config';

// 6. 절대금지
// import { foo } from '../../../../../../services/foo'; ❌
// import { bar } from '../../../utils/bar'; ❌ (3단계 이상)
```

### 순서 및 그룹화 (모바일)

```dart
// 1. Dart 표준 라이브러리
import 'dart:async';
import 'dart:convert';

// 2. Flutter 패키지
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

// 3. 외부 패키지
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

// 4. 로컬 임포트 (package:dangam/)
import 'package:dangam/core/network/api_client.dart';
import 'package:dangam/features/auth/domain/repositories/auth_repository.dart';

// 5. 상대 경로는 금지 ❌
// import '../../../services/user_service.dart';
```

### Wildcard Import 금지

```typescript
// ❌ 금지
import * as userService from '../services/user.service';

// ✅ 올바름
import { getUserById, updateUser } from '../services/user.service';
```

---

## 🔒 타입 정의 규칙 (TypeScript)

### DTO (Request/Response)

```typescript
// src/services/user/create-user.dto.ts
export class CreateUserDto {
  @IsPhoneNumber('KR')
  @IsNotEmpty()
  phone: string;

  @IsString()
  @MinLength(2)
  @MaxLength(50)
  @IsNotEmpty()
  name: string;

  @IsEnum(UserRole)
  @IsNotEmpty()
  role: UserRole;

  @IsOptional()
  @IsUrl()
  profileImage?: string;
}

// src/services/user/user-response.dto.ts
export class UserResponseDto {
  id: string;
  phone: string; // 마스킹됨
  name: string;
  role: UserRole;
  profileImage?: string;
  rating: number;
  createdAt: Date;
}
```

### 인터페이스 vs 타입

```typescript
// ✅ 데이터 구조: 인터페이스 (확장 가능)
interface IUser {
  id: string;
  phone: string;
  name: string;
}

// ✅ 타입 별칭: 타입 (단순)
type UserRole = 'farmer' | 'partner';
type UserId = string & { readonly __brand: 'UserId' };

// ❌ 금지: 인터페이스로 단순 타입 정의
// interface UserRole extends 'farmer' | 'partner' {}
```

### Enum 사용

```typescript
// ✅ 올바름
enum UserStatus {
  ACTIVE = 'active',
  SUSPENDED = 'suspended',
  DELETED = 'deleted'
}

// 또는 const enum (컴파일 시 제거됨)
const enum WorkOrderStatus {
  CREATED = 'created',
  MATCHING = 'matching',
  MATCHED = 'matched',
  IN_PROGRESS = 'in_progress',
  COMPLETED = 'completed'
}
```

---

## 🧪 테스트 작성 규칙

### 파일 구조
```
services/auth/
├── auth.service.ts
├── auth.controller.ts
└── __tests__/
    ├── auth.service.test.ts
    └── auth.controller.test.ts
```

### 테스트 작성 (백엔드)

```typescript
// src/services/auth/__tests__/auth.service.test.ts
describe('AuthService', () => {
  let authService: AuthService;
  let smsClient: jest.Mocked<ISmsClient>;

  beforeEach(() => {
    smsClient = {
      send: jest.fn(),
    } as any;
    authService = new AuthService(smsClient);
  });

  describe('requestSmsCode', () => {
    it('should send SMS code for valid phone number', async () => {
      // Arrange
      const phone = '01012345678';
      const expectedCode = '123456';
      smsClient.send.mockResolvedValue({ success: true });

      // Act
      const result = await authService.requestSmsCode(phone);

      // Assert
      expect(smsClient.send).toHaveBeenCalledWith(
        expect.objectContaining({ phone })
      );
      expect(result).toHaveProperty('requestId');
    });

    it('should throw ValidationError for invalid phone', async () => {
      // Arrange
      const phone = 'invalid';

      // Act & Assert
      await expect(authService.requestSmsCode(phone))
        .rejects
        .toThrow(ValidationError);
    });
  });
});
```

### 테스트 작성 (모바일)

```dart
// test/features/auth/domain/repositories/auth_repository_test.dart
void main() {
  group('AuthRepository', () => {
    late AuthRepository authRepository;
    late MockAuthRemoteDataSource mockRemoteDataSource;

    setUp(() {
      mockRemoteDataSource = MockAuthRemoteDataSource();
      authRepository = AuthRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
      );
    });

    group('requestSmsCode', () => {
      test('should return RequestId on successful SMS request', () async {
        // Arrange
        const phone = '01012345678';
        when(() => mockRemoteDataSource.requestSmsCode(phone))
            .thenAnswer((_) async => SmsRequestModel(
              requestId: 'req_123',
              expiresIn: 600,
            ));

        // Act
        final result = await authRepository.requestSmsCode(phone);

        // Assert
        expect(result.isRight(), true);
        expect(result.fold((l) => null, (r) => r.requestId), 'req_123');
      });

      test('should return ValidationException for invalid phone', () async {
        // Arrange
        const phone = 'invalid';

        // Act
        final result = await authRepository.requestSmsCode(phone);

        // Assert
        expect(result.isLeft(), true);
      });
    });
  });
}
```

### 테스트 명명

```typescript
// ✅ 좋은 명명
it('should return user when phone exists', () => {});
it('should throw ValidationError when phone is invalid', () => {});
it('should update user rating when review is added', () => {});

// ❌ 나쁜 명명
it('test user', () => {});
it('works', () => {});
it('check if', () => {});
```

---

## 🚫 금지 사항

### 절대 금지

| 항목 | 이유 | 대안 |
|------|------|------|
| `var` | 스코프 혼동 | `const` 또는 `let` |
| `any` | 타입 안정성 상실 | 정확한 타입 정의 |
| `console.log` | 프로덕션 로그 혼재 | `logger.debug()` |
| 비동기 무시 | 에러 감지 불가 | `await` 또는 `.catch()` |
| 하드코딩 상수 | 유지보수 어려움 | 환경변수 또는 `constants.ts` |
| 깊은 상대 경로 | 경로 복잡도 | 절대 경로 import |

### 코드 예시

```typescript
// ❌ 금지
var userId = '123';
const data: any = response.data;
console.log('User data:', user);
function asyncTask() { fetchData(); } // await 없음
const API_KEY = 'sk-1234567890';
import { foo } from '../../../../../utils/foo';

// ✅ 올바름
const userId = '123';
const data: UserResponse = response.data;
logger.debug('User data:', user);
async function asyncTask() { await fetchData(); }
const API_KEY = process.env.API_KEY || '';
import { foo } from '@/utils/foo';
```

---

## ✨ 에러 처리 패턴

### 서비스 레이어

```typescript
// src/services/user/user.service.ts
export class UserService {
  async getUserById(userId: string): Promise<User> {
    if (!userId) {
      throw new ValidationError('User ID is required');
    }

    const user = await this.userRepository.findById(userId);
    if (!user) {
      throw new NotFoundError('User');
    }

    return user;
  }
}
```

### 컨트롤러 레이어

```typescript
// src/services/user/user.controller.ts
export class UserController {
  async getUserById(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.params.userId;
      const user = await this.userService.getUserById(userId);

      res.json({
        success: true,
        data: user,
      });
    } catch (error) {
      next(error); // 글로벌 에러 핸들러로 전달
    }
  }
}
```

---

## 🔐 보안 패턴

### SQL Injection 방지

```typescript
// ❌ 금지
const query = `SELECT * FROM users WHERE phone = '${phone}'`;
db.query(query);

// ✅ 올바름 (Parameterized Query)
const query = 'SELECT * FROM users WHERE phone = $1';
db.query(query, [phone]);
```

### 민감 정보 보호

```typescript
// ✅ 응답 시 민감 정보 마스킹
const userResponse = {
  id: user.id,
  name: user.name,
  phone: maskPhoneNumber(user.phone), // 010****5678
  // password는 절대 포함 금지
};

// ✅ 은행계좌 암호화
const encryptedAccount = encrypt(bankAccount);
```

---

## 📦 패키지/의존성 관리

### 의존성 설치 원칙

```bash
# ✅ 프로덕션 의존성
npm install express typescript

# ✅ 개발 의존성만
npm install --save-dev @types/express jest ts-jest

# ❌ 금지: 최신 버전 자동 설치
npm install  # 불필요한 버전 업그레이드 방지
```

### package.json 버전 관리

```json
{
  "dependencies": {
    "express": "^4.18.2",  // Minor, Patch 자동 업데이트
    "typescript": "~5.0.0"  // Patch만 자동 업데이트
  },
  "devDependencies": {
    "@types/node": "^20.0.0"
  }
}
```

---

## 🔍 코드 리뷰 체크리스트

PR 생성 전 다음을 확인하세요:

### 코드 품질
- [ ] ESLint/Dart 분석 통과 (0 errors)
- [ ] 모든 변수 사용됨 (미사용 변수 없음)
- [ ] 타입 정의 완료 (`any` 없음)
- [ ] 함수는 한 가지만 수행 (단일 책임)
- [ ] 순환 의존성 없음

### 테스트
- [ ] 단위 테스트 작성 (커버리지 80%+)
- [ ] 모든 테스트 통과 (`npm run test` / `flutter test`)
- [ ] Edge case 테스트 포함
- [ ] Mock 정상 작동

### 문서화
- [ ] JSDoc/Dartdoc 작성 (모든 public 함수)
- [ ] README 업데이트 (필요시)
- [ ] 환경변수 `.env.example` 업데이트

### 보안
- [ ] 민감 정보 하드코딩 없음
- [ ] SQL 인젝션 방지 (Parameterized Query)
- [ ] XSS 방지 (입력 검증)
- [ ] 에러 메시지 안전함 (정보 유출 없음)

### 성능
- [ ] 불필요한 데이터베이스 쿼리 없음
- [ ] N+1 쿼리 문제 해결
- [ ] 정규식 성능 최적화
- [ ] 대용량 데이터 처리 확인

---

## 📊 커밋 메시지 규칙

### 포맷 (Conventional Commits)

```
<type>(<scope>): <subject>
<blank line>
<body>
<blank line>
<footer>
```

### Type 정의

| Type | 설명 | 예시 |
|------|------|------|
| `feat` | 새 기능 | `feat(auth): add phone login` |
| `fix` | 버그 수정 | `fix(chat): prevent message duplication` |
| `docs` | 문서 변경 | `docs: update API specification` |
| `style` | 코드 스타일 (기능 무관) | `style(auth): format code` |
| `refactor` | 코드 리팩토링 | `refactor(user): extract validation logic` |
| `perf` | 성능 개선 | `perf(search): optimize query` |
| `test` | 테스트 추가 | `test(auth): add sms verification tests` |
| `ci` | CI/CD 설정 | `ci: add github actions workflow` |
| `chore` | 빌드, 패키지 관리 | `chore: update dependencies` |

### 예시

```
feat(work-order): add matching algorithm

- Implement rule-based matching with distance, rating, and response time
- Add match score calculation (0-100)
- Add 30-minute expiration for matching requests
- Include Riverpod state management for real-time updates

Closes #456
```

---

## 🎯 개발자 체크리스트 (커밋 전)

```bash
# 1. 로컬 테스트
npm run lint
npm run test
npm run test:coverage  # 80% 이상 확인

# 2. 빌드 확인
npm run build

# 3. Git 상태 확인
git status
git diff

# 4. Commit 생성
git commit -m "feat(module): description"

# 5. Push
git push origin feature/branch-name
```

---

**최종 수정일**: 2026-02-28
**버전**: 1.0

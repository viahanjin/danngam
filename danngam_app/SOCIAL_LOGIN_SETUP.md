# 소셜 로그인 설정 가이드

## 🔐 Kakao 로그인 설정

### 1. Kakao Developers에서 앱 생성
1. https://developers.kakao.com/ 접속
2. 앱 생성 (앱 키 발급)
3. 네이티브 앱 키, JavaScript 앱 키 복사

### 2. iOS 설정 (`ios/Runner/Info.plist`)

```xml
<dict>
    ...
    <!-- Kakao -->
    <key>KAKAO_APP_KEY</key>
    <string>YOUR_KAKAO_NATIVE_APP_KEY</string>

    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>kakaoYOUR_KAKAO_APP_ID</string>
            </array>
        </dict>
    </array>

    <!-- Google -->
    <key>GIDClientID</key>
    <string>YOUR_GOOGLE_CLIENT_ID</string>

    ...
</dict>
```

### 3. Android 설정 (`android/app/src/main/AndroidManifest.xml`)

```xml
<manifest>
    ...
    <uses-permission android:name="android.permission.INTERNET" />

    <application>
        ...
        <!-- Kakao -->
        <activity
            android:name="com.kakao.sdk.auth.AuthCodeHandlerActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data
                    android:scheme="kakao"
                    android:host="oauth" />
            </intent-filter>
        </activity>

        <!-- Google (Auto-configured by google_sign_in) -->

    </application>
</manifest>
```

### 4. Android 앱 서명 (google_sign_in 필요)
```bash
# SHA-1 인증서 지문 생성
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

---

## 🔵 Google 로그인 설정

### 1. Google Cloud Console에서 프로젝트 생성
1. https://console.cloud.google.com/ 접속
2. 프로젝트 생성
3. OAuth 2.0 클라이언트 ID 생성 (Android, iOS)

### 2. iOS 설정
- Google Cloud에서 iOS용 OAuth 클라이언트 ID 생성
- `ios/Runner/Info.plist`에 GIDClientID 추가 (위 참조)

### 3. Android 설정
- Google Cloud에서 Android용 OAuth 클라이언트 ID 생성
- 앱 SHA-1 지문 필요

---

## 🍎 Apple 로그인 설정

### 1. Apple Developer에서 설정
1. https://developer.apple.com/ 접속
2. Certificates, Identifiers & Profiles → Identifiers
3. App ID 생성 시 "Sign In with Apple" 활성화

### 2. iOS 설정 (`ios/Runner/Info.plist`)
```xml
<dict>
    ...
    <key>NSLocalNetworkUsageDescription</key>
    <string>This app uses local network for sign in</string>
    ...
</dict>
```

### 3. Xcode 설정
- Xcode 열기: `open ios/Runner.xcworkspace`
- Signing & Capabilities → "+ Capability"
- "Sign in with Apple" 추가

---

## 📱 Flutter 코드 수정

### `lib/main.dart`에서 Kakao 앱 키 설정

```dart
void main() {
  // Replace with actual Kakao app keys
  KakaoSdk.init(
    nativeAppKey: 'YOUR_KAKAO_NATIVE_APP_KEY',
    javaScriptAppKey: 'YOUR_KAKAO_JS_APP_KEY',
  );

  runApp(const MyApp());
}
```

---

## ✅ 테스트 체크리스트

- [ ] Kakao 로그인 작동
- [ ] Google 로그인 작동
- [ ] Apple 로그인 작동 (iOS만)
- [ ] 로그인 후 MainScreen 네비게이션
- [ ] 프로필 정보 저장
- [ ] 로그아웃 기능

---

## 🚀 배포 시 필수사항

1. 실제 앱 키 적용
2. App Store, Google Play에 앱 등록
3. 각 소셜 플랫폼에 앱 정보 승인 요청
4. 프라이버시 정책 추가
5. 백엔드 API 구축 (사용자 정보 동기화)

---

## 📚 참고 링크

- Kakao SDK: https://developers.kakao.com/docs/latest/ko/sdk/sdk-android
- Google Sign-In: https://pub.dev/packages/google_sign_in
- Sign in with Apple: https://pub.dev/packages/sign_in_with_apple

# OutfitLICA

> AI 기반 옷장 관리 & 날씨 맞춤 코디 추천 앱

---

## 앱 컨셉

**OutfitLICA**는 내 옷장을 디지털로 관리하고, 오늘의 날씨에 맞는 코디를 AI가 추천해주는 패션 앱입니다.

| 핵심 가치 | 설명 |
|-----------|------|
| **스마트 옷장** | 카메라로 촬영하면 배경이 자동 제거되어 깔끔하게 저장 |
| **자유로운 코디** | 카테고리별 아이템을 캔버스 위에 올려 직접 조합 |
| **날씨 기반 추천** | 현재 위치의 날씨를 분석해 적합한 코디를 자동 추천 |

---

## 주요 기능

### 1. 내 옷장 (Wardrobe)
- 카메라 또는 갤러리에서 옷 사진 추가
- Remove.bg API로 배경 자동 제거
- 카테고리별 분류: 상의, 하의, 아우터, 신발, 액세서리
- 등록된 아이템 조회 및 삭제

### 2. 코디 조합 (Outfit Builder)
- 카테고리별 아이템 선택 → 캔버스 합성
- 드래그로 아이템 위치 조정
- 완성된 코디 저장

### 3. 오늘의 코디 추천 (Recommendation)
- GPS 위치 기반 현재 날씨 조회 (OpenWeatherMap API)
- 기온 / 날씨 상태에 맞는 카테고리 자동 필터링
- 내 옷장 아이템 중 어울리는 조합 추천

---

## 기술 스택

| 구분 | 기술 |
|------|------|
| 프레임워크 | Flutter 3.19+ (Android / iOS 크로스플랫폼) |
| 상태관리 | Riverpod 2 + Riverpod Generator |
| 라우팅 | go_router |
| 로컬 저장소 | shared_preferences + path_provider |
| 이미지 처리 | image_picker, camera, image |
| AI / API | Remove.bg (배경 제거), OpenWeatherMap (날씨) |
| 위치 | geolocator |

---

## 프로젝트 구조

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/       # 앱 상수
│   ├── database/        # 로컬 DB 헬퍼
│   ├── router/          # go_router 설정
│   ├── services/        # 날씨 API, 배경 제거 서비스
│   ├── theme/           # 앱 테마
│   └── utils/           # 이미지 유틸
├── features/
│   ├── wardrobe/        # 내 옷장 기능
│   ├── outfit_builder/  # 코디 조합 기능
│   ├── recommendation/  # 날씨 기반 추천 기능
│   ├── camera/          # 카메라 화면
│   ├── outfit/          # 코디 결과 모델
│   └── home/            # 홈 (BottomNavigation)
└── shared/
    └── widgets/         # 공통 UI 컴포넌트
```

---

## 개발 환경 설정

### 사전 요구사항
- Flutter SDK 3.19.0 이상
- Dart SDK 3.3.0 이상
- Android Studio / Xcode (에뮬레이터 사용 시)

### 설치

```bash
# 1. 저장소 클론
git clone <repo-url>
cd OutfitLICA-App

# 2. 작업 브랜치로 전환
git checkout claude/setup-cross-platform-mobile-WbYzJ

# 3. 환경변수 파일 생성
cp .env.example .env
# .env 파일에 API 키 입력 (아래 참고)

# 4. 패키지 설치
flutter pub get
```

### 환경변수 (.env)

```
REMOVE_BG_API_KEY=여기에_RemoveBg_API키_입력
OPENWEATHER_API_KEY=여기에_OpenWeather_API키_입력
```

> API 키가 없어도 앱은 실행됩니다.
> - 배경 제거 없이 원본 이미지 그대로 저장됩니다.
> - 날씨는 서울 / 20°C 기본값으로 동작합니다.

---

## 테스트 방법

### 기기 확인 및 실행

```bash
# 연결된 기기/에뮬레이터 목록 확인
flutter devices

# 앱 실행 (기기 자동 선택)
flutter run

# 특정 플랫폼 지정 실행
flutter run -d android
flutter run -d ios        # macOS 전용
flutter run -d chrome     # 웹 브라우저 (빠른 UI 확인용)
```

### 코드 분석 및 자동 테스트

```bash
# 정적 분석 (코드 오류 검사)
flutter analyze

# 단위 테스트 실행
flutter test

# 빌드 테스트 (APK)
flutter build apk --debug
```

### 기능별 수동 테스트 시나리오

| 순서 | 탭 | 테스트 항목 | 예상 결과 |
|------|----|-------------|-----------|
| 1 | 앱 실행 | BottomNavigation 확인 | 3개 탭 표시 |
| 2 | 내 옷장 | `+` 버튼 → 카메라/갤러리 | 이미지 선택 화면 |
| 3 | 내 옷장 | 카테고리 선택 → 저장 | 옷장 목록에 아이템 추가 |
| 4 | 내 옷장 | 배경 제거 (.env API 키 필요) | 배경 없는 의류 이미지 저장 |
| 5 | 코디 조합 | 카테고리별 아이템 선택 | 캔버스에 아이템 합성 |
| 6 | 코디 조합 | 드래그로 위치 조정 → 저장 | 코디 저장 완료 |
| 7 | 오늘의 코디 | 위치 권한 허용 | 현재 날씨 정보 표시 |
| 8 | 오늘의 코디 | 추천 코디 확인 | 날씨 기반 코디 목록 표시 |

---

## API 키 발급

| 서비스 | 용도 | 발급 링크 |
|--------|------|-----------|
| Remove.bg | 옷 사진 배경 자동 제거 | https://www.remove.bg/api |
| OpenWeatherMap | 현재 위치 날씨 조회 | https://openweathermap.org/api |

두 서비스 모두 **무료 플랜** 제공 (Remove.bg 월 50회, OpenWeather 1분당 60회).

---
description: 코드 정리 및 리팩토링 — dead code 제거, import 정리, 구조 최적화
argument-hint: "[경로] [--type code|imports|files|all] [--safe|--aggressive]"
---

# Refactoring Code

코드베이스를 체계적으로 정리합니다. 기능 보존을 최우선으로 하며, 안전하지 않은 변경은 반드시 사용자에게 확인합니다.

## 인자 파싱

**$ARGUMENTS에서 추출:**
- 경로: 대상 디렉토리/파일 (기본값: 프로젝트 루트)
- `--type`: `code` | `imports` | `files` | `all` (기본값: `all`)
- `--safe`: 보수적 정리 — 확실한 것만 (기본값)
- `--aggressive`: 적극적 정리 — 간접 참조도 분석

**인자 없으면:**
```
❓ 정리 대상을 지정하세요.

사용법:
  /refactoring-code src/
  /refactoring-code src/components/ --type imports
  /refactoring-code --type code --aggressive
```
→ 중단

## Step 1: 현황 분석

대상 경로의 파일 구조와 기술 스택을 파악합니다.

```bash
# 파일 수 및 언어 분포
find {경로} -type f -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" | wc -l

# 프레임워크 감지
ls package.json tsconfig.json next.config.* vite.config.* 2>/dev/null
```

분석 결과를 요약합니다:
```
📊 분석 대상
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
경로: {경로}
파일 수: {N}개
스택: {감지된 프레임워크}
정리 타입: {type}
모드: {safe|aggressive}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Step 2: 정리 대상 탐지

`--type`에 따라 해당 단계만 실행합니다. `all`이면 전부 실행.

### 2a. Dead Code 탐지 (`--type code` 또는 `all`)

1. **미사용 export 탐지**: export된 심볼이 다른 파일에서 import되지 않는 경우
2. **미사용 변수/함수**: 선언 후 참조가 없는 경우
3. **빈 블록**: 빈 if/else/try/catch 블록
4. **주석 처리된 코드**: 코드 블록이 주석으로 감싸진 경우
5. **중복 코드**: 3줄 이상 동일한 패턴이 반복되는 경우

```bash
# 미사용 export 예시
grep -rn "export " {경로} --include="*.ts" --include="*.tsx"
# 각 export에 대해 다른 파일에서 import 여부 확인
```

### 2b. Import 정리 (`--type imports` 또는 `all`)

1. **미사용 import**: import 했지만 파일 내에서 사용하지 않는 것
2. **중복 import**: 같은 모듈에서 여러 번 import
3. **import 정렬**: 외부 패키지 → 내부 모듈 → 상대 경로 순서

### 2c. 파일/구조 정리 (`--type files` 또는 `all`)

1. **빈 파일**: 내용이 없거나 export만 있는 파일
2. **미사용 파일**: 어디서도 import되지 않는 파일
3. **barrel 파일 정리**: index.ts에서 re-export하지만 실제 사용되지 않는 항목

## Step 3: 분류 및 리포트

탐지된 항목을 안전도에 따라 분류합니다:

### 자동 수정 (확인 없이 적용)
- 미사용 import 제거
- 참조 0건인 dead code
- 빈 블록 제거
- import 정렬

### 사용자 확인 필요
- 간접 참조 가능성이 있는 코드
- 외부에서 사용될 수 있는 export
- 테스트 유틸리티/픽스처
- 설정 값

리포트를 표시합니다:

```
🔍 정리 대상 발견
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ 자동 수정 (N개):
  - 미사용 import 제거: X개
  - dead code 제거: Y개
  - 빈 블록 제거: Z개

⚠️ 확인 필요 (M개):
  - {파일:라인} — {설명} — {이유}
  - {파일:라인} — {설명} — {이유}

예상 제거 라인: ~{N}줄
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

`AskUserQuestion`으로 진행 여부 확인:
1. **전체 적용** — 자동 수정 + 확인 항목 모두 적용
2. **안전한 것만** — 자동 수정만 적용
3. **하나씩 검토** — 각 항목을 개별 확인
4. **취소**

## Step 4: 수정 적용

승인된 항목을 파일별로 적용합니다.

**규칙:**
- 한 파일씩 순서대로 수정
- 수정 전 파일 Read → 수정 후 Edit (Read 없이 Edit 금지)
- 기능 변경 금지 — 동작이 바뀌는 수정은 하지 않음
- 수정할 때 주변 코드 건드리지 않음

진행 상황 표시:
```
[1/N] src/utils/helpers.ts — 미사용 import 3개 제거 ✅
[2/N] src/components/Modal.tsx — dead function 1개 제거 ✅
...
```

## Step 5: 검증

수정 완료 후 빌드/타입 체크로 기능 보존을 확인합니다:

```bash
# TypeScript 프로젝트
tsc --noEmit 2>&1 | head -30

# package.json 스크립트 확인
cat package.json | grep -A5 '"scripts"'
```

**빌드 성공 시:**
```
✅ 검증 통과 — 타입 에러 없음
```

**빌드 실패 시:**
```
❌ 타입 에러 발견 — 수정 사항을 되돌리고 문제를 분석합니다.
```
→ 실패한 수정을 되돌리고, 원인을 분석하여 재시도 또는 사용자에게 보고

## Step 6: 완료 리포트

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Refactoring Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 수정된 파일: {N}개
🗑️ 제거된 라인: {N}줄
📦 정리된 import: {N}개
🧹 제거된 dead code: {N}개

검증: {tsc --noEmit 결과}

변경 파일 목록:
  - {파일}: {변경 내용 요약}
  - {파일}: {변경 내용 요약}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 주의사항

1. **public API는 건드리지 않음** — 라이브러리/패키지의 외부 export는 면제
2. **테스트 파일은 보수적으로** — 테스트에서만 쓰이는 유틸은 확인 후 처리
3. **설정 파일 면제** — `.env`, `config.*`, `*.config.*`는 자동 수정 대상에서 제외
4. **프레임워크 규칙 존중** — Next.js의 `page.tsx`, `layout.tsx` 등 프레임워크가 요구하는 파일은 면제

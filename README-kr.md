# oh-my-stalab-harness

### Claude Code를 위한 개발 하니스 (Development Harness)

> **한 줄 요약**: Claude Code에 전문가 에이전트 10명, 자동화 커맨드 14개, 보안 훅 12개,
> 생산성 스킬 13개, 개발 규칙 6개를 한 번에 설치합니다.

oh-my-stalab-harness는 [Claude Code](https://claude.ai/claude-code) 위에서 동작하는 **개발 도구 모음**입니다.
코드 설계, TDD, 코드 리뷰, 보안 감사, 빌드 수정까지 — AI 에이전트가 각 역할을 전담하여
개발 생산성을 극대화합니다.

---

## 목차

- [누구를 위한 도구인가요?](#누구를-위한-도구인가요)
- [설치 및 시작하기](#설치-및-시작하기)
- [첫 번째 사용: 3분 체험](#첫-번째-사용-3분-체험)
- [핵심 개념 이해하기](#핵심-개념-이해하기)
- [10개 에이전트 완전 가이드](#10개-에이전트-완전-가이드)
- [14개 커맨드 완전 가이드](#14개-커맨드-완전-가이드)
- [13개 스킬 완전 가이드](#13개-스킬-완전-가이드)
- [12개 훅 (자동 보안/품질)](#12개-훅-자동-보안품질)
- [6개 개발 규칙](#6개-개발-규칙)
- [MCP 서버 통합](#mcp-서버-통합)
- [CC Chips 상태줄](#cc-chips-상태줄)
- [추천 워크플로우](#추천-워크플로우)
- [문제가 생겼을 때](#문제가-생겼을-때)
- [충돌 방지 메커니즘](#충돌-방지-메커니즘)
- [프로젝트 구조](#프로젝트-구조)
- [자주 묻는 질문](#자주-묻는-질문)

---

## 누구를 위한 도구인가요?

| 사용자 유형 | oh-my-stalab-harness가 도와주는 방법 |
|------------|---------------------------------------|
| **코딩 초보자** | `/feature-dev`로 5단계 가이드 기능 개발. 무엇부터 해야 할지 몰라도 OK |
| **주니어 개발자** | TDD 에이전트가 테스트 작성법을 알려주고, 코드 리뷰어가 실시간 피드백 |
| **시니어 개발자** | `/plan`으로 아키텍처 설계 자동화, `/commit-push-pr`로 반복 작업 제거 |
| **팀 리더** | 보안 훅이 위험 명령 차단, 시크릿 유출 방지. PR 리뷰 자동화 |

---

## 설치 및 시작하기

### 필요한 것

1. **Claude Code** 설치 완료 (터미널에서 `claude` 명령이 동작하면 OK)
2. **Node.js** v18+ (훅 실행에 필요)
3. **Git** 설치 완료

### macOS / Linux

```bash
git clone https://github.com/ThingsLikeClaude/oh-my-stalab-harness.git
cd oh-my-stalab-harness
bash install.sh
```

### Windows (PowerShell)

```powershell
git clone https://github.com/ThingsLikeClaude/oh-my-stalab-harness.git
cd oh-my-stalab-harness
.\install.ps1
```

설치 스크립트는 `~/.claude/`에 파일을 설치합니다.
- **macOS/Linux**: 심볼릭 링크 생성 → `git pull`로 즉시 업데이트 반영
- **Windows**: 파일 복사 → 업데이트 시 `install.ps1` 재실행 필요

### 업데이트

```bash
cd oh-my-stalab-harness
git pull
# macOS/Linux: 심링크가 자동 반영
# Windows: .\install.ps1 재실행
```

---

## 첫 번째 사용: 3분 체험

### 가장 간단한 시작 — 기능 개발

프로젝트 폴더에서 Claude Code를 열고:

```
/feature-dev
```

5단계 가이드가 시작됩니다:
1. **탐색**: 코드베이스 구조 파악
2. **설계**: 아키텍처 설계 (code-architect 에이전트)
3. **테스트**: TDD로 테스트 먼저 작성 (tdd-guide 에이전트)
4. **구현**: 테스트 통과하는 코드 작성
5. **리뷰**: 코드 품질 검사 (code-reviewer 에이전트)

### TDD 체험

```
/tdd
```

tdd-guide 에이전트가 RED → GREEN → REFACTOR 사이클을 안내합니다.
테스트를 먼저 작성하고, 통과시키고, 리팩토링하는 과정을 밟습니다.

### 빌드 에러 수정

```
/build-fix
```

build-error-resolver 에이전트가 빌드 에러를 자동 진단하고 수정합니다.

---

## 핵심 개념 이해하기

### 에이전트 (Agent)

**에이전트**는 특정 역할을 가진 AI 전문가입니다.

일상적인 비유: 건설 현장에서 **건축가**(code-architect)가 설계하고, **감리관**(code-reviewer)이
품질을 검사하고, **보안 전문가**(security-reviewer)가 안전을 확인합니다. 각자 전문 분야가
다르고, 필요할 때 불려옵니다.

에이전트는 `agents/` 폴더의 `.md` 파일에 정의됩니다. 10개 에이전트가 있습니다.

### 커맨드 (Command)

**커맨드**는 `/`로 시작하는 명령어입니다. 에이전트를 특정 워크플로우로 조합하여 실행합니다.

```
/plan       ← 커맨드 (code-architect 에이전트를 계획 모드로 호출)
/tdd        ← 커맨드 (tdd-guide 에이전트를 TDD 모드로 호출)
/review-pr  ← 커맨드 (code-reviewer 에이전트를 PR 리뷰 모드로 호출)
```

커맨드는 `commands/` 폴더의 `.md` 파일에 정의됩니다. 14개 커맨드가 있습니다.

### 훅 (Hook)

**훅**은 특정 이벤트에 자동으로 실행되는 스크립트입니다.

일상적인 비유: 가게 출입문에 달린 **경보기**입니다. 누가 들어오면 (PreToolUse) 신분을
확인하고, 나갈 때 (PostToolUse) 물건 검사를 하고, 영업 종료 시 (Stop) 금고를 잠급니다.

훅은 `hooks/` 폴더의 `.sh` 파일에 정의됩니다. 12개 훅이 있습니다.

### 스킬 (Skill)

**스킬**은 특정 작업을 수행하는 도구입니다. 에이전트보다 더 큰 범위의 기능을 제공합니다.

```
deep-interview    ← 1:1 인터뷰로 요구사항 발굴
stalab-ppt-make   ← HTML 프레젠테이션 자동 생성
visualize         ← 아이디어를 단일 HTML 시각화로 변환
```

스킬은 `skills/` 폴더에 각각 디렉토리로 존재합니다. 13개 스킬이 있습니다.

### 규칙 (Rule)

**규칙**은 Claude Code가 자동으로 따르는 개발 규범입니다. 특정 파일을 수정할 때 해당
규칙이 자동 로드됩니다.

```
git-workflow-v2.md  ← .git 파일 수정 시 자동 로드
security.md         ← .ts/.js 파일 수정 시 자동 로드
testing.md          ← 테스트 파일 수정 시 자동 로드
```

규칙은 `rules/` 폴더의 `.md` 파일에 정의됩니다. 6개 규칙이 있습니다.

---

## 10개 에이전트 완전 가이드

### 설계/리뷰 그룹 (고수준 판단)

#### code-architect — 수석 아키텍트

기존 코드 패턴을 분석하여 새 기능의 아키텍처를 설계합니다.

**역할**: 코드베이스를 탐색 → 패턴 파악 → 아키텍처 문서 생성
**사용 커맨드**: `/plan`, `/feature-dev`
**비유**: 건축가. 기존 건물 스타일에 맞춰 새 증축 설계를 그리는 사람.

#### code-reviewer — 코드 리뷰어

코드 품질을 3단계(CRITICAL/HIGH/MEDIUM)로 평가합니다.

**역할**: 변경된 파일 읽기 → 이슈 분류 → 수정 제안
**사용 커맨드**: `/review-pr`
**비유**: 감리관. 시공 품질을 검사하고 합격/불합격 판정하는 사람.

#### tdd-guide — TDD 가이드 (Opus 모델)

RED → GREEN → REFACTOR 사이클을 강제합니다.

**역할**: 테스트 먼저 작성 → 통과 코드 구현 → 리팩토링 → 반복
**사용 커맨드**: `/tdd`
**비유**: 코치. "먼저 골대를 세우고(테스트), 그다음 공을 차라(구현)" 하는 지도자.

#### security-reviewer — 보안 감사관

OWASP Top 10 기준으로 보안 취약점을 스캔합니다.

**역할**: SQL 주입, XSS, CSRF, 하드코딩된 시크릿 등 탐지
**사용 커맨드**: `/security-review`
**비유**: 보안 컨설턴트. 건물의 방화 설비, 비상구, CCTV를 점검하는 전문가.

### 구현/수정 그룹 (실행)

#### build-error-resolver — 빌드 수리공

빌드 에러를 자동으로 진단하고 수정합니다.

**역할**: 에러 메시지 분석 → 원인 파악 → 자동 수정 → 재빌드 확인
**사용 커맨드**: `/build-fix`
**비유**: 배관공. 막힌 파이프를 찾아서 뚫어주는 사람.

#### code-simplifier — 복잡도 감소기

복잡한 코드를 단순하게 리팩토링합니다.

**역할**: 높은 복잡도 코드 탐지 → 단순화 → 동작 보존 확인
**사용 커맨드**: `/refactoring-code`
**비유**: 정리 전문가. 어질러진 방을 깔끔하게 정리하되 물건은 하나도 버리지 않는 사람.

#### code-explorer — 코드베이스 탐색기

코드베이스에서 유사한 기능, 패턴, 파일을 빠르게 찾습니다.

**역할**: 키워드/패턴 기반 검색 → 관련 파일 목록 → 코드 흐름 추적
**사용 커맨드**: `/explore`
**비유**: 정찰병. 미지의 영역을 빠르게 돌아다니며 지도를 그리는 사람.

### 분석 그룹 (특수 목적)

#### comment-analyzer — 코드 주석 분석기

코드 주석의 품질, 정확성, 최신성을 분석합니다.

**역할**: 주석과 실제 코드의 불일치 탐지 → 개선 제안

#### pr-test-analyzer — PR 테스트 분석기

PR에 포함된 테스트 결과를 분석하여 리스크를 평가합니다.

**역할**: 테스트 커버리지 변화 → 실패 테스트 원인 → 머지 리스크 판단

#### silent-failure-hunter — 침묵하는 버그 탐지기

에러를 발생시키지 않고 조용히 잘못된 결과를 내는 버그를 찾습니다.

**역할**: try-catch 빈 블록, 무시된 반환값, 타입 강제 변환 등 탐지
**비유**: 가스 탐지기. 냄새 없는 가스 누출을 감지하는 장비.

---

## 14개 커맨드 완전 가이드

### 개발 워크플로우

| 커맨드 | 설명 | 에이전트 |
|--------|------|---------|
| `/plan` | 아키텍처 계획 수립 | code-architect |
| `/tdd` | TDD 워크플로우 시작 | tdd-guide |
| `/feature-dev` | 5단계 가이드 기능 개발 | code-architect → tdd-guide → code-reviewer |
| `/build-fix` | 빌드 에러 자동 수정 | build-error-resolver |
| `/refactoring-code` | 코드 리팩토링 | code-simplifier |
| `/explore` | 코드베이스 탐색 | code-explorer |

### 코드 리뷰 & 보안

| 커맨드 | 설명 | 에이전트 |
|--------|------|---------|
| `/review-pr` | PR 코드 리뷰 | code-reviewer |
| `/security-review` | 보안 감사 | security-reviewer |

### Git 자동화

| 커맨드 | 설명 |
|--------|------|
| `/commit` | 스마트 커밋 메시지 생성 |
| `/commit-push-pr` | 커밋 → 푸시 → PR 생성 자동화 |
| `/worktree-start` | Git worktree 생성 (도메인 자동 감지) |
| `/worktree-cleanup` | PR 완료 후 worktree 정리 |
| `/clean_gone` | 삭제된 원격 브랜치 로컬 정리 |

### 가이드 기능 개발 상세 (`/feature-dev`)

`/feature-dev`는 가장 포괄적인 커맨드입니다. 5단계로 기능 개발을 안내합니다:

```
Phase 1: 탐색
  └→ code-explorer가 코드베이스 분석
  └→ 유사 기능, 사용 가능한 패턴 파악

Phase 2: 설계
  └→ code-architect가 아키텍처 설계
  └→ 기존 패턴에 맞는 구조 제안

Phase 3: 테스트
  └→ tdd-guide가 실패하는 테스트 작성 (RED)

Phase 4: 구현
  └→ 테스트 통과하는 코드 작성 (GREEN)

Phase 5: 리뷰
  └→ code-reviewer가 품질 검사
  └→ 필요시 수정 → 재리뷰
```

---

## 13개 스킬 완전 가이드

### 핵심 스킬

#### deep-interview — 요구사항 발굴 인터뷰

소크라테스식 1:1 질문으로 요구사항을 구체화합니다. 한 번에 하나의 질문만 하며,
답변에서 새로운 분기가 나타나면 즉시 파고듭니다.

**사용법**: 자동 트리거 (모호한 요구사항 감지 시) 또는 직접 호출

#### stalab-ppt-make — STALAB 브랜드 프레젠테이션

24종 레이아웃(Cover, Two-Column, Card Grid, Chart, KPI, Timeline, Funnel, Roadmap,
Before/After, Pros/Cons, Comparison Matrix, Bento Grid 등)으로 HTML 프레젠테이션을
자동 생성합니다. SVG 다이어그램 + 웹 리서치 통합.

**사용법**: `/stalab-ppt-make "주제"`

#### visualize — 아이디어 시각화

어떤 아이디어든 단일 HTML 파일로 시각화합니다. 대시보드, 인포그래픽, 슬라이드,
플로우차트, 타임라인 등.

**사용법**: `/visualize "시각화할 내용"`

#### playground — 인터랙티브 HTML 탐험기

디자인, 데이터, 개념 맵 등을 인터랙티브 HTML로 탐색할 수 있는 도구.

#### pdf — PDF 처리

PDF 병합, 분할, 추출, 회전, 워터마크, 폼 채우기, OCR 등.

#### docx — Word 문서 처리

Word 문서 생성, 편집, 추적 변경, 이미지 삽입, 찾기/바꾸기 등.

### 도구 관리 스킬

#### skill-creator — 스킬 생성기

새 스킬(SKILL.md)을 만들거나 기존 스킬을 개선합니다. eval 벤치마크 포함.

#### manage-skills — 스킬 유지보수

세션 중 변경사항을 분석하여 스킬 커버리지 누락을 탐지합니다.

#### find-skills — 스킬 검색

설치 가능한 스킬을 검색하고 설치를 도와줍니다.

### 기타 스킬

| 스킬 | 설명 |
|------|------|
| merge-worktree | Git worktree 병합 관리 |
| verify-implementation | 패턴 검증 (구현 규칙 준수 확인) |
| frontend-design | 프론트엔드 UI/UX 설계 |
| claude-md-management | CLAUDE.md 관리 및 업데이트 |

---

## 12개 훅 (자동 보안/품질)

훅은 **자동으로 실행**됩니다. 설정할 필요 없이 설치만 하면 동작합니다.

### PreToolUse (도구 실행 전 차단)

| 훅 | 역할 |
|-----|------|
| **remote-command-guard** | `rm -rf /`, `curl` 외부 전송, `git push --force` 등 위험 명령 차단 |
| **rate-limiter** | MCP 호출 속도 제한 (과도한 API 호출 방지) |
| **db-guard** | SQL `DROP TABLE`, `TRUNCATE` 등 파괴적 쿼리 차단 |
| **expensive-mcp-warning** | Playwright/Hyperbrowser 등 고비용 MCP 사용 시 경고 |

### PostToolUse (도구 실행 후 검사)

| 훅 | 역할 |
|-----|------|
| **output-secret-filter** | 출력에서 API 키, 토큰, 비밀번호 패턴 마스킹 |
| **code-quality-reminder** | 코드 수정 후 품질 셀프체크 리마인더 |
| **security-auto-trigger** | 보안 관련 파일 수정 감지 → 보안 리뷰 제안 |

### Stop (세션 종료)

| 훅 | 역할 |
|-----|------|
| **commit-session** | 세션 종료 시 자동 WIP 커밋 (작업 유실 방지) |

### WorktreeCreate

| 훅 | 역할 |
|-----|------|
| **worktree-create** | Worktree 생성 후 프로젝트별 자동 처리 |

---

## 6개 개발 규칙

규칙은 특정 파일 수정 시 **자동으로 로드**됩니다.

| 규칙 | 트리거 | 핵심 내용 |
|------|--------|----------|
| **git-workflow-v2** | `.git/**` 수정 시 | 커밋 형식, PR 워크플로우, 기능 구현 체크리스트 |
| **security** | `.ts`, `.js`, `.env*` 수정 시 | 하드코드 시크릿 검사, SQL 주입 방지, XSS/CSRF |
| **coding-style** | TS/JS 파일 수정 시 | 명명 규칙, 코드 스타일, 파일 크기 제한 |
| **testing** | 테스트 파일 수정 시 | 테스트 작성 가이드, 커버리지 요구사항 |
| **date-calculation** | 날짜/시간 관련 | `date` 명령 사용 필수, 수동 계산 금지 |
| **mcp-management** | MCP 설정 수정 시 | MCP 서버 추가/제거 규칙, 중복 방지 |

---

## MCP 서버 통합

`.mcp.json`에 7개 서버가 사전 설정되어 있습니다:

| 서버 | 용도 |
|------|------|
| **context7** | 라이브러리 문서 + 코드 예제 (최신 버전) |
| **exa** | 웹 검색 (EXA_API_KEY 필요) |
| **github** | GitHub API 통합 |
| **fetch** | HTTP 페칭 |
| **jina-reader** | 웹페이지 읽기 (JINA_API_KEY 필요) |
| **playwright** | 브라우저 자동화 |
| **sequential** | LLM 순차 사고 (Chain-of-Thought) |

---

## CC Chips 상태줄

Claude Code 터미널 하단에 실시간 정보를 표시합니다:

```
[📁 폴더] [🔀 Git상태] [🤖 모델+토큰+비용+세션] [📊 캐시율+API시간]
```

**필요한 폰트**: JetBrainsMono Nerd Font (`fonts/` 폴더에 포함)

설치:
- **Windows**: `fonts/` 폴더 열기 → 4개 ttf 파일 우클릭 → "설치"
- **macOS**: 더블클릭 → "폰트 설치"
- **Linux**: `cp fonts/*.ttf ~/.local/share/fonts/ && fc-cache -fv`

---

## 추천 워크플로우

### 새 기능 개발 (권장)

```
/plan                  ← 1. 아키텍처 계획
/tdd                   ← 2. 테스트 먼저 작성
(구현)                  ← 3. 테스트 통과하는 코드 작성
/review-pr             ← 4. 코드 리뷰
/commit-push-pr        ← 5. 커밋 → PR
```

### 간단한 버그 수정

```
/build-fix             ← 빌드 에러면 이것
또는 직접 수정 후:
/commit                ← 스마트 커밋
```

### 대규모 리팩토링

```
/explore               ← 1. 영향 범위 파악
/plan                  ← 2. 리팩토링 계획
/worktree-start        ← 3. 별도 브랜치에서 작업
(리팩토링)              ← 4. 작업 수행
/review-pr             ← 5. 리뷰
/commit-push-pr        ← 6. PR
/worktree-cleanup      ← 7. 정리
```

### 보안 감사

```
/security-review       ← 전체 프로젝트 보안 스캔
```

### 피해야 할 패턴

| 하지 마세요 | 이유 | 대신 이렇게 |
|------------|------|------------|
| 테스트 없이 기능 개발 | 나중에 버그 찾기 어려움 | `/tdd` 먼저 |
| 리뷰 없이 PR | 품질 보증 없음 | `/review-pr` 먼저 |
| 수동으로 커밋 메시지 | 형식 불일치 | `/commit` 사용 |
| 빌드 에러 무시 | 점점 더 꼬임 | `/build-fix` 즉시 |

---

## 문제가 생겼을 때

| 상황 | 해결 |
|------|------|
| 빌드 에러 | `/build-fix` |
| 테스트 실패 | `/tdd`로 재시작 |
| PR 리뷰 거절 | `/review-pr`로 이슈 확인 후 수정 |
| 보안 경고 | `/security-review` 전체 스캔 |
| 훅이 명령 차단 | 위험 명령이 아닌지 확인. 정당하면 훅 일시 비활성화 |

---

## 충돌 방지 메커니즘

설치 스크립트는 **파일 단위 병합**으로 동작합니다:

| 상황 | 동작 |
|------|------|
| 새 파일 (기존에 없음) | 설치 |
| 동일 파일 (SHA256 일치) | 스킵 |
| 다른 내용의 파일 | `.backup-{timestamp}` 백업 후 설치 + 경고 |
| 사용자 커스텀 파일 | **절대 건드리지 않음** (harness에 없는 파일) |

사용자가 직접 만든 `my-custom-agent.md` 같은 파일은 안전합니다.

---

## 프로젝트 구조

```
oh-my-stalab-harness/
├── .claude-plugin/           ← Claude Code 플러그인 매니페스트
│   ├── plugin.json
│   └── marketplace.json
├── agents/                   ← 10개 에이전트 정의
│   ├── code-architect.md
│   ├── code-reviewer.md
│   ├── tdd-guide.md
│   ├── security-reviewer.md
│   ├── build-error-resolver.md
│   ├── code-simplifier.md
│   ├── code-explorer.md
│   ├── comment-analyzer.md
│   ├── pr-test-analyzer.md
│   └── silent-failure-hunter.md
├── commands/                 ← 14개 커맨드
├── hooks/                    ← 12개 보안/품질 훅
├── skills/                   ← 13개 스킬
├── rules/                    ← 6개 개발 규칙
├── cc-chips-custom/          ← 상태줄 커스텀
├── knowledge/                ← Anthropic 공식 문서 요약
├── fonts/                    ← JetBrainsMono Nerd Font
├── install.sh                ← macOS/Linux 설치
├── install.ps1               ← Windows 설치
├── settings.json             ← Claude Code 설정 (훅 등록)
├── .mcp.json                 ← MCP 서버 설정
├── CLAUDE.md                 ← Golden Rules
├── README.md                 ← 영어 문서
├── README-kr.md              ← 이 문서
├── README-summary.md         ← 요약본
└── LICENSE                   ← MIT
```

---

## 자주 묻는 질문

### Q: oh-my-stalab-pro-max와 뭐가 다른가요?

**harness**는 개별 도구 모음 (에이전트, 커맨드, 훅, 스킬)입니다.
**pro-max**는 이 도구들을 9-Phase 파이프라인으로 조합한 자율 실행 엔진입니다.

harness만 설치해도 `/plan`, `/tdd`, `/review-pr` 등을 개별적으로 사용할 수 있습니다.
pro-max는 harness가 설치된 상태에서 `/oms-pro-max "기능"` 한 줄로 전체 사이클을 자동 실행합니다.

### Q: 기존에 ~/.claude/에 내 파일이 있는데 덮어쓰나요?

아닙니다. 파일 단위로 비교하여, 다른 내용인 파일만 백업 후 설치합니다.
harness에 없는 사용자 커스텀 파일은 절대 건드리지 않습니다.

### Q: 특정 에이전트만 쓰고 싶은데?

가능합니다. 커맨드를 직접 호출하면 됩니다:
- code-architect만: `/plan`
- tdd-guide만: `/tdd`
- code-reviewer만: `/review-pr`

### Q: 비용이 많이 들지 않나요?

에이전트별로 다릅니다:
- **code-architect, tdd-guide**: Opus 모델 (고비용, 고품질)
- **나머지 8개**: Sonnet 모델 (저비용, 적절한 품질)

CC Chips 상태줄에서 실시간 비용을 확인할 수 있습니다.

### Q: 훅을 비활성화하고 싶어요

`settings.json`에서 해당 훅을 주석 처리하거나 삭제하세요.
또는 `~/.claude/settings.json`에서 직접 수정.

### Q: bkit 플러그인도 필요한가요?

harness만 사용할 때는 **필요 없습니다**.
pro-max를 함께 사용할 때만 bkit이 필요합니다 (gap-detector, pdca-iterator 등).

---

## 기여하기

1. 이 레포를 Fork
2. 기능 브랜치 생성 (`git checkout -b feat/my-feature`)
3. 커밋 (`git commit -m "feat: add my feature"`)
4. 푸시 (`git push origin feat/my-feature`)
5. PR 생성

---

## 라이선스

MIT

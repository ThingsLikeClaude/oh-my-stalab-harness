# Research Phase Workflow

주제만 제공된 경우 리서치 → 구조화 → PPT 생성까지 자동 수행하는 워크플로우.

---

## 개요

사용자가 "AI 반도체 시장 분석 PPT 만들어줘"처럼 **주제만** 제공하면, 3인 Agent Team이 순차적으로 리서치 → 아웃라인 → HTML 생성을 수행한다.

```
사용자: "AI 반도체 시장 분석 PPT 만들어줘"
         │
    ┌────▼────────────────┐
    │ Lead (main session) │ ← 오케스트레이터, 체크포인트 관리
    └──┬──────┬───────┬───┘
       │      │       │
  ┌────▼──┐ ┌▼────┐ ┌▼──────────┐
  │리서처 │→│에디터│→│PPT 빌더   │
  │sonnet │ │sonnet│ │sonnet     │
  └───────┘ └──────┘ └───────────┘
```

---

## 스테이징 디렉토리

```
/tmp/ppt-research/{slug}/
  ├── raw-research.md          ← 리서처 작성
  └── structured-outline.md    ← 에디터 작성
```

`{slug}` = 주제를 kebab-case로 변환 (예: `ai-semiconductor-market-analysis`)

---

## Agent Team 구성

| Agent | 역할 | 모델 | 소유 파일 | 도구 |
|-------|------|------|-----------|------|
| **리서처** | 웹 리서치 + 합성 | sonnet | `raw-research.md` | WebSearch, Read, Write |
| **에디터** | 슬라이드 구조화 + 레이아웃 배정 | sonnet | `structured-outline.md` | Read, Write |
| **PPT 빌더** | HTML 프레젠테이션 생성 | sonnet | `~/Downloads/{filename}.html` | Read, Write, Bash(start) |

### 파일 소유권 규칙

- 각 에이전트는 **자신의 소유 파일만 Write** 가능
- 다른 에이전트의 파일은 **Read만** 가능
- 충돌 방지: 동시 Write 없음 (순차 실행)

---

## Task Pipeline

### 검토 모드 (기본)

```
[리서처] T1: 웹 리서치 (한/영 3~5회)
         T2: 결과 합성 (NotebookLM 가용 시 활용)
         T3: raw-research.md 작성 → Lead에 보고

── Checkpoint 1: 리서치 결과 요약 → 사용자 확인/수정 ──

[에디터] T4: raw-research.md 읽기 + Decision Tree 적용
         T5: structured-outline.md 작성 (슬라이드별 제목/레이아웃/콘텐츠)
         T6: Lead에 아웃라인 보고

── Checkpoint 2: 슬라이드 아웃라인 → 사용자 확인 ──

[빌더]  T7: outline + slide-template.html + layouts.md 읽기
         T8: HTML 생성 (SKILL.md Step 2~3 로직)
         T9: ~/Downloads/ 저장 + 브라우저 열기
```

### 자동 모드

```
[리서처] T1~T3: 리서치 → raw-research.md
[에디터] T4~T6: 구조화 → structured-outline.md
[빌더]  T7~T9: HTML 생성 → ~/Downloads/ 저장 + 브라우저 열기
→ 최종 결과만 사용자에게 보고 (슬라이드 목록 + 파일 경로)
```

### Task 의존성

```
T1 → T2 → T3 → [CP1] → T4 → T5 → T6 → [CP2] → T7 → T8 → T9
```

모든 태스크는 **순차 의존**. 병렬 실행 없음.

---

## 실행 모드

| 모드 | 트리거 | 체크포인트 | 용도 |
|------|--------|-----------|------|
| **검토 모드** (기본) | 별도 지정 없음 | 2회 (리서치 후 + 아웃라인 후) | 정확도 중요한 발표, 첫 사용 |
| **자동 모드** | "알아서", "자동으로", "auto", "바로" | 없음 — 끝까지 논스톱 | 빠른 초안, 시간 없을 때 |

### 자동 모드 감지 키워드

한국어: `알아서`, `자동으로`, `바로`, `한방에`, `끝까지`
영어: `auto`, `automatically`, `just do it`, `straight through`

---

## 리서치 도구 선택 (감지 기반)

리서처는 **실행 시점에 가용한 도구를 감지**하여 최적 도구를 선택한다.
실패 후 폴백이 아니라, **먼저 감지하고 가용한 것부터 사용**한다.

### 도구 감지 순서

```
1. Gemini CLI 설치 여부: command -v gemini
2. Exa MCP 가용 여부: mcp__exa__web_search_exa 도구 존재 확인
3. Jina MCP 가용 여부: mcp__jina-reader__jina_search 도구 존재 확인
4. WebSearch: Claude 내장 (항상 가용)
```

### 도구별 리서치 전략

#### WebSearch (항상 가용 — 기본 도구)

```
1차: WebSearch("{주제} 최신 동향 핵심 데이터 주요 플레이어 전망")
2차: WebSearch("{topic_en} latest trends market data key players forecasts")
3차: WebSearch("{주제} 통계 시장 규모 성장률 점유율")
4차~5차: 갭 채우기 (선택)
```

#### Gemini CLI (설치된 경우 — 심층 리서치)

```bash
gemini -p "'{주제}'에 대해 최신 동향, 핵심 데이터, 주요 플레이어, 전망을 포함하여 종합 리서치해줘. 출처와 날짜를 명시해." -o text
gemini -p "'Analyze {topic_en}: latest trends, market data, key players, forecasts. Include sources and dates." -o text
gemini -p "'{주제}' 관련 최신 통계, 시장 규모, 성장률, 점유율 데이터를 숫자 중심으로 찾아줘." -o text
```

#### Exa MCP (가용 시 — 기술/코드 문서에 강점)

```
mcp__exa__web_search_exa("{주제} 분석 데이터")
```

#### Jina MCP (가용 시 — 구조화된 웹 페이지 읽기)

```
mcp__jina-reader__jina_search("{주제}")
```

### 조합 전략

가용한 도구를 **조합**하여 리서치 품질을 높인다:

| 가용 도구 | 전략 |
|-----------|------|
| WebSearch만 | WebSearch 3~5회 (한/영/데이터) |
| WebSearch + Gemini | Gemini로 심층 리서치 + WebSearch로 최신 데이터 보완 |
| WebSearch + Exa | WebSearch로 일반 리서치 + Exa로 기술 문서 |
| 전부 가용 | Gemini 심층 + Exa 기술 + WebSearch 최신 + Jina 구조화 |

---

## NotebookLM 통합 (선택)

NotebookLM CLI가 설치된 경우 (`command -v notebooklm`), 리서치 결과를 합성:

```bash
# 1. 노트북 생성
notebooklm create "{주제} 리서치" --no-open

# 2. 리서치 결과를 소스로 추가
notebooklm source add --text "$(cat /tmp/ppt-research/{slug}/raw-*.md)"

# 3. 합성 질문
notebooklm ask "이 자료들을 종합하여 프레젠테이션 핵심 메시지 5~7개로 요약해줘"

# 4. (선택) 마인드맵 생성
notebooklm generate mind-map
```

### NotebookLM 미설치 시

- 스킵. 리서치 결과만으로 `raw-research.md` 작성
- 합성 품질은 낮아지지만 워크플로우는 계속 진행

---

## Agent 프롬프트 템플릿

### 리서처

```
너는 프레젠테이션을 위한 리서치 전문가야.

## 임무
주제: "{topic}"
다음 단계를 수행해:

1. 가용한 리서치 도구를 감지하여 웹 리서치 (한국어 1회 + 영어 1회 + 데이터 1회, 필요시 추가)
2. NotebookLM 가용 시 소스 추가 후 합성 요약
3. 결과를 /tmp/ppt-research/{slug}/raw-research.md에 작성

## raw-research.md 포맷
아래 형식을 정확히 따라:

---
topic: "{topic}"
date: {YYYY-MM-DD}
queries_count: {N}
sources_count: {N}
---

## 핵심 요약
- {메시지 1}
- {메시지 2}
...

## 상세 리서치

### {섹션 1 제목}
{내용}
출처: {URL/이름}

### {섹션 2 제목}
...

## 데이터/통계
| 지표 | 값 | 출처 | 연도 |
|------|-----|------|------|
| ... | ... | ... | ... |

## 주요 플레이어
| 기업/조직 | 역할/점유율 | 특이사항 |
|-----------|------------|---------|
| ... | ... | ... |
```

### 에디터

```
너는 프레젠테이션 구조화 전문가야.

## 임무
1. /tmp/ppt-research/{slug}/raw-research.md를 읽어
2. references/decision.md의 Decision Tree를 참고하여 슬라이드별 레이아웃 배정
3. 결과를 /tmp/ppt-research/{slug}/structured-outline.md에 작성

## 규칙
- 같은 레이아웃 3연속 금지
- 커버(1장) + 콘텐츠(8~15장) + 마무리(1장) 구성
- 데이터가 있으면 Chart/KPI 레이아웃 우선
- 코드가 있으면 Code Block 레이아웃
- 비교 항목 → Two-Column, 나열 항목 → Card Grid

## structured-outline.md 포맷

---
topic: "{topic}"
total_slides: {N}
mode: "{single|chunk}"
---

## 슬라이드 구성

### Slide 1: Cover
- layout: cover
- title: "{제목}"
- subtitle: "{부제}"

### Slide 2: {제목}
- layout: {text|two-column|card-grid|chart|kpi|code-block|image}
- title: "{슬라이드 제목}"
- content:
  - {불릿 1}
  - {불릿 2}
  ...
- data: (차트/KPI인 경우)
  - {항목}: {값}
  ...
- notes: "{발표자 노트}"

### Slide N: 마무리
- layout: text
- title: "Thank You / Q&A"
- content: ...
```

### PPT 빌더

```
너는 프레젠테이션 HTML 생성 전문가야.

## 임무
1. /tmp/ppt-research/{slug}/structured-outline.md를 읽어
2. 이 파일의 SKILL.md Step 2~3 워크플로우를 따라 HTML 생성
3. references/slide-template.html을 복사 원본으로 사용
4. references/layouts.md에서 레이아웃별 HTML 마크업 참조
5. ~/Downloads/{kebab-case-title}.html에 저장
6. 브라우저에서 열기

## Critical 제약
- CSS-only 차트만 (Chart.js/Canvas 금지)
- 단일 HTML 파일 (외부 JS/CSS 없음, 폰트 CDN만 예외)
- 색상 체계/텍스트 크기 계층 준수
- 커버에 data-type="cover" 필수
- 그리드 배경은 .slides::before
```

---

## 핸드오프 파일 포맷

### raw-research.md

```yaml
---
topic: "AI 반도체 시장 분석"
date: 2026-03-12
queries_count: 4
sources_count: 12
---
```

본문 섹션:
- `## 핵심 요약` — 불릿 5~7개
- `## 상세 리서치` — 주제별 h3 섹션 + 출처
- `## 데이터/통계` — 테이블 형식
- `## 주요 플레이어` — 테이블 형식

### structured-outline.md

```yaml
---
topic: "AI 반도체 시장 분석"
total_slides: 12
mode: "chunk"
---
```

본문: `### Slide N: {제목}` 형식으로 슬라이드별 명세.

---

## 순차 폴백 모드

Agent Team(TeamCreate)을 사용할 수 없는 환경에서는, **Lead(메인 세션)가 직접** 동일 워크플로우를 순차 실행한다:

1. Lead가 리서처 역할 수행 → 웹 리서치 + raw-research.md 작성
2. (검토 모드: Checkpoint 1)
3. Lead가 에디터 역할 수행 → Decision Tree 적용 + structured-outline.md 작성
4. (검토 모드: Checkpoint 2)
5. Lead가 빌더 역할 수행 → SKILL.md Step 2~3 → HTML 생성

파일 경로와 포맷은 동일. 차이는 에이전트 분리 여부뿐.

---

## 에러 핸들링

| 에러 | 대응 |
|------|------|
| 리서치 도구 전부 실패 | WebSearch는 항상 가용 — 최소 WebSearch로 진행 |
| NotebookLM 미설치/인증 만료 | 스킵, 리서치 결과로만 진행 |
| `/tmp` 쓰기 불가 | `~/Downloads/ppt-research/{slug}/`로 대체 |
| Agent Team 생성 실패 | 순차 폴백 모드로 전환 |
| structured-outline.md 누락 | 에디터 단계 재실행 요청 |
| 리서치 결과 부족 (소스 3개 미만) | 사용자에게 추가 키워드/자료 요청 |

---

## 라우팅 판단 기준 (Step 0에서 사용)

| 입력 패턴 | 판단 | 라우팅 |
|-----------|------|--------|
| 주제/질문 형태만 (불릿/데이터 없음) | 리서치 필요 | → Research Phase |
| 주제 + "알아서"/"auto" 키워드 | 리서치 필요 + 자동 모드 | → Research Phase (auto) |
| 불릿 리스트, 데이터, 구조화된 텍스트 포함 | 콘텐츠 충분 | → Step 1 (바로 생성) |
| 주제 + 부분 데이터 혼합 | 갭만 리서치 | → Research Phase (부분) |

### "부분 리서치" 모드

사용자가 일부 데이터를 제공했지만 부족한 경우:
1. 제공된 데이터를 raw-research.md의 기초로 사용
2. 리서처가 부족한 영역만 추가 리서치
3. 나머지 워크플로우 동일

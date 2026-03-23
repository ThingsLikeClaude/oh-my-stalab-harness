# oh-my-stalab-harness

Claude Code 개발 하니스 — AI 기반 개발을 위한 에이전트, 커맨드, 훅, 스킬, 규칙 모음.

## 구성 요소

| 카테고리 | 개수 | 설명 |
|---------|------|------|
| **에이전트** | 10 | code-architect, tdd-guide, code-reviewer, security-reviewer 등 |
| **커맨드** | 14 | /plan, /tdd, /feature-dev, /build-fix, /commit-push-pr 등 |
| **훅** | 12 | 보안 가드, 시크릿 필터, 코드 품질 리마인더 |
| **스킬** | 13 | deep-interview, stalab-ppt-make, visualize, pdf, docx 등 |
| **규칙** | 6 | git-workflow, security, coding-style, testing 등 |

추가: CC Chips 커스텀 상태줄, 지식 베이스, JetBrainsMono Nerd Font.

## 빠른 시작

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

`~/.claude/`에 글로벌 설치됩니다. macOS/Linux는 심링크, Windows는 파일 복사.

## 업데이트

```bash
cd oh-my-stalab-harness
git pull
# 심링크는 자동 반영 (macOS/Linux)
# Windows: install.ps1 재실행
```

## 충돌 방지

설치 스크립트는 **파일 단위 병합**으로 동작합니다:
- 새 파일 → 설치
- 동일 파일 → 스킵 (SHA256 비교)
- 다른 내용 → `.backup-{timestamp}` 백업 후 설치 + 경고
- 사용자 커스텀 파일 → 절대 건드리지 않음

## 에이전트

| 에이전트 | 역할 |
|---------|------|
| code-architect | 기존 패턴 분석 → 아키텍처 설계 |
| code-reviewer | 코드 품질 리뷰 (CRITICAL/HIGH/MEDIUM) |
| tdd-guide | TDD 워크플로우 강제 (RED → GREEN → REFACTOR) |
| build-error-resolver | 빌드 에러 진단 + 수정 |
| code-simplifier | 복잡도 감소 |
| security-reviewer | OWASP 취약점 스캔 |
| code-explorer | 코드베이스 탐색 |
| comment-analyzer | 코드 주석 분석 |
| pr-test-analyzer | PR 테스트 결과 분석 |
| silent-failure-hunter | 침묵하는 버그 탐지 |

## 커맨드

| 커맨드 | 설명 |
|--------|------|
| `/plan` | 플래너 에이전트로 아키텍처 계획 |
| `/tdd` | TDD 워크플로우 시작 |
| `/feature-dev` | 5단계 가이드 기능 개발 |
| `/build-fix` | 빌드 에러 자동 수정 |
| `/review-pr` | PR 코드 리뷰 |
| `/security-review` | 보안 감사 |
| `/commit-push-pr` | 커밋 → 푸시 → PR 자동화 |
| `/worktree-start` | Git worktree 생성 |
| `/worktree-cleanup` | PR 후 worktree 정리 |
| `/explore` | 코드베이스 탐색 |
| `/refactoring-code` | 코드 리팩토링 |
| `/commit` | 스마트 커밋 메시지 |
| `/clean_gone` | 삭제된 원격 브랜치 정리 |

## 훅 (자동 실행)

- **PreToolUse**: 위험 명령 차단, 속도 제한, DB 보호, 고비용 MCP 경고
- **PostToolUse**: 시크릿 필터, 코드 품질 리마인더, 보안 자동 트리거
- **Stop**: 자동 WIP 커밋

## 스킬

deep-interview, stalab-ppt-make, visualize, playground, pdf, docx, skill-creator, manage-skills, find-skills, merge-worktree, verify-implementation, frontend-design, claude-md-management

## MCP 서버

`.mcp.json`에 사전 설정:
- context7 (라이브러리 문서), exa (웹 검색), github, fetch, jina-reader, playwright, sequential-thinking

## 요구 사항

- Claude Code v2.1.63+
- Node.js v18+
- Git

## 폰트 설정 (선택)

CC Chips 상태줄 아이콘용 JetBrainsMono Nerd Font (`fonts/`):
- **Windows**: 우클릭 → 설치
- **macOS**: 더블클릭 → 폰트 설치
- **Linux**: `~/.local/share/fonts/`에 복사

## 라이선스

MIT

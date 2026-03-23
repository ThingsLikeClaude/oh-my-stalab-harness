# oh-my-stalab-harness

Claude Code development harness — agents, commands, hooks, skills, and rules for productive AI-assisted development.

## What's Inside

| Category | Count | Description |
|----------|-------|-------------|
| **Agents** | 10 | code-architect, tdd-guide, code-reviewer, security-reviewer, ... |
| **Commands** | 14 | /plan, /tdd, /feature-dev, /build-fix, /commit-push-pr, ... |
| **Hooks** | 12 | Security guards, secret filters, code quality reminders |
| **Skills** | 13 | deep-interview, stalab-ppt-make, visualize, pdf, docx, ... |
| **Rules** | 6 | git-workflow, security, coding-style, testing, ... |

Plus: CC Chips custom statusline, knowledge base, JetBrainsMono Nerd Font.

## Quick Start

### macOS / Linux
```bash
git clone https://github.com/stalab-ai/oh-my-stalab-harness.git
cd oh-my-stalab-harness
bash install.sh
```

### Windows (PowerShell)
```powershell
git clone https://github.com/stalab-ai/oh-my-stalab-harness.git
cd oh-my-stalab-harness
.\install.ps1
```

The installer creates symlinks (macOS/Linux) or copies files (Windows) to `~/.claude/`.

## Upgrade

```bash
cd oh-my-stalab-harness
git pull
# Symlinks auto-reflect changes (macOS/Linux)
# Windows: re-run install.ps1
```

## Components

### Agents
| Agent | Purpose |
|-------|---------|
| code-architect | Architecture design from existing patterns |
| code-reviewer | Code quality review (CRITICAL/HIGH/MEDIUM) |
| tdd-guide | TDD workflow enforcement (RED → GREEN → REFACTOR) |
| build-error-resolver | Build error diagnosis and fix |
| code-simplifier | Complexity reduction |
| security-reviewer | OWASP vulnerability scanning |
| code-explorer | Codebase navigation |
| comment-analyzer | Code comment analysis |
| pr-test-analyzer | PR test result analysis |
| silent-failure-hunter | Silent bug detection |

### Commands
| Command | Description |
|---------|-------------|
| `/plan` | Invoke planner agent for architecture planning |
| `/tdd` | Start TDD workflow |
| `/feature-dev` | Guided 5-phase feature development |
| `/build-fix` | Auto-fix build errors |
| `/review-pr` | PR code review |
| `/security-review` | Security audit |
| `/commit-push-pr` | Commit → Push → PR automation |
| `/worktree-start` | Git worktree creation |
| `/worktree-cleanup` | Post-PR worktree cleanup |
| `/explore` | Codebase exploration |
| `/refactoring-code` | Code refactoring |
| `/commit` | Smart commit message |
| `/clean_gone` | Clean deleted remote branches |

### Hooks (Auto-active)
- **PreToolUse**: remote-command-guard, rate-limiter, db-guard, expensive-mcp-warning
- **PostToolUse**: output-secret-filter, code-quality-reminder, security-auto-trigger
- **Stop**: commit-session (auto WIP commit)

### Skills
deep-interview, stalab-ppt-make, visualize, playground, pdf, docx, skill-creator, manage-skills, find-skills, merge-worktree, verify-implementation, frontend-design, claude-md-management

## MCP Servers

Pre-configured in `.mcp.json`:
- context7 (library docs), exa (web search), github, fetch, jina-reader, playwright, sequential-thinking

## Requirements

- Claude Code v2.1.63+
- Node.js v18+
- Git

## Font Setup (Optional)

Install JetBrainsMono Nerd Font from `fonts/` for CC Chips statusline icons:
- **Windows**: Right-click → Install
- **macOS**: Double-click → Install Font
- **Linux**: Copy to `~/.local/share/fonts/`

## License

MIT

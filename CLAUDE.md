# Claude Code Config

## Golden Rules

- Always respond in Korean
- Conclusion first, reasoning second. Never start with "Because..."
- Surgical changes only. Don't touch adjacent code unless asked
- Date/time: always use `date` or `python3`. Never calculate mentally
- No completion claims without fresh execution evidence. "should work" is banned
- 3+ files changing → `/plan` first. Exception: 1-2 file trivial fixes
- Immutability: no object mutation, use spread for new objects
- File ≤800 lines / Function ≤50 lines / Nesting ≤4 levels
- When uncertain: "Let me verify" + verification method. No guessing
- Analogy first (1-2 sentences) → technical explanation
- Ambiguous requirements → state assumptions, ask for confirmation

## Tool Priority (CRITICAL)

| Purpose          | 1st                              | 2nd                 | Banned                   |
| ---------------- | -------------------------------- | ------------------- | ------------------------ |
| Library docs     | `mcp__context7__*`               | -                   | -                        |

## MCP Server Management

- Add/modify servers only in `~/.claude.json` `mcpServers` section
- Duplicate names = both fail to load. Check existing configs before adding
- Never add to `~/.claude/.mcp.json` or `mcp-servers.json`

## Agent Usage

- Complex features → planner agent
- After writing code → code-reviewer agent
- Bug fix / new feature → tdd-guide agent
- Independent tasks → parallel execution (never sequential)
- Details: `~/.claude/rules/agents-v2.md`

## Git

- Commits: `<type>: <description>` (feat, fix, refactor, docs, test, chore)
- Never amend/rebase pushed commits
- Never commit secrets or API keys

## Security

- Before commit: check hardcoded secrets, SQL injection, XSS
- Secrets via `process.env` only. Throw immediately if unset
- Security issue found → deploy security-reviewer agent

## Rules Index (Conversation Keyword → Read rule file)

When conversation matches keywords below, Read the rule file and follow it.

| Keywords | Rule File |
|----------|-----------|
| 날짜, 요일, D-day, 며칠, 언제, date, calendar, schedule | `~/.claude/rules/date-calculation.md` |
| MCP, mcp 서버, mcp 추가, mcp server | `~/.claude/rules/mcp-management.md` |
| 에이전트, 서브에이전트, 병렬 실행, agent, subagent, parallel | `~/.claude/rules/agents-v2.md` |

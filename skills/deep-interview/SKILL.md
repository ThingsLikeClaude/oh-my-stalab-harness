---
name: deep-interview
description: Relentless 1-on-1 interview that walks down every branch of the decision tree until shared understanding is reached
---
# Deep Interview - Relentless Requirements Discovery

## Purpose

Interview the user **one question at a time**, like a real conversation.
Walk down every branch of the decision tree. When an answer opens a new branch,
follow it before moving on. Don't stop until every assumption is surfaced,
every ambiguity resolved, and shared understanding is reached.

This is not a questionnaire. This is a **conversation**.

## Use When

- Vague or ambiguous task description
- User says "interview", "clarify", "what do I need?", "grill me"
- Before planning or implementation for complex features
- When multiple valid interpretations exist
- User wants to stress-test a plan or design

## Do Not Use When

- Requirements are already clear and specific
- Simple bug fix with obvious solution
- User has already provided detailed spec

## Modes

### Full Mode (Default) — up to 30 questions

Relentless exploration of every decision branch. Keeps going until all branches
are resolved or 30 questions are reached.

```
/deep-interview "build a notification system"
/deep-interview "redesign the authentication flow"
```

### Quick Mode — up to 10 questions

Focused pass on core areas only. Use when requirements are mostly clear.

```
/deep-interview --quick "add caching"
```

## Interview Protocol

### Phase 0: Explore the Codebase First

Before asking ANY questions, silently explore:
- Glob for related files
- Grep for related patterns
- Read key files to understand current state

If a question can be answered by exploring the codebase, **explore the codebase
instead of asking the user**. Never waste the user's time on questions the code
already answers.

### Phase 1: Open with Context

Start the interview by:
1. Stating what you already know from the codebase (2-3 sentences)
2. Stating your initial understanding of the task
3. Asking your **first question** — one question only

Example:
```
"I explored the project. It's Express + PostgreSQL with JWT auth.

You want a notification system — what triggers a notification?
For example, new comments, likes, follows, or system announcements?"
```

### Phase 2: One Question at a Time (Core Loop)

**Rules:**
1. **One question per turn.** Never ask multiple questions at once.
2. **Follow up on answers.** When an answer reveals a new branch, dig into it immediately.
3. **Resolve branches before moving on.** Never leave an unresolved branch behind.
4. **Check code instead of asking.** If the codebase can answer a question, look it up yourself.
5. **State assumptions and confirm.** "I'm assuming X — does that sound right?"
6. **Parallel explorer dispatch.** While waiting for the user's answer, if their previous answer
   mentioned a concept, module, or integration point, dispatch an explorer agent in the background
   to gather codebase context. Use this "free time" to inform your next question.

**Decision Tree Walking:**

```
Q1: "What triggers a notification?"
A1: "Comments, likes, follows"
  -> Branch found: 3 event types
Q2: "Are all three real-time, or are some batched via email?"
A2: "Comments are real-time, the rest are batched email"
  -> Branch found: real-time vs batch
Q3: "For real-time — WebSocket or SSE?"
A3: "WebSocket"
  -> Branch resolved -> move to next topic
Q4: "What's the batch interval for emails?"
...
```

**Coverage Areas** (cover only what's relevant — not all required):

| Area | What to Explore |
|------|----------------|
| **Problem** | Why is this needed? How is it currently handled? |
| **Users** | Who uses this? What's their skill level? |
| **Scope** | What's in and what's out? |
| **Data** | What data flows in/out? Where is it stored? |
| **Behavior** | Happy path? Edge cases? |
| **Integration** | Which existing systems does this touch? |
| **Performance** | Expected load, latency tolerance? |
| **Security** | Sensitive data? Auth/authz requirements? |
| **Error handling** | How should failures be communicated? |
| **Testing** | What level of test coverage is expected? |
| **Deployment** | Environment-specific considerations? |
| **Future** | What extensions might be needed later? |
| **Constraints** | Technical limits, timeline, dependencies? |
| **Validation** | How to determine completion? |

### Phase 3: Closing

When all branches are resolved:

1. **Present summary**: Show confirmed decisions in a structured format
2. **Check for gaps**: "Anything I missed?"
3. **Final confirmation**: "Ready to proceed with this?"

### Phase 4: Record & Transition

Save interview results to `docs/interviews/interview-{slug}-{timestamp}.md`:

```markdown
# Interview: {task description}
Date: {ISO date}
Questions asked: {count}
Mode: full | quick

## Decisions Made
1. {decision}: {rationale}
2. ...

## Scope
- In scope: {list}
- Out of scope: {list}

## Technical Decisions
- {topic}: {choice} (because {reason})

## Data & Integration
- {data flow description}
- {integration points}

## Constraints
- {constraint}: {impact}

## Validation Criteria
- {how to verify completion}

## Assumptions Confirmed
- {assumption}: confirmed by user

## Open Questions
- {any remaining unknowns}
```

After interview:
- Always save the interview file for reference
- Recommend next step:

```
══════════════════════════════════════════════════
📋 Interview Complete — {count} questions resolved

인터뷰 결과가 저장되었습니다:
  docs/interviews/interview-{slug}-{timestamp}.md

다음 단계로 계획 문서를 생성하시겠습니까?
  👉 /pdca plan {task description}

인터뷰에서 확인된 결정사항이 Plan 문서에 자동 반영됩니다.
══════════════════════════════════════════════════
```

## Anti-Patterns

| Don't | Why | Do Instead |
|-------|-----|-----------|
| Ask 5 questions at once | User gives shallow answers | One question per turn |
| "Is it A, B, or C?" | Forces premature choices | Open question first, then narrow |
| Ask what the code already answers | Wastes user time | Explore codebase first |
| Skip a branch to move on | Leaves unresolved assumptions | Resolve every branch fully |
| Repeat "What would you like?" | User may not know | Propose an assumption, then confirm |
| Always fill 30 questions | Unnecessary questions | End early when branches are resolved |

## Interview Style

- **Conversational**: Natural dialogue, not a rigid survey
- **Contextual linking**: "Following up on what you said about X..."
- **Assumption-first**: "Typically this is done with Y — does that work here?"
- **Adaptive depth**: Short answers = dig deeper. Detailed answers = move on faster.
- **Progress indicator**: Every 5 questions, state: "We've covered {N} questions so far, currently on {topic}"

## Constraints

- Full mode: max 30 questions (may end early when all branches are resolved)
- Quick mode: max 10 questions
- One question per turn (multiple questions per turn is strictly forbidden)
- If the codebase can answer a question, do not ask the user
- Show progress indicator every 5 questions

## Original Task

$ARGUMENTS

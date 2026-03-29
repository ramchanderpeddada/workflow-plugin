---
name: execute-plan
description: "Use when user wants to implement or build from an approved plan. Trigger on: build it, implement, let's build it, start building, start coding, go ahead and implement, proceed with implementation, approved go ahead, execute tasks, execute the plan, run the plan, implement the plan, start implementing. Do NOT use when no plan exists — run plan-epic first. Do NOT use for shipping — use ship."
context: fork
---

# Execute Plan

**Announce:** "I'm using the execute-plan skill to implement the approved plan task by task."

## Overview

Read an approved implementation plan, create tasks from the task breakdown, execute each task sequentially with a quality gate after every task, and suggest ship when complete.

<HARD-GATE>
An approved plan MUST exist before this skill runs. If no plan exists (no plan mode file, no pasted plan, no plan-epic output), STOP immediately: "No approved plan found. Run plan-epic first, or paste your implementation plan."

NEVER search the codebase for context. The plan already has all file paths — read only what's listed.
NEVER run `yarn dev` or `yarn start` — only build checks.
</HARD-GATE>

## When to Use

- User approves a plan-epic plan and says "execute", "implement", "start implementing"
- User says "execute the plan", "run the plan", "execute tasks", "build from plan"
- User pastes a structured implementation plan and says "implement this"

### When NOT to Use

- No plan exists yet → use `plan-epic` to create one first
- Ready to commit and push → use `ship`
- Single task with no plan context → just implement it directly
- Need schema exploration → use `explore-schema`

---

## Workflow

### Step 1: Ingest the Plan

**Find the plan:**
1. Check for plan mode file in `~/.claude/plans/` (most recent)
2. If user pasted plan text → use that directly
3. If neither found → STOP: "No plan found. Paste your plan or run plan-epic first."

**Parse the task breakdown.** For each task in `## Task Breakdown`, extract:

| Field | Source in plan | Required? |
|-------|---------------|-----------|
| title | `### Task N: [Title]` | Yes |
| type | `Type:` line | No (infer from files) |
| service | `Service:` line | Yes |
| depends_on | `Depends on:` line | No (assume sequential) |
| effort | `Effort:` line | No (default M) |
| files_to_modify | `Files to modify:` list | Yes — STOP if missing |
| existing_code | `Existing code to reuse:` list | No |
| impl_notes | `Implementation notes:` list | No |

Also extract from the plan:
- `## Schema Changes` — for migration tasks
- `## API Changes` — for endpoint tasks
- `## Testing Strategy` — for test requirements per task
- `## Dependency Order` — for execution sequencing

**Create Claude Code tasks:**
Use TaskCreate for each parsed task. Set status to `pending`. This tracks progress across the session.

**Display the execution plan:**

```
EXECUTION PLAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Source: [plan file path or "pasted plan"]
Tasks:  [N] total

  #  Status   Task                          Service           Effort
  1  PENDING  [title]                       [service]         S/M/L/XL
  2  PENDING  [title] (depends: Task 1)     [service]         S/M/L/XL
  3  PENDING  [title]                       [service]         S/M/L/XL

Estimated total: [sum of efforts]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Proceed? (yes / skip to task N / modify)
```

Wait for user confirmation before executing.

---

### Step 2: Execute Tasks (Sequential Loop)

For each task in dependency order:

#### 2a. Start Task

Mark task `in_progress` (TaskUpdate). Show header:

```
TASK [N]/[TOTAL]: [Title]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Type:    [type]
Service: [service path]
Effort:  [S/M/L/XL]
Files:   [count] to read, [count] to modify
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### 2b. Read Context

Read ONLY the files listed in the plan for this task. Use the Read tool directly — do NOT launch Explore subagents, do NOT Grep, do NOT Glob. The plan already did the exploration.

Read in this order:
1. `Existing code to reuse` files — understand patterns to follow
2. `Files to modify` files — understand what exists before changing it
3. If a file is listed but doesn't exist → it's a new file to create, note it

If a path from the plan doesn't exist and isn't a new file: flag it — "Plan references `{path}` but it doesn't exist. Skipping or ask user to clarify."

#### 2c. Implement

Follow CampX implementation order within each task:

**Backend task order:**
1. Entity changes (if any)
2. Migration file — write only, NEVER run. Always include `down()` method. File: `{TIMESTAMP}-{description}.ts`
3. DTOs — `class-validator` decorator on every field, never use `any`
4. Service methods — all business logic here, not in controller, `try/catch` on all async
5. Controller endpoints — `@UseGuards(JwtAuthGuard)` on every controller class
6. Module registration — add to providers, controllers, imports as needed

**Frontend task order:**
1. Types/interfaces
2. API service functions
3. Components (prefer @campxdev/shared and @campxdev/react-blueprint)
4. Page components
5. Route registration

**CampX patterns to enforce:**
- No `any` types — explicit TypeScript
- No `console.log` — use NestJS `Logger`
- No `@ts-ignore`
- No `synchronize: true`
- `try/catch` on all async operations
- Parameterized queries (never string concatenation)
- `@UseGuards(JwtAuthGuard)` on every controller
- File names: kebab-case | Classes: PascalCase | Functions: camelCase

#### 2d. Write Tests

For every new service method or controller endpoint, write tests alongside the implementation.

**Backend — test file location:**
```
{service}/src/{module}/__tests__/{file}.spec.ts
```

Minimum per new method/endpoint:
- Happy path test
- Error/edge case test
- Guard/auth test for controller endpoints

**Frontend — test file location:**
```
{app}/src/{feature}/__tests__/{Component}.test.tsx
```

Minimum:
- Render test
- User interaction test
- API error state test

Target: 80%+ coverage of new code.

#### 2e. Quality Gate

Run for the affected service/app:

```bash
cd /Users/ramchanderpeddada/Desktop/CampX/{service} && yarn test --passWithNoTests
cd /Users/ramchanderpeddada/Desktop/CampX/{service} && yarn tsc --noEmit
cd /Users/ramchanderpeddada/Desktop/CampX/{service} && yarn lint
```

Show results:

```
QUALITY GATE — Task [N]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tests:      ✓ PASS  / ✗ FAIL ([X] tests, [Y] suites)
TypeScript: ✓ PASS  / ✗ FAIL ([X] errors)
Lint:       ✓ PASS  / ⚠ WARN ([X] warnings)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**On failure:**
- Tests FAIL → diagnose the failing test, fix the code or test, re-run
- TypeScript FAIL → read the error, fix type issues, re-run
- Lint WARN → note it, continue (non-blocking)
- Max 3 retry attempts per task. After 3 failures → STOP:

```
BLOCKED — Task [N]: [Title]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Quality gate failed after 3 attempts.

Errors:
  [list specific errors]

Action required:
  Please review manually. Fix the issue and say
  "retry task [N]" to continue.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### 2f. Complete Task

Mark task `completed` (TaskUpdate). Show:

```
TASK [N] COMPLETE ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[title]
Files modified:  [list]
Files created:   [list]
Tests added:     [count]
Quality gate:    PASS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Progress: [N]/[TOTAL] tasks complete
```

Move to next task.

---

### Agent Teams Mode

**Only activate when user explicitly says "use agent teams" / "create a team" / "swarm this".**

If requested:
- Create an efficient agent team with worker teammates
- Assign each independent task (no `depends_on`) to a separate teammate
- Dependent tasks still run sequentially after their prerequisites
- Each teammate gets its own cold-start context brief: task title, files to read, implementation notes, CampX patterns
- All teammates use haiku model
- Quality gate runs per-task after each teammate completes

Do NOT proactively suggest agent teams — only use when explicitly requested.

---

### Step 3: Migration Safety Check

After all tasks complete, if ANY migration files were written:

```
MIGRATION FILES WRITTEN — Manual Run Required
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Files written (NOT run):
  1. {service}/src/migrations/{timestamp}-{name}.ts
  2. {service}/src/migrations/{timestamp}-{name}.ts

To run:
  cd {service} && yarn typeorm migration:run -d src/datasource.ts

⚠ NEVER auto-run migrations. Always confirm data + run manually.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### Step 4: Final Summary & Handoff

Run quality gate one final time across ALL affected services:

```bash
cd /Users/ramchanderpeddada/Desktop/CampX/{service1} && yarn test --passWithNoTests && yarn tsc --noEmit
cd /Users/ramchanderpeddada/Desktop/CampX/{service2} && yarn test --passWithNoTests && yarn tsc --noEmit
```

Show the execution report:

```
EXECUTION COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Plan:    [plan title]
Tasks:   [N]/[N] complete — ALL PASSED / [X] BLOCKED

  #  Status     Task                          Quality Gate
  1  COMPLETE   [title]                       PASS
  2  COMPLETE   [title]                       PASS
  3  BLOCKED    [title]                       FAIL (3 attempts)

Files modified:   [total count]
Files created:    [total count]
Tests added:      [total count]
Migrations:       [N] written (NOT run — manual execution required)

Final Quality Gate:
  Tests:      ✓ PASS
  TypeScript: ✓ PASS
  Lint:       ⚠ WARN ([N] warnings)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Ready to ship? Run: git diff  (review your changes first)
Then say "ship this" to invoke the ship skill.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Do NOT auto-invoke ship. The user decides when to ship.

---

## Red Flags - STOP

- "No plan, just start implementing" — STOP. Require a plan first. Run plan-epic or paste your plan.
- "Skip the quality gate" — NEVER. Quality gate runs after EVERY task, no exceptions.
- "Run the migration" — NEVER. Write the file only. Tell user to run manually.
- "Skip tests, add them later" — NEVER. Tests are written with each task.
- "Search the codebase for more context" — NEVER during execution. Trust the plan's file paths.
- "Run yarn dev to test it" — NEVER. Only build checks: `yarn test` and `yarn tsc --noEmit`.
- "3 quality gate failures — force through" — STOP. Ask user to review manually.

All of these mean: STOP and explain why the step cannot be skipped.

---

## Rules

1. NEVER execute without an approved plan — HARD-GATE enforced
2. NEVER search for files — read only what the plan lists
3. NEVER skip quality gate for any task — `yarn test` and `yarn tsc --noEmit` must pass per-task
4. NEVER run migrations — write the file only, user runs manually
5. NEVER run `yarn dev` or `yarn start` — only build checks
6. NEVER auto-invoke ship — user reviews and decides
7. Max 3 quality gate retry attempts per task — then STOP and ask

---

## Integration

- Called by: user after plan-epic approval ("execute the plan", "implement the plan", "start implementing")
- Calls: agent teams (haiku model workers) only if user explicitly requests
- Pairs with: `plan-epic` (produces the plan this skill consumes), `ship` (user invokes after execution)

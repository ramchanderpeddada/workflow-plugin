---
name: ship
description: "Use when user is done coding and wants to commit, push, and create a PR. Trigger on: done push it, ship it, ship this, commit and push, push this, create a PR, ready to ship, let's merge this, done coding, finished let's ship, create a pull request, merge this."
---

# Ship

**Announce:** "I'm using the ship skill to ship your changes."

## Overview

Quality gate → branch check → commit → push → PR with structured template. Never skip the quality gate.

## Workflow

### Step 1: Detect State

```bash
git rev-parse --show-toplevel
git branch --show-current
git status --porcelain
```

- Not a git repo → STOP
- Nothing to commit → "Nothing to ship — working tree is clean."
- Detached HEAD → STOP, ask user to checkout a branch

### Step 2: Branch Check

If on `main` or `master`:
```
You're on main/master. Create a feature branch first.
Branch name suggestion: feat/{short-description}
```
Ask user to confirm branch name or provide their own. Create and checkout.

### Step 3: Quality Gate

Run ALL checks. Report results as a table.

```bash
# Tests (hard block on failure)
yarn test --passWithNoTests 2>&1

# TypeScript (hard block on failure)
npx tsc --noEmit 2>&1

# Lint (warn, don't block)
yarn lint 2>&1
```

```
QUALITY GATE
━━━━━━━━━━━━━━━━━━━━
Tests:      PASS / FAIL (X tests, Y suites)
TypeScript: PASS / FAIL (X errors)
Lint:       PASS / WARN (X warnings)
━━━━━━━━━━━━━━━━━━━━
```

- Tests FAIL → STOP. "Fix tests before shipping."
- TypeScript FAIL → STOP. "Fix type errors before shipping."
- Lint WARN → Show warnings but continue.
- If no test command or test config → WARN: "No tests found. Proceeding without tests."

### Step 4: Generate Commit Message

Analyze the diff:
```bash
git diff --cached --stat
git diff --stat
```

Generate commit message format: `<type>(<scope>): <description>`

Types: `feat` | `fix` | `refactor` | `docs` | `test` | `chore` | `perf`

```
Proposed commit:
  feat(grades): add grade verification with audit trail

Accept? Or type your own:
```

### Step 5: Stage, Commit, Push

```bash
git add -A
git commit -m "<message>"
git push -u origin <branch>
```

If push fails (remote ahead):
```
Push failed. Run: git pull --rebase origin <branch>
Then retry shipping.
```

### Step 6: Extract Issue Number

From branch name:
1. `feat/123-description` → `Closes #123`
2. `fix/456-description` → `Closes #456`
3. No number → ask: "What issue does this close? (#N or 'none')"

### Step 7: Create PR

Ask: "Create pull request? (yes/no)"

If yes:

```bash
gh pr create \
  --title "<commit-message>" \
  --body "<PR template below>" \
  --assignee @me
```

**PR Template:**

```markdown
## What
[2-3 sentences: what changed and why]

## Changes
- `file/path` — what changed
- `file/path` — what changed

## Type
- [ ] Feature
- [ ] Bug fix
- [ ] Refactor
- [ ] Docs
- [ ] Chore

## Testing
- [ ] Tests pass
- [ ] TypeScript clean
- [ ] Manually verified: [what was tested]

## Review Notes
[Anything the reviewer should pay attention to — tricky logic, edge cases, decisions made]

## Screenshots
[If UI changes — before/after]

Closes #N
```

### Step 8: Done

```
SHIPPED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Branch:  <branch>
Commit:  <message>
PR:      <pr-url>
Closes:  #N
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Red Flags - STOP

- "Skip tests, just ship" — NEVER skip quality gate
- "Force push" — NEVER force push without explicit user confirmation
- "Ship to main directly" — Always create a branch first

## Rules

1. NEVER skip quality gate — tests and tsc MUST pass
2. NEVER force push unless user explicitly says "force push"
3. NEVER commit to main/master directly
4. ALWAYS ask before creating PR
5. If tests or tsc fail — STOP and tell user to fix

## Integration

- Called by: user says "ship this" / "commit and push" etc.
- Calls: nothing
- Pairs with: Superpowers verification-before-completion (runs before ship)

---
name: plan-epic
description: "Use proactively when user wants to plan or design a feature, epic, or implementation. Trigger on: plan this feature, I need to build X, we need to add X, plan this issue, GitHub issue URL pasted, break this down, what do we need to build, plan this for me, new feature for, plan this issue, how should we implement, design this, architect this. Do NOT use for data fixes (use triage-ticket) or blast radius checks (use check-impact)."
---

# Plan Epic

**Announce:** "I'm using the plan-epic skill to fetch, analyze, and plan this issue."

## Overview

Fetch a GitHub issue or epic, parse its structure (task lists, linked issues, acceptance criteria), explore the codebase for affected services, ask clarifying questions, and produce a structured implementation plan written to plan mode.

<HARD-GATE>
NEVER start implementation. This skill produces a PLAN ONLY. If the user wants to implement, they exit plan mode and work from the plan. No code edits, no file creation (except the plan file).
</HARD-GATE>

## When to Use

- User pastes a GitHub issue URL (`github.com/campx-org/*/issues/N`)
- User says "plan this issue", "plan epic", "plan issue #N", "plan this feature", "analyze this epic"
- User pastes issue body containing task lists (`- [ ]` items) or linked issues (`#N`)
- Issue has label "epic" or "enhancement" with multiple sub-tasks

### When NOT to Use

- Support tickets / data fixes → `triage-ticket`
- Blast radius / impact analysis → `check-impact`
- Schema exploration only → `explore-schema`
- Ready to ship code → `ship`
- Single small bug with a clear fix → just fix it

---

## Workflow

### Step 1: Fetch the Issue

**If GitHub URL provided:**
Extract org, repo, and issue number from the URL pattern `github.com/{org}/{repo}/issues/{N}`.

```bash
gh issue view {N} --repo {org}/{repo} --json title,body,labels,assignees,milestone,comments
```

**If issue number only (no URL):**
Try repos in CampX search order until one returns results:

```bash
gh issue view {N} --repo campx-org/campx-exams-server --json title,body,labels,comments
gh issue view {N} --repo campx-org/campx-api-gateway --json title,body,labels,comments
gh issue view {N} --repo campx-org/campx-exams-web --json title,body,labels,comments
gh issue view {N} --repo campx-org/exam-configurations --json title,body,labels,comments
gh issue view {N} --repo campx-org/campx-evaluator-web --json title,body,labels,comments
gh issue view {N} --repo campx-org/reports-forge-server --json title,body,labels,comments
```

**If pasted text / no URL:**
Use the pasted content directly. Skip to Step 2.

---

### Step 2: Parse Issue Structure

Extract from the issue body:

1. **Task list items** — lines matching `- [ ]` or `- [x]` pattern
2. **Linked issues** — references matching `#N`, `org/repo#N`, or full `github.com/.../issues/N` URLs
3. **Acceptance criteria** — section under "Acceptance Criteria", "AC", or "Definition of Done" heading
4. **Technical requirements** — section under "Technical", "Implementation Notes", or similar
5. **Constraints** — deadlines, backward compat notes, tenant-specific notes

**If linked issues found — fetch ALL of them:**
```bash
gh issue view {N} --repo campx-org/{repo} --json title,body,labels
```

Compile everything into an EPIC STRUCTURE card:

```
EPIC STRUCTURE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Title:  [epic title]
Repo:   [org/repo]
Labels: [labels]

Sub-tasks:
  1. [ ] #N — [title] ([labels])
  2. [ ] #M — [title] ([labels])
  3. [ ] [inline task from body, no issue link]

Acceptance Criteria:
  - [criterion 1]
  - [criterion 2]

Constraints:
  - [constraint or "none found"]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### Step 3: Classify & Identify Services

**Classify the epic type:**
- Feature (new capability)
- Enhancement (extend existing behavior)
- Bug fix (fix broken behavior)
- Refactor (restructure without behavior change)
- Infrastructure (CI/CD, config, tooling)
- Data migration (schema changes, data backfill)

**Identify affected services** by scanning issue title, body, and labels for keywords:

| Keywords in issue | Service |
|-------------------|---------|
| exam, marks, grade, moderation, GPA, memo, transcript, revaluation, grafting, grace | campx-exams-server |
| route, gateway, proxy, auth middleware, API route registration | campx-api-gateway |
| exam UI, student portal, exam page, result page, student-facing | campx-exams-web |
| config, settings, exam configuration, exam setup | exam-configurations |
| evaluator, answer sheet, evaluation, valuator | campx-evaluator-web |
| report, PDF, template, forge, mark sheet | reports-forge-server |
| admin, tenant management, admin portal | campx-admin-server |
| LMS, course, assignment, attendance, learning | campx-lms-server |
| payment, fee, transaction, challan | campx-paymentx-server |
| tenant, multi-tenant, institution setup | campx-tenant-server |

If no clear service match, ask: "Which service does this epic belong to?"

---

### Step 4: Codebase Exploration (ONE Explore subagent)

Launch ONE Explore subagent (haiku model), scoped to the primary service only. Never search the entire `~/Desktop/CampX/` root. Never spawn multiple subagents.

**Single Explore Agent**
Scope: `/Users/ramchanderpeddada/Desktop/CampX/{primary-service}/src/`

```
Search for:
1. Entity files matching keyword: grep -r "class.*Entity" src/domain/ --include="*.ts" -l
2. Related service files: grep -r "{keyword}" src/ --include="*.service.ts" -l
3. Controller endpoints: grep -r "{keyword}" src/ --include="*.controller.ts" -l
4. Existing DTOs: grep -r "{keyword}" src/ --include="*.dto.ts" -l
5. Recent migrations (latest 5): ls -t src/migrations/ | head -5
6. Frontend pages (if applicable): grep -r "{keyword}" {frontend}/src/pages/ --include="*.tsx" -l 2>/dev/null
7. Gateway routes: grep -r "{keyword}" campx-api-gateway/src/ --include="*.ts" -l 2>/dev/null

Report: entity names, service methods, endpoint paths, frontend pages found.
```

---

### Step 5: Clarifying Questions

Based on issue content AND codebase findings, ask targeted questions. Scale to epic size:

- **Small (1-3 sub-tasks):** 3-5 questions
- **Medium (4-7 sub-tasks):** 5-7 questions
- **Large (8+ sub-tasks):** 7-10 questions

Question categories:
- **[SCOPE]** What's explicitly in/out? Which portals? All tenants or specific?
- **[PRIORITY]** Which sub-tasks are blocking? What's the delivery order?
- **[EDGE CASE]** What happens with existing data? Backward compat requirements?
- **[UNKNOWN]** Things the issue doesn't specify but codebase exploration revealed
- **[DEPENDENCY]** Sub-tasks blocked by other teams, services, or pending PRs?

Frame questions with codebase context:
```
Based on the issue and codebase analysis, I have [N] questions before planning:

1. [SCOPE] The issue mentions X, but I found an existing implementation at
   {file-path}:line that already handles Y. Should we extend it or replace it?

2. [PRIORITY] Sub-tasks #A, #B, #C — what's the implementation order?
   I see #B depends on the entity changes from #A.

3. [EDGE CASE] Are there tenants already using this feature in production?
   I found a tenant-config check at {file-path} that may need updating.
```

Wait for answers before generating the plan.

---

### Step 6: Plan Generation

After answers are received, compile all context and write the implementation plan to the plan mode file.

```
============================================================
IMPLEMENTATION PLAN: [Epic Title]
Issue: [URL or campx-org/{repo}#N]
Generated: [YYYY-MM-DD]
============================================================

## Context
[Why this change exists — 2-3 sentences from the issue and clarifications]

## Scope
Building:      [items confirmed in scope]
NOT building:  [items explicitly out of scope]
Services:      [list of affected services]
Portals:       [student / evaluator / admin / none]
Tenants:       [all / specific list / N/A]

------------------------------------------------------------

## Clarifications
[Summary of user answers from Step 5 — key decisions made]

------------------------------------------------------------

## Task Breakdown

### Task 1: [Title] (sub-issue #N or inline task)
Type:       entity change / endpoint / frontend / migration / config
Service:    [service name]
Depends on: none / Task N
Effort:     S (<2hr) / M (2-4hr) / L (4-8hr) / XL (>8hr)

Files to modify:
  - `{service}/src/path/to/file.ts` — [what changes and why]
  - `{service}/src/path/to/file.ts` — [what changes and why]

Existing code to reuse:
  - `{service}/src/path/to/existing.ts` — [function/pattern to follow]

Implementation notes:
  - [Specific guidance from codebase exploration]
  - [Patterns to follow, guard patterns, DTO conventions]

### Task 2: [Title]
[same structure]

------------------------------------------------------------

## Schema Changes
(omit section if no DB changes)

Migration file: `{TIMESTAMP}-{description}.ts` in `{service}/src/migrations/`
Always include down() method.

```sql
-- Table: [name]
-- New columns:
ALTER TABLE [table] ADD COLUMN [col] [TYPE] [constraints];

-- New table (if applicable):
CREATE TABLE [name] (
  id INT AUTO_INCREMENT PRIMARY KEY,
  ...
);
```

------------------------------------------------------------

## API Changes
(omit section if no new endpoints)

| Method | Path | Guard | Request DTO | Response |
|--------|------|-------|-------------|----------|
| POST | /api/v1/... | JwtAuthGuard | { field: type } | { field: type } |

------------------------------------------------------------

## Testing Strategy

Unit Tests:
  - [ ] [Scenario] — `{service}/src/path/file.spec.ts`

Integration Tests:
  - [ ] [Scenario — e2e or API-level]

Manual Verification:
  1. [Step-by-step check]
  2. [Expected result]

------------------------------------------------------------

## Dependency Order

```
Task 1 (entity + migration)
  └──→ Task 2 (service logic)
        ├──→ Task 3 (controller / API endpoint)
        └──→ Task 4 (frontend page / component)
              └──→ Task 5 (integration test)
```

------------------------------------------------------------

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [risk] | Low/Med/High | Low/Med/High | [how to mitigate] |

------------------------------------------------------------

## Services to Run Locally for Testing

| Repo | Command | Why |
|------|---------|-----|
| {service} | yarn start:dev | [what it provides] |

------------------------------------------------------------

## Effort Summary

| Task | Effort |
|------|--------|
| Task 1 | S/M/L/XL |
| ... | ... |
| **Total** | **[sum]** |

============================================================
```

---

### Step 7: Iterate or Proceed

After presenting the plan:

- **User approves** → Plan is locked. User exits plan mode to implement.
- **User modifies** → Incorporate changes, update the plan file, confirm.
- **User rejects** → Discuss issues, identify gaps, re-plan from Step 5.

---

## Red Flags - STOP

- "Just start coding, skip the plan" — NEVER. This skill produces plans only. Tell the user: "Exit plan mode to implement."
- "Skip the codebase exploration, I know what's affected" — NEVER skip. CampX has 10+ services; undiscovered dependencies break things.
- "Search everything at once" — NEVER search `~/Desktop/CampX/` root. Scope to identified service directories.
- "Don't bother asking questions" — NEVER skip Step 5. Questions surface scope gaps before work begins, not after.

All of these mean: STOP and explain why the step cannot be skipped.

---

## Rules

1. NEVER write code or make edits — plan output ONLY
2. NEVER skip Step 4 codebase exploration — always launch subagents before generating the plan
3. NEVER search the entire `~/Desktop/CampX/` root — scope to service directories
4. ALWAYS fetch linked/child issues — epics are incomplete without their sub-tasks
5. ALWAYS ask clarifying questions (Step 5) before generating the plan (Step 6)
6. ALWAYS include absolute file paths in the task breakdown
7. Use haiku model for Explore subagents, opus for any planning subagent — no exceptions

---

## Integration

- Called by: user directly (GitHub URL pasted, "plan this issue", "plan epic", "plan issue #N")
- Calls: Explore subagents (haiku, 2-3 parallel in Step 4)
- Pairs with: `explore-schema` (deeper entity FK tracing), `check-impact` (blast radius for risky changes in the plan)

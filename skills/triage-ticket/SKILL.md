---
name: triage-ticket
description: "Investigates and resolves CampX support tickets and data issues. Use PROACTIVELY when user says: 'I got a ticket', 'support ticket', 'student can't see', 'wrong data', 'wrong marks', 'wrong grades', 'wrong branch', 'someone reported', 'client reported', 'data fix', 'data issue', 'triage this', pastes a campx.frappe.cloud link, or reports any student/tenant data problem. Fetches ticket from Frappe or GitHub, classifies severity, finds matching z-migration, reads affected entities, generates verification SQL queries — all in one pass."
---

# Triage Ticket

**Announce:** "I'm using the triage-ticket skill to classify and route this ticket."

## Overview

Route incoming support tickets and data issues to the right response path. For data fixes: auto-match z-migrations, generate verification SQL/MongoDB queries, and guide the fix lifecycle through to closure.

<HARD-GATE>
Steps 3a through 3d MUST ALL run automatically in one pass. Do NOT stop after finding the z-migration and wait for user to ask for queries. The user expects: z-migration match + entity reading + verification queries ALL in one response.
</HARD-GATE>

## When to Use

- User mentions any data-fix keyword (see description)
- User pastes a Frappe ticket link (campx.frappe.cloud)
- User pastes a GitHub issue that describes a data problem
- User says "got a support ticket" or "triage this"

### When NOT to Use

- Planned feature work → Superpowers brainstorming handles this
- Code bugs without data issues → Superpowers systematic-debugging
- Creating GitHub issues → Spec Kit /speckit.taskstoissues or gh CLI

## Workflow

### Step 1: Read the Ticket

- **If Frappe link** → fetch via MCP: `mcp__claude_ai_campx-hd__get_document`
- **If GitHub issue** → `gh issue view {number} --repo campx-org/{repo} --json title,body,labels,comments`
- **If pasted text** → use directly

Extract: what user/tenant reported, affected entity/data, expected vs actual behavior, error messages.

### Step 2: Classify Severity

**CRITICAL** (any true): student exam in progress AND cannot submit, payment charged but enrollment failed, student data deleted/corrupted, all users in tenant blocked, security breach.

**HIGH** (any true, no CRITICAL): wrong data displayed, core feature broken for 1+ tenants, exam process blocked for batch/semester.

**MEDIUM:** cosmetic issue, feature works with extra steps, non-essential feature unavailable.

**LOW:** enhancement disguised as bug, feature request. → Recommend backlog.

**Tie-breaker:** If LOW/MEDIUM but blocks a time-sensitive event (exam, graduation, fee deadline) → escalate one level.

Announce: `Severity: [LEVEL] — [1-line reason]`

### Step 3: Check Codebase (ALL AUTO — One Pass)

#### 3a. Search z-migrations

Search BOTH servers using absolute paths:

```bash
find /Users/ramchanderpeddada/Desktop/CampX/campx-exams-server/src/z-migrations -name "*.ts" 2>/dev/null
find /Users/ramchanderpeddada/Desktop/CampX/campx-square-server/src/z-migrations -name "*.ts" 2>/dev/null
```

Known patterns:

- Branch change → `student-branch-change.ts`
- Missing registrations → `student-course-registration.ts`
- Internal exam records → `remove-internal-registrations.ts` / `restore-internal-records.ts`
- Grade deletion → `student-grade-deletion.ts`
- Barcode mapping → `external-barcode-mapping.ts`
- Subject code → `subject-code-update.ts` (square-server)

#### 3b. Search Affected Service

Find the relevant entity/module. Check for feature flags or tenant-specific config.

#### 3c. If No Z-Migration Exists

Tell user: "No existing z-migration matches. Here's the pattern to create one:" → show template from an existing similar script.

#### 3d. Generate Verification Queries (AUTO — Do NOT Wait)

**Process:**

1. Identify affected entity from ticket keywords
2. Search: `grep -r "class.*Entity" src/domain/` for entity names
3. Read entity file → get table name, columns, @ManyToOne/@JoinColumn
4. Trace FK chain by reading related entity files
5. Generate SELECT queries for MySQL Workbench:

```
VERIFICATION QUERIES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Query 1: Check the reported record
-- [explain what this checks]
SELECT [columns]
FROM [table] t
JOIN [related_table] r ON t.fk_column = r.id
WHERE t.[identifier] = '[value from ticket]';

Query 2: Check related records
-- [explain what this checks]
SELECT [columns] FROM [related_table] WHERE [condition];

Query 3: Verify expected state
-- [what correct data should look like]
SELECT [columns] FROM [table] WHERE [condition];

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Run these in MySQL Workbench and paste results back.
```

For MongoDB data: `db.collection.find({ key: "value" }).pretty()`

### Step 4: Triage Card

```
┌─────────────────────────────────────────────┐
│ TRIAGE: [summary]                            │
├─────────────────────────────────────────────┤
│ Severity: [CRITICAL/HIGH/MEDIUM/LOW]         │
│ Type: [data fix / code bug / config / gap]   │
│                                              │
│ RECOMMENDATION: [one of below]               │
│                                              │
│ HOTFIX (z-migration)                         │
│   z-migration: [filename] or "none — new"    │
│   What to do: [specific steps]               │
│   ETA: immediate / < 1hr                     │
│                                              │
│ — OR —                                       │
│                                              │
│ SPRINT TASK                                  │
│   Why not hotfix: [reason]                   │
│   Scope: S / M / L                           │
│                                              │
│ — OR —                                       │
│                                              │
│ NEEDS BRD                                    │
│   Why: [too complex / cross-service]         │
└─────────────────────────────────────────────┘
```

### Step 5: Act on User Decision

**"hotfix" / "go ahead"** → Step 5b: Data Fix Execution

#### Step 5b: Data Fix Execution

1. Read the z-migration file completely
2. Show the data array structure to fill
3. Pre-fill with values from the ticket
4. Generate PRE-FIX verification SQL
5. Tell user: "Run these in MySQL Workbench, paste results"
6. After user pastes → confirm: "Yes, N records match — [description]"
   OR: "Data doesn't match — investigate further"
7. Show execution checklist:
   - [ ] Fill data array with confirmed values
   - [ ] Uncomment `onModuleInit()`
   - [ ] Deploy to target environment
   - [ ] Run POST-FIX verification SQL
   - [ ] Re-comment `onModuleInit()`
   - [ ] Push re-commented code
8. Generate Frappe closing comment:
   ```
   Issue: [summary] | Verified: [query] | Fix: [z-migration] | Status: Resolved
   ```

**"create issue"** → use gh CLI to create GitHub issue with ticket context

**"investigate more"** → search deeper, re-triage

## Red Flags - STOP

- "I'll just manually fix the database" — Never. Always use z-migration.
- "This looks like a code bug not data" — Re-route to Superpowers systematic-debugging.
- "I'll skip the verification queries" — Never. Always verify before AND after.

All of these mean: STOP and re-evaluate before proceeding.

## Rules

1. NEVER run z-migrations — only show what to fill and what command to run manually
2. NEVER guess the fix if unsure — flag as "needs investigation"
3. Always check BOTH exams-server AND square-server z-migrations
4. CRITICAL tickets = skip sprint queue, always hotfix or escalate
5. Always generate verification queries in the SAME response as the triage card

## Integration

- Called by: user directly (auto-triggered on data keywords)
- Calls: nothing (standalone)
- Pairs with: Superpowers finishing-a-development-branch (if code fix needed after data fix)

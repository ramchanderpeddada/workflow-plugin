---
name: check-impact
description: Use when user wants to understand the impact or risk of a code change. Fire on natural phrases like: "before I change X", "is it safe to change", "what's affected by", "I want to modify X what breaks", "will this break anything", "checking before refactor", or trigger phrases: "what breaks if", "check impact", "blast radius", "what does this affect", "impact of changing", "dependencies of", "safe to refactor". Also auto-activate when user mentions changing exam pipeline entities: moderation, grace, grafting, grading, GPA, memo, transcript. Do NOT use for general exploration — use explore-schema.
---

# Check Impact

**Announce:** "I'm using the check-impact skill to trace the blast radius of this change."

## Overview

Trace the blast radius of a change across the CampX exam pipeline. Uses a hardcoded 9-stage DAG to identify downstream impacts, affected tenants, and critical scenarios.

## When to Use

- User asks "what breaks if I change X"
- User asks about blast radius of a change
- Detecting changes to exam pipeline files (moderation, grace, grafting, grading, GPA)
- Before major refactoring of shared entities

### When NOT to Use

- General schema exploration → use `explore-schema`
- Understanding what a file does → just read it
- Planning a new feature → Superpowers brainstorming

## Exam Pipeline DAG (9 Stages)

```
Stage 0: Raw Marks Entry
    ↓
Stage 1: Moderation (internal marks adjustment)
    ↓
Stage 2: Grace Marks (policy-based additions)
    ↓
Stage 3: Grafting (cross-subject adjustments)
    ↓
Stage 4: Grading (letter grade assignment)
    ↓
Stage 5: GPA Calculation
    ↓
Stage 6: Memo Generation (grade cards)
    ↓
Stage 7: Transcript Generation
    ↓
Stage 8: Publishing (results portal)
```

**Key rule:** Changes to Stage N affect ALL stages N+1 through 8.

## Workflow

### Step 1: Identify What's Changing

Ask: "What entity/file/module is changing?" if not clear from context.

Map the change to a pipeline stage (or "non-pipeline" if it doesn't touch the DAG).

### Step 2: Trace Downstream (Parallel Search)

Spawn 4 Explore subagents (haiku model) in parallel:

1. **DB Impact** — search for FK references, CASCADE rules, JOIN queries involving the changed entity
2. **Service Impact** — search for service methods that consume data from the changed module
3. **Frontend Impact** — search React components that display data affected by the change
4. **Pipeline Impact** — trace the DAG: list all stages from N+1 to 8 that would be affected

### Step 3: Tenant Scope Check

Determine if this change affects:
- All tenants (schema change, shared logic)
- Specific tenants (tenant-config-gated feature, specific exam type)
- No tenant impact (internal refactor)

### Step 4: Generate Impact Report

```
IMPACT REPORT: [Change Description]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Pipeline Stage: [N] — [Stage Name]
Downstream Stages Affected: [N+1] through [8]

DB Impact:
  - [table] — [FK/CASCADE relationship]
  - [table] — [affected by JOIN]

Service Impact:
  - [service.method()] — [what it does with this data]
  - [service.method()] — [what it does]

Frontend Impact:
  - [component] — [what it displays]

Tenant Scope: [All / Specific / None]

CRITICAL SCENARIOS:
  ⚠ What if moderation already ran and this re-runs it?
  ⚠ What if grades are published and this changes retroactively?
  ⚠ What if GPA is calculated and formula changes?

RECOMMENDATION:
  [Safe to proceed / Needs migration plan / Needs staging test first]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 5: Special Scenarios (Exam Pipeline Only)

Always check these if pipeline stages are affected:
- What if moderation already ran and this re-runs it?
- What if grafting ran but the formula changes?
- What if GPA is published and calc method changes retroactively?
- What if results are on the portal and marks change?
- Revaluation flow: does this change break re-evaluation?

## Red Flags - STOP

- "This only affects one table" — Check FKs. CampX entities are deeply connected.
- "No downstream impact" — Verify by actually searching, don't assume.
- "We can fix it after deploy" — If it touches published results, you can't.

All of these mean: STOP and verify before claiming safe.

## Integration

- Called by: user directly (auto-triggered on "blast radius", "what breaks")
- Calls: Explore subagents (haiku, 4 parallel)
- Pairs with: explore-schema (for deeper entity relationship mapping)

# Workflow Plugin

Professional agentic workflow for Claude Code: **5 agents**, **7 skills**, **quality hooks**.

Speak naturally — agents route automatically to the right workflow.

## What's Inside

### 5 Specialized Agents

- **planner** — Plan features, epics, GitHub issues. Asks clarifying questions, searches for precedent, produces structured plans with file paths and effort estimates.
- **builder** — Implement approved plans. Writes code following NestJS patterns, generates migrations, writes tests (80%+ coverage target).
- **triage** — Handle support tickets and data issues. Classifies severity, finds z-migrations, generates verification SQL in one pass.
- **impact** — Analyze blast radius before risky changes. Uses 9-stage exam pipeline DAG, searches for DB/service/frontend/pipeline impacts in parallel.
- **shipper** — Run quality gate (tests + tsc + lint), then commit, push, and create a PR. Never commits to main.

### 7 Skills

Preloaded into agents — always available, fire on natural language triggers:

- **plan-epic** — Create structured plans for features and tasks
- **execute-plan** — Implement from approved plans
- **triage-ticket** — Classify and route support tickets
- **check-impact** — Trace blast radius of code changes
- **explore-schema** — Map database relationships
- **ship** — Quality gate + commit + push + PR
- **switch-env** — Switch environment configuration

### 4 Commands

Quick slash-shortcuts for manual workflows:

- `/workflow:plan [description]` — Invoke planner
- `/workflow:triage [description]` — Invoke triage
- `/workflow:ship` — Invoke quality gate
- `/workflow:save-session` — Save session state

### Quality Hooks

Security-first hooks auto-enforced:

- **PreToolUse** — Block writes to .env, credentials, secret files
- **PreCompact** — Auto-save session state before compaction

## Installation

```bash
claude plugin install https://github.com/ramchanderpeddada/workflow-plugin
```

## Usage

### Plan a Feature

Just say: "I need to build a fee reminder system" → planner announces and asks clarifying questions → produces a structured plan.

### Implement a Plan

After plan is approved: "build it" → builder announces, implements per the plan, writes tests, creates PR.

### Triage a Ticket

"Got a ticket about wrong marks" → triage announces, classifies severity, finds z-migrations, generates SQL verification queries.

### Check Impact

Before refactoring: "is it safe to change moderation logic" → impact announces, traces 9-stage pipeline, shows downstream effects.

## Architecture

- **Single Git repo** — versioned, shareable
- **Agents with system prompts** — Opus for planning, Sonnet for building/triage/impact, Haiku for shipping
- **Skills preloaded** — no manual invocation needed, fire on natural phrases
- **Memory enabled** — agents remember user context across sessions
- **Professional hooks** — security + quality enforced automatically

## Version

4.0.0 — Initial plugin architecture.

---

Built for professional agentic workflows.

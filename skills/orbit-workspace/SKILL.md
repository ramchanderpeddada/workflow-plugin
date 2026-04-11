---
name: orbit-workspace
description: "Use PROACTIVELY at the start of every new CampX feature, task, or bug fix. Trigger on: 'new feature', 'new task', 'I want to build', 'start work on', 'new bug fix', 'I need to', 'we need to add', 'build X', 'fix X in campx'. Asks branch + repos + env before brainstorming. Outputs orbit new command. Waits for workspace to be up before reading code."
---

# Orbit Workspace

**Announce:** "Let me set up the workspace before we start."

## Overview

Every CampX task starts with an Orbit workspace. This skill collects branch name, repos, and env — outputs the `orbit new` command — waits for confirmation — then reads the workspace CLAUDE.md and begins brainstorming/planning with full code context.

<HARD-GATE>
Do NOT start brainstorming, planning, or reading any code until:
1. You have branch name, repos, and env from the user
2. You have output the orbit new command
3. The user has confirmed the workspace is running
</HARD-GATE>

## Workflow

### Step 1: Ask branch + repos + env

Ask ALL THREE in one message:

```
Before we start — three things:

1. Branch name? (e.g. feat/new-report, fix/grade-bug, chore/cleanup)
2. Repos? (e.g. campx-exams-server, reports-forge-server, campx-api-gateway, reports-forge-web)
3. Env? local-dev / local-prod / dev / prod  [default: local-dev]
```

Wait for the user's answer. Do NOT ask one at a time.

### Step 2: Output orbit new command

Once you have all three, output:

```bash
orbit new <branch> \
  --repos <repo1>,<repo2>,<repo3> \
  --env <env> \
  --desc "<short description of what we're building>"
```

Then say:
```
Run that and let me know when services are up.
```

### Step 3: Wait for confirmation

Wait for the user to say something like "done", "up", "running", "ready", "services started".

Do NOT proceed until confirmed.

### Step 4: Read workspace context

Once confirmed, read:
```
~/Desktop/launchpad/<branch-as-folder>/CLAUDE.md
```

Where branch `feat/new-report` → folder `feat-new-report` (slash → hyphen).

The CLAUDE.md contains: branch, env, port map, and merged rules from all repo CLAUDE.md files.

### Step 5: Confirm and start

Tell the user:
```
Workspace ready. I can see:
- [list services and ports from CLAUDE.md]
- Env: [env]

Let's build. What exactly do we need?
```

Then invoke `superpowers:brainstorming` to start the design process.

## Rules

1. NEVER skip the workspace setup — every CampX task needs a workspace
2. NEVER start brainstorming before workspace is confirmed up
3. ALWAYS read the workspace CLAUDE.md before starting — it has repo rules
4. If user already has a workspace running (they mention a branch/path), skip to Step 4

## Integration

- Called by: auto-triggered on new feature/task keywords
- Calls: superpowers:brainstorming after workspace is confirmed
- Pairs with: orbit pr (when shipping), orbit destroy (after PR merges)

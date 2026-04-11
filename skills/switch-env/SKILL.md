---
name: switch-env
description: "Switches CampX backend environment config using merge-env.sh. Use PROACTIVELY when user says: 'switch env', 'switch to staging', 'switch to prod', 'switch to dev', 'change environment', 'use staging', 'use production', 'point to prod', 'point to staging'. Do NOT use for frontend env changes or Docker config."
---

# Switch Env

**Announce:** "I'm using the switch-env skill to switch to [environment]."

## Overview

Safely switch environment configuration across CampX backend services using the merge-env.sh script. Includes safety checks and service restart reminders.

<HARD-GATE>
NEVER modify .env files directly. ALWAYS use merge-env.sh. This is a safety rule — direct .env edits are blocked by the security hook.
</HARD-GATE>

## When to Use

- User says "switch to staging" / "switch to prod" / "switch to dev"
- User says "switch env" or "change environment"

### When NOT to Use

- Frontend env changes → those use different config files
- Docker environment → different mechanism
- Setting a single env var → just tell the user

## Workflow

### Step 1: Confirm Target Environment

If not specified, ask:

```
Which environment? (dev / staging / prod)
```

### Step 2: Safety Check

**If switching to prod:**

```
⚠️ PRODUCTION ENVIRONMENT
- All API calls will hit production data
- Any database operations affect real users
- Are you sure? (yes/no)
```

### Step 3: Run merge-env.sh

```bash
./merge-env.sh [environment]
# or
/Users/ramchanderpeddada/Desktop/CampX/merge-env.sh [environment]
```

Show the output to user.

### Step 4: Remind About Services

```
Environment switched to [env].

⚠️ RESTART REQUIRED:
Services using the old env are still running with old config.
Restart any running services manually:
  - Kill running yarn dev processes
  - Restart the services you need
```

### Step 5: Verify

```bash
# Show current env to confirm
cat .env | grep -E "DB_HOST|API_URL|NODE_ENV" | head -5
```

## Red Flags - STOP

- "Just edit the .env directly" — NEVER. Use merge-env.sh only.
- "Switch to prod for testing" — Warn strongly. Suggest staging instead.

## Integration

- Called by: user directly or auto-triggered on env switch keywords
- Calls: nothing
- Pairs with: nothing

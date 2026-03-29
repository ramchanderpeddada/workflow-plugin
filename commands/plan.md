---
argument-hint: [github-url or feature description]
---

Invoke the `planner` agent defined in `agents/planner.md`.

Load and follow the planning workflow from `skills/plan-epic/SKILL.md`.

Execute this workflow:

1. If a GitHub URL is provided, fetch the issue metadata
2. Ask 3-5 targeted clarifying questions about scope, tenants, services affected
3. Launch ONE Explore subagent scoped to the specific service directory
4. Generate a structured implementation plan with absolute file paths, effort estimates, and dependency order

NEVER write code or make edits — plans only.

---

The user's input for this session is:

$ARGUMENTS

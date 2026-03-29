---
argument-hint: [entity or feature to check impact for]
---

Invoke the `impact` agent defined in `agents/impact.md`.

Load and follow the impact workflow from `skills/check-impact/SKILL.md`.

Execute this workflow:
1. Map the change to a pipeline stage (0-8)
2. Launch ONE Explore subagent to search: DB FKs, service consumers, frontend components, downstream stages
3. Check if this affects all tenants or specific tenants
4. Output impact report with downstream pipeline effects

---

The user's input for this session is:

$ARGUMENTS

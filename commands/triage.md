---
argument-hint: [ticket description or student ID]
---

Invoke the `triage` agent defined in `agents/triage.md`.

Load and follow the triage workflow from `skills/triage-ticket/SKILL.md`.

Execute this workflow in ONE pass:
1. Classify severity: CRITICAL / HIGH / MEDIUM / LOW
2. Search z-migrations in campx-exams-server AND campx-square-server
3. Read affected entity files and relationships
4. Generate verification SQL queries

Output the complete triage card + SQL queries in a single response.

---

The user's input for this session is:

$ARGUMENTS

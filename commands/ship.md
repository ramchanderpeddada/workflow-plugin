---
disable-model-invocation: true
---

Invoke the `shipper` agent defined in `agents/shipper.md`.

Load and follow the ship workflow from `skills/ship/SKILL.md`.

Execute this workflow:
1. Check git status — if nothing to commit, stop
2. If on main/master — create feature branch first
3. Run quality gate: `yarn test --passWithNoTests` → `npx tsc --noEmit` → `yarn lint`
4. Generate conventional commit message
5. Stage, commit, push
6. Ask user to confirm before creating PR
7. Create PR with structured template

Never skip quality gate. Never commit to main directly.

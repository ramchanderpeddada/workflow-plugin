---
argument-hint: [optional: specific task to implement]
---

Invoke the `builder` agent defined in `agents/builder.md`.

Load and follow the implementation workflow from `skills/execute-plan/SKILL.md`.

Execute implementation in this order:

1. Read existing code — match patterns in the service
2. Entity changes (TypeORM)
3. Migration file — WRITE ONLY, never run
4. DTOs — class-validator, no `any`
5. Service methods — try/catch on all async
6. Controller — @UseGuards(JwtAuthGuard)
7. Module — register providers
8. Tests — 80%+ coverage

---

The user's input for this session is:

$ARGUMENTS

# CampX Exam Pipeline — 9-Stage DAG

## Stage Definitions

| Stage | Name | What It Does | Key Entity |
|-------|------|-------------|------------|
| 0 | Raw Marks Entry | Faculty enters internal/external marks | StudExternal, StudInternal |
| 1 | Moderation | Adjusts internal marks per policy | ModerationConfig |
| 2 | Grace Marks | Adds grace marks per institution rules | GraceMarksConfig |
| 3 | Grafting | Cross-subject mark adjustments | GraftingConfig |
| 4 | Grading | Assigns letter grades (O, A+, A, B+...) | GradingConfig, StudentGrade |
| 5 | GPA Calculation | SGPA + CGPA computation | StudentGPA |
| 6 | Memo Generation | Produces grade cards / memos | MemoTemplate |
| 7 | Transcript Generation | Official academic transcripts | TranscriptTemplate |
| 8 | Publishing | Results visible on student portal | PublishConfig |

## Dependency Rules

- Changes to Stage N affect ALL stages N+1 through 8
- Stage 0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 (strictly sequential)
- Each stage reads output of previous stage
- Revaluation can re-trigger stages 0-5

## Tenant Logic

Each tenant can have different:
- Grading scale (10-point, 7-point, pass/fail)
- Grace marks policy (fixed, percentage, conditional)
- Moderation formula
- GPA calculation method (weighted, unweighted)
- Memo/transcript template

## Critical Revaluation Flows

1. Student requests revaluation → re-enters Stage 0
2. Re-runs Stage 1-5 for affected subjects
3. If GPA changes → regenerate memo (Stage 6)
4. If already published → must handle portal update (Stage 8)

## Common Support Scenarios

- "Wrong marks after moderation" → Stage 1 issue
- "Grace marks not applied" → Stage 2 config issue
- "Wrong letter grade" → Stage 4 grading scale issue
- "GPA calculation wrong" → Stage 5 formula issue
- "Old marks showing on portal" → Stage 8 cache/publish issue

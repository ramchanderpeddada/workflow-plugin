---
name: explore-schema
description: "Use when user wants to understand database schema, entity relationships, or table structure. Trigger on: what tables are involved, explore schema, what's the schema for, entity relationships, FK chain, what entities are related, schema for this feature, what does this entity look like, map the database."
context: fork
---

# Explore Schema

**Announce:** "I'm using the explore-schema skill to map entities and relationships for [area]."

## Overview

Map entity relationships across CampX services. Reads TypeORM entity files, traces FK chains, and produces relationship diagrams. Saves output for reference.

## When to Use

- User asks about schema or entity relationships
- User asks "what tables are involved in X"
- Before designing a new feature that touches existing entities
- When check-impact needs deeper entity analysis

### When NOT to Use

- Blast radius analysis → use `check-impact`
- General code search → use ck semantic search or Grep
- Understanding a single file → just read it

## Workflow

### Step 1: Identify the Feature Area

If not specified, ask: "Which feature area? (e.g., student grades, exam registration, evaluator marks)"

### Step 2: Find Relevant Entities

Search for entity files in the relevant service:

```bash
# Search primary service first
find {service}/src -name "*.entity.ts" | head -30
grep -r "class.*Entity" {service}/src/domain/ --include="*.ts" -l
```

Filter to entities matching the feature area keywords.

### Step 3: Read Entity Files

For each relevant entity, read and extract:
- Table name (from `@Entity('table_name')`)
- Columns (from `@Column` decorators) — note types, nullable, defaults
- Relationships (from `@ManyToOne`, `@OneToMany`, `@ManyToMany`, `@JoinColumn`)
- Indexes and unique constraints

### Step 4: Trace FK Chain

Follow the relationship decorators:
1. Read primary entity → find all `@ManyToOne` and `@JoinColumn`
2. Read each related entity → get their table names and key columns
3. Build the JOIN path from what the code says (not from memory)
4. Go 2-3 levels deep (primary → related → related-of-related)

### Step 5: Generate Relationship Map

```
SCHEMA MAP: [Feature Area]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[PrimaryEntity] (table: primary_table)
  ├── column1: VARCHAR — description
  ├── column2: INT — description
  ├── fk_related_id → [RelatedEntity]
  │   ├── column_a: VARCHAR
  │   └── fk_another_id → [AnotherEntity]
  └── fk_other_id → [OtherEntity]

Relationships:
  PrimaryEntity ──M:1──→ RelatedEntity (ON DELETE CASCADE)
  PrimaryEntity ──M:1──→ OtherEntity (ON DELETE SET NULL)
  RelatedEntity ──1:M──→ ChildEntity

Key Observations:
  - [Cascade rule that matters]
  - [Nullable FK that could cause issues]
  - [Index that exists or is missing]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 6: Save Output

Save to a file the user can reference later:
```
~/Desktop/Plans/schema/YYYY-MM-DD-{feature-area}.md
```

Create the directory if it doesn't exist.

## Red Flags - STOP

- "I know this entity has columns X and Y" — NEVER assume. Always read the file.
- "The FK is probably on DELETE CASCADE" — READ the decorator. Don't guess.
- "This entity isn't related to that" — Search before claiming. CampX entities are deeply linked.

All of these mean: read the actual entity file before making any claim.

## Integration

- Called by: user directly, or by check-impact for deeper analysis
- Calls: Explore subagents (haiku) for parallel entity file reading
- Pairs with: check-impact (provides entity data for blast radius analysis)

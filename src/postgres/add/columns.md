# Add Columns

> List fo how-tos related to tese operations:
>
> - [How can the ACCESS EXCLUSIVE lock break applications?](../how_tos.md#how-can-the-access-exclusive-lock-break-applications)
> - [How can the lock queue break applications?](../how_tos.md#how-can-the-lock-queue-break-applications)
> - [How can applications block migrations?](../how_tos.md#how-can-applications-block-migrations)
> - [HOW-TO: Write applications to not block migrations](../how_tos.md#how-to-write-applications-to-not-block-migrations)
> - [How to obtain a lock safely for a migration](../how_tos.md#how-to-obtain-a-lock-safely-for-a-migration)

## Nullable

### With a default

It is unsafe to add a new column:

```sql
ALTER TABLE table ADD COLUMN column INT DEFAULT 0;
```

All queries of every kind will be blocked until the migration is complete because an `ACCESS EXCLUSIVE` lock is required.

However, if the application is written with this in mind and migration timeouts are used, then it is possible to _eventually_ do this safely.

See the [How to obtain a lock safely for a migration](../how_tos.md#how-to-obtain-a-lock-safely-for-a-migration) section below for a step-by-step guide on what to do.

## Without a default

It is unsafe to add a new column:

```sql
ALTER TABLE table ADD COLUMN column INT;
```

All queries of every kind will be blocked until the migration is complete because an `ACCESS EXCLUSIVE` lock is required.

However, if the application is written with this in mind and migration timeouts are used, then it is possible to _eventually_ do this safely.

See the [How to obtain a lock safely for a migration](../how_tos.md#how-to-obtain-a-lock-safely-for-a-migration) section below for a step-by-step guide on what to do.

> Warning: `NULL` columns cannot be made into `NOT NULL` columns safely after-the-fact until Postgres 12. So if you are actually intending to make a `NOT NULL` column, then create a `NOT NULL` column with a dummy default value.

## Not nullable

Add not null - safe alternative possible.

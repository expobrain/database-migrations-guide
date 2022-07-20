## Rename a table

!!! error

    **UNSAFE - NEVER DO THAT**

## Rename a column

A rename must be treated as **adding a column**, then **backfilling data**, then **removing a column**, which means it has the pitfalls of all three, along with the problem of **synchronising writes** to the old and new columns.

### Safe alternative

1. Add the new column.
1. Synchronise writes to both columns.
1. Backfill data to the new column.
1. Read and write to the new column in the application.
1. Remove the old column and any remaining synchronisation.

This remaining part of this section will detail the synchronisation process only. Other sections of this guide (by following the flow chart again) detail how to do each of the other above steps safely.

There are three possible strategies for synchronising writes to both columns:

1. Use database-level triggers to synchronise the new column with the old column and vica versa.
1. Use ORM framework-level synchronisation to synchronise the fields across the whole application automatically.
1. **Not recommended** Use application-level synchronisation, where the fields are manually synchronised in code at each line the fields are modified.

!!! note

    This section is incomplete and does not tell you how to do each strategy _yet_.

## Make a column not nullable

!!! info

    List fo how-tos related to tese operations:

    - [How can the ACCESS EXCLUSIVE lock break applications?](../how_tos.md#how-can-the-access-exclusive-lock-break-applications)
    - [How can the lock queue break applications?](../how_tos.md#how-can-the-lock-queue-break-applications)
    - [How to obtain a lock safely for a migration](../how_tos.md#how-to-obtain-a-lock-safely-for-a-migration)
    - [What are the disadvantages of a NOT NULL check constraint?](../how_tos.md#what-are-the-disadvantages-of-a-not-null-check-constraint)

### Unsafe alternative

It is unsafe to make a column `NOT NULL`:

``` sql
ALTER TABLE table COLUMN column SET NOT NULL;
```

!!! tip

    **Until Postgres 12**

    All queries of every kind will be blocked until the migration is complete because an `ACCESS EXCLUSIVE` lock is required. Since a full table scan is required to validate the constraint, this could take a long time for large tables.

### Safe alternative

Create a `NOT NULL` check constraint instead.

```sql
ALTER TABLE table ADD CONSTRAINT constraint CHECK (column IS NOT NULL) NOT VALID;
ALTER TABLE table VALIDATE CONSTRAINT constraint;
```

In order to do this safely, please see [Add > Constraint](../add/constraints.md).

That's it... Until Postgres 12 where this check constraint can be converted into a proper NOT NULL constraint.

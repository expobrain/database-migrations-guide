# How to guides

## How can the ACCESS EXCLUSIVE lock break applications?

An `ACCESS EXCLUSIVE` lock conflicts with everything, including:

- `SELECT`
- `INSERT`
- `UPDATE`
- `DELETE`

If a transaction is used, all rows will be locked until the transaction is committed.

> Warning: A migration needing this lock will block other queries as soon as the SQL is sent to Postgres (even while waiting for a lock). See [How can the lock queue break applications](#how-can-the-lock-queue-break-applications)?

## How can the lock queue break applications?

A migration can block application queries even while it is waiting for its turn to execute.

1. Migration SQL is sent to Postgres
1. It cannot execute right now because it needs to obtain a lock
1. The migration enters the lock queue
1. Now, the application executes another query that needs a lock that would conflict with the migration's lock.
1. The application query enters the lock queue _behind_ the migration SQL.
1. The application query is blocked on the migration SQL which is blocked on some other application query.

So even though the application query _could_ execute because the migration is not executing, Postgres will not do this!

So even if the migration would execute instantly _if only it had the lock_, it doesn't matter. It starts to block other conflicting queries immediately.

This could mean the application has temporarily degraded performance, and worse, if the migration is taking too long, actual queries and requests will start to fail until the migration has completed.

Therefore, you _should_ use a `statement_timeout` that is about a second long.

```sql
SET statement_timeout = 1000;
```

> Note that a `lock_timeout` is a subset of a `statement_timeout`, but queries are blocked while in the lock queue and while the migration is executing therefore a `statement_timeout` is the appropriate timeout to use.

Since this is likely to timeout for busy tables, an automatic retry script _should_ be used. See [How to obtain a lock safely for a migration](#how-can-the-lock-queue-break-applications).

## How can applications block migrations?

Lock queue.

Migration can never obtain a lock because it uses a `lock_timeout` because it must never break applications.

When a query or migration requires a lock, it will enter the lock queue.

Any locks that conflict with a lock in the queue will have to wait for its turn.

This means application queries can be blocked by migrations.

It **also** means that migrations can be blocked by application queries.

Therefore, applications should keep queries and transactions short.

Try to break transactions into smaller chunks that are less than a minute long, and add a sleep time in between these chunks.

This will give a chance for a migration to obtain a lock before its `lock_timeout` expires.

Of course, it is likely that a migration will need to be retried using a bash script.

A migration _should_ use a short `lock_timeout` and a slightly longer `statement_timeout` when it is retrying.

This is so that the application does not become degraded.

There are usually two parts to a server application: the client-facing application such as an API, and background services/jobs such as crons or message processors.

The client-facing part usually naturally has short queries and transactions. However, background tasks can have long-running transactions and queries that can block migrations.

## Write applications to not block migrations

**GOAL**: The application needs to give migrations a chance to obtain a lock.

**SOLUTION**: Structure application queries and transactions so that there is opportunity for other processes to obtain a lock.

Actions:

1. All transactions should be as short as possible, ideally less than minute long.
1. Split up long-running transactions into smaller chunks. Consider using a separate staging table for the job.
1. In between these smaller transactions, sleep for a few seconds to give other processes a chance to get a lock on the table.
1. Even with this, for extremely busy tables, it will be necessary to be able to temporarily shut down background jobs leaving only the absolutely necessary parts of the application running.
1. Background tasks should be written to handle immediate termination, and there should be a mechanism to immediately or gracefully stop these tasks.

## How to obtain a lock safely for a migration

**GOAL**: Execute a migration that obtains a dangerous lock without blocking application queries.

Execute the migration using a script to automatically retry, and use a short `lock_timeout` with a sleep time to minimise the impact on the application.

The retry script:

```bash
#!/bin/bash
while true; do
    date
    psql -qX -v ON_ERROR_STOP=1 -f migration.sql && echo "done" && break
    sleep 1
done
```

Example `migration.sql` file:

```sql
SET lock_timeout = 100;
SET statement_timeout = 1000;

ALTER TABLE table ADD COLUMN column INT DEFAULT 0;
```

Every one second queries will be blocked for 100 milliseconds, except when the migration has got its lock, then queries could be blocked for 1000 milliseconds.

## How can the FOR UPDATE lock break applications?

From the perspective of an application, the row-level `FOR UPDATE` lock will block some writes to the table, e.g.:

- `UPDATE`
- `SELECT FOR UPDATE`
- `DELETE`

This lock only blocks the selected rows, rather than the whole table. However, `UPDATE table SET column = value;` will effectively lock the entire table.

If a transaction is used, the rows will be locked until the transaction is committed.

Therefore it's important to reduce the number of rows blocked, and to reduce the amount of time those rows are blocked, in order to prevent the application from being blocked with its update operations.

## Can the ROW EXCLUSIVE lock break applications?

Technically, a table-level `ROW EXCLUSIVE` is obtained as well as this is an UPDATE. However, this doesn't conflict with the kind of queries that applications do including other `UPDATE` SQL.

On the other hand, it _can_ conflict with other migrations, so make sure you only do one migration at a time and this includes data migrations.

## What are the disadvantages of a NOT NULL check constraint

- People may not realise the column is` NOT NULL` because the constraint belongs to the table rather than being an option on the column.
- Writes are slower (~0.5-1% hit)
- Managing a constraint may be more complicated with your ORM and migration framework(s).

## Get the list of index for a given table

To get the list of all the indexes for a given table in PostgreSQL:

```sql
SELECT *
FROM pg_indexes
WHERE tablename = 'my-table'
```

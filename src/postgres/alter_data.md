# Alter data

> List fo how-tos related to tese operations:
>
> - [How can the FOR UPDATE lock break applications?](how_tos.md#how-can-the-for-update-lock-break-applications)
> - [Can the ROW EXCLUSIVE lock break applications?](how_tos.md#can-the-row-exclusive-lock-break-applications)

The following kinds of data migrations are unsafe:

```sql
UPDATE table SET column = value;
UPDATE table SET column = value WHERE condition;
```

Where many rows are updated, this will take a long time to complete, and, as a FOR UPDATE lock is obtained on the selected rows, **writes to those rows will be blocked** until the migration is complete.

## Safe Alternative

Modify the data in batches that take about a second each to execute. This will reduce the amount of time the lock is held.

Execute the script in a persistent shell:

```bash
#!/bin/bash
set -e
for i in {0..100}; do
    echo "=== === === Batch#{i}"
    psql -v ON_ERROR_STOP=1 -v v1="${i}" -f migration.sql
done
```

`migration.sql` file:

```sql
SET statement_timeout = 2000;

begin;
\timing on

UPDATE table
SET column = value
WHERE
    id >= (:v1 + 0) _ 1000
AND id < (:v1 + 1) _ 1000
;

commit;
```

In this example, we use the primary key of the table to chunk the rows into batches of 1000, and the start and stop range `0..100` was determined manually. Also, the transaction is useless, but it may be necessary for more complex migrations. Furthermore, we enable timing so that we have insight on how long each update takes. Finally, it is trivial to stop/resume by altering the start of the range.

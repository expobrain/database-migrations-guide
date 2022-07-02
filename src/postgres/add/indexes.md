# Add indexes

Creating an index is unsafe:

```sql
CREATE INDEX my_index ON my_table (my_column)
```

Creating an index acquire a write lock on the table and needs a full scan, this means that for the whole duration of the index creation any read operation will be allowed but write operations will be waiting for the lock to be released.

## Safe alternative

A safe alternative for write-centric high traffic tables is to create an index concurrently:

```sQL
CREATE INDEX CONCURRENTLY my_index ON my_table (my_column)
```

A concurrent index is an index created in background by PostgresSQL which doesn't interfere with the normal operation of the table.

The index is created in more than one step and the whole process is described in the [Building Indexes Concurrently](https://www.postgresql.org/docs/current/sql-createindex.html#SQL-CREATEINDEX-CONCURRENTLY) document.

Creating an index concurrently has two major drawbacks:

1. **the DDL cannot be performed in a transaction**, because of the nature of the process itself; this means that the operation is not atomic and to roll back you need to perform a DROP INDEX IF EXISTS
2. **consider indempotent index creation in tyour database migrations**, because the concurrent creation of an index is not an atomic operation if it fails will leave an invalid index in the database; this means that in your database migrations must consider this case and i.e. use DROP INDEX IF EXISTS before creating the new index concurrently:
    ```sql
    DROP INDEX IF EXISTS my_index;
    CREATE INDEX CONCURRENTLY my_index ON my_table (my_column);
    ```

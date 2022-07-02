# Drop data

Deleting all data in a table using TRUNCATE is unsafe because it needs an ACCESS EXCLUSIVE lock:

```sql
TRUNCATE TABLE my_table
```

Also TRUNCATE is not MVCC-safe.

## Safe alternative

Use DELETE to delete data from a table.

# Add indexes

Creating an index is unsafe:

```sql
CREATE INDEX my_index ON my_table (my_column)
```

Creating an index acquire a write lock on the table and needs a full scan, this means that for the whole duration of the index creation any read operation will be allowed but write operations will be waiting for the lock to be released.

## Safe alternative

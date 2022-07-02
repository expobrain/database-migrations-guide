# Drop tables

Dropping a table is unsafe if the table has foreign keys to other tables:

```sql
DROP TABLE my_table;
```

When dropping a table for each foreign key the database must check if there are any row in the referenced table that will violate the constraint.

This can take a lot of time depending if the referenced table is optimised for querying or not (i.e. don't have an index) also will require an `ACCESS EXCLUSIVE` lock on the referenced table.

To safely drop the table it's better first drop each foreign key one by one using the technique describe in [How to obtain a lock safely for a migration](../how_tos.md#how-to-obtain-a-lock-safely-for-a-migration) and then drop the table as last operation.

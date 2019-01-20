SELECT
  'postgresql' AS dbms,
  t.table_catalog,
  t.table_schema,
  t.table_name,
  c.column_name,
  c.ordinal_position,
  c.data_type,
  c.character_maximum_length,
  n.constraint_type,
  k.table_schema,
  k.table_name,
  k.column_name
FROM information_schema.tables t NATURAL LEFT JOIN information_schema.columns c
  LEFT JOIN (information_schema.key_column_usage k NATURAL JOIN information_schema.table_constraints n
    NATURAL LEFT JOIN information_schema.referential_constraints r)
    ON c.table_catalog = k.table_catalog AND c.table_schema = k.table_schema AND c.table_name = k.table_name AND
       c.column_name = k.column_name
WHERE t.TABLE_TYPE = 'BASE TABLE' AND t.table_schema NOT IN ('information_schema', 'pg_catalog');
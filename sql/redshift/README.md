### Check coding schema for a table:
```postgresplsql
select "column", type, encoding from pg_table_def where tablename = <table_name>;
```

### Maintainance
```postgresplsql
VACUMM <table_name>
ANALIZE <table_name>
ANALIZE COMPRESSION <table_name>
```


### Query STL_LOAD_ERROR:
`select * from stl_load_errors;`

```postgresplsql
create view loadview as
(select distinct tbl, trim(name) as table_name, query, starttime, trim(filename) as input, line_number, colname, err_code, trim(err_reason) as reason
from stl_load_errors sl, stv_tbl_perm sp where sl.tbl = sp.id);
```

### Example create table:
```postgresplsql
CREATE TABLE orders_v4 (
  o_orderkey int8 NOT NULL PRIMARY KEY                             ,
  o_custkey int8 NOT NULL DISTKEY REFERENCES customer_v3(c_custkey),
  o_orderstatus char(1) NOT NULL                                   ,
  o_totalprice numeric(12,2) NOT NULL                              ,
  o_orderdate date NOT NULL SORTKEY                                ,
  o_orderpriority char(15) NOT NULL                                ,
  o_clerk char(15) NOT NULL                                        ,
  o_shippriority int4 NOT NULL                                     ,
  o_comment varchar(79) NOT NULL
);
```

### Example copy command
```postgresplsql
COPY orders_v1
FROM 's3://us-west-2-aws-training/awsu-spl/redshift-quest/orders/orders.tbl.'
COMPUPDATE ON CREDENTIALS 'aws_access_key_id=<YOUR-ACCESS-KEY-ID>;aws_secret_access_key=<YOUR-SECRET-ACCESS-KEY>' LZOP;
```

### Check grant permissions
```postgresplsql
SELECT *
FROM
    (
    SELECT
        schemaname
        ,objectname
        ,usename
        ,HAS_TABLE_PRIVILEGE(usrs.usename, fullobj, 'select') AS sel
        ,HAS_TABLE_PRIVILEGE(usrs.usename, fullobj, 'insert') AS ins
        ,HAS_TABLE_PRIVILEGE(usrs.usename, fullobj, 'update') AS upd
        ,HAS_TABLE_PRIVILEGE(usrs.usename, fullobj, 'delete') AS del
        ,HAS_TABLE_PRIVILEGE(usrs.usename, fullobj, 'references') AS ref
    FROM
        (
        SELECT schemaname, 't' AS obj_type, tablename AS objectname, schemaname + '.' + tablename AS fullobj FROM pg_tables
        WHERE schemaname not in ('pg_internal')
        UNION
        SELECT schemaname, 'v' AS obj_type, viewname AS objectname, schemaname + '.' + viewname AS fullobj FROM pg_views
        WHERE schemaname not in ('pg_internal')
        ) AS objs
        ,(SELECT * FROM pg_user) AS usrs
    ORDER BY fullobj
    )
WHERE (sel = true or ins = true or upd = true or del = true or ref = true)
and schemaname='input_buffer';

```

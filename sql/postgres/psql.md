# psql

psql commands
--------------------
`\?`

`\q`            quit

`\conninfo`      current connection info

 `\a`           toggle between unaligned and aligned mode

 `\c[onnect] [dbname|- [user]]`   connect to new database

 `\C <title>`     table title

 `\copy ...`      perform SQL COPY with data stream to the client machine

 `\copyright`   show PostgreSQL usage and distribution terms

 `\d <table>`     describe table (or view, index, sequence)

 `\d{t|i|s|v}`    list tables/indices/sequences/views

 `\d{p|S|l}`      list permissions/system tables/lobjects

 `\da`            list aggregates

 `\dd [object]`   list comment for table, type, function, or operator

 `\df`           list functions

 `\do`            list operators

 `\dT`            list data types

 `\e [file]`      edit the current query buffer or [file] with external editor

 `\echo <text>`   write text to stdout

 `\encoding <encoding>`  set client encoding

 `\f <sep>`       change field separator

 `\g [file]`     send query to backend (and results in [file] or |pipe)

 `\h [cmd]`       help on syntax of sql commands, * for all commands

 `\H`             toggle HTML mode (currently off)

 `\i <file>`    read and execute queries from <file>

 `\l`           list all databases

 `\lo_export, \lo_import, \lo_list, \lo_unlink` large object operations

 `\o [file]`      send all query results to [file], or |pipe

 `\p`            show the content of the current query buffer

 `\pset <opt>`    set table output  <opt> = {format|border|expanded|fieldsep|null|recordsep|tuples_only|title|tableattr|pager}

 `\q`             quit psql

 `\qecho <text>`  write text to query output stream (see \o)

 `\r`            reset (clear) the query buffer

 `\s [file]`      print history or save it in [file]

 `\set <var> <value>`  set internal variable

 `\t`            show only rows (currently off)

 `\T <tags>`      HTML table tags

 `\unset <var>`  unset (delete) internal variable

 `\w <file>`      write current query buffer to a <file>

 `\x`             toggle expanded output (currently off)

 `\z`             list table access permissions

 `\! [cmd]`       shell escape or command


### playground quick set up
>$ sudo su - postgres
>$ psql
# or
>$ sudo -u postgres psql
```postgresplsql
ALTER USER postgres PASSWORD 'postgres'
CREATE SCHEMA test
CREATE USER xxxx CREATEDB CREATEUSER PASSWORD 'xxxx'
GRANT ALL ON SCHEMA test TO xxxx
GRANT ALL ON ALL TABLES IN SCHEMA test TO xxxx
```

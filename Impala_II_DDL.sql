-- DATA DEFINITION LANGUAGE: creating, deleting, or modifying schema objects such as databases, tables, and views

-- ALTER TABLE (source:https://www.cloudera.com/documentation/enterprise/latest/topics/impala_alter_table.html#alter_table)
-- Drop partition
alter table historical_data drop partition (year < 1995);
alter table historical_data drop partition (year = 1996 and month between 1 and 6);
alter table historical_data drop partition (year < 1995, last_name like 'A%');
alter table fast_growing_data partition (year = 2016, month in (10,11,12)) set fileformat parquet;
--Rename
create database d1;
create database d2;
create database d3;
use d1;
create table mobile (x int);
use d2;
-- Move table from another database to the current one.
alter table d1.mobile rename to mobile;
use d1;
-- Move table from one database to another.
alter table d2.mobile rename to d3.mobile;
--change location
ALTER TABLE table_name [PARTITION (partition_spec)] SET LOCATION 'hdfs_path_of_directory';
-- automatically detect new partition directories added through Hive or HDFS operations (like refresh table)
alter table t1 recover partitions;
-- Set table statistics
create table t1 (x int, s string);
insert into t1 values (1, 'one'), (2, 'two'), (2, 'deux');
show column stats t1;
/*
+--------+--------+------------------+--------+----------+----------+
| Column | Type   | #Distinct Values | #Nulls | Max Size | Avg Size |
+--------+--------+------------------+--------+----------+----------+
| x      | INT    | -1               | -1     | 4        | 4        |
| s      | STRING | -1               | -1     | -1       | -1       |
+--------+--------+------------------+--------+----------+----------+
*/
alter table t1 set column stats x ('numDVs'='2','numNulls'='0');
alter table t1 set column stats s ('numdvs'='3','maxsize'='4');
show column stats t1;
/*
+--------+--------+------------------+--------+----------+----------+
| Column | Type   | #Distinct Values | #Nulls | Max Size | Avg Size |
+--------+--------+------------------+--------+----------+----------+
| x      | INT    | 2                | 0      | 4        | 4        |
| s      | STRING | 3                | -1     | 4        | -1       |
+--------+--------+------------------+--------+----------+----------+
*/
-- insert column
create table t1 (x int);
insert into t1 values (1), (2);

alter table t1 add columns (s string, t timestamp);
insert into t1 values (3, 'three', now());

alter table t1 add columns (b boolean);
insert into t1 values (4, 'four', now(), true);

select * from t1 order by x;
/*
+---+-------+-------------------------------+------+
| x | s     | t                             | b    |
+---+-------+-------------------------------+------+
| 1 | NULL  | NULL                          | NULL |
| 2 | NULL  | NULL                          | NULL |
| 3 | three | 2016-05-11 11:19:45.054457000 | NULL |
| 4 | four  | 2016-05-11 11:20:20.260733000 | true |
+---+-------+-------------------------------+------+
*/
-- Drop column
/*if you expect to someday drop a column, declare it as the last column in the table, 
where its data can be ignored by queries after the column is dropped. Or, re-run your ETL process 
and create new data files if you drop or change the type of a column in a way that causes problems with existing data files.*/
-- Parquet table showing how dropping a column can produce unexpected results.
create table p1 (s1 string, s2 string, s3 string) stored as parquet;

insert into p1 values ('one', 'un', 'uno'), ('two', 'deux', 'dos'),
  ('three', 'trois', 'tres');
select * from p1;
/*
+-------+-------+------+
| s1    | s2    | s3   |
+-------+-------+------+
| one   | un    | uno  |
| two   | deux  | dos  |
| three | trois | tres |
+-------+-------+------+
*/

alter table p1 drop column s2;
-- The S3 column contains unexpected results.
-- Because S2 and S3 have compatible types, the query reads
-- values from the dropped S2, because the existing data files
-- still contain those values as the second column.
/*select * from p1;
+-------+-------+
| s1    | s3    |
+-------+-------+
| one   | un    |
| two   | deux  |
| three | trois |
+-------+-------+*/

--add/drop partition
alter table partition_t add if not exists partition (y=2000);
alter table partition_t drop if exists partition (y=2000);
--The value specified for a partition key can be an arbitrary constant expression, without any references to columns.
alter table time_data add partition (month=concat('Decem','ber'));
alter table sales_data add partition (zipcode = cast(9021 * 10 as string));

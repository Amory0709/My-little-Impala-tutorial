--Source: https://www.cloudera.com/documentation/enterprise/latest/topics/impala_tutorial.html
/*2019-Jul-08*/
/*Impala supports data types with the same names and semantics as the equivalent Hive data types: 
STRING, TINYINT, SMALLINT, INT, BIGINT, FLOAT, DOUBLE, BOOLEAN, STRING, TIMESTAMP.*/

-- For schema

SHOW TABLE STATS xxx;
-- high-level summary of the table, showing how many files and how much total data it contains
-- confirms that the table is expecting all the associated data files to be in Parquet format

SHOW FILES IN xxx;
-- data in the table has the expected number, names, and sizes of the original Parquet files.

DESCRIBE xxx;
-- field's name, type, comment

DESCRIBE FORMATTED xxx;
-- as follow:
/*
+------------------------------+-------------------------------
| name                         | type
+------------------------------+-------------------------------
...
| # Detailed Table Information | NULL
| Database:                    | airlines_data
| Owner:                       | impala
...
| Location:                    | /user/impala/staging/airlines
| Table Type:                  | EXTERNAL_TABLE
...
| # Storage Information        | NULL
| SerDe Library:               | org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe
| InputFormat:                 | org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputForma
| OutputFormat:                | org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat

*/

SHOW CREATE TABLE xxx;
--Display the SQL to create this table

-- Analyze Data

SELECT COUNT(*), NDV(x), NDV(y), NDV(z), SUM(h), MIN(yr), MAX(yr), AVG(e) FROM xxx;
SELECT DISTINCT x FROM xxx;
--NDV:returns a number of distinct values = COUNT(DISTINCT colname)
--SUM : null vs notnull
--count null in one field

 WITH t1 AS
  (SELECT COUNT(*) AS 'rows', COUNT(tail_num) AS 'nonnull'
  FROM airlines_external)
SELECT `rows`, `nonnull`, `rows` - `nonnull` AS 'nulls',
  (`nonnull` / `rows`) * 100 AS 'percentage non-null'
FROM t1;

/*
+-----------+---------+-----------+---------------------+
| rows      | nonnull | nulls     | percentage non-null |
+-----------+---------+-----------+---------------------+
| 123534969 | 412968  | 123122001 | 0.3342923897119365  |
+-----------+---------+-----------+---------------------+
*/

CREATE TABLE xx PARTITIONED BY (yr INT) STORED AS PARQUET;
INSERT INTO table1 PARTITION(yr) SELECT m,d,wk,yr FROM table2;
-- partitioned table :  dramatically cut down on I/O by ignoring all the data from years outside the desired range. 
-- will not read all the data and select the ones that match the condition like "WHERE X BETWEEN xx and xx"/ "WHERE yr = xxxx"

COMPUTE INCREMENTAL STATS xx;
-- way to collect statistics for partitioned tables

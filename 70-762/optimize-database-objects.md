# scripts

1.
``` sql
USE WideWorldImporters;
GO
CREATE NONCLUSTERED INDEX IX_Purchasing_Suppliers_ExamBook762Ch4
ON Purchasing.Suppliers
(
SupplierCategoryID,
SupplierID
)
INCLUDE (SupplierName);
GO

DBCC SHOW_STATISTICS ('Purchasing.Suppliers',
IX_Purchasing_Suppliers_ExamBook762Ch4 );
```
2.
``` sql
CREATE DATABASE ExamBook762Ch4_Statistics;
GO
ALTER DATABASE ExamBook762Ch4_Statistics
SET AUTO_CREATE_STATISTICS OFF;
ALTER DATABASE ExamBook762Ch4_Statistics
SET AUTO_UPDATE_STATISTICS OFF;
ALTER DATABASE ExamBook762Ch4_Statistics
SET AUTO_UPDATE_STATISTICS_ASYNC OFF;
GO
USE ExamBook762Ch4_Statistics;
GO
CREATE SCHEMA Examples;
GO
CREATE TABLE Examples.OrderLines (
OrderLineID int NOT NULL,
OrderID int NOT NULL,
StockItemID int NOT NULL,
Description nvarchar(100) NOT NULL,
PackageTypeID int NOT NULL,
Quantity int NOT NULL,
UnitPrice decimal(18, 2) NULL,
TaxRate decimal(18, 3) NOT NULL,
PickedQuantity int NOT NULL,
PickingCompletedWhen datetime2(7) NULL,
LastEditedBy int NOT NULL,
LastEditedWhen datetime2(7) NOT NULL);
GO
INSERT INTO Examples.OrderLines
SELECT *
FROM WideWorldImporters.Sales.OrderLines;
GO
CREATE INDEX ix_OrderLines_StockItemID
ON Examples.OrderLines (StockItemID);
GO
DBCC SHOW_STATISTICS ('Examples.OrderLines',
ix_OrderLines_StockItemID );
GO
```
3.
``` sql
Use WideWorldImporters;
GO
SELECT
OBJECT_NAME(object_id) AS ObjectName,
name,
auto_created
FROM sys.stats
WHERE auto_created = 1 AND
object_id IN
(SELECT object_id FROM sys.objects WHERE type = 'U');
```
4.
``` sql
SELECT
name AS ObjectName,
STATS_DATE(object_id, stats_id) AS UpdateDate
FROM sys.stats
WHERE object_id = OBJECT_ID('Sales.Customers');
```
5.
``` sql
SELECT
OBJECT_NAME(ixu.object_id, DB_ID('WideWorldImporters')) AS [object_name] ,
ix.[name] AS index_name ,
ixu.user_seeks + ixu.user_scans + ixu.user_lookups AS user_reads,
ixu.user_updates AS user_writes
FROM sys.dm_db_index_usage_stats ixu
INNER JOIN WideWorldImporters.sys.indexes ix ON
ixu.[object_id] = ix.[object_id] AND
ixu.index_id = ix.index_id
WHERE ixu.database_id = DB_ID('WideWorldImporters')
ORDER BY user_reads DESC;
```
6. Find unused indexes
``` sql
USE WideWorldImporters;
GO
SELECT
OBJECT_NAME(ix.object_id) AS ObjectName ,
ix.name
FROM sys.indexes AS ix
INNER JOIN sys.objects AS o ON
ix.object_id = o.object_id
WHERE ix.index_id NOT IN (
SELECT ixu.index_id
FROM sys.dm_db_index_usage_stats AS ixu
WHERE
ixu.object_id = ix.object_id AND
ixu.index_id = ix.index_id AND
database_id = DB_ID()
) AND
o.[type] = 'U'
ORDER BY OBJECT_NAME(ix.object_id) ASC ;
```
7. Find indexes that are updated but never used
``` sql
USE WideWorldImporters;
GO
SELECT
o.name AS ObjectName ,
ix.name AS IndexName ,
ixu.user_seeks + ixu.user_scans + ixu.user_lookups AS user_reads ,
ixu.user_updates AS user_writes ,
SUM(p.rows) AS total_rows
FROM sys.dm_db_index_usage_stats ixu
INNER JOIN sys.indexes ix ON
ixu.object_id = ix.object_id AND
ixu.index_id = ix.index_id
INNER JOIN sys.partitions p ON
ixu.object_id = p.object_id AND
ixu.index_id = p.index_id
INNER JOIN sys.objects o ON
ixu.object_id = o.object_id
WHERE
ixu.database_id = DB_ID() AND
OBJECTPROPERTY(ixu.object_id, 'IsUserTable') = 1 AND
ixu.index_id > 0
GROUP BY
o.name ,
ix.name ,
ixu.user_seeks + ixu.user_scans + ixu.user_lookups ,
ixu.user_updates
HAVING ixu.user_seeks + ixu.user_scans + ixu.user_lookups = 0
ORDER BY
ixu.user_updates DESC,
o.name ,
ix.name ;
```
8. Find overlapping indexes
``` sql
USE [WideWorldImporters];
WITH IndexColumns AS (
SELECT
'[' + s.Name + '].[' + T.Name + ']' AS TableName,
ix.name AS IndexName,
c.name AS ColumnName,
ix.index_id,
ixc.index_column_id,
COUNT(*) OVER(PARTITION BY t.OBJECT_ID, ix.index_id) AS ColumnCount
FROM sys.schemas AS s
INNER JOIN sys.tables AS t ON
t.schema_id = s.schema_id
INNER JOIN sys.indexes AS ix ON
ix.OBJECT_ID = t.OBJECT_ID
INNER JOIN sys.index_columns AS ixc ON
ixc.OBJECT_ID = ix.OBJECT_ID AND
ixc.index_id = ix.index_id
INNER JOIN sys.columns AS c ON
c.OBJECT_ID = ixc.OBJECT_ID AND
c.column_id = ixc.column_id
WHERE
ixc.is_included_column = 0 AND
LEFT(ix.name, 2) NOT IN ('PK', 'UQ', 'FK')
)
SELECT DISTINCT
ix1.TableName,
ix1.IndexName AS Index1,
ix2.IndexName AS Index2
FROM IndexColumns AS ix1
INNER JOIN IndexColumns AS ix2 ON
ix1.TableName = ix2.TableName AND
ix1.IndexName <> ix2.IndexName AND
ix1.index_column_id = ix2.index_column_id AND
ix1.ColumnName = ix2.ColumnName AND
ix1.index_column_id < 3 AND
ix1.index_id < ix2.index_id AND
ix1.ColumnCount <= ix2.ColumnCount
ORDER BY ix1.TableName, ix2.IndexName;
```


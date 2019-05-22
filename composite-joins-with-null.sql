DROP TABLE IF EXISTS dbo.EmpLocations;
SELECT country, region, city, COUNT(*) AS numemps
INTO dbo.EmpLocations
FROM HR.Employees
GROUP BY country, region, city;
ALTER TABLE dbo.EmpLocations ADD CONSTRAINT UNQ_EmpLocations
UNIQUE CLUSTERED(country, region, city);

DROP TABLE IF EXISTS dbo.CustLocations;
SELECT country, region, city, COUNT(*) AS numcusts
INTO dbo.CustLocations
FROM Sales.Customers
GROUP BY country, region, city;
ALTER TABLE dbo.CustLocations ADD CONSTRAINT UNQ_CustLocations
UNIQUE CLUSTERED(country, region, city);

SELECT EL.country, EL.region, EL.city, EL.numemps, CL.numcusts
FROM dbo.EmpLocations AS EL
INNER JOIN dbo.CustLocations AS CL
ON EXISTS (SELECT EL.country, EL.region, EL.city
INTERSECT
SELECT CL.country, CL.region, CL.city);

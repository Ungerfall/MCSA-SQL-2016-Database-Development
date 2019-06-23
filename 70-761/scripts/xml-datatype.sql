ALTER TABLE Production.Products
ADD additionalattributes XML NULL;
GO

-- Auxiliary tables
CREATE TABLE dbo.Beverages(percentvitaminsRDA INT);
CREATE TABLE dbo.Condiments(shortdescription NVARCHAR(50));
GO

-- Store the schemas in a variable and create the collection
DECLARE @mySchema AS NVARCHAR(MAX) = N'';
SET @mySchema +=
(SELECT *
FROM Beverages
From the Library of Leonid microsoftpressstore PetrovSkill 2.4: Query temporal data and non-relational data CHAPTER 2 203
FOR XML AUTO, ELEMENTS, XMLSCHEMA('Beverages'));
SET @mySchema +=
(SELECT *
FROM Condiments
FOR XML AUTO, ELEMENTS, XMLSCHEMA('Condiments'));
SELECT CAST(@mySchema AS XML);
CREATE XML SCHEMA COLLECTION dbo.ProductsAdditionalAttributes AS @mySchema;
GO

-- Drop auxiliary tables
DROP TABLE dbo.Beverages, dbo.Condiments;
GO

ALTER COLUMN additionalattributes
XML(dbo.ProductsAdditionalAttributes);
GO
-- Function to retrieve the namespace
CREATE FUNCTION dbo.GetNamespace(@chkcol AS XML)
RETURNS NVARCHAR(15)
AS
BEGIN
RETURN @chkcol.value('namespace-uri((/*)[1])','NVARCHAR(15)');
END;
GO

-- Function to retrieve the category name
CREATE FUNCTION dbo.GetCategoryName(@catid AS INT)
RETURNS NVARCHAR(15)
AS
BEGIN
RETURN
(SELECT categoryname
FROM Production.Categories
WHERE categoryid = @catid);
END;
GO

-- Add the constraint
ALTER TABLE Production.Products ADD CONSTRAINT ck_Namespace
CHECK (dbo.GetNamespace(additionalattributes) =
dbo.GetCategoryName(categoryid));
GO

-- Beverage
UPDATE Production.Products
SET additionalattributes = N'
<Beverages xmlns="Beverages">
<percentvitaminsRDA>27</percentvitaminsRDA>
</Beverages>'
WHERE productid = 1;

-- Condiment
UPDATE Production.Products
SET additionalattributes = N'
<Condiments xmlns="Condiments">
<shortdescription>very sweet</shortdescription>
</Condiments>'
WHERE productid = 3;

-- String instead of int
UPDATE Production.Products
SET additionalattributes = N'
<Beverages xmlns="Beverages">
<percentvitaminsRDA>twenty seven</percentvitaminsRDA>
</Beverages>'
WHERE productid = 1;

-- Wrong namespace
UPDATE Production.Products
SET additionalattributes = N'
<Condiments xmlns="Condiments">
<shortdescription>very sweet</shortdescription>
</Condiments>'
WHERE productid = 2;

-- Wrong element
UPDATE Production.Products
SET additionalattributes = N'
<Condiments xmlns="Condiments">
<unknownelement>very sweet</unknownelement>
</Condiments>'
WHERE productid = 3';

-- cleanup
ALTER TABLE Production.Products
DROP CONSTRAINT ck_Namespace;
ALTER TABLE Production.Products
DROP COLUMN additionalattributes;
DROP XML SCHEMA COLLECTION dbo.ProductsAdditionalAttributes;
DROP FUNCTION dbo.GetNamespace;
DROP FUNCTION dbo.GetCategoryName;

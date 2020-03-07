CREATE DATABASE ExamBook762Ch3;
GO
USE ExamBook762Ch3;
GO
CREATE SCHEMA Examples;
GO
CREATE TABLE Examples.TestParent
(
ParentId int NOT NULL
CONSTRAINT PKTestParent PRIMARY KEY,
ParentName varchar(100) NULL
);
CREATE TABLE Examples.TestChild
(
ChildId int NOT NULL
CONSTRAINT PKTestChild PRIMARY KEY,
ParentId int NOT NULL,
ChildName varchar(100) NULL
);
ALTER TABLE Examples.TestChild
ADD CONSTRAINT FKTestChild_Ref_TestParent
FOREIGN KEY (ParentId) REFERENCES Examples.TestParent(ParentId);
INSERT INTO Examples.TestParent(ParentId, ParentName)
VALUES (1, 'Dean'),(2, 'Michael'),(3, 'Robert');
INSERT INTO Examples.TestChild (ChildId, ParentId, ChildName)
VALUES (1,1, 'Daniel'), (2, 1, 'Alex'), (3, 2, 'Matthew'), (4, 3, 'Jason');
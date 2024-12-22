use AdventureWorks2008R2

select * from HumanResources.Department

WITH SumSale AS
(SELECT SUM(TotalDue) AS SumTotalDue,
CustomerID
FROM Sales.SalesOrderHeader
GROUP BY CustomerID)

go 

SELECT o.CustomerID, TotalDue,
TotalDue / SumTotalDue * 100 AS PercentOfSales
FROM SumSale INNER JOIN Sales.SalesOrderHeader AS o
ON SumSale.CustomerID = o.CustomerID
ORDER BY CustomerID;

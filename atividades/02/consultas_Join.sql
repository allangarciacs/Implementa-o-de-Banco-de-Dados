-- 1 
SELECT
    P.ProductName AS 'Produto',
    S.CompanyName AS 'Fornecedor',
    C.CategoryName AS 'Categoria',
    P.UnitPrice AS 'Preco Unitario',
    P.UnitsInStock AS 'Quantidade em Estoque'
FROM Products AS P
INNER JOIN Suppliers AS S
    ON P.SupplierID = S.SupplierID
INNER JOIN Categories AS C
    ON P.CategoryID = C.CategoryID;


-- 2 
SELECT
    P.ProductName AS 'Produto',
    S.CompanyName AS 'Fornecedor',
    C.CategoryName AS 'Categoria',
    P.UnitPrice AS 'Preco Unitario',
    P.UnitsInStock AS 'Quantidade em Estoque'
FROM Products AS P
INNER JOIN Suppliers AS S
    ON P.SupplierID = S.SupplierID
INNER JOIN Categories AS C
    ON P.CategoryID = C.CategoryID
WHERE P.UnitsInStock > 0
  AND P.Discontinued = 0;


-- 3 
SELECT
    E.FirstName + ' ' + E.LastName AS 'Vendedor',
    COUNT(O.OrderID) AS 'Quantidade de Vendas'
FROM Employees AS E
INNER JOIN Orders AS O
    ON E.EmployeeID = O.EmployeeID
GROUP BY
    E.FirstName,
    E.LastName;


-- 4 
SELECT
    E.FirstName + ' ' + E.LastName AS 'Vendedpr',
    COUNT(O.OrderID) AS 'Quantidade de Vendas'
FROM Employees AS E
INNER JOIN Orders AS O
    ON E.EmployeeID = O.EmployeeID
GROUP BY
    E.FirstName,
    E.LastName
HAVING COUNT(O.OrderID) >= 100;


-- 5 
SELECT
    E.FirstName + ' ' + E.LastName AS 'Vendedor',
    COUNT(ET.TerritoryID) AS 'Quantidade de Territorios'
FROM Employees AS E
INNER JOIN EmployeeTerritories AS ET
    ON E.EmployeeID = ET.EmployeeID
INNER JOIN Territories AS T
    ON ET.TerritoryID = T.TerritoryID
GROUP BY
    E.FirstName,
    E.LastName;

-- 6

-- 7

# Anotações da disciplina

### **Aula 5 (28/08/2026)**
VARIÁVEIS EM SQL
	-> DECLARE @nomeDaVariável tipo
```sql
DECLARE @nome VARCHAR(100),
		@idade INT,
		@salario DECIMAL(10,2),
		@data DATE;

SET @nome = 'Allan S. Garcia';
SET @idade = 20;
SET @salario = 1000;
SET @data = GETDATE(); -- Essa função pega a data de hoje

PRINT 'Nome: ' + @nome + ' Idade: ' + CAST(@idade AS VARCHAR);

SELECT 
	@nome AS 'Nome',
	@idade AS 'Idade',
	@salario AS 'Salario',
	@data AS 'Data de hoje';


```
OPERADORES E JOIN - Testando em consultas
```sql
-- GROUP BY	
SELECT COUNT(F.Cpf) AS 'qtde', F.Sexo
FROM FUNCIONARIO AS F
GROUP BY F.Sexo

SELECT COUNT(F.Cpf) AS 'qtde', D.Dnome
FROM FUNCIONARIO AS F
JOIN DEPARTAMENTO AS D
ON F.Dnr = D.Dnumero
GROUP BY D.Dnome;

-- Soma dos salários de cada departamento
SELECT SUM(F.Salario) AS 'SOMA', D.Dnome
FROM FUNCIONARIO AS F
JOIN DEPARTAMENTO AS D
ON F.Dnr = D.Dnumero
GROUP BY D.Dnome;

-- Média de horas por projeto
SELECT avg(T.Horas) AS 'HORAS', P.Projnome
FROM TRABALHA_EM AS T
JOIN PROJETO AS P
ON T.Pnr = P.Projnumero
GROUP BY P.Projnome;

-- Maior salário por departamento
SELECT MAX(F.Salario) AS 'Maior salário', D.Dnome
FROM FUNCIONARIO AS F
JOIN DEPARTAMENTO AS D
ON F.Dnr = D.Dnumero
GROUP BY D.Dnome;

-- Exibir departamentos que possuem mais de 3 funcionários
SELECT COUNT(F.CPF) AS 'FUNC', D.Dnome
FROM FUNCIONARIO AS F
JOIN DEPARTAMENTO AS D
ON F.Dnr = D.Dnumero
GROUP BY D.Dnome
HAVING COUNT(F.Cpf) > 3;

-- Exibir projetos q tem mais de 50 horas
SELECT SUM(T.Horas) AS 'Qtd horas', P.Projnome
FROM TRABALHA_EM AS T
JOIN PROJETO AS P
ON T.Pnr = P.Projnumero
GROUP BY P.Projnome
HAVING SUM(T.Horas) > 50;

-- EXISTS
SELECT * 
FROM DEPARTAMENTO
WHERE EXISTS (
	SELECT 1
	FROM PROJETO
	WHERE PROJETO.Dnum = DEPARTAMENTO.Dnumero
)

-- ANY ou ALL - O any pega qualquer um maior q o da lista, ja o all pega
-- o que ganha mais do que todos presentes da lista
SELECT Pnome, Salario
FROM FUNCIONARIO
	WHERE Salario > ANY ( -- ALL
	SELECT F.Salario
	FROM FUNCIONARIO AS F
	JOIN DEPARTAMENTO AS D
	ON F.Dnr = Dnumero
	WHERE D.Dnome = 'Administração'
	)
ORDER BY Salario;

-- Aumente em 10% o salário da Jennifer
DECLARE @salario DECIMAL(10,2),
		@novo_Salario DECIMAL(10,2),
		@nome VARCHAR(100);

SET @nome = 'Jennifer'

SELECT @salario = F.Salario
FROM FUNCIONARIO AS F
WHERE F.Pnome = @nome;
SET @novo_Salario = @salario * 1.1;
PRINT 'Salário: ' + CAST(@salario AS VARCHAR(10))
PRINT 'Novo salário: ' + CAST(@novo_Salario AS VARCHAR(10))

-- Printe a idade da Jennifer
DECLARE @data_nasc DATE,
		@idade INT;

SELECT @data_nasc = f.Datanasc
FROM FUNCIONARIO AS F
WHERE F.Pnome = 'Jennifer';
SET @idade = YEAR(GETDATE()) - YEAR(@data_nasc);
PRINT 'Idade: ' + CAST(@idade AS VARCHAR(5));
```

### **Aula 3 (24/08/2026)**
Testando consultas e operações
```sql
  -- DISTINCT 
SELECT DISTINCT F.Salario
FROM FUNCIONARIO AS F;

SELECT DISTINCT F.SEXO
FROM FUNCIONARIO AS F;

-- WHERE 
SELECT *
FROM FUNCIONARIO AS F
WHERE F.Pnome =	'Carlos'

-- AND
SELECT *
FROM FUNCIONARIO AS F
WHERE F.Sexo = 'm'
  AND F.Salario > 30000;

  -- OR e LIKE (parecido)
SELECT *
FROM FUNCIONARIO AS F
WHERE F.Endereco LIKE '%São Paulo%'
   OR F.Endereco LIKE '%Curitiba%';

-- NOT 
SELECT *
FROM FUNCIONARIO AS F
WHERE F.Endereco NOT LIKE '%São Paulo%';

-- Outra sintaxe é:
SELECT *
FROM FUNCIONARIO AS F
WHERE NOT
	F.Endereco LIKE '%São Paulo%';

-- ORDER BY (ASC - DESC)
SELECT f.Pnome, F.Endereco, F.Salario
FROM FUNCIONARIO AS F
ORDER BY f.Pnome ASC;

SELECT
	F.Pnome AS 'Nome',
	F.Unome AS 'Sobreome',
	F.Minicial,
	F.Salario * 12 AS 'CustoAnual'
FROM FUNCIONARIO AS F
ORDER BY CustoAnual DESC;

-- IS NULL
SELECT
	F.Pnome AS 'Nome',
	F.Unome AS 'Sobreome',
	F.Cpf_supervisor
FROM FUNCIONARIO AS F
WHERE F.Cpf_supervisor IS NULL;

-- IS NOT NULL 
SELECT
	F.Pnome AS 'Nome',
	F.Unome AS 'Sobreome',
	F.Cpf_supervisor
FROM FUNCIONARIO AS F
WHERE F.Cpf_supervisor IS NOT NULL;

-- TOP - MySQL Limit
-- TOP 3 maiores salarios
SELECT TOP 3 *
FROM FUNCIONARIO AS F
ORDER BY F.Salario DESC;

-- Mostras infos do funcionário com o menor salário
-- Método 1
SELECT *
FROM FUNCIONARIO AS F
WHERE F.Salario = (SELECT MIN(F.Salario) FROM FUNCIONARIO AS F);

-- Método 2 - Declarando variáveis
DECLARE @Salario_min DECIMAL(10,2);
SET @Salario_min = (SELECT MIN(F.Salario) FROM FUNCIONARIO AS F);
-- PRINT @Salario_min;

SELECT *
FROM FUNCIONARIO AS F
WHERE F.Salario = @Salario_min;

-- COUNT
SELECT 
	(SELECT COUNT(F.Cpf) FROM FUNCIONARIO AS F)+
	(SELECT COUNT(D.Nome_dependente)FROM DEPENDENTE AS D) AS QtdeFuncionarios;

-- AVG
SELECT AVG(F.Salario
FROM FUNCIONARIO AS F;

-- SUM - Gasto c salário mensal
SELECT SUM(F.Salario)
FROM FUNCIONARIO AS F;

-- SUM - Gasto c salário anual
SELECT SUM(F.Salario) * 12
FROM FUNCIONARIO AS F;

SELECT *
FROM FUNCIONARIO AS F
WHERE F.Datanasc LIKE '__72%';

```

### **Aula 1 (31/07/2026)**

Conceitos da revisão:
  - BC Lógico tem o domínio de todos os dados e representa a estrutura fisica do banco de dados.
  - Toda chave primária é punica e não nula.

SELECT <Lista de atributos>
FROM   <Lista de tabelas>
WHERE  <Condição>

Ferramenta: brModelo.jar


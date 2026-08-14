# Anotações da disciplina

### **Aula 3 (24/08/2026)**

SELECT <Lista de atributos>
FROM   <Lista de tabelas>
WHERE  <Condição>

SELECT DISTINCT -> Retorna valor distintos dentro de uma tabela. Ela pega os valores...

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

Ferramenta: brModelo.jar


# Anotações da disciplina

### **Aula 6 (04/09/2026)**
BEGIN E END são o abre e fecha chaves do sql ({}).

FUNÇÕES - FUNCTION 
```sql
CREATE FUNCTION fn_dobro(@numero INT)
RETURNS INT 
AS 
BEGIN	
	RETURN @numero*2;
END
GO;

SELECT dbo.fn_dobro(250);

-- Mostrar o dobro do salário da Maria

SELECT 
	Pnome,
	Unome,
	f.Salario, 
	dbo.fn_dobro(F.Salario) AS 'Dobro'
FROM FUNCIONARIO AS F
WHERE F.Pnome = 'Maria';

-- Mudar o parâmetro 

CREATE OR ALTER FUNCTION fn_dobro(@numero DECIMAL(10,2))
RETURNS DECIMAL(10,2) 
AS 
BEGIN	
	RETURN @numero*2;
END
GO;

-- Mostre os funcionarios cujo o salario é maior que o 
-- dobro do menor salário

DECLARE @menor_salario DECIMAL(10,2);
SELECT @menor_salario = MIN(Salario)
FROM FUNCIONARIO;
SELECT 
	Pnome,
	Unome,
	F.Salario
FROM FUNCIONARIO AS F
WHERE F.Salario > dbo.fn_dobro(@menor_salario)

-- FUNÇÃO QUE CALCULA A IDADE

CREATE FUNCTION fn_calcula_idade(@data_nasc DATE) 
RETURNS INT 
AS 
BEGIN 
    DECLARE @idade INT; 

    SET @idade = DATEDIFF(YEAR, @data_nasc, GETDATE()); 

    IF (MONTH(@data_nasc) > MONTH(GETDATE()) OR 
       (MONTH(@data_nasc) = MONTH(GETDATE()) AND DAY(@data_nasc) > DAY(GETDATE()))) 
    
    SET @idade = @idade - 1; 
   
    RETURN @idade; 
END
GO

-- Exbição

SELECT
	F.Pnome,
	Unome,
	CONVERT(VARCHAR,F.Datanasc,103) AS 'Data Nasc',
	dbo.fn_calcula_idade(F.Datanasc) AS 'Idade'
FROM FUNCIONARIO AS F

-- MOSTRAR FUNCIONARIOS DE UM DETERMINADO DEPARTAMENTO

CREATE FUNCTION fn_funcionarios_dp(@nome_dp VARCHAR(50))
RETURNS TABLE
AS 
RETURN (
	SELECT 
		F.Pnome,
		F.Unome
	FROM FUNCIONARIO AS F
	JOIN DEPARTAMENTO AS D
	ON F.Dnr = D.Dnumero
	WHERE D.Dnome = @nome_dp
)

-- Por n ser um campo e sim uma tabela, é necessario executa-la no FROM
SELECT * FROM dbo.fn_funcionarios_dp('Pesquisa');

```

### **Aula 6 (04/09/2026)**

CURSORES - Não cairá em prova
```sql
DECLARE @nome VARCHAR(50);

DECLARE cursorFuncionario CURSOR FOR
SELECT Pnome FROM FUNCIONARIO;

OPEN cursorFuncionario;

FETCH NEXT FROM cursorFuncionario INTO @nome;

WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT @nome;
	FETCH NEXT FROM cursorFuncionario INTO @nome;
END

CLOSE cursorFuncionario;
DEALLOCATE cursorFuncionario;
```
WHILE
```sql
-- Exemplo 01

DECLARE @contador INT = 0;

WHILE @contador < 10
BEGIN
	SET @contador = @contador+1
	PRINT 'Contador: ' + CAST(@contador AS VARCHAR(3));	
END

-- Ímpares

DECLARE @contador INT = 0;

WHILE @contador < 10
BEGIN
	SET @contador = @contador+1
	IF @contador % 2 != 0
		PRINT 'Contador: ' + CAST(@contador AS VARCHAR(3));	
END

-- Pares e comando CONTINUE
DECLARE @contador INT = 0;

WHILE @contador < 10
BEGIN
	SET @contador = @contador+1
	IF @contador % 2 != 0
		CONTINUE --
		PRINT 'Contador: ' + CAST(@contador AS VARCHAR(3));	
END
```
IIF - Um if com duas condições, q pode ser colocado no Select 
IFF(condicao, se for verdade, se for falsa)
```sql
SELECT 
	F.Pnome,
	F.Unome,
	F.Salario,
	IIF(F.Salario < 20000,'Baixo','Alto') AS 'Categoria'
	-- IFF(condicao, se for verdade, se for falsa)
FROM FUNCIONARIO AS F;
```
IF / ELSE
```sql
-- Descubra a idade de um funcionário

DECLARE @dataNasc DATE,
		@nome VARCHAR(100),
		@idade INT;

SET @nome = 'Maria';
SELECT @dataNasc = Datanasc FROM FUNCIONARIO WHERE Pnome = @nome;

IF (MONTH(GETDATE()) < MONTH(@dataNasc) 
    OR MONTH(GETDATE()) = MONTH(@dataNasc) 
	AND DAY(@dataNasc) > DAY(GETDATE()))
	SET @idade = DATEDIFF(YEAR,@dataNasc, GETDATE())-1
ELSE 
	SET @idade = DATEDIFF(YEAR,@dataNasc, GETDATE())

PRINT @dataNasc;
PRINT @idade;

-- Descubra se um funcionario esta perto de se aposentar (idd > 55)

DECLARE @dataNasc DATE,
		@nome VARCHAR(100),
		@idade INT;

SET @nome = 'Jennifer';
SELECT @dataNasc = Datanasc FROM FUNCIONARIO WHERE Pnome = @nome;

SET @idade = YEAR(GETDATE()) - YEAR(@dataNasc);
-- Outra maneira de calcular idade:
-- SET @idade = DATEDIFF(YEAR, @dataNasc, GETDATE());

IF (@idade <= 55)
		PRINT 'Longe, idade: '
		+ CAST(@idade AS VARCHAR(10));
ELSE IF (@idade > 55 AND @idade < 60)
		PRINT 'Próximo, idade: '
		+ CAST(@idade AS VARCHAR(10));
ELSE 
	PRINT 'Passou, idade: ' 
		+ CAST(@idade AS VARCHAR(10));
```
DATEDIFF(unidade, data_inicial, data_final)
-> unidade = ano, mês ou dia
```sql
-- Descubra se um funcionario tem o salario maior que a media

DECLARE @dataNasc DATE,
		@nome VARCHAR(100),
		@salario DECIMAL(10,2),
		@media_salarial DECIMAL(10,2);

SET @nome = 'Ana';
SELECT @media_salarial = AVG(Salario) FROM FUNCIONARIO;
SELECT @salario = Salario FROM FUNCIONARIO WHERE Pnome = @nome;

IF (@salario > @media_salarial)
	BEGIN
		PRINT 'Salario do funcionario(a) '
		+ @nome
		+ ' é maior que a média ';
	END;
ELSE 
	BEGIN
		PRINT 'Salario do funcionario(a) '
		+ @nome
		+ ' é menor que a média ';
	END;
```
CONVERT - Converte o estilo (principalmente de datas), tabela de conversão:
<img width="671" height="219" alt="Captura de tela 2026-09-04 105927" src="https://github.com/user-attachments/assets/d57bbe9a-9fbd-43d7-9f09-4e3b1684ece2" />
```sql
-- Converter o formato da data de nasc de um funcionario

DECLARE @dataNasc DATE,
		@nome VARCHAR(100),
		@salario DECIMAL(10,2); 

SET @nome = 'Ana';
SELECT @dataNasc = Datanasc FROM FUNCIONARIO WHERE Pnome = @nome;

PRINT   'O funcionario(a) ' 
		+ @nome 
		+ ' nascido(a) em: '
		+ CONVERT(VARCHAR(10), @dataNasc, 103);

G-- Descobrir o salário a partir do nome

DECLARE @nome VARCHAR(100),
		@salario DECIMAL(10,2);

SET @nome = 'Ana';
SELECT @salario = Salario FROM FUNCIONARIO WHERE Pnome = @nome;

PRINT   'O funcionario(a) ' 
		+ @nome 
		+ ' tem um salario de: RS '
		+ CONVERT(VARCHAR(10), @salario*1.1);
```
CAST - Muda o tipo de dado de uma variável
CAST(@nove_da_variavel AS NOVOTIPO);
```sql
-- Descobrir o salário a partir do nome

DECLARE @nome VARCHAR(100),
		@salario DECIMAL(10,2);

SET @nome = 'Jennifer';
SELECT @salario = Salario FROM FUNCIONARIO WHERE Pnome = @nome;

PRINT   'O funcionario(a) ' 
		+ @nome 
		+ ' tem um salario de: RS '
		+ CAST(@salario AS VARCHAR(10));
```

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


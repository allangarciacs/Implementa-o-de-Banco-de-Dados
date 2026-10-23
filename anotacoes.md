# Anotações da disciplina
OBS: LOG C TRIGGER VAI CAIR NA PROVA
Atividades extras: 
<img width="704" height="309" alt="image" src="https://github.com/user-attachments/assets/113bad08-72af-46d4-93e1-02e20b143627" />
### **Aula 9 (23/10/2026)**
## VIEW
```sql
CREATE VIEW vw_fh_funcionario_dpt
AS
SELECT
	CONCAT(Pnome, ' ', Minicial, ' ', Unome) AS 'NOME',
	DATEDIFF(YEAR, Datanasc, GETDATE()) AS 'IDADE',
	Endereco AS 'ENDERECO',
	Data_Admissao AS 'ADMICAO',
	D.Dnome AS 'DEPARTAKENTO'
FROM FUNCIONARIO AS F
JOIN DEPARTAMENTO AS D
ON F.Dnr = D.Dnumero
```
## Triggers + Mensagem de erro para o USER
Um TRIGGER, quase sempre, é vinculado à uma tabela. (ON TABLE_NAME)
```sql
CREATE TRIGGER trg_after_insert_dpt
ON DEPARTAMENTO
AFTER INSERT 
AS
BEGIN
	PRINT 'Olá meu primeiro trigger!'
END;

INSERT INTO DEPARTAMENTO (Dnumero, Dnome)
VALUES (88, 'Expedicao');
```
INSTEAD OF 
```sql
CREATE TRIGGER trg_insetadof_delete_dpt
ON DEPARTAMENTO 
INSTEAD OF DELETE 
AS BEGIN 
	PRINT 'Nao deletei o registro';
END

DELETE 
FROM DEPARTAMENTO
WHERE Dnumero = 88;
```
Desavbilitar trigger's
```sql
ALTER TABLE DEPARTAMENTO
DISABLE TRIGGER trg_insetadof_delete_dpt;
```
Mostrar trigger's de cada tablea
```sql
EXEC sp_helptrigger DEPARTAMENTO;
```
Função UPDATE() - Verificar se um nome foi alterado.
```sql
CREATE TRIGGER trg_for_update_nome
ON DEPARTAMENTO
FOR UPDATE -- FOR = AFTER 
AS 
BEGIN 
	DECLARE @nome_antigo VARCHAR(40),
			@nome_novo	VARCHAR(40);
	SELECT @nome_antigo = D.Dnome FROM deleted AS D;
	SELECT @nome_novo = I.Dnome FROM inserted AS I;
	IF UPDATE(Dnome)
	BEGIN
		PRINT 'O NOME ERA: ' + @nome_antigo;
		PRINT 'O NOME NOVO É: ' + @nome_novo;
	END
	ELSE
		PRINT 'O NOME N FOI ALTERADO'
END

-- EXEC'S
UPDATE DEPARTAMENTO
SET Dnome = 'Tecnologia'
WHERE Dnome = 'TI'

UPDATE DEPARTAMENTO
SET Dnumero = 10
WHERE Dnome = 'palio'
```

Trigger para impedir mais de um departamento com o mesmo nome (caso o coluna não tenha sido posta como única na criação do BD)
```sql
CREATE TRIGGER trg_insteadof_insert_dpt
ON DEPARTAMENTO 
INSTEAD OF INSERT  
AS 
BEGIN 
	DECLARE @nome VARCHAR(40), @numero INT;
	-- Atribuir a variavel @nome o valor que esta no insert 
	SELECT @nome = I.Dnome, @numero = Dnumero FROM inserted AS I
	IF EXISTS (SELECT 1 FROM DEPARTAMENTO WHERE Dnome = @nome)
		RAISERROR('JA EXISTE UM DP COM ESSE NOME!',16,1)
	ELSE 
		INSERT INTO DEPARTAMENTO (Dnumero,Dnome,Cpf_gerente,Data_inicio_gerente)
		SELECT I.Dnumero, I.Dnome, I.Cpf_gerente, I.Data_inicio_gerente
		FROM inserted AS I
END
GO

-- execução
SELECT * FROM DEPARTAMENTO
INSERT INTO DEPARTAMENTO (Dnumero, Dnome)
VALUES (100, 'palio');
```
Salvar logs (insert, update, delete) usando triggers (realizar um operação em uma tabela, o os triggers salvar o tipo, data, e parte q foi feita essa operação em outra tabela - LOG_FUNCIONARIO, nesse caso):
```sql 
CREATE TABLE LOG_FUNCIONARIO(
	log_id INT IDENTITY(100,1) PRIMARY KEY,
	cpf CHAR(11),
	operacao VARCHAR(10),
	data_hora DATETIME DEFAULT GETDATE()
	)

CREATE TRIGGER trg_for_insert_funcionario
ON FUNCIONARIO
FOR INSERT 
AS 
BEGIN 
	INSERT INTO LOG_FUNCIONARIO (cpf_funcionario, operacao)
	SELECT I.Cpf, 'INSERT' 
	FROM inserted AS I
END 


CREATE TRIGGER trg_for_updated_funcionario
ON FUNCIONARIO
FOR UPDATE 
AS 
BEGIN 
	INSERT INTO LOG_FUNCIONARIO (cpf_funcionario, operacao)
	SELECT I.Cpf, 'UPDATE' 
	FROM inserted AS I
END 

CREATE TRIGGER trg_for_deleted_funcionario
ON FUNCIONARIO
FOR DELETE 
AS 
BEGIN 
	INSERT INTO LOG_FUNCIONARIO (cpf_funcionario, operacao)
	SELECT D.Cpf, 'DELETE' 
	FROM deleted AS D
END 

INSERT INTO FUNCIONARIO (Pnome, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Bonus, Data_Admissao, Dnr)
VALUES ('Allan', 'Garcia', '01234512345', '2005-02-02', 'Andradas','M',10000,0,'2026-10-23',6);

select * from FUNCIONARIO;
select * from LOG_FUNCIONARIO;

UPDATE FUNCIONARIO 
SET Salario = 500
WHERE Cpf = '01234512345';

DELETE FROM FUNCIONARIO
WHERE Cpf = '01234512345';
```
De maneira simplificada (Insert, Delete e Update em um só trigger):
```sql
CREATE TRIGGER trg_for_IDU_funcionario
ON FUNCIONARIO
FOR INSERT, DELETE, UPDATE
AS 
BEGIN 
-- Se update 
	IF EXISTS (SELECT * FROM inserted)
	BEGIN 
		IF EXISTS (SELECT * FROM deleted)
			INSERT INTO LOG_FUNCIONARIO (cpf_funcionario, operacao)
			SELECT I.Cpf, 'UPDATE' 
			FROM inserted AS I
		ELSE 
			INSERT INTO LOG_FUNCIONARIO (cpf_funcionario, operacao)
			SELECT I.Cpf, 'INSERT' 
			FROM inserted AS I
		END
		ELSE
			INSERT INTO LOG_FUNCIONARIO (cpf_funcionario, operacao)
			SELECT D.Cpf, 'DELETE' 
			FROM deleted AS D
END 
```

### **Aula 8 (09/10/2026)**
### Transações


### **Aula 7 (04/09/2026)**
Human Resourse Machine
The Farmer Was Replaced 
```sql 
CREATE OR ALTER PROCEDURE sp_add_funcionario(
	@Pnome VARCHAR(50),
	@Minicial VARCHAR(1),
	@Unome VARCHAR(50),
	@cpf VARCHAR(11))
AS
BEGIN 
	DECLARE @nome_completo VARCHAR(100);
	SET @nome_completo = CONCAT(@Pnome, ' ',@Minicial, ' ',@Unome);
	IF EXISTS (SELECT 1 FROM FUNCIONARIO
		WHERE @nome_completo = CONCAT(Pnome,' ',Minicial,' ',Unome))
		PRINT 'Esse funcionario ja esta no sistema!'
	ELSE 
		BEGIN 
			INSERT INTO FUNCIONARIO(Pnome, Minicial, Unome, Cpf) 
			VALUES(@Pnome, @Minicial, @Unome, @Cpf)
			PRINT @Pnome + 'Novo funcionario inserido no sistema!';
		END
END
GO

EXEC dbo.sp_add_funcionario 'Moscou', 'M', 'Ferreira', '00000000001';
EXEC dbo.sp_add_funcionario 'Allan', 'S', 'Garcia', '00000000000';
```

### **Aula 6 (04/09/2026)**

OUTRO PROCEDURE + GERAL
```sql
CREATE PROCEDURE sp_add_dpt(
	@dpt_nome VARCHAR(50),
	@dpt_numero INT,
	@dpt_loc VARCHAR(50))
AS
BEGIN 
	IF EXISTS (SELECT 1 FROM DEPARTAMENTO 
			   WHERE Dnome = @dpt_nome)
		BEGIN
			PRINT 'Esse dp ja existe' + @dpt_nome;
			RETURN;
		END
	ELSE 
		BEGIN 
			INSERT INTO DEPARTAMENTO (Dnome, Dnumero) 
			VALUES(@dpt_nome, @dpt_numero);

			INSERT INTO LOCALIZACAO_DEP (Dnumero, Dlocal)
			VALUES(@dpt_numero, @dpt_loc);
			PRINT @dpt_nome + 'Dp inserido com sucesso';
			PRINT @dpt_loc + 'Local inserido com sucesso';
		END
END
GO

EXEC sp_add_dpt 'Compras', 130, 'Santa Maria';

SELECT * FROM DEPARTAMENTO;

```
FALTA CONCLUIR !!!!!!!!!!!! - lista funcionario per dp, se dp nao for especificado mostrar todos func de todos dp
```sql
CREATE OR ALTER PROCEDURE sp_func_per_dpt(
	@dpt_nome VARCHAR(50))
AS
BEGIN 
	IF EXISTS (SELECT 1 FROM DEPARTAMENTO 
			   WHERE @dpt_nome = ' ')
		BEGIN
			SELECT  
				F.Pnome,
				F.Unome
				FROM FUNCIONARIO AS F
				JOIN DEPARTAMENTO AS D
				ON F.Dnr = D.Dnumero
			RETURN;
		END
	ELSE 
		BEGIN 
			SELECT  
				F.Pnome,
				F.Unome
				FROM FUNCIONARIO AS F
				JOIN DEPARTAMENTO AS D
				ON F.Dnr = D.Dnumero
				WHERE Dnome = @dpt_nome
			RETURN;
		END
END
GO

EXEC sp_funcsp_func_per_dpt	@dpt_nome = ' ';

SELECT * FROM DEPARTAMENTO;

```
ENCRYPTION
```sql
CREATE PROCEDURE sp_funcionarios
WITH ENCRYPTION
AS 
SELECT * FROM FUNCIONARIO;
GO
```

sp_help mostra os metadados de objetos do banco (tabelas, funções, procedures, etc)
```sql
EXEC sp_help FUNCIONARIO;
EXEC sp_help sp_aumento;
```


STORED PROCEDURE - PROCEDIMENTO ARMAZENADO
```sql
CREATE PROCEDURE sp_exibe_meu_nome
AS 
BEGIN
	PRINT 'Allan S. Garcia';
END
GO

EXEC sp_exibe_meu_nome;

```
AUMENTAR O SALARIO NO BANCO
```sql
CREATE PROCEDURE sp_aumento(@porcentagem DECIMAL(3,1)) -- 3 casas, 1 após a vírgula
AS 
BEGIN 
	UPDATE FUNCIONARIO
	SET Salario = Salario*(1+(@porcentagem/100))

END
GO

EXEC dbo.sp_aumento @porcentagem = 5;

CREATE OR ALTER PROCEDURE sp_aumento(
	@porcentagem DECIMAL(3,1),
	@cpf CHAR(11))
AS
BEGIN 
	UPDATE FUNCIONARIO
	SET Salario = Salario*(1+(@porcentagem/100))
	WHERE Cpf = @cpf
END 
GO

EXEC dbo.sp_aumento @porcentagem = 50, @cpf = '98765432300'
```
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

```
Mostrar o dobro do salário da Maria
```sql
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
```
Mostre os funcionarios cujo o salario é maior que o dobro do menor salário
```sql
DECLARE @menor_salario DECIMAL(10,2);
SELECT @menor_salario = MIN(Salario)
FROM FUNCIONARIO;
SELECT 
	Pnome,
	Unome,
	F.Salario
FROM FUNCIONARIO AS F
WHERE F.Salario > dbo.fn_dobro(@menor_salario)
```
FUNÇÃO QUE CALCULA A IDADE
```sql
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
```
MOSTRAR FUNCIONARIOS DE UM DETERMINADO DEPARTAMENTO
```sql
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

CREATE FUNCTION fn_salario_anual()
RETURNS @sal_ano TABLE
(
	nome_completo VARCHAR(100),
	salario DECIMAL(10,2),
	salario_anual DECIMAL(10,2)
)
AS 
BEGIN

	INSERT INTO @sal_ano
	SELECT 
		CONCAT(F.Pnome, ' ', F.Minicial, ' ', F.Unome),
		F.Salario,
		F.Salario*13+(F.salario*0.3)
	FROM FUNCIONARIO AS F
	RETURN;

END
SELECT * FROM dbo.fn_salario_anual();
```

BEGIN E END são o abre e fecha chaves do sql ({}).

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


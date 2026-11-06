GO
/* 1) Uma transação em um banco de dados é uma consulta/ação realizada dentro de um bloco, 
que pode ser isolado, desfeito ou repartido (SavePoint). 
Atomicidade:
Consistência: 
Isolamento: A transação pode isolar parte dos comandos sql e trata-los separadamente. 
Durabilidade: SavePoints */
GO

-- 2)
GO
BEGIN TRANSACTION

UPDATE Procedimento
SET PrecoPadrao = 105.00
WHERE ProcedimentoID = 'HEMO';

-- SELECT * FROM Procedimento; -- 1 row afetada

COMMIT TRANSACTION;

GO

GO
/* 3) Triggers podem ser descritos como 'armadilhas', que vão ser ativadas depois de uma determinada
ação (definida pelo gerenciador do banco). Elas podem ser executadas no ligar de uma determinada
ação (instead of) ou depois de uma determinada ação (after). Essas ações (comandos que podem ser
vinculados) são: UPDATE, DELETE e INSERT. */
GO

-- 4)
GO
CREATE or alter TRIGGER trg_Consulta_Ativos
ON Consulta
AFTER INSERT
AS 
BEGIN

	DECLARE @anatv BIT, @vtavt BIT;

	SELECT @anatv = A.Ativo, @vtavt = V.Ativo FROM inserted AS I
	JOIN Veterinario AS V
		ON I.VeterinarioID = V.VeterinarioID
	JOIN Animal AS A
		ON I.AnimalID = A.AnimalID 
	WHERE A.AnimalID IS NOT NULL

	IF (@anatv = 0) OR (@vtavt = 0)
	BEGIN 
		RAISERROR('Animal ou veterinario inativo', 16, 1);
		ROLLBACK TRANSACTION;
	END
END;
	
INSERT INTO Consulta(AnimalID,VeterinarioID,DataConsulta,Motivo)
VALUES(1,3,'2026-11-20 09:00:00','Consulta de rotina');
GO

-- 5)
GO
CREATE TRIGGER trg_ConsultaProcedimento_ValorTotal
ON ConsultaProcedimento
AFTER INSERT 
AS 
BEGIN 

	DECLARE @qtde INT, @PU DECIMAL(10,2), @CID INT;

	SELECT @qtde = I.Quantidade, @PU = I.PrecoUnitario, @CID = I.ConsultaID FROM inserted AS I;

	UPDATE Consulta
	SET ValorTotal = ValorTotal + (@qtde * @PU)
	WHERE @CID = ConsultaID;

END;

SELECT * FROM Consulta;
SELECT * FROM ConsultaProcedimento;
SELECT * FROM Procedimento;

INSERT INTO ConsultaProcedimento (ConsultaID,ProcedimentoID,Quantidade,PrecoUnitario)
VALUES (4,'COLETA',2,100.00);
GO;

-- 6)
GO
CREATE TABLE HistorioPrecoProcedimento(
	HistoricoID INT IDENTITY(1,1) PRIMARY KEY,
	ProcedimentoID VARCHAR(10) NOT NULL,
	PrecoAnterior DECIMAL(10,2) NOT NULL,
	PrecoNovo DECIMAL(10,2) NOT NULL,
	DataAlteracao DATETIME2(0) NOT NULL
);
GO

GO
CREATE TRIGGER trg_Procedimento_Preco
ON Procedimento
FOR UPDATE
AS 
BEGIN
	INSERT INTO HistorioPrecoProcedimento(ProcedimentoID,PrecoAnterior,PrecoNovo,DataAlteracao)
	SELECT I.ProcedimentoID, P.PrecoPadrao, I.PrecoPadrao, SYSDATETIME()
	FROM inserted AS I
	JOIN Procedimento AS P
		ON I.ProcedimentoID = p.ProcedimentoID;
END

UPDATE Procedimento
SET PrecoPadrao = 1000
WHERE ProcedimentoID = 'COLETA';

SELECT * FROM Procedimento;
SELECT * FROM HistorioPrecoProcedimento;

GO

-- 7) 
GO 
CREATE TRIGGER trg_Animal_Desativar
ON Animal
instead of DELETE
AS 
BEGIN
	DECLARE @AID INT;
	SELECT @AID = D.AnimalID FROM deleted as D;

	UPDATE Animal
	SET Ativo = 0
	WHERE AnimalID = @AID;

END

-- EXECUÇÃO

SELECT * FROM ANIMAL;

DELETE FROM Animal
WHERE AnimalID = 5;

SELECT * FROM ANIMAL;
GO

GO
/* 8) Integridade de domínio é dar uma regra a uma variável (limite de qtde etc.), 
exemplo: idade INT CHECK(idade >= 18), ja integridade referencial também é uma regra
mas é sobre a relação da variável entre tabelas, exemplo: 
Foreing Key (id_departamento) references Departamento(id), departamento deve existir. 
Restrição declarativa: Ao criar a tabela Animal foi definido q o nome não poderia ser nulo
Restrição procedural: CONSTRAINT PK_Animal PRIMARY KEY (AnimalID)
*/
GO

-- 9)

GO
/* 10) Uma view é um procedimento que fica salvo no banco, ela serve para visualizar 
algo definido pelo administrador do banco. Vantagens: praticidade em visualizar 
certas coisas quando preciso, fácil atualização */
GO

-- 11)
GO
CREATE OR ALTER  VIEW vw_RelatorioConsultas AS 
SELECT 
	C.ConsultaID, 
	C.DataConsulta,
	T.Nome,
	A.Nome AS 'NomeAnimal',
	V.Nome AS 'NomeVeterinario',
	C.Situacao,
	D.Descricao,
	P.Quantidade,
	P.PrecoUnitario
FROM Animal A
JOIN Tutor AS T
	ON A.TutorID = T.TutorID
JOIN Consulta AS C
	ON A.AnimalID = C.AnimalID
JOIN Veterinario AS V
	ON C.VeterinarioID = V.VeterinarioID
JOIN ConsultaProcedimento AS P
	ON C.ConsultaID = P.ConsultaID
JOIN Procedimento AS D
	ON D.ProcedimentoID = P.ProcedimentoID
WHERE A.AnimalID IS NOT NULL;
GO

-- 12)

-- 13)
GO 
CREATE OR ALTER VIEW vw_AnimalOwners AS
SELECT 
	A.Nome AS 'ANIMAL NAME',
	A.Especie AS 'ANIMAL SPECIES',
	T.Nome AS 'OWNER NAME'
FROM Animal A
JOIN Tutor AS T
	ON A.TutorID = T.TutorID
WHERE AnimalID IS NOT NULL;
GO



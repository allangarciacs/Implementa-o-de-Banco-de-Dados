## TRANSACTION 

### Para que serve:

  1. Garantir integridade e consistência dos dados
  2. Reverter alterações em caso de erro
  3. Controlar múltiplas operações simultâneas

### Principais comandos: 
BEGIN TRANSACTION
COMMIT TRANSACTION
ROLLBACK TRANSACTION
SAVEPOINT

Inserir dois departamentos, criar um ponto de salvamento após o primeiro INSERT, desfazer o segundo e confirmar apenas o primeiro.
```sql
BEGIN TRANSACTION;

INSERT INTO DEPARTAMENTO
(Dnumero, Dnome)
VALUES (12, 'Financeiro');

SAVE TRANSACTION PontoSalvo;

INSERT INTO DEPARTAMENTO
(Dnumero, Dnome)
VALUES (13, 'Comercial');

-- Desfaz somente a segunda inserção
ROLLBACK TRANSACTION PontoSalvo;

-- Confirma a primeira inserção
COMMIT TRANSACTION;

SELECT * FROM DEPARTAMENTO
WHERE Dnumero IN (12, 13);
```

## TRIGGER
Sintaxe básica
```sql
CREATE TRIGGER nome_do_trigger
ON nome_da_tabela
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Lógica do trigger
END;
```
Exemplo de AFTER TRIGGER: Neste exemplo, o AFTER trigger é executado após uma inserção ou atualização na tabela FUNCIONARIO. Ele verifica se o salário é menor que R$ 1.000,00 e, se for, a operação é desfei
```sql
CREATE TRIGGER trg_check_salary
ON FUNCIONARIO
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @Salario DECIMAL(10,2);
    
    -- Obtém o salário que foi inserido ou atualizado
    SELECT @Salario = i.Salario FROM inserted i;
    
    -- Verifica se o salário é menor que o mínimo permitido
    IF @Salario < 1000.00
    BEGIN
        RAISERROR('O salário não pode ser menor que R$ 1.000,00.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
```
Exemplo de INSTEAD OF Trigger:
```sql
CREATE TRIGGER trg_instead_insert_funcionario
ON FUNCIONARIO
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @Cpf CHAR(11), @Salario DECIMAL(10,2);
    
    -- Obtém os valores da nova inserção
    SELECT @Cpf = i.Cpf, @Salario = i.Salario FROM inserted i;
    
    -- Verifica se o salário é menor que o mínimo permitido
    IF @Salario >= 1000.00
    BEGIN
        -- Realiza a inserção normal se o salário for válido
        INSERT INTO FUNCIONARIO (Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr)
        SELECT Pnome, Minicial, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Cpf_supervisor, Dnr FROM inserted;
    END
    ELSE
    BEGIN
        -- Se o salário for menor, gera um erro
        RAISERROR('Salário inválido. Não foi possível inserir o funcionário.', 16, 1);
    END
END;
GO
```
## SALVAR LOGS
```sql
-- cria a tabela de logs
CREATE TABLE LOG_FUNCIONARIO(
	log_id INT IDENTITY(100,1) PRIMARY KEY,
	cpf CHAR(11),
	operacao VARCHAR(10),
	data_hora DATETIME DEFAULT GETDATE()
	)

-- cria o trigger
CREATE TRIGGER trg_for_insert_funcionario
ON FUNCIONARIO
FOR INSERT 
AS 
BEGIN 
	INSERT INTO LOG_FUNCIONARIO (cpf_funcionario, operacao)
	SELECT I.Cpf, 'INSERT' 
	FROM inserted AS I
END

-- uso
INSERT INTO FUNCIONARIO (Pnome, Unome, Cpf, Datanasc, Endereco, Sexo, Salario, Bonus, Data_Admissao, Dnr)
VALUES ('Allan', 'Garcia', '01234512345', '2005-02-02', 'Andradas','M',10000,0,'2026-10-23',6);

-- verificar
select * from FUNCIONARIO;
select * from LOG_FUNCIONARIO;

-- juntar insert, delete e update
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
## RESTRIÇÕES DE DOMÍNIO
```sql
CREATE TABLE Funcionarios (
    id INT PRIMARY KEY, -- Chave: único e não nulo
    nome VARCHAR(100) NOT NULL, -- Vazio: não aceita NULL
    idade INT CHECK (idade >= 18), -- Domínio: idade mínima de 18
    salario DECIMAL(10,2) NOT NULL, -- Vazio: salário obrigatório
    cargo VARCHAR(50) CHECK (cargo IN ('Gerente', 'Analista', 'Desenvolvedor')), -- Usuário: cargos permitidos
    id_departamento INT, -- Campo para relacionar com outra tabela
    FOREIGN KEY (id_departamento) REFERENCES Departamentos(id) -- Referencial: departamento deve existir
);
```

## VIEW
Sintaxe básica
```sql
CREATE VIEW FuncionariosVendas AS
SELECT Pnome, Unome, Salario
FROM Funcionarios
WHERE Dnr = 3;
```


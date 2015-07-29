CREATE TABLE [dbo].[GALA_CONTATTI]
(
	[Id] INT NOT NULL  IDENTITY, 
    [ID_contatto] VARCHAR(50) NOT NULL, 
    [ID_CLIENTE] VARCHAR(30) NOT NULL, 
    [ID_azienda] VARCHAR(10) NULL, 
    [NOME] VARCHAR(100) NOT NULL, 
    [COGNOME] VARCHAR(100) NOT NULL, 
    [TIPOCONTATTO] VARCHAR(100) NOT NULL, 
    [CODFISC] VARCHAR(16) NULL, 
    [INDIRIZZO] VARCHAR(100) NULL, 
    [CAP] VARCHAR(10) NULL, 
    [COMUNE] VARCHAR(100) NULL, 
    [PROVINCIA] VARCHAR(5) NULL, 
    [NAZIONE] VARCHAR(3) NULL, 
    [FAX] VARCHAR(50) NULL, 
    [EMAIL] VARCHAR(100) NULL, 
    [TELEFONO] VARCHAR(50) NULL, 
    [PEC] VARCHAR(100) NULL, 
    [CELLULARE] VARCHAR(50) NULL, 
    PRIMARY KEY ([Id], [ID_contatto])
)

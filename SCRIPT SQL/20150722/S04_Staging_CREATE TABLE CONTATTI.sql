CREATE TABLE [dbo].[GALA_CONTATTI]
(
    [ID_contatto] VARCHAR(50) NOT NULL, 
    [ID_CLIENTE] VARCHAR(30) NOT NULL, 
    [ID_azienda] VARCHAR(10) NULL, 
    [NOME] VARCHAR(100) NULL, 
    [COGNOME] VARCHAR(100) NULL, 
	[ID_TIPOCONTATTO] VARCHAR(10) NOT NULL, 
    [TIPOCONTATTO] VARCHAR(100) NOT NULL, 
    [CODFISC] VARCHAR(16) NULL, 
    [INDIRIZZO] VARCHAR(255) NULL, 
    [CAP] VARCHAR(10) NULL, 
    [COMUNE] VARCHAR(100) NULL, 
    [PROVINCIA] VARCHAR(5) NULL, 
    [NAZIONE] VARCHAR(3) NULL, 
    [FAX] VARCHAR(50) NULL, 
    [EMAIL] VARCHAR(500) NULL, 
    [TELEFONO] VARCHAR(50) NULL, 
    [PEC] VARCHAR(100) NULL, 
    [CELLULARE] VARCHAR(50) NULL, 
	RagioneSociale VARCHAR(110) NULL, 
	PartitaIVa VARCHAR(50) NULL,
	[ID_Tipo_persona]   VARCHAR (10)  NULL,
    [Descrizione_tipo_persona] VARCHAR (50)  NULL
    PRIMARY KEY ([ID_contatto], [ID_TIPOCONTATTO])
)

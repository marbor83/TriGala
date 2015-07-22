CREATE TABLE [dbo].[POD_PDR]
(
	[Id] INT NOT NULL PRIMARY KEY IDENTITY, 
    [ID_AZIENDA] VARCHAR(10) NOT NULL, 
    [ID_CLIENTE] VARCHAR(30) NOT NULL, 
    [ID_CONTRATTO] VARCHAR(20) NOT NULL, 
    [ID_RIGA_CONTRATTI] INT NULL, 
    [CODICE_DISPOSITIVO] VARCHAR(100) NOT NULL, 
    [VOL_QTA] NUMERIC(18, 2) NOT NULL, 
    [COMMODITY] CHAR NOT NULL,
	[INDIRIZZO] VARCHAR(100) NOT NULL, 
    [CAP] VARCHAR(10) NOT NULL, 
    [COMUNE] VARCHAR(100) NOT NULL, 
    [PROVINCIA] VARCHAR(5) NOT NULL, 
    [NAZIONE] VARCHAR(3) NOT NULL, 
    [RIFERIMENTO] VARCHAR(200) NULL, 
    [CONVERSIONE] VARCHAR(100) NULL,
	[CIG] VARCHAR(200) NULL, 
    [CUP] VARCHAR(200) NULL, 
    [ODA] VARCHAR(200) NULL, 
    [COMPONENTE TARIFFARIA] VARCHAR(50) NULL
)
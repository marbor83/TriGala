CREATE TABLE [dbo].[GALA_ANAGRAFICA_CONTRATTI]
(
    [ID_CONTRATTO] VARCHAR(20) NOT NULL PRIMARY KEY,
    [ID_AZIENDA] VARCHAR(10) NOT NULL, 
    [ID_CLIENTE] VARCHAR(30) NOT NULL, 
    [STATO] VARCHAR(10) NOT NULL, 
    [DATA_INIZIO] DATETIME  NULL, 
    [DATA_FINE] DATETIME  NULL, 
    [DATA_CESSAZIONE] DATETIME NULL, 
    [CONV_APPARTENENZA] VARCHAR(100) NULL, 
    [ID_BU] VARCHAR(10) NULL, 
    [DESCR_BU] VARCHAR(50) NULL, 
    [ID_AREA] VARCHAR(10) NULL, 
    [DESCR_AREA] VARCHAR(50) NULL, 
    [ID_AGENTE] VARCHAR(10) NULL, 
    [DESCR_AGENTE] VARCHAR(50) NULL, 
    [CENTRO_DI_COSTO] VARCHAR(50) NULL, 
    [ID_PAG_MOD] VARCHAR(10)  NULL, 
    [DESCR_PAG_MOD] VARCHAR(50)  NULL, 
    [CIG] VARCHAR(200) NULL, 
    [CUP] VARCHAR(200) NULL, 
    [ODA] VARCHAR(200) NULL,
	IdTipoContratto VARCHAR(10) NULL,
	DescrizioneTipoContratto VARCHAR(200) NULL,
	IDAgenzia VARCHAR(10) NULL,
	NomeAgenzia VARCHAR(200) NULL	
)

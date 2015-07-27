CREATE TABLE [dbo].[GALA_POD_PDR] (
    [Id]                    INT             IDENTITY (1, 1) NOT NULL,
    [ID_AZIENDA]            VARCHAR (10)    NOT NULL,
    [ID_CLIENTE]            VARCHAR (30)    NOT NULL,
    [ID_CONTRATTO]          VARCHAR (20)    NOT NULL,
    [ID_RIGA_CONTRATTI]     INT             NULL,
    [CODICE_DISPOSITIVO]    VARCHAR (100)   NOT NULL,
    [VOL_QTA]               NUMERIC (18, 2) NOT NULL,
    [COMMODITY]             CHAR (1)        NOT NULL,
    [INDIRIZZO]             VARCHAR (100)   NOT NULL,
    [CAP]                   VARCHAR (10)    NOT NULL,
    [COMUNE]                VARCHAR (100)   NOT NULL,
    [PROVINCIA]             VARCHAR (5)     NOT NULL,
    [NAZIONE]               VARCHAR (3)     NOT NULL,
    [RIFERIMENTO]           VARCHAR (200)   NULL,
    [CONVENZIONE]           VARCHAR (100)   NULL,
    [CIG]                   VARCHAR (200)   NULL,
    [CUP]                   VARCHAR (200)   NULL,
    [ODA]                   VARCHAR (200)   NULL,
    [COMPONENTE_TARIFFARIA] VARCHAR (50)    NULL,
	[DATA_INIZIO]           DATETIME        NOT NULL,
    [DATA_FINE]         	DATETIME      	NOT NULL,
    [DATA_CESSAZIONE]   	DATETIME     	NULL,
	[ID_PAG_MOD]            VARCHAR (10)    NULL,
    [DESCR_PAG_MOD]         VARCHAR (50)    NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


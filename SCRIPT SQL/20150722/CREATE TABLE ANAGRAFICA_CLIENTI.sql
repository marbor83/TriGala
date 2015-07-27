CREATE TABLE [dbo].[GALA_ANAGRAFICA_CLIENTI] (
    [Id]                       INT           NOT NULL,
    [ID_AZIENDA]               VARCHAR (10)  DEFAULT ((1)) NOT NULL,
    [ID_CLIENTE]               VARCHAR (30)  NOT NULL,
	[ID_MASTER]               VARCHAR (30)  NOT NULL,
    [ID_TIPO_CLIENTE]          VARCHAR (10)  NULL,
    [DESCR_TIPO_CLIENTE]       VARCHAR (50)  NULL,
    [DESC_STATO_CLIENTE]       CHAR (1)      NOT NULL,
    [STATO_LAVORAZIONE]        VARCHAR (50)  NULL,
    [ID_Tipo_persona]          CHAR (1)      NULL,
    [Descrizione_tipo_persone] VARCHAR (50)  NULL,
    [PIVA]                     CHAR (16)     DEFAULT ((0)) NULL,
    [CODFISC]                  CHAR (16)     DEFAULT ((0)) NULL,
    [RAGIONESOCIALE]           VARCHAR (200) NOT NULL,
    [INDIRIZZO]                VARCHAR (100) NULL,
    [CAP]                      VARCHAR (10)  NULL,
    [COMUNE]                   VARCHAR (100) NULL,
    [PROVINCIA]                VARCHAR (5)   NULL,
    [NAZIONE]                  VARCHAR (3)   NULL,
    [FAX]                      VARCHAR (50)  NULL,
    [EMAIL]                    VARCHAR (100) NULL,
    [TELEFONO]                 VARCHAR (50)  NULL,
    [PEC]                      VARCHAR (100) NULL,
    [CELLULARE]                VARCHAR (10)  NULL,
    [ID_AGENTE]                VARCHAR (10)  NULL,
    [DESCR_AGENTE]             VARCHAR (50)  NULL,
    [ID_AGENZIA]               VARCHAR (10)  NULL,
    [DESCR_AGENZIA]            VARCHAR (50)  NULL,
    [TRATTENUTA_0_5]           CHAR (1)      NULL,
    [CONVENZIONE]              VARCHAR (250) NULL,
    [FORMA_GIURIDICA]          VARCHAR (100) NULL,
    [NOME]                     VARCHAR (100) NULL,
    [COGNOME]                  VARCHAR (100) NULL,
    [Classe_di_rischio]        VARCHAR (250) NULL,
    [Descrizione_del_rischio]  VARCHAR (250) NULL,
    [FIDO]					   VARCHAR (250) DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC, [ID_AZIENDA] ASC, [ID_CLIENTE] ASC)
);


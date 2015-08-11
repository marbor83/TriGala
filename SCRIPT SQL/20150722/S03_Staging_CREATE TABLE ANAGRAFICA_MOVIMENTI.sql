CREATE TABLE [dbo].[GALA_ANAGRAFICA_MOVIMENTI] (
    [ID_RECORD]                      INT		     NOT NULL PRIMARY KEY,
    [ID_AZIENDA]                     VARCHAR (10)    NOT NULL,
    [ID_CLIENTE]                     VARCHAR (30)    NOT NULL,
    [N_DOC]                          VARCHAR (50)    NOT NULL,
	[DATA_DOC] 						 DATETIME 		 NOT NULL, 
    [DATA_REG]                       DATETIME        NOT NULL,
    [DATA_ACQ]                       DATETIME        NOT NULL,
    [DATA_UPD]                       DATETIME        NULL,
    [DATA_SCAD]                      DATETIME        NOT NULL,
    [SEGNO]                          CHAR (1)        NOT NULL,
    [VALUTA]                         CHAR (3)        NOT NULL,
    [IMPORTO]                        NUMERIC (18, 2) NOT NULL,
    [ID_CAUSALE]                     VARCHAR (10)    NOT NULL,
    [DESCR_CAUSALE]                  VARCHAR (50)    NOT NULL,
    [ID_PAG_MOD]                     VARCHAR (10)    NULL,
    [DESCR_PAG_MOD]                  VARCHAR (50)    NULL,
    [ID_PAG_TER]                     VARCHAR (10)    NULL,
    [DESCR_PAG_TER]                  VARCHAR (50)    NULL,
    [COMMODITY]                      VARCHAR (10)    NULL,
    [CODICE_PARTITA]                 VARCHAR (50)    NULL,
    [FACTOR]                         VARCHAR (50)    NULL,
    [Tipologia_fattura]              VARCHAR (100)   NULL,
    [Desscrizione_tipologia_fattura]  VARCHAR (200)   NULL,
    [URL] 							 VARCHAR(2048) 	 NULL
);


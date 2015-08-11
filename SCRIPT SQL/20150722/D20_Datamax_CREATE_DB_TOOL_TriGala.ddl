/*
ALTER TABLE GALA_CB.CB_EntitaCampi DROP CONSTRAINT FKCB_EntitaC895445;
ALTER TABLE GALA_CB.CB_EntitaCampi DROP CONSTRAINT FKCB_EntitaC26772;
ALTER TABLE GALA_CB.CB_EntitaCampiValoriAmmessi DROP CONSTRAINT FKCB_EntitaC134717;
ALTER TABLE GALA_CB.CB_Elaborazioni DROP CONSTRAINT FKCB_Elabora281711;
ALTER TABLE GALA_CB.CB_Elaborazioni DROP CONSTRAINT FKCB_Elabora72081;
ALTER TABLE GALA_CB.CB_Elaborazioni DROP CONSTRAINT FKCB_Elabora877250;
DROP TABLE GALA_CB.CB_Entita;
DROP TABLE GALA_CB.CB_EntitaCampi;
DROP TABLE GALA_CB.CB_TipoCampo;
DROP TABLE GALA_CB.CB_EntitaCampiValoriAmmessi;
DROP TABLE GALA_CB.CB_Elaborazioni;
DROP TABLE GALA_CB.CB_TipologiaElaborazione;
DROP TABLE GALA_CB.CB_Esito;
*/

CREATE TABLE GALA_CB.CB_Entita (id int IDENTITY NOT NULL, Nome varchar(100) NOT NULL, NomeTabellaDestinazione varchar(100) NOT NULL, ProceduraEstrazione varchar(100) NOT NULL, PathCSV varchar(512) NOT NULL, PathCSVscarti varchar(512) NOT NULL, OrdineElaborazione int NOT NULL, Attivo bit DEFAULT 1 NOT NULL, PRIMARY KEY (id));
CREATE TABLE GALA_CB.CB_EntitaCampi (id int IDENTITY NOT NULL, id_Entita int NOT NULL, NomeCampoOrigine varchar(100) NOT NULL, NomeCampoDestinazione varchar(100) NOT NULL, Descrizione varchar(100) NOT NULL, Obbligatorio bit NOT NULL, Lunghezza int NOT NULL, id_TipoCampo int NOT NULL, OrdineEstrazione int NOT NULL, Attivo bit DEFAULT 1 NOT NULL, PRIMARY KEY (id));
CREATE TABLE GALA_CB.CB_TipoCampo (id int IDENTITY NOT NULL, Nome varchar(100) NOT NULL, PRIMARY KEY (id));
CREATE TABLE GALA_CB.CB_EntitaCampiValoriAmmessi (id int IDENTITY NOT NULL, id_EntitaCampi int NOT NULL, Valore varchar(100) NOT NULL, Attivo bit DEFAULT 1 NOT NULL, PRIMARY KEY (id));
CREATE TABLE GALA_CB.CB_Elaborazioni (id int IDENTITY NOT NULL, id_Entita int NOT NULL, id_Tipologia int NOT NULL, DataDa datetime NOT NULL, DataA datetime NULL, IdCliente int NULL, DataElaborazione datetime NOT NULL, id_Esito int NOT NULL, PRIMARY KEY (id));
CREATE TABLE GALA_CB.CB_TipologiaElaborazione (id int NOT NULL, Descrizione varchar(100) NOT NULL, PRIMARY KEY (id));
CREATE TABLE GALA_CB.CB_Esito (id int IDENTITY NOT NULL, Descrizione varchar(100) NOT NULL, PRIMARY KEY (id));
ALTER TABLE GALA_CB.CB_EntitaCampi ADD CONSTRAINT FKCB_EntitaC895445 FOREIGN KEY (id_Entita) REFERENCES GALA_CB.CB_Entita (id);
ALTER TABLE GALA_CB.CB_EntitaCampi ADD CONSTRAINT FKCB_EntitaC26772 FOREIGN KEY (id_TipoCampo) REFERENCES GALA_CB.CB_TipoCampo (id);
ALTER TABLE GALA_CB.CB_EntitaCampiValoriAmmessi ADD CONSTRAINT FKCB_EntitaC134717 FOREIGN KEY (id_EntitaCampi) REFERENCES GALA_CB.CB_EntitaCampi (id);
ALTER TABLE GALA_CB.CB_Elaborazioni ADD CONSTRAINT FKCB_Elabora281711 FOREIGN KEY (id_Entita) REFERENCES GALA_CB.CB_Entita (id);
ALTER TABLE GALA_CB.CB_Elaborazioni ADD CONSTRAINT FKCB_Elabora72081 FOREIGN KEY (id_Tipologia) REFERENCES GALA_CB.CB_TipologiaElaborazione (id);
ALTER TABLE GALA_CB.CB_Elaborazioni ADD CONSTRAINT FKCB_Elabora877250 FOREIGN KEY (id_Esito) REFERENCES GALA_CB.CB_Esito (id);


SET IDENTITY_INSERT GALA_CB.CB_Entita ON;
INSERT INTO GALA_CB.CB_Entita(id, Nome, NomeTabellaDestinazione, ProceduraEstrazione, PathCSV, PathCSVscarti, OrdineElaborazione, Attivo) VALUES (1001, 'Anagrafica Clienti', 'GALA_ANAGRAFICA_CLIENTI', 'GALA_CB.CB_Sp_GetAnagraficaClienti', '\\path\', '\\path\', 2, 1);
INSERT INTO GALA_CB.CB_Entita(id, Nome, NomeTabellaDestinazione, ProceduraEstrazione, PathCSV, PathCSVscarti, OrdineElaborazione, Attivo) VALUES (1002, 'Anagrafica Contratti', 'GALA_ANAGRAFICA_CONTRATTI', 'GALA_CB.CB_Sp_GetAnagraficaContratti', '\\path\', '\\path\', 1, 1);
INSERT INTO GALA_CB.CB_Entita(id, Nome, NomeTabellaDestinazione, ProceduraEstrazione, PathCSV, PathCSVscarti, OrdineElaborazione, Attivo) VALUES (1003, 'Dati POD PDR', 'GALA_POD_PDR', 'GALA_CB.CB_Sp_GetPodPdr', '\\path\', '\\path\', 4, 1);
INSERT INTO GALA_CB.CB_Entita(id, Nome, NomeTabellaDestinazione, ProceduraEstrazione, PathCSV, PathCSVscarti, OrdineElaborazione, Attivo) VALUES (1004, 'Anagrafica Movimenti', 'GALA_ANAGRAFICA_MOVIMENTI', 'GALA_CB.CB_Sp_GetAnagraficaMovimenti', '\\path\', '\\path\', 5, 1);
INSERT INTO GALA_CB.CB_Entita(id, Nome, NomeTabellaDestinazione, ProceduraEstrazione, PathCSV, PathCSVscarti, OrdineElaborazione, Attivo) VALUES (1005, 'Anagrafica Contatti', 'GALA_CONTATTI', 'GALA_CB.CB_Sp_GetAnagraficaContatti', '\\path\', '\\path\', 3, 1);
INSERT INTO GALA_CB.CB_Entita(id, Nome, NomeTabellaDestinazione, ProceduraEstrazione, PathCSV, PathCSVscarti, OrdineElaborazione, Attivo) VALUES (1006, 'Garanzie Factor', 'GALA_GARANZIE_FACTOR', 'GALA_CB.CB_Sp_GetGaranzieFactor', '\\path\', '\\path\', 6, 1);
INSERT INTO GALA_CB.CB_Entita(id, Nome, NomeTabellaDestinazione, ProceduraEstrazione, PathCSV, PathCSVscarti, OrdineElaborazione, Attivo) VALUES (1007, 'Esposizione', 'GALA_ESPOSIZIONE', 'GALA_CB.CB_Sp_SetEsposizione', '\\path\', '\\path\', 7, 0);
SET IDENTITY_INSERT GALA_CB.CB_Entita OFF;

SET IDENTITY_INSERT GALA_CB.CB_TipoCampo ON;
INSERT INTO GALA_CB.CB_TipoCampo(id, Nome) VALUES (10, 'INT');
INSERT INTO GALA_CB.CB_TipoCampo(id, Nome) VALUES (20, 'STRING');
INSERT INTO GALA_CB.CB_TipoCampo(id, Nome) VALUES (30, 'DATE');
INSERT INTO GALA_CB.CB_TipoCampo(id, Nome) VALUES (40, 'DECIMAL2');
SET IDENTITY_INSERT GALA_CB.CB_TipoCampo OFF;

SET IDENTITY_INSERT GALA_CB.CB_EntitaCampi ON;
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (1, 1005, 'ID_CONTATTO', 'ID_CONTATTO', 'ID CONTATTO', 1, 50, 20, 1, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (2, 1005, 'ID_CLIENTE', 'ID_CLIENTE', 'ID CLIENTE', 1, 30, 20, 2, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (3, 1005, 'ID_AZIENDA', 'ID_AZIENDA', 'ID AZIENDA', 1, 10, 20, 3, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (4, 1005, 'NOME', 'NOME', 'NOME', 0, 100, 20, 4, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (5, 1005, 'COGNOME', 'COGNOME', 'COGNOME', 0, 100, 20, 5, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (6, 1005, 'ID_TIPOCONTATTO', 'ID_TIPOCONTATTO', 'ID TIPO CONTATTO', 1, 10, 20, 6, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (7, 1005, 'TIPOCONTATTO', 'TIPOCONTATTO', 'TIPO CONTATTO', 1, 100, 20, 7, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (8, 1005, 'CODFISC', 'CODFISC', 'CODICE FISCALE', 0, 16, 20, 8, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (9, 1005, 'INDIRIZZO', 'INDIRIZZO', 'INDIRIZZO', 0, 255, 20, 9, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (10, 1005, 'CAP', 'CAP', 'CAP', 0, 10, 20, 10, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (11, 1005, 'COMUNE', 'COMUNE', 'COMUNE', 0, 100, 20, 11, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (12, 1005, 'PROVINCIA', 'PROVINCIA', 'PROVINCIA', 0, 5, 20, 12, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (13, 1005, 'NAZIONE', 'NAZIONE', 'NAZIONE', 0, 3, 20, 13, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (14, 1005, 'FAX', 'FAX', 'FAX', 0, 50, 20, 14, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (15, 1005, 'EMAIL', 'EMAIL', 'EMAIL', 0, 500, 20, 15, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (16, 1005, 'TELEFONO', 'TELEFONO', 'TELEFONO', 0, 50, 20, 16, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (17, 1005, 'PEC', 'PEC', 'PEC', 0, 100, 20, 17, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (18, 1005, 'CELLULARE', 'CELLULARE', 'CELLULARE', 0, 50, 20, 18, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (19, 1005, 'RAGIONESOCIALE', 'RAGIONESOCIALE', 'RAGIONE SOCIALE', 0, 110, 20, 19, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (20, 1005, 'PARTITAIVA', 'PARTITAIVA', 'PARTITA IVA', 0, 50, 20, 20, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (21, 1005, 'ID_TIPO_PERSONA', 'ID_TIPO_PERSONA', 'ID_TIPO_PERSONA', 1, 1, 20, 21, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (22, 1005, 'DESCRIZIONE_TIPO_PERSONA', 'DESCRIZIONE_TIPO_PERSONA', 'DESCRIZIONE TIPO PERSONA', 1, 50, 20, 22, 1);
SET IDENTITY_INSERT GALA_CB.CB_EntitaCampi OFF;

SET IDENTITY_INSERT GALA_CB.CB_EntitaCampi ON;
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (30, 1006, 'ID_COUNTRY', 'ID_COUNTRY', 'ID COUNTRY', 1, 10, 20, 1, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (31, 1006, 'ID_AZIENDA', 'ID_AZIENDA', 'ID AZIENDA', 1, 10, 20, 2, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (32, 1006, 'ID_CLIENTE', 'ID_CLIENTE', 'ID CLIENTE', 1, 30, 20, 3, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (33, 1006, 'ID_GARANZIA', 'ID_GARANZIA', 'ID GARANZIA', 1, 10, 10, 4, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (34, 1006, 'ID_GAR_ENTE', 'ID_GAR_ENTE', 'ID_GAR_ENTE', 0, 9, 10, 5, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (35, 1006, 'DESCR_GAR_ENTE', 'DESCR_GAR_ENTE', 'DESCR GAR ENTE', 0, 100, 20, 6, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (36, 1006, 'PLAFOND', 'PLAFOND', 'PLAFOND', 1, 20, 40, 7, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (37, 1006, 'DATA_INIZIO', 'DATA_INIZIO', 'DATA INIZIO VALIDITA', 1, 25, 30, 8, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (38, 1006, 'DATA_FINE', 'DATA_FINE', 'DATA FINE VALIDITA', 1, 25, 30, 9, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (39, 1006, 'DESC_GAR_TIPO', 'DESC_GAR_TIPO', 'DESC GAR TIPO', 1, 100, 20, 10, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (40, 1006, 'ID_GAR_TIPO', 'ID_GAR_TIPO', 'ID GAR TIPO', 1, 9, 10, 11, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (41, 1006, 'PERSONALE', 'PERSONALE', 'PERSONALE', 1, 1, 20, 12, 1);
SET IDENTITY_INSERT GALA_CB.CB_EntitaCampi OFF;

SET IDENTITY_INSERT GALA_CB.CB_EntitaCampi ON;
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (50, 1001, 'ID_AZIENDA', 'ID_AZIENDA', 'ID AZIENDA', 1, 10, 20, 1, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (51, 1001, 'ID_CLIENTE', 'ID_CLIENTE', 'ID CLIENTE', 1, 30, 20, 2, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (52, 1001, 'ID_MASTER', 'ID_MASTER', 'ID MASTER', 1, 10, 20, 3, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (53, 1001, 'ID_TIPO_CLIENTE', 'ID_TIPO_CLIENTE', 'ID TIPO CLIENTE', 0, 10, 20, 4, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (54, 1001, 'DESCR_TIPO_CLIENTE', 'DESCR_TIPO_CLIENTE', 'DESCR TIPO CLIENTE', 0, 50, 20, 5, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (55, 1001, 'DESC_STATO_CLIENTE', 'DESC_STATO_CLIENTE', 'DESC STATO CLIENTE', 1, 10, 20, 6, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (56, 1001, 'STATO_LAVORAZIONE', 'STATO_LAVORAZIONE', 'STATO LAVORAZIONE', 0, 50, 20, 7, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (57, 1001, 'ID_TIPO_PERSONA', 'ID_TIPO_PERSONA', 'ID TIPO PERSONA', 1, 1, 20, 8, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (58, 1001, 'DESCRIZIONE_TIPO_PERSONE', 'DESCRIZIONE_TIPO_PERSONE', 'DESCRIZIONE TIPO PERSONE', 1, 50, 20, 9, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (59, 1001, 'PIVA', 'PIVA', 'PARTITA IVA', 0, 16, 20, 10, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (60, 1001, 'CODFISC', 'CODFISC', 'CODFISC', 0, 16, 20, 11, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (61, 1001, 'RAGIONESOCIALE', 'RAGIONESOCIALE', 'RAGIONE SOCIALE', 1, 200, 20, 12, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (62, 1001, 'INDIRIZZO', 'INDIRIZZO', 'INDIRIZZO', 0, 255, 20, 13, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (63, 1001, 'CAP', 'CAP', 'CAP', 0, 10, 20, 14, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (64, 1001, 'COMUNE', 'COMUNE', 'COMUNE', 0, 100, 20, 15, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (65, 1001, 'PROVINCIA', 'PROVINCIA', 'PROVINCIA', 0, 5, 20, 16, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (66, 1001, 'NAZIONE', 'NAZIONE', 'NAZIONE', 0, 3, 20, 17, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (67, 1001, 'FAX', 'FAX', 'FAX', 0, 50, 20, 18, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (68, 1001, 'EMAIL', 'EMAIL', 'EMAIL', 0, 500, 20, 19, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (69, 1001, 'TELEFONO', 'TELEFONO', 'TELEFONO', 0, 50, 20, 20, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (70, 1001, 'PEC', 'PEC', 'PEC', 0, 100, 20, 21, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (71, 1001, 'CELLULARE', 'CELLULARE', 'CELLULARE', 0, 50, 20, 22, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (72, 1001, 'ID_AGENTE', 'ID_AGENTE', 'ID AGENTE', 0, 10, 20, 23, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (73, 1001, 'DESCR_AGENTE', 'DESCR_AGENTE', 'DESCR AGENTE', 0, 50, 20, 24, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (74, 1001, 'ID_AGENZIA', 'ID_AGENZIA', 'ID AGENZIA', 0, 10, 20, 25, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (75, 1001, 'DESCR_AGENZIA', 'DESCR_AGENZIA', 'DESCR AGENZIA', 0, 50, 20, 26, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (76, 1001, 'TRATTENUTA_0_5', 'TRATTENUTA_0_5', 'TRATTENUTA_0_5', 0, 1, 20, 27, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (77, 1001, 'CONVENZIONE', 'CONVENZIONE', 'CONVENZIONE', 0, 250, 20, 28, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (78, 1001, 'FORMA_GIURIDICA', 'FORMA_GIURIDICA', 'FORMA GIURIDICA', 0, 100, 20, 29, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (79, 1001, 'NOME', 'NOME', 'NOME', 0, 100, 20, 30, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (80, 1001, 'COGNOME', 'COGNOME', 'COGNOME', 0, 100, 20, 31, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (81, 1001, 'CLASSE_DI_RISCHIO', 'CLASSE_DI_RISCHIO', 'CLASSE DI RISCHIO', 0, 250, 20, 32, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (82, 1001, 'DESCRIZIONE_DEL_RISCHIO', 'DESCRIZIONE_DEL_RISCHIO', 'DESCRIZIONE DEL RISCHIO', 0, 250, 20, 33, 1);
SET IDENTITY_INSERT GALA_CB.CB_EntitaCampi OFF;


SET IDENTITY_INSERT GALA_CB.CB_EntitaCampi ON;
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (90, 1002, 'ID_CONTRATTO', 'ID_CONTRATTO', 'ID CONTRATTO', 1, 20, 20, 1, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (91, 1002, 'ID_AZIENDA', 'ID_AZIENDA', 'ID AZIENDA', 1, 10, 20, 2, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (92, 1002, 'ID_CLIENTE', 'ID_CLIENTE', 'ID CLIENTE', 1, 30, 20, 3, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (93, 1002, 'STATO', 'STATO', 'STATO', 1, 10, 20, 4, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (94, 1002, 'DATA_INIZIO', 'DATA_INIZIO', 'DATA INIZIO', 0, 30, 30, 5, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (95, 1002, 'DATA_FINE', 'DATA_FINE', 'DATA FINE', 0, 30, 30, 6, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (96, 1002, 'DATA_CESSAZIONE', 'DATA_CESSAZIONE', 'DATA CESSAZIONE', 0, 30, 30, 7, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (97, 1002, 'CONV_APPARTENENZA', 'CONV_APPARTENENZA', 'CONV APPARTENENZA', 0, 100, 20, 8, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (98, 1002, 'ID_BU', 'ID_BU', 'ID BU', 0, 10, 20, 9, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (99, 1002, 'DESCR_BU', 'DESCR_BU', 'DESCR_BU', 0, 50, 20, 10, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (100, 1002, 'ID_AREA', 'ID_AREA', 'ID AREA', 0, 10, 20, 11, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (101, 1002, 'DESCR_AREA', 'DESCR_AREA', 'DESCR AREA', 0, 50, 20, 12, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (102, 1002, 'ID_AGENTE', 'ID_AGENTE', 'ID AGENTE', 0, 10, 20, 13, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (103, 1002, 'DESCR_AGENTE', 'DESCR_AGENTE', 'DESCR AGENTE', 0, 50, 20, 14, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (104, 1002, 'CENTRO_DI_COSTO', 'CENTRO_DI_COSTO', 'CENTRO DI COSTO', 0, 50, 20, 15, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (105, 1002, 'ID_PAG_MOD', 'ID_PAG_MOD', 'ID MODALITA PAGAMENTO', 0, 10, 20, 16, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (106, 1002, 'DESCR_PAG_MOD', 'DESCR_PAG_MOD', 'DESCRIZIONE MODALITA PAGAMENTO', 0, 50, 20, 17, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (107, 1002, 'CIG', 'CIG', 'CIG', 0, 200, 20, 18, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (108, 1002, 'CUP', 'CUP', 'CUP', 0, 200, 20, 19, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (109, 1002, 'ODA', 'ODA', 'ODA', 0, 200, 20, 20, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (110, 1002, 'IDTIPOCONTRATTO', 'IDTIPOCONTRATTO', 'ID TIPO CONTRATTO', 0, 10, 20, 21, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (111, 1002, 'DESCRIZIONETIPOCONTRATTO', 'DESCRIZIONETIPOCONTRATTO', 'DESCRIZIONE TIPO CONTRATTO', 0, 200, 20, 22, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (112, 1002, 'IDAGENZIA', 'IDAGENZIA', 'ID AGENZIA', 0, 10, 20, 23, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (113, 1002, 'NOMEAGENZIA', 'NOMEAGENZIA', 'NOME AGENZIA', 0, 200, 20, 24, 1);
SET IDENTITY_INSERT GALA_CB.CB_EntitaCampi OFF;


SET IDENTITY_INSERT GALA_CB.CB_EntitaCampi ON;
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (120, 1003, 'ID_AZIENDA', 'ID_AZIENDA', 'ID AZIENDA', 1, 10, 20, 1, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (121, 1003, 'ID_CLIENTE', 'ID_CLIENTE', 'ID CLIENTE', 1, 30, 20, 2, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (122, 1003, 'ID_CONTRATTO', 'ID_CONTRATTO', 'ID CONTRATTO', 0, 20, 20, 3, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (123, 1003, 'ID_RIGA_CONTRATTI', 'ID_RIGA_CONTRATTI', 'ID RIGA CONTRATTI', 1, 10, 10, 4, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (124, 1003, 'CODICE_DISPOSITIVO', 'CODICE_DISPOSITIVO', 'CODICE DISPOSITIVO', 1, 100, 20, 5, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (125, 1003, 'VOL_QTA', 'VOL_QTA', 'VOLUME QUANTITA', 1, 20, 40, 6, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (126, 1003, 'COMMODITY', 'COMMODITY', 'COMMODITY', 1, 10, 20, 7, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (127, 1003, 'INDIRIZZO', 'INDIRIZZO', 'CONV INDIRIZZO', 1, 100, 20, 8, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (128, 1003, 'CAP', 'CAP', 'CAP', 1, 10, 20, 9, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (129, 1003, 'COMUNE', 'COMUNE', 'COMUNE', 1, 100, 20, 10, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (130, 1003, 'PROVINCIA', 'PROVINCIA', 'PROVINCIA', 1, 5, 20, 11, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (131, 1003, 'NAZIONE', 'NAZIONE', 'NAZIONE', 1, 3, 20, 12, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (132, 1003, 'RIFERIMENTO', 'RIFERIMENTO', 'RIFERIMENTO', 0, 200, 20, 13, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (133, 1003, 'CONVENZIONE', 'CONVENZIONE', 'CONVENZIONE', 0, 100, 20, 14, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (134, 1003, 'CIG', 'CIG', 'CIG', 0, 200, 20, 15, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (135, 1003, 'CUP', 'CUP', 'CUP', 0, 200, 20, 16, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (136, 1003, 'ODA', 'ODA', 'ODA', 0, 200, 20, 17, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (137, 1003, 'CIG_GARA', 'CIG_GARA', 'CIG GARA', 0, 200, 20, 18, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (138, 1003, 'COMPONENTE_TARIFFARIA', 'COMPONENTE_TARIFFARIA', 'COMPONENTE TARIFFARIA', 0, 200, 20, 19, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (139, 1003, 'DATA_INIZIO', 'DATA_INIZIO', 'DATA INIZIO', 1, 30, 30, 20, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (140, 1003, 'DATA_FINE', 'DATA_FINE', 'DATA FINE', 1, 30, 30, 21, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (141, 1003, 'DATA_CESSAZIONE', 'DATA_CESSAZIONE', 'DATA CESSAZIONE', 0, 30, 30, 22, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (142, 1003, 'ID_PAG_MOD', 'ID_PAG_MOD', 'ID MODALITA PAGAMENTO', 1, 10, 20, 23, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (143, 1003, 'DESCR_PAG_MOD', 'DESCR_PAG_MOD', 'DESCRIZIONE MODALITA PAGAMENTO', 1, 50, 20, 24, 1);
SET IDENTITY_INSERT GALA_CB.CB_EntitaCampi OFF;


SET IDENTITY_INSERT GALA_CB.CB_EntitaCampi ON;
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (150, 1004, 'ID_RECORD', 'ID_RECORD', 'ID RECORD', 1, 50, 20, 1, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (151, 1004, 'ID_AZIENDA', 'ID_AZIENDA', 'ID AZIENDA', 1, 10, 20, 2, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (152, 1004, 'ID_CLIENTE', 'ID_CLIENTE', 'ID CLIENTE', 1, 30, 20, 3, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (153, 1004, 'N_DOC', 'N_DOC', 'NUMERO DOCUMENTO', 1, 50, 20, 4, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (154, 1004, 'DATA_DOC', 'DATA_DOC', 'DATA DOCUMENTO', 1, 30, 30, 5, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (155, 1004, 'DATA_REG', 'DATA_REG', 'DATA REGISTRAZIONE', 1, 30, 30, 6, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (156, 1004, 'DATA_ACQ', 'DATA_ACQ', 'DATA ACQUISIZIONE', 1, 30, 30, 7, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (157, 1004, 'DATA_UPD', 'DATA_UPD', 'DATA MODIFICA', 0, 30, 30, 8, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (158, 1004, 'DATA_SCAD', 'DATA_SCAD', 'DATA SCADENZA', 1, 30, 30, 9, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (159, 1004, 'SEGNO', 'SEGNO', 'SEGNO', 1, 1, 20, 10, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (160, 1004, 'VALUTA', 'VALUTA', 'VALUTA', 1, 3, 20, 11, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (161, 1004, 'IMPORTO', 'IMPORTO', 'IMPORTO', 1, 20, 40, 12, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (162, 1004, 'ID_CAUSALE', 'ID_CAUSALE', 'ID CAUSALE', 1, 10, 20, 13, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (163, 1004, 'DESCR_CAUSALE', 'DESCR_CAUSALE', 'DESCRIZIONE CAUSALE', 1, 50, 20, 14, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (164, 1004, 'ID_PAG_MOD', 'ID_PAG_MOD', 'ID MODALITA PAGAMENTO', 0, 10, 20, 15, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (165, 1004, 'DESCR_PAG_MOD', 'DESCR_PAG_MOD', 'DESCRIZIONE MODALITA PAGAMENTO', 0, 50, 20, 16, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (166, 1004, 'ID_PAG_TER', 'ID_PAG_TER', 'ID PAG TER', 0, 10, 20, 17, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (167, 1004, 'DESCR_PAG_TER', 'DESCR_PAG_TER', 'DESCR PAG TER', 0, 50, 20, 18, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (168, 1004, 'COMMODITY', 'COMMODITY', 'COMMODITY', 0, 10, 20, 19, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (169, 1004, 'CODICE_PARTITA', 'CODICE_PARTITA', 'CODICE PARTITA', 0, 50, 20, 20, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (170, 1004, 'FACTOR', 'FACTOR', 'FACTOR', 0, 50, 20, 21, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (171, 1004, 'TIPOLOGIA_FATTURA', 'TIPOLOGIA_FATTURA', 'TIPOLOGIA FATTURA', 0, 100, 20, 22, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (172, 1004, 'DESSCRIZIONE_TIPOLOGIA_FATTURA', 'DESSCRIZIONE_TIPOLOGIA_FATTURA', 'DESCRIZIONE TIPOLOGIA FATTURA', 0, 200, 20, 23, 1);
INSERT INTO GALA_CB.CB_EntitaCampi(id, id_Entita, NomeCampoOrigine, NomeCampoDestinazione, Descrizione, Obbligatorio, Lunghezza, id_TipoCampo, OrdineEstrazione, Attivo) VALUES (173, 1004, 'URL', 'URL', 'URL', 0, 2048, 20, 24, 1);
SET IDENTITY_INSERT GALA_CB.CB_EntitaCampi OFF;


SET IDENTITY_INSERT GALA_CB.CB_EntitaCampiValoriAmmessi ON;
INSERT INTO GALA_CB.CB_EntitaCampiValoriAmmessi(id, id_EntitaCampi, Valore, Attivo) VALUES (1, 168, 'EE', 1);
INSERT INTO GALA_CB.CB_EntitaCampiValoriAmmessi(id, id_EntitaCampi, Valore, Attivo) VALUES (2, 168, 'GAS', 1);
INSERT INTO GALA_CB.CB_EntitaCampiValoriAmmessi(id, id_EntitaCampi, Valore, Attivo) VALUES (3, 168, 'SERV', 1);

INSERT INTO GALA_CB.CB_EntitaCampiValoriAmmessi(id, id_EntitaCampi, Valore, Attivo) VALUES (4, 126, 'EE', 1);
INSERT INTO GALA_CB.CB_EntitaCampiValoriAmmessi(id, id_EntitaCampi, Valore, Attivo) VALUES (5, 126, 'GAS', 1);
INSERT INTO GALA_CB.CB_EntitaCampiValoriAmmessi(id, id_EntitaCampi, Valore, Attivo) VALUES (6, 126, 'SERV', 0);

INSERT INTO GALA_CB.CB_EntitaCampiValoriAmmessi(id, id_EntitaCampi, Valore, Attivo) VALUES (7, 159, 'D', 1);
INSERT INTO GALA_CB.CB_EntitaCampiValoriAmmessi(id, id_EntitaCampi, Valore, Attivo) VALUES (8, 159, 'A', 1);

INSERT INTO GALA_CB.CB_EntitaCampiValoriAmmessi(id, id_EntitaCampi, Valore, Attivo) VALUES (9, 21, 'F', 1);
INSERT INTO GALA_CB.CB_EntitaCampiValoriAmmessi(id, id_EntitaCampi, Valore, Attivo) VALUES (10, 21, 'G', 1);

INSERT INTO GALA_CB.CB_EntitaCampiValoriAmmessi(id, id_EntitaCampi, Valore, Attivo) VALUES (11, 41, 'S', 1);
INSERT INTO GALA_CB.CB_EntitaCampiValoriAmmessi(id, id_EntitaCampi, Valore, Attivo) VALUES (12, 41, 'N', 1);
SET IDENTITY_INSERT GALA_CB.CB_EntitaCampiValoriAmmessi OFF;

INSERT INTO GALA_CB.CB_TipologiaElaborazione(id, Descrizione) VALUES (100, 'AUTOMATICA');
INSERT INTO GALA_CB.CB_TipologiaElaborazione(id, Descrizione) VALUES (200, 'MANUALE');

SET IDENTITY_INSERT GALA_CB.CB_Esito ON;
INSERT INTO GALA_CB.CB_Esito(id, Descrizione) VALUES (10, 'OK');
INSERT INTO GALA_CB.CB_Esito(id, Descrizione) VALUES (-98, 'Tabella di destinazione piena');
INSERT INTO GALA_CB.CB_Esito(id, Descrizione) VALUES (-99, 'Errore durante l''elaborazione');
SET IDENTITY_INSERT GALA_CB.CB_Esito OFF;

CREATE TABLE GALA_CB.GALA_DESCRIZIONE_TIPO_FATTURA
(
	IDTipoDoc    varchar(10),
	IDCatDoc	 varchar(10),
	Descrizione		varchar(100),
	Attivo		int,
	Sigla		varchar(10),
	Tipo		varchar(10),
	IDSubTipoDoc	varchar(10),
	DescrizioneAlternativa	varchar(50),
	CodTrasco	varchar(10)
)


INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'FAE', N'FA', N'Fornitura energia', 1, N'FT', N'E', N'', N'', N'C1')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'FAG', N'FA', N'Fattura Fornitura Gas Naturale', 1, N'FT', N'G', N'', N'Fattura', N'C3')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'FCC', N'FA', N'Fattura servizi di Connessione', 1, N'FT', N'S', N'', N'Fattura', N'C5')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'FCI', N'FA', N'Fattura interessi di mora', 1, N'FT', N'S', N'', N'Fattura', N'C7')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'FCP', N'FA', N'FatturaPA Connessione', 1, N'FT', N'S', N'', N'Fattura', N'P5')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'FEP', N'FA', N'FatturaPA Energia', 1, N'FT', N'E', N'', N'Fattura', N'P1')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'FGP', N'FA', N'FatturaPA Gas', 1, N'FT', N'G', N'', N'Fattura', N'P3')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'FIP', N'FA', N'FatturaPA Interessi', 1, N'FT', N'S', N'', N'Fattura', N'P7')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'FSP', N'FA', N'FatturaPA Servizi', 1, N'FT', N'S', N'', N'Fattura', N'P1')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'FTE', N'FA', N'Fattura Fornitura Energia Elettrica', 0, N'', N'E', N'', N'Fattura', N'')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'FTG', N'FA', N'Fattura GAS - obsoleta', 0, N'', N'G', N'', N'Fattura', N'')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'FTM', N'FA', N'Fattura', 0, N'', N'S', N'', N'Fattura', N'')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'FTS', N'FA', N'Fattura Servizi', 1, N'FT', N'S', N'', N'Fattura', N'C1')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'NAE', N'NA', N'Nota accredito energia', 1, N'NC', N'E', N'', N'Nota Credito', N'C2')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'NAG', N'NA', N'Nota di Accredito Gas Naturale', 1, N'NC', N'G', N'', N'Nota Credito', N'C4')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'NCC', N'NA', N'Nota di accredito serv. di connessione', 1, N'NC', N'S', N'', N'Nota Credito', N'C6')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'NCE', N'NA', N'Nota di Accredito Energia Elettrica', 0, N'', N'E', N'', N'Nota Credito', N'')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'NCG', N'NA', N'Nota di Accredito GAS - obsoleta', 0, N'', N'G', N'', N'Nota Credito', N'')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'NCI', N'NA', N'Nota Credito Interessi di Mora', 1, N'NC', N'S', N'', N'Nota Credito', N'C8')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'NCM', N'NA', N'Nota di Accredito', 0, N'', N'S', N'', N'Nota Credito', N'')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'NCP', N'NA', N'Nota di CreditoPA Connessione', 1, N'NC', N'S', N'', N'Nota Credito', N'P6')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'NCS', N'NA', N'Nota di Accredito Servizi', 1, N'NC', N'S', N'', N'Nota Credito', N'C2')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'NDI', N'FA', N'Nota Debito Interessi di Mora', 0, N'', N'S', N'', N'Nota Debito', N'')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'NEP', N'NA', N'Nota di CreditoPA Energia', 1, N'NC', N'E', N'', N'Nota Credito', N'P2')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'NGP', N'NA', N'Nota di CreditoPA Gas', 1, N'NC', N'G', N'', N'Nota Credito', N'P4')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'NIP', N'NA', N'Nota di CreditoPA Interessi', 1, N'NC', N'S', N'', N'Nota Credito', N'P8')
INSERT INTO GALA_CB.[GALA_DESCRIZIONE_TIPO_FATTURA] ([IDTipoDoc], [IDCatDoc], [Descrizione], [Attivo], [Sigla], [Tipo], [IDSubTipoDoc], [DescrizioneAlternativa], [CodTrasco]) VALUES (N'NSP', N'NA', N'Nota di CreditoPA Servizi', 1, N'NC', N'S', N'', N'Nota Credito', N'P2')

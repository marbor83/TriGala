CREATE PROC [GALA_CB].[CB_Sp_GetAnagraficaMovimenti]
	@DataDa Datetime,
	@DataA  Datetime,
	@IdCliente INT
AS
BEGIN


select	m.idMovimento as Id_Record,
		'IT10' as id_Azienda,		
		s.IDAnagrafica as Id_Cliente,
		s.NumDocSuFatt as N_DOC,
		s.DataDoc as DATA_DOC,
		m.DATPMO as DATA_REG,
		m.DATPMO as Data_Acq,
		m.DATUMO as Data_Upd,
		s.DataScad DATA_SCAD,
		CASE WHEN ISNULL(m.importo, 0) < 0 THEN 'A' ELSE 'D' END as Segno,	
		'EUR' as Valuta,
		m.importo as IMPORTO,
		m.IDCausale as ID_CAUSALE,
		c.descrizione DESCR_CAUSALE,		
		CASE WHEN c.idCausale in (1,7) THEN doct.idMetodoPag  ELSE null END as ID_PAG_MOD,
		CASE WHEN c.idCausale in (1,7) THEN tp.descrizione  ELSE null END as DESCR_PAG_MOD,		
		null as ID_PAG_TER,
		null as DESCR_PAG_TER,
		(CASE	WHEN s.SiglaRegIVA In ('E','T') THEN 'EE'
				WHEN s.SiglaRegIVA In ('G','S') THEN 'GAS'
				WHEN s.SiglaRegIVA In ('C','I','N','O') THEN 'SERV'
				ELSE 'EE' END) as COMMODITY, 
		m.idFattura as CODICE_PARTITA,
		null as CODICE_PARTITA_STORNO,
		null as Factor,
		s.TipoDoc as Tipologia_fattura,		
		gdf.descrizione as  Desscrizione_tipologia_fattura,
		('\\VMTRIMP\Fatture\Attive\' +
			(CASE	WHEN s.SiglaRegIVA In ('E','T') THEN 'EE'
					WHEN s.SiglaRegIVA In ('G','S') THEN 'GAS'
					WHEN s.SiglaRegIVA In ('C','I','N','O') THEN 'SERV'
					ELSE 'EE' END) +
			'\' + s.IDAnagrafica + '\' + CONVERT(VARCHAR(4),bill.AnnoDoc) + '_' +
					(CASE	WHEN LEN(s.NumeroDoc) = 1 THEN '0000000'
							WHEN LEN(s.NumeroDoc) = 2 THEN '000000'
							WHEN LEN(s.NumeroDoc) = 3 THEN '00000'
							WHEN LEN(s.NumeroDoc) = 4 THEN '0000'
							WHEN LEN(s.NumeroDoc) = 5 THEN '000'
							WHEN LEN(s.NumeroDoc) = 6 THEN '00'
							WHEN LEN(s.NumeroDoc) = 7 THEN '0'
							ELSE '' END) +	s.NumeroDoc + s.SiglaRegIVA + '.pdf') as URL,
		doct.IDDocT as IDDocT	
INTO #tmpMovimenti
from Tes.Movimenti m
inner join Scadenzario s  on m.IDAnagrafica = s.IDAnagrafica and m.IDFattura=s.IDFattura 	
inner join dbo.Anagrafica a on m.IDAnagrafica=a.IDAnagrafica 
inner join tes.causali c on m.idCausale = c.idCausale
LEFT JOIN	BillingTGALA.dbo.DocT bill	ON s.IDTBilling = bill.IDDocT
LEFT JOIN	dbo.DocT doct	ON s.IDTBilling = doct.IDDocT
left join dbo.TipiPagamento tp on tp.IDTipoPagamento = doct.idMetodoPag
left join GALA_CB.GALA_DESCRIZIONE_TIPO_FATTURA gdf on s.TipoDoc = gdf.IdTipoDOC
where	a.IDStatoAnagrafica=1
		and m.IDAnagrafica!='100001'
		and m.IDStato>=0
		and exists (select	1 
					from	dbo.Contratti contr
					inner join dbo.ContrattiRighe cr on contr.IDContratto_Cnt=cr.IDContratto_Cnt
					where	contr.IDAnagrafica=m.IDAnagrafica
							and cr.IDStatoRiga != 11)
							--and getdate() between cr.DataInizioValidita and coalesce(cr.DataCessazione, cr.dataFineValidita, '20501231'))
AND m.DatPMO between @DataDa and @DataA
and m.IDAnagrafica = ISNULL(@IdCliente, m.IDAnagrafica)	



SELECT *, 
	   CASE WHEN IDDocT IS NULL THEN 0 ELSE  billingtgala.dbo.de_isstorno(IDDocT) END as STORNO
INTO #tmpMovimenti2
FROM #tmpMovimenti

UPDATE #tmpMovimenti2
SET CODICE_PARTITA_STORNO = (select distinct d.idfattura  --id della fattura stornata
							from docr c
								 inner join scadenzario d on c.iddoctparent = d.idtbilling							
							     and c.iddoct = #tmpMovimenti2.IDDocT
								 and c.idtiporiga = 4)
WHERE   STORNO=1 
AND idDOCT IS NOT NULL

/*UPDATE #tmpMovimenti
SET CODICE_PARTITA_STORNO = (select distinct d.idfattura  --id della fattura stornata
							from scadenzario a
								 inner join doct b on a.idtbilling = b.iddoct
								 inner join docr c on b.iddoct = c.iddoct
								 inner join scadenzario d on c.iddoctparent = d.idtbilling
							where a.idfattura= #tmpMovimenti.CODICE_PARTITA
								 and c.idtiporiga = 4)
WHERE   IDDocT IS NOT NULL
	AND billingtgala.dbo.de_isstorno(IDDocT) = 1*/							
 	


SELECT Id_Record, id_Azienda, Id_Cliente, N_DOC,
		DATA_DOC, DATA_REG, Data_Acq, Data_Upd, DATA_SCAD,
		Segno, Valuta, IMPORTO,
		ID_CAUSALE, DESCR_CAUSALE, ID_PAG_MOD, DESCR_PAG_MOD, ID_PAG_TER, DESCR_PAG_TER,
		COMMODITY, ISNULL(CODICE_PARTITA_STORNO,CODICE_PARTITA) AS CODICE_PARTITA, Factor,
		Tipologia_fattura, Desscrizione_tipologia_fattura, URL
FROM #tmpMovimenti2



DROP TABLE #tmpMovimenti
DROP TABLE #tmpMovimenti2




END
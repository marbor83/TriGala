CREATE PROC GALA_CB.CB_Sp_GetAnagraficaMovimenti
	@DataDa Datetime,
	@DataA  Datetime,
	@IdCliente INT
AS
BEGIN

select	 m.idMovimento as Id_Record,
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
							ELSE '' END) +	s.NumeroDoc + s.SiglaRegIVA + '.pdf') as URL	
from Tes.Movimenti m
inner join Scadenzario s  on m.IDFattura=s.IDFattura	
inner join dbo.Anagrafica a on s.IDAnagrafica=a.IDAnagrafica 
inner join tes.causali c on m.idCausale = c.idCausale
LEFT JOIN	BillingTGALA.dbo.DocT bill	ON s.IDTBilling = bill.IDDocT
LEFT JOIN	dbo.DocT doct	ON s.IDTBilling = doct.IDDocT
left join dbo.TipiPagamento tp on tp.IDTipoPagamento = doct.idMetodoPag
left join GALA_CB.GALA_DESCRIZIONE_TIPO_FATTURA gdf on s.TipoDoc = gdf.IdTipoDOC
where	a.IDStatoAnagrafica=1
		and a.IDAnagrafica!='100001'
		and m.IDStato>=0
		--and m.IDCausale not in (1, 7) --Valorizzare modalità pagamento solo per 1 e 7
		/*and exists (select	1 
					from	dbo.Contratti c
					inner join dbo.ContrattiRighe cr on c.IDContratto_Cnt=cr.IDContratto_Cnt
					where	c.IDAnagrafica=a.IDAnagrafica
							and cr.IDStatoRiga != 11
							and getdate() between cr.DataInizioValidita and coalesce(cr.DataCessazione, cr.dataFineValidita, '20501231'))*/
AND m.DatPMO between @DataDa and @DataA
and s.IDAnagrafica = ISNULL(@IdCliente, s.IDAnagrafica)	


END
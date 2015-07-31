select	 m.idMovimento as Id_Record,
		'IT10' as id_Azienda,		
		s.IDAnagrafica as Id_Cliente,
		s.NumDocSuFatt NumerodDoc,
		s.DataDoc,
		m.DATPMO as DataReg,
		m.DATPMO as DataAcq,
		m.DATUMO as DataUpd,
		s.DataScad DataScadenza,
		CASE WHEN ISNULL(m.importo, 0) < 0 THEN 'A' ELSE 'D' END as Segno,	
		'EUR' as Valuta,
		m.importo,
		m.IDCausale,
		m.Descrizione,
		CASE WHEN c.idCausale in (1,7) THEN s.modPag  ELSE null END as IdModalitaPagamento,
		CASE WHEN c.idCausale in (1,7) THEN c.descrizione  ELSE null END as Descr_Pag_Mod,
		null as idPagTer,
		null as DescPagTer,
		(CASE	WHEN s.SiglaRegIVA In ('E','T') THEN 'EE'
				WHEN s.SiglaRegIVA In ('G','S') THEN 'GAS'
				WHEN s.SiglaRegIVA In ('C','I','N','O') THEN 'SERV'
				ELSE 'EE' END) as comodity, 
		m.idFattura as codicePartita,
		null as Factor,
		s.TipoDoc as tipologia_fattura,		
		gdf.descrizione as  descrizione_tipologia_fattura,
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
from	dbo.Anagrafica a
inner join Scadenzario s on a.IDAnagrafica=s.IDAnagrafica
inner join Tes.Movimenti m on s.IDFattura=m.IDFattura
inner join tes.causali c on m.idCausale = c.idCausale
left join dbo.TipiPagamento tp on tp.IDTipoPagamento = s.modPag
LEFT JOIN	BillingTGALA.dbo.DocT bill	ON s.IDTBilling = bill.IDDocT
left join dbo.GALA_DESCRIZIONE_TIPO_FATTURA gdf on s.TipoDoc = gdf.IdTipoDOC
where	a.IDStatoAnagrafica=1
		and a.IDAnagrafica!='100001'
		and m.IDStato>=0
		--and m.IDCausale not in (1, 7) --Valorizzare modalità pagamento solo per 1 e 7
		and exists (select	1 
					from	dbo.Contratti c
					inner join dbo.ContrattiRighe cr on c.IDContratto_Cnt=cr.IDContratto_Cnt
					where	c.IDAnagrafica=a.IDAnagrafica
							and cr.IDStatoRiga != 11
							and getdate() between cr.DataInizioValidita and coalesce(cr.DataCessazione, cr.dataFineValidita, '20501231'))
and year(m.DATPMO) = 2015 and MONTH(m.DATPMO) between 7 and 12

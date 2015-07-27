select	 m.idMovimento as Id_Record,
		'IT10' as id_Azienda,		
		s.IDAnagrafica as Id_Cliente,
		s.NumDocSuFatt NumerodDoc,
		s.DataDoc,
		m.DATPMO as DataReg,
		m.DATPMO as DataAcq,
		m.DATUMO as DataUpd,
		s.DataScad DataScadenza,
		CASE WHEN ISNULL(m.importo, 0) < 0 THEN 'D' ELSE 'A' END as Segno,	
		'EUR' as Valuta,
		m.importo,
		m.IDCausale,
		m.Descrizione,
		CASE WHEN m.idCausale in (1,7) THEN s.modPag  ELSE null END as IdModalitaPagamento,
		CASE WHEN m.idCausale in (1,7) THEN tp.descrizione  ELSE null END as Descr_Pag_Mod,
		null as idPagTer,
		null as DescPagTer,
		null as comodity, --comodity EE o GG da capire come recuperare il valore 
		m.idFattura as codicePartita,
		null as Factor,
		s.TipoDoc as tipologia_fattura,		
		null descrizione_tipologia_fattura,-- descrizione tipologia fattura	 da capire come recuperare
		null as url,	
		a.IDTERP CLienteSAP,		
		year(s.DataDoc) AnnoDoc,		
		s.Saldo,
		s.Importo ImportoFattura,
		m.Importo,		
		m.DataIncasso		
from	dbo.Anagrafica a
inner join Scadenzario s on a.IDAnagrafica=s.IDAnagrafica
inner join Tes.Movimenti m on s.IDFattura=m.IDFattura
left join dbo.TipiPagamento tp on tp.IDTipoPagamento = s.modPag
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

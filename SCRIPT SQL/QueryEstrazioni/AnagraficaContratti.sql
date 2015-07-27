select	c.IDContratto,
		'IT10' as idAzienda,
		c.IDAnagrafica IdCliente,
		CASE WHEN (select COUNT(*) from ContrattiRighe cr where c.IDContratto = cr.IDContratto_cnt )= 0 THEN 'PROSPECT'  ELSE 
			CASE WHEN (select COUNT(*) from ContrattiRighe cr where c.IDContratto = cr.IDContratto_cnt and cr.IDStatoRiga=4 )>0 THEN 'ATTIVO'  ELSE 'CESSATO' END
		END as Stato, -- Da verificare logica , ora: nessuna riga contrastto = 'PROSPECT', almeno 1 attiva ='ATTIVA' else 'CESSATO'		
		null as DataInizio,
		null as DataFine,
		null as DataCessazione,
		null as ConvAppartenenza,
		null ID_BU,
		null DESCR_BU,
		null ID_AREA,
		null DESCR_AREA,		
		c.IDAgente,
		ag.Nome DescrizioneAgente,
		null as centroCosto,
		null as idPagMod,
		null as DescrPagMod,
		null as CIG,
		null as CUP,
		null as ODA,
		c.IDTipoContratto,
		t.Descrizione TipoContratto,
		c.IDAgenzia,
		ag1.Nome Agenzia,
		c.DataStipula
from	dbo.Contratti c
inner join dbo.Anagrafica a on c.IDAnagrafica=a.IDAnagrafica
inner join [dbo].[TipoContratto] t on c.IDTipoContratto=t.IDTipoContratto
left outer join dbo.AgentiAnagrafica ag on c.IDAgente=ag.IDAgente
left outer join dbo.AgentiAnagrafica ag1 on c.IDAgenzia=ag1.IDAgente
where	a.IDStatoAnagrafica=1
		and a.IDAnagrafica!='100001'
		/*and exists (select	1 
					from	dbo.ContrattiRighe cr 
					where	c.IDContratto_Cnt=cr.IDContratto_Cnt
							and cr.IDStatoRiga != 11
							and cr.IDMacroStatoRiga in (2, 3)
							and getdate() between cr.DataInizioValidita and coalesce(cr.DataCessazione, cr.dataFineValidita, '20501231'))
order by a.IDAnagrafica, c.IDContratto*/
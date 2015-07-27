select *
from (
select	'IT10' idAzienda,		
		ans.IDAnagrafica as IdCliente,
		c.IDContratto,
		cr.IDRigaContratto,
		ecs.POD CodiceDispositivo,
		'TRILANCE_EMPTY' as vol_qta, -- da capire meglio il calcolo del volume
		'TRILANCE_EMPTY' as commodity, -- da capire dove recuperarlo
		ans.Indirizzo,
		ans.CAP,
		ans.Localita,
		ans.Provincia,
		ans.Nazione,	
		null as riferimento,
		null as convenzione,
		null as CIG,
		null as CUP,
		null as ODA,
		'TRILANCE_EMPTY' as componenteTariffaria, -- da capire come recuperarlo		
		cr.DataInizioValidita as DataInizio,
		cr.DataFineValidita as DataFine,
		cr.DataCessazione as DataCessazione, -- da rivedere la logica cessazione
		cr.IDSede,
		cr.IDTipoPagamento ID_Pag_Mod,
		tp.Descrizione		
from	dbo.Contratti c
inner join dbo.Anagrafica a on c.IDAnagrafica=a.IDAnagrafica
inner join dbo.ContrattiRighe cr on c.IDContratto_Cnt=cr.IDContratto_Cnt
left outer join dbo.eneClienteSedi ecs on cr.IDSede=ecs.IDSede
inner join dbo.AnaSedi ans on cr.IDSede=ans.IDSede
left outer join dbo.TipiPagamento tp on cr.IDTipoPagamento = tp.IDTipoPagamento
where	a.IDStatoAnagrafica=1
		and a.IDAnagrafica!='100001'
		and cr.IDStatoRiga != 11
		and cr.IDMacroStatoRiga in (2, 3)
		and getdate() between cr.DataInizioValidita and coalesce(cr.DataCessazione, cr.dataFineValidita, '20501231')
		and getdate() between ecs.dtInizioVal and isnull(ecs.dtFineVal, '20501231')
union all 
select	'IT10' idAzienda,		
		ans.IDAnagrafica as IdCliente,
		c.IDContratto,
		cr.IDRigaContratto,
		gcs.CodPDR CodiceDispositivo,
		'TRILANCE_EMPTY' as vol_qta, -- da capire meglio il calcolo del volume
		'TRILANCE_EMPTY' as commodity, -- da capire dove recuperarlo
		ans.Indirizzo,
		ans.CAP,
		ans.Localita,
		ans.Provincia,
		ans.Nazione,	
		null as riferimento,
		null as convenzione,
		null as CIG,
		null as CUP,
		null as ODA,
		'TRILANCE_EMPTY' as componenteTariffaria, -- da capire come recuperarlo		
		cr.DataInizioValidita as DataInizio,
		cr.DataFineValidita as DataFine,
		cr.DataCessazione as DataCessazione, -- da rivedere la logica cessazione
		cr.IDSede,
		cr.IDTipoPagamento ID_Pag_Mod,
		tp.Descrizione	
from	dbo.Contratti c
inner join dbo.Anagrafica a on c.IDAnagrafica=a.IDAnagrafica
inner join dbo.ContrattiRighe cr on c.IDContratto_Cnt=cr.IDContratto_Cnt
left outer join dbo.gasClienteSedi gcs on cr.IDSede=gcs.IDSede
inner join dbo.AnaSedi ans on cr.IDSede=ans.IDSede
left outer join dbo.TipiPagamento tp on cr.IDTipoPagamento = tp.IDTipoPagamento
where	a.IDStatoAnagrafica=1
		and a.IDAnagrafica!='100001'
		and cr.IDStatoRiga != 11
		and cr.IDMacroStatoRiga in (2, 3)
		and getdate() between cr.DataInizioValidita and coalesce(cr.DataCessazione, cr.dataFineValidita, '20501231')
		and getdate() between gcs.validoDal and isnull(gcs.validoAl, '20501231')
) V
order by IdCliente, IDContratto, IDRigaContratto
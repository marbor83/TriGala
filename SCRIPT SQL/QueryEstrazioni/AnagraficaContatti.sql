select	--distinct capire motivo distinct
		ac.IDContatto,
		a.IDAnagrafica as idCliente,
		'IT10' as idAzienda,
		case when ac.TipoPersonaContatto='F' then ac.Nome  else '' end Nome,
		case when ac.TipoPersonaContatto='F' then ac.Cognome  else '' end Cognome,						
		t.Descrizione TipoContatto,		
		ac.TipoPersonaContatto,
		case when ac.TipoPersonaContatto='G' then ac.RagSoc  else '' end RagSoc,
		ac.CFisc,
		ac.Indirizzo,
		ac.CAP,
		ac.Localita,
		ac.Provincia,
		ac.Nazione,
		ac.Fax,
		ac.EMail,
		ac.Telefono1 Telefono,
		ac.Pec,
		ac.Cellulare,					
		ac.PIVA,
		t.IDTipoContatto
from	dbo.AnaContatti ac
inner join dbo.Anagrafica a on ac.IDAnagrafica=a.IDAnagrafica
inner join dbo.AnaContattiTipoMatch m on ac.IDContatto=m.IDContatto
inner join dbo.AnaContattiTipo t on m.IDTipoCOntatto=t.IDTipoContatto
where	a.IDStatoAnagrafica=1
		and a.IDAnagrafica!='100001'
		and exists (select	1 
					from	dbo.Contratti c
					inner join dbo.ContrattiRighe cr on c.IDContratto_Cnt=cr.IDContratto_Cnt
					where	c.IDAnagrafica=a.IDAnagrafica
							and cr.IDStatoRiga != 11
							and getdate() between cr.DataInizioValidita and coalesce(cr.DataCessazione, cr.dataFineValidita, '20501231'))
order by a.IDAnagrafica, ac.IDContatto
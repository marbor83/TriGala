select	'IT10' as IDAzienda,
		a.IDAnagrafica IdCliente,		
		'TRILANCE_EMPTY' as id_master, -- da capire dove recuperare l informazione di cliente master
		af.IDAnaForma IDTipoCliente,
		af.Descrizione DescrizioneTipoCliente,
		CASE WHEN (select COUNT(*) from Contratti c, ContrattiRighe cr where c.IDContratto = cr.IDContratto_cnt and c.IDAnagrafica=a.IDAnagrafica )= 0 THEN 'PROSPECT'  ELSE 
			CASE WHEN (select COUNT(*) from Contratti c, ContrattiRighe cr where c.IDContratto = cr.IDContratto_cnt and c.IDAnagrafica=a.IDAnagrafica and cr.IDStatoRiga=4 )>0 THEN 'ATTIVO'  ELSE 'CESSATO' END
		END as descStatoCliente, -- Da verificare logica , ora: nessuna riga contrastto = 'PROSPECT', almeno 1 attiva ='ATTIVA' else 'CESSATO'
		null StatoLavorazione,
		a.TipoPersona as idTipoPersona,
		CASE WHEN a.TipoPersona = 'F' THEN 'FISICA'  ELSE 'GIURIDICA' END as DescrizioneTipoPersona,
		a.PIVA,
		a.CFISC,
		a.RagSoc,
		a.Indirizzo,
		a.CAP,
		a.Localita,
		a.Provincia,
		a.Nazione,
		a.NumeroFax Fax,
		a.Email,
		a.NumeroTelefonico Telefono,
		'TRILANCE_EMPTY' as pec, -- da capire come recuperare la pec su anacontatti vista relazione 1 a n			
		'TRILANCE_EMPTY' as cellulare, 	-- su anacontatti vista relazione 1 a n	 (stesso problema di cui sopra)	
		a.IDAgente,
		ag.Nome DescrizioneAgente,
		a.IDAgenzia,
		ag1.Nome DescrizioneAgenzia,
		case when perc995.IDAnagrafica is not null then 'Y' else 'N' end [TRATTENUTA 0,5],
		null CONVENZIONE,
		case when a.TipoPersona='G' then a.RagSoc else NULL end [FORMA GIURIDICA],
		case when a.TipoPersona='F' then a.Nome else null end NOME,
		case when a.TipoPersona='F' then a.Cognome else null end COGNOME,
		null as classeDiRischio,
		null as descrizioneRischio,
		0 as fido,		
		a.IDTipoCapogruppo,
		cg.Descrizione TipoCapogruppo,
		'N/A' ID_BU,
		'N/A' DESCR_BU,
		'N/A' ID_AREA,
		'N/A' DESCR_AREA,
		a.IDTERP
from	dbo.Anagrafica a
--left outer join dbo.AnaContatti ac on a.IDAnagrafica=ac.IDAnagrafica 
left outer join dbo.AnaForme af on a.IDAnaForma=af.IDAnaForma
left outer join dbo.TipiCapogruppo cg on a.IDTipoCapogruppo=cg.IDTipoCapogruppo
left outer join dbo.AgentiAnagrafica ag on a.IDAgente=ag.IDAgente
left outer join dbo.AgentiAnagrafica ag1 on a.IDAgenzia=ag1.IDAgente
left outer join dbo.Gala_AnagrafichePagamento995Perc perc995 on a.IDAnagrafica=perc995.IDAnagrafica and getdate() between perc995.ValidoDal and isnull(perc995.ValidoAl, '20501231')
where	a.IDStatoAnagrafica=1
		and a.IDAnagrafica!='100001'
		and exists (select	1 
					from	dbo.Contratti c
					inner join dbo.ContrattiRighe cr on c.IDContratto_Cnt=cr.IDContratto_Cnt
					where	c.IDAnagrafica=a.IDAnagrafica
							and cr.IDStatoRiga != 11
							and getdate() between cr.DataInizioValidita and coalesce(cr.DataCessazione, cr.dataFineValidita, '20501231'))
order by a.IDAnagrafica
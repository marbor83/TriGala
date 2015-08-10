-- per clienti PA prendo tutti i contatti appartenenti alle categorie NS Referente, Referente Aziendale
-- per i clienti NO PA prendo tutti i contatti appartennenti alle categorie Rappresentante Legale
-- per i clienti prospect non prendo nessun contatto

-- NS Referente prendo le info da Contatto
-- Referente aziendale prendo da Cliente
-- Rappresentante Legale da Cliente

CREATE PROC GALA_CB.CB_Sp_GetAnagraficaContatti
	@DataDa Datetime,
	@DataA  Datetime,
	@IdCliente INT
AS
BEGIN

select	ac.IDContatto as ID_Contatto,
		a.IDAnagrafica as id_Cliente,
		'IT10' as id_Azienda,
		case when ac.TipoPersonaContatto='F' then CASE WHEN t.IDTipoContatto = 6 THEN ac.Nome ELSE a.Nome END  else null end Nome,
		case when ac.TipoPersonaContatto='F' then CASE WHEN t.IDTipoContatto = 6 THEN ac.Cognome ELSE a.Cognome END  else null end Cognome,						
		t.IDTipoContatto as ID_TIPOCONTATTO,
		t.Descrizione TipoContatto,	
		ac.CFisc as CODFISC,
		CASE WHEN t.IDTipoContatto = 6 THEN ac.indirizzo ELSE a.Indirizzo END indirizzo,
		CASE WHEN t.IDTipoContatto = 6 THEN ac.CAP ELSE a.CAP END CAP,
		CASE WHEN t.IDTipoContatto = 6 THEN ac.Localita ELSE a.Localita END Localita,
		CASE WHEN t.IDTipoContatto = 6 THEN ac.Provincia ELSE a.Provincia END Provincia,
		CASE WHEN t.IDTipoContatto = 6 THEN ac.Nazione ELSE a.Nazione END Nazione,		
		ac.Fax Fax,
		CASE WHEN t.IDTipoContatto = 6 THEN ac.EMail ELSE a.EMail END EMail,
		isnull(ac.Telefono1, a.NumeroTelefonico) Telefono,
		ac.Pec,
		CASE WHEN t.IDTipoContatto = 6 THEN ac.Cellulare ELSE a.NumeroCellulare END Cellulare,
		case when ac.TipoPersonaContatto='G' then CASE WHEN t.IDTipoContatto = 6 THEN ac.RagSoc ELSE a.RagSoc END  else null end RagioneSociale,
		case when ac.TipoPersonaContatto='G' then CASE WHEN t.IDTipoContatto = 6 THEN ac.Piva ELSE a.Piva END  else null end PartitaIva	,
		ac.TipoPersonaContatto as ID_Tipo_persona,
		CASE WHEN ac.TipoPersonaContatto = 'F' THEN 'FISICA'  ELSE 'GIURIDICA' END as Descrizione_tipo_persona		
from	dbo.AnaContatti ac
inner join dbo.Anagrafica a on ac.IDAnagrafica=a.IDAnagrafica
inner join dbo.AnaContattiTipoMatch m on ac.IDContatto=m.IDContatto
inner join dbo.AnaContattiTipo t on m.IDTipoCOntatto=t.IDTipoContatto
where	a.IDStatoAnagrafica=1
		and t.IDTipoContatto IN (6, 1004)  -- NS Referente, Referente Aziendale
		and a.IDAnagrafica!='100001'
		and ac.DatUMO between @DataDa and @DataA
		and ac.IDAnagrafica = ISNULL(@IdCliente, ac.IDAnagrafica)			
		and exists(select 1
			from dbo.Contratti c, dbo.ContrattiRighe cr, GALA_CB.[GALA_SEGMENTAZIONE_CLIENTI] gsc
			where c.IDContratto_Cnt=cr.IDContratto_Cnt
			and c.IDAnagrafica=a.IDAnagrafica
			and cr.IDProdotto = gsc.IDProdotto
			and gsc.[IdSegmentoCliente] = 1) --'PA'
		and exists (select	1 
					from	dbo.Contratti c
					inner join dbo.ContrattiRighe cr on c.IDContratto_Cnt=cr.IDContratto_Cnt
					where	c.IDAnagrafica=a.IDAnagrafica
							and cr.IDStatoRiga != 11)
							--and getdate() between cr.DataInizioValidita and coalesce(cr.DataCessazione, cr.dataFineValidita, '20501231'))						
union all 
select	ac.IDContatto as ID_Contatto,
		a.IDAnagrafica as id_Cliente,
		'IT10' as idAzienda,
		case when ac.TipoPersonaContatto='F' THEN ac.Nome else null end Nome,
		case when ac.TipoPersonaContatto='F' THEN ac.Cognome else null end Cognome,	
		t.IDTipoContatto as ID_TIPOCONTATTO,					
		t.Descrizione TipoContatto,	
		ac.CFisc  as CODFISC,
		a.Indirizzo,
		a.CAP,
		a.Localita,
		a.Provincia,
		a.Nazione,		
		ac.Fax Fax,
		a.EMail,
		isnull(ac.Telefono1, a.NumeroTelefonico) Telefono,
		ac.Pec,
		a.NumeroCellulare,
		case when ac.TipoPersonaContatto='G' THEN a.RagSoc else null end RagioneSociale,
		case when ac.TipoPersonaContatto='G' THEN a.Piva else null end PartitaIva,
		ac.TipoPersonaContatto as ID_Tipo_persona,
		CASE WHEN ac.TipoPersonaContatto = 'F' THEN 'FISICA'  ELSE 'GIURIDICA' END as Descrizione_tipo_persona		
from	dbo.AnaContatti ac
inner join dbo.Anagrafica a on ac.IDAnagrafica=a.IDAnagrafica
inner join dbo.AnaContattiTipoMatch m on ac.IDContatto=m.IDContatto
inner join dbo.AnaContattiTipo t on m.IDTipoCOntatto=t.IDTipoContatto
where	a.IDStatoAnagrafica=1
		and t.IDTipoContatto = 5  -- Rappresentante Legale
		and a.IDAnagrafica!='100001'
		and ac.DatUMO between @DataDa and @DataA
		and ac.IDAnagrafica = ISNULL(@IdCliente, ac.IDAnagrafica)			
		and not exists(select 1
			from dbo.Contratti c, dbo.ContrattiRighe cr, GALA_CB.[GALA_SEGMENTAZIONE_CLIENTI] gsc
			where c.IDContratto_Cnt=cr.IDContratto_Cnt
			and c.IDAnagrafica=a.IDAnagrafica
			and cr.IDProdotto = gsc.IDProdotto
			and gsc.[IdSegmentoCliente] = 1) -- PA
		and exists(select 1
			from dbo.Contratti c, dbo.ContrattiRighe cr, GALA_CB.[GALA_SEGMENTAZIONE_CLIENTI] gsc
			where c.IDContratto_Cnt=cr.IDContratto_Cnt
			and c.IDAnagrafica=a.IDAnagrafica
			and cr.IDProdotto = gsc.IDProdotto
			and gsc.[IdSegmentoCliente] = 2) -- NO PA			
		and exists (select	1 
					from	dbo.Contratti c
					inner join dbo.ContrattiRighe cr on c.IDContratto_Cnt=cr.IDContratto_Cnt
					where	c.IDAnagrafica=a.IDAnagrafica
							and cr.IDStatoRiga != 11)
							--and getdate() between cr.DataInizioValidita and coalesce(cr.DataCessazione, cr.dataFineValidita, '20501231'))							
order by a.IDAnagrafica, ac.IDContatto		

END
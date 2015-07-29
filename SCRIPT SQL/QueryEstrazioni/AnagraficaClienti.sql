select  'IT10' as IDAzienda,
		a.IDAnagrafica IdCliente,		
		a.IDAnagrafica as id_master, -- per ora impostato ad idcliente poichè sono tutti master / oppure rimuovere dal tracciato
		af.IDAnaForma IDTipoCliente,
		af.Descrizione DescrizioneTipoCliente,
		CASE 
	    WHEN  
			(select count(*) 
			from dbo.Contratti c, dbo.ContrattiRighe cr		
			where c.IDContratto = cr.IDContratto_cnt 
			and c.IDAnagrafica=a.IDAnagrafica
			and cr.IDStatoRiga = 4) > 0   --Attivo
			
	    THEN 'ATTIVO'  
	    
	    ELSE  
		CASE 
			WHEN  
				(select count(*) 
				from dbo.Contratti c, dbo.ContrattiRighe cr		
				where c.IDContratto = cr.IDContratto_cnt 
				and c.IDAnagrafica=a.IDAnagrafica
				and cr.IDStatoRiga in (3000, 3001, 3002, 3003, 9000, 3004, 3005)  -- Cambio Piano, Voltura, Disdetta, Recesso, Moroso, Moroso ExFornitore, Disalimentato
				and cr.dataCessazione > getdate()-30 ) > 0
				
			THEN 'ATTIVO'  
		    
			ELSE  			
			CASE 
				WHEN  
					(select count(*) 
					from dbo.Contratti c, dbo.ContrattiRighe cr		
					where c.IDContratto = cr.IDContratto_cnt 
					and c.IDAnagrafica=a.IDAnagrafica
					and cr.IDStatoRiga in (3006, 3099) --Scaduto, Sfilato
					and cr.dataCessazione > getdate()-30 
					and cr.dataCessazione > cr.dataFineValidita) > 0
					
				THEN 'ATTIVO'  
			    
				ELSE  
					CASE 
						WHEN  
							(select count(*) 
							from dbo.Contratti c, dbo.ContrattiRighe cr		
							where c.IDContratto = cr.IDContratto_cnt 
							and c.IDAnagrafica=a.IDAnagrafica) = 0  -- Se non sono presenti contratti
							
						THEN 'PROSPECT'  
					    
						ELSE  
							'CESSATO'
					END							
			END				
		    
		END	    
	END descStatoCliente,
		null StatoLavorazione, -- Rimane in sospeso per ora (Dupla : mail massimo, lista stati)
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
		null as pec, -- RIMOSSO da capire come recuperare la pec su anacontatti vista relazione 1 a n			
		a.NumeroCellulare as cellulare, 
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
		0 as fido
from	dbo.Anagrafica a
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
select	c.IDContratto as ID_CONTRATTO,
		'IT10' as id_Azienda,
		c.IDAnagrafica Id_Cliente,
		CASE 
	    WHEN  
			(select count(*) 
			from dbo.Contratti c, dbo.ContrattiRighe cr		
			where c.IDContratto_Cnt=cr.IDContratto_Cnt
			and c.IDAnagrafica=a.IDAnagrafica
			and cr.IDStatoRiga = 4) > 0   --Attivo
			
	    THEN 'ATTIVO'  
	    
	    ELSE  
		CASE 
			WHEN  
				(select count(*) 
				from dbo.Contratti c, dbo.ContrattiRighe cr		
				where c.IDContratto_Cnt=cr.IDContratto_Cnt
				and c.IDAnagrafica=a.IDAnagrafica
				and cr.IDStatoRiga in (3000, 3001, 3002, 3003, 3004, 3005)  -- Cambio Piano, Voltura, Disdetta, Recesso, Morosità, Disalimentato
				and cr.dataCessazione > getdate()-30 ) > 0
				
			THEN 'ATTIVO'  
		    
			ELSE  			
			CASE 
				WHEN  
					(select count(*) 
					from dbo.Contratti c, dbo.ContrattiRighe cr		
					where c.IDContratto_Cnt=cr.IDContratto_Cnt
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
							where c.IDContratto_Cnt=cr.IDContratto_Cnt
							and cr.IDStatoRiga != 11 -- StatoContratti - Annullato Non Attivo ID 11 (Usare in caso di inserimenti ERRATI su contratti ATTIVI)
							and c.IDAnagrafica=a.IDAnagrafica) = 0  -- Se non sono presenti contratti
							
						THEN 'NON ATTIVO'  
					    
						ELSE  
							'CESSATO' 
					END							
			END				
		    
		END	    
	END Stato,	
		null as Data_Inizio,
		null as Data_Fine,
		null as Data_Cessazione,
		null as Conv_Appartenenza,
		null ID_BU,
		null DESCR_BU,
		null ID_AREA,
		null DESCR_AREA,		
		c.IDAgente as ID_AGENTE,
		ag.Nome Descr_Agente,
		null as centro_DI_Costo,
		null as id_Pag_Mod,
		null as Descr_Pag_Mod,
		null as CIG,
		null as CUP,
		null as ODA,
		c.IDTipoContratto,
		t.Descrizione DescrizioneTipoContratto,
		c.IDAgenzia,
		ag1.Nome as NomeAgenzia
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





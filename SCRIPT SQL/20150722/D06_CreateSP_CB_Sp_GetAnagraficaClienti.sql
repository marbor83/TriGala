USE [dbDatamaxGALA]
GO
/****** Object:  StoredProcedure [GALA_CB].[CB_Sp_GetAnagraficaClienti]    Script Date: 09/11/2015 11:26:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [GALA_CB].[CB_Sp_GetAnagraficaClienti]	
	@DataDa Datetime,
	@DataA  Datetime,
	@IdCliente INT
AS
BEGIN 

	-- In caso di cambio avvenuto nei contratti, devo poter aggiornare i clienti --
	-- nel caso in cui IdCliente è NULL, lancio la procedura di recupero dei contratti e recupero tutti gli IdCliente che --
	-- potrebbero aver necessità di aggiornamento --
	CREATE TABLE #tmpContratti
	(
		[ID_CONTRATTO] VARCHAR(20) NOT NULL,
		[ID_AZIENDA] VARCHAR(10) NOT NULL, 
		[ID_CLIENTE] VARCHAR(30) NOT NULL, 
		[STATO] VARCHAR(10) NOT NULL, 
		[DATA_INIZIO] DATETIME  NULL, 
		[DATA_FINE] DATETIME  NULL, 
		[DATA_CESSAZIONE] DATETIME NULL, 
		[CONV_APPARTENENZA] VARCHAR(100) NULL, 
		[ID_BU] VARCHAR(10) NULL, 
		[DESCR_BU] VARCHAR(50) NULL, 
		[ID_AREA] VARCHAR(10) NULL, 
		[DESCR_AREA] VARCHAR(50) NULL, 
		[ID_AGENTE] VARCHAR(10) NULL, 
		[DESCR_AGENTE] VARCHAR(50) NULL, 
		[CENTRO_DI_COSTO] VARCHAR(50) NULL, 
		[ID_PAG_MOD] VARCHAR(10)  NULL, 
		[DESCR_PAG_MOD] VARCHAR(50)  NULL, 
		[CIG] VARCHAR(200) NULL, 
		[CUP] VARCHAR(200) NULL, 
		[ODA] VARCHAR(200) NULL,
		IdTipoContratto VARCHAR(10) NULL,
		DescrizioneTipoContratto VARCHAR(200) NULL,
		IDAgenzia VARCHAR(10) NULL,
		NomeAgenzia VARCHAR(200) NULL	
	)	
	
	CREATE TABLE #tmpClientiContratti
	(
		ID_CLIENTE VARCHAR(30) NOT NULL
	)
	
	IF @IdCliente IS NULL
	BEGIN
		INSERT INTO #tmpContratti
			EXEC GALA_CB.CB_Sp_GetAnagraficaContratti
				@DataDa,
				@DataA,
				@IdCliente		
				
		INSERT INTO #tmpClientiContratti
			SELECT  DISTINCT ID_CLIENTE 		
			FROM #tmpContratti 
	END


	select  'IT10' as ID_AZIENDA,
			a.IDAnagrafica ID_CLIENTE,		
			a.IDAnagrafica as id_master, -- per ora impostato ad idcliente poichè sono tutti master / oppure rimuovere dal tracciato
			null ID_TIPO_CLIENTE,
			CASE 
				WHEN  
					(select count(*)
					from dbo.Contratti c, dbo.ContrattiRighe cr, GALA_CB.[GALA_SEGMENTAZIONE_CLIENTI] gsc
					where c.IDContratto_Cnt=cr.IDContratto_Cnt
					and c.IDAnagrafica=a.IDAnagrafica
					and cr.IDProdotto = gsc.IDProdotto
					and cr.IDStatoRiga != 11				
					and gsc.[IdSegmentoCliente] = 1) > 0 --'PA'			
				THEN 
					'PA'  			
				ELSE  
					CASE 
						WHEN  
							(select count(*)
							from dbo.Contratti c, dbo.ContrattiRighe cr, GALA_CB.[GALA_SEGMENTAZIONE_CLIENTI] gsc
							where c.IDContratto_Cnt=cr.IDContratto_Cnt
							and c.IDAnagrafica=a.IDAnagrafica
							and cr.IDProdotto = gsc.IDProdotto
							and cr.IDStatoRiga != 11
							and gsc.[IdSegmentoCliente] = 2) > 0 --'NO PA'			
						THEN 
							'NO PA'  			
						ELSE  
							CASE 
								WHEN  
									(select count(*)
									from dbo.Contratti c, dbo.ContrattiRighe cr
									where c.IDContratto_Cnt=cr.IDContratto_Cnt
									and cr.IDStatoRiga != 11
									and c.IDAnagrafica=a.IDAnagrafica) = 0 --'PROSPECT'			
								THEN 
									'PROSPECT'  			
								ELSE  
									CASE
										WHEN  
											(select count(*)
											from dbo.Contratti c, dbo.ContrattiRighe cr, GALA_CB.[GALA_SEGMENTAZIONE_CLIENTI] gsc
											where c.IDContratto_Cnt=cr.IDContratto_Cnt
											and c.IDAnagrafica=a.IDAnagrafica
											and cr.IDProdotto = gsc.IDProdotto
											and cr.IDStatoRiga != 11
											and gsc.[IdSegmentoCliente] = 99) > 0 --'ALTRO'			
										THEN 
											'ALTRO' --- legati a prodotti esclusi sulla [GALA_SEGMENTAZIONE_CLIENTI] 			
										ELSE  
											null  -- casistiche non gestite
									END
							END	
					END	
			END	 DESCR_TIPO_CLIENTE,	
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
					and cr.IDStatoRiga in (3000, 3001, 3002, 3003, 3004, 3005)  -- Cambio Piano, Voltura, Disdetta, Recesso, Morosità , Disalimentato
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
								and cr.IDStatoRiga != 11   -- StatoContratti - Annullato Non Attivo ID 11 (Usare in caso di inserimenti ERRATI su contratti ATTIVI)							
								and c.IDAnagrafica=a.IDAnagrafica) = 0  -- Se non sono presenti contratti
								
							THEN 'PROSPECT'  
						    
							ELSE  
								'CESSATO'
						END							
				END				
			    
			END	    
		END DESC_STATO_CLIENTE,
			null STATO_LAVORAZIONE, -- Rimane in sospeso per ora (Dupla : mail massimo, lista stati)
			a.TipoPersona as ID_TIPO_PERSONA,
			CASE WHEN a.TipoPersona = 'F' THEN 'FISICA'  ELSE 'GIURIDICA' END as Descrizione_tipo_persone,
			a.PIVA as PIVA,
			a.CFISC as CODFISC,
			a.RagSoc as RAGIONESOCIALE,
			a.Indirizzo as INDIRIZZO,
			a.CAP as CAP,
			a.Localita as COMUNE,
			a.Provincia as PROVINCIA,
			a.Nazione as NAZIONE,
			a.NumeroFax as Fax,
			a.Email as Email,
			a.NumeroTelefonico as Telefono,
			null as PEC, -- RIMOSSO da capire come recuperare la pec su anacontatti vista relazione 1 a n			
			a.NumeroCellulare as cellulare, 
			a.IDAgente as ID_AGENTE,
			ag.Nome as DESCR_AGENTE,
			a.IDAgenzia as ID_AGENZIA,
			ag1.Nome DESCR_AGENZIA,
			case when perc995.IDAnagrafica is not null then 'Y' else 'N' end as TRATTENUTA_0_5,
			null CONVENZIONE,
			af.Descrizione as FORMA_GIURIDICA,
			--case when a.TipoPersona='G' then a.RagSoc else NULL end as FORMA_GIURIDICA,
			case when a.TipoPersona='F' then a.Nome else null end as NOME,
			case when a.TipoPersona='F' then a.Cognome else null end as COGNOME,
			null as Classe_di_rischio,
			null as Descrizione_del_rischio,
			(SELECT distinct oc.Origine
			 from dbo.Contratti c, dbo.ContrattiRighe cr, GALA_CB.ORIGINE_CLIENTI oc
			 where c.IDContratto_Cnt=cr.IDContratto_Cnt
			 and c.IDAnagrafica=a.IDAnagrafica
			 and cr.IDProdotto = oc.IdProdotto
			 and cr.IDStatoRiga != 11)	as ORIGINE_CLIENTE
	from	dbo.Anagrafica a
	left outer join dbo.AnaForme af on a.IDAnaForma=af.IDAnaForma
	left outer join dbo.TipiCapogruppo cg on a.IDTipoCapogruppo=cg.IDTipoCapogruppo
	left outer join dbo.AgentiAnagrafica ag on a.IDAgente=ag.IDAgente
	left outer join dbo.AgentiAnagrafica ag1 on a.IDAgenzia=ag1.IDAgente
	left outer join dbo.Gala_AnagrafichePagamento995Perc perc995 on a.IDAnagrafica=perc995.IDAnagrafica and getdate() between perc995.ValidoDal and isnull(perc995.ValidoAl, '20501231')
	where	a.IDStatoAnagrafica=1 -- Cliente Attivo (con 2 il cliente non è visualizzabile)
			and a.IDAnagrafica!='100001'
			--and a.IDAnagrafica in (166532,179893)
			/*and exists (select	1 
						from	dbo.Contratti c
						inner join dbo.ContrattiRighe cr on c.IDContratto_Cnt=cr.IDContratto_Cnt
						where	c.IDAnagrafica=a.IDAnagrafica
								and cr.IDStatoRiga != 11
								and getdate() between cr.DataInizioValidita and coalesce(cr.DataCessazione, cr.dataFineValidita, '20501231'))	
				
			and (exists (select	1 
						from	dbo.Contratti c
						inner join dbo.ContrattiRighe cr on c.IDContratto_Cnt=cr.IDContratto_Cnt
						inner join GALA_CB.[GALA_SEGMENTAZIONE_CLIENTI] gsc on cr.IDProdotto = gsc.IDProdotto
						where	c.IDAnagrafica=a.IDAnagrafica
								and gsc.idsegmentoCliente != 99 -- Da Escludere
								and getdate() between cr.DataInizioValidita and coalesce(cr.DataCessazione, cr.dataFineValidita, '20501231'))		
				or 	(select	count(*) 
						from	dbo.Contratti c
						inner join dbo.ContrattiRighe cr on c.IDContratto_Cnt=cr.IDContratto_Cnt
						where	c.IDAnagrafica=a.IDAnagrafica
								and getdate() between cr.DataInizioValidita and coalesce(cr.DataCessazione, cr.dataFineValidita, '20501231')) = 0
				)*/			
	and ((a.DatUMO between @DataDa and @DataA
		and a.IDAnagrafica = ISNULL(@IdCliente, a.IDAnagrafica)	) 
		OR (a.IDAnagrafica in (SELECT ID_CLIENTE FROM #tmpClientiContratti)))
	order by a.IDAnagrafica
	
	drop table #tmpContratti
	drop table #tmpClientiContratti
		
	
END
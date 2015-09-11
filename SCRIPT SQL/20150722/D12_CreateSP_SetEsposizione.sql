CREATE PROCEDURE [GALA_CB].[CB_Sp_SetEsposizione]
	@DataDa Datetime,
	@DataA  Datetime,
	@IdCliente INT
AS
BEGIN
	
	create table #TempAnag
	(
		idAnagrafica INT,
		SaldoScaduto Numeric(18,2),
		SaldoAScadere Numeric(18,2),
		SaldoExtra Numeric(18,2),
		STATO_LAVORAZIONE INT

	)
	
	
	create table #TempEsposizioni
	(
		idAnagrafica INT,
		SaldoScaduto Numeric(18,2),
	)
	
	create table #TempEsposizioni2
	(
		idAnagrafica INT,
		SaldoAScadere Numeric(18,2)
	)
	
		create table #TempEsposizioni3
	(
		idAnagrafica INT,
		SaldoExtra Numeric(18,2)
	)
	
	
	-- Tutti gli idAnagrafica--
	insert into #TempAnag select a.idAnagrafica, 0 , 0, 0, 
	(Case WHEN (Select COUNT(*) 
				from Reclami r 
				where r.IDAnagrafica = a.IdAnagrafica 
					and r.IDStatoReclamo in(1,3) 
					and r.IDMotivoReclamo in (Select IDMotivoReclamo 
												from Ticket_SospensioneCredito)
	 ) > 0 THEN 1 ELSE 0 END) as STATO_LAVORAZIONE  
	from Anagrafica a
	where a.IDStatoAnagrafica=1 -- Cliente Attivo (con 2 il cliente non è visualizzabile)
		and a.IDAnagrafica!='100001'
	

	
	-- Calcolo Saldo Scaduto --
	insert into #TempEsposizioni (idAnagrafica,SaldoScaduto)
	
	select    s.IDAnagrafica,
                sum(m.Importo) SaldoScaduto
		from      Tes.Movimenti m
			inner join Scadenzario s on s.IDFattura=m.IDFattura
		where  m.IDAnagrafica=s.IDAnagrafica 
                and m.IDStato>=0 
                and s.DataScad < getdate()        
		group by s.IDAnagrafica
	
		update T  set T.SaldoScaduto = OT.SaldoScaduto
		from #TempAnag T inner join #TempEsposizioni OT on T.idAnagrafica = OT.idAnagrafica
	
	-- Calcolo Saldo A Scadere --
	insert into #TempEsposizioni2 (idAnagrafica, SaldoAScadere)
			select    s.IDAnagrafica,
				      sum(m.Importo) SaldoAScadere
			from      Tes.Movimenti m
			inner join Scadenzario s on s.IDFattura=m.IDFattura  
			where  m.IDAnagrafica=s.IDAnagrafica 
				   and m.IDStato>=0 
				   and s.DataScad >= getdate()
			group by s.IDAnagrafica
	
	update T  set T.SaldoAScadere = OT.SaldoAScadere
		from #TempAnag T inner join #TempEsposizioni2 OT on T.idAnagrafica = OT.idAnagrafica
	
	-- Calcolo Saldo Extra --
	insert into #TempEsposizioni3 (idAnagrafica, SaldoExtra)
			select    IDAnagrafica,
					  sum(Importo) SaldoExtra
			from      Tes.Movimenti
			where  IDStato>=0 
				   and IDFattura is null
			group by IDAnagrafica
	
	update T  set T.SaldoExtra = OT.SaldoExtra
		from #TempAnag T inner join #TempEsposizioni3 OT on T.idAnagrafica = OT.idAnagrafica
	
	
	-- Return dei valori estratti--
	select 'IT10' as ID_AZIENDA, e.idAnagrafica as ID_CLIENTE,( e.SaldoScaduto + ISNULL(e.SaldoAScadere, 0)) as Saldo , ISNULL(e.SaldoExtra, 0) as Extra_Saldo, e.STATO_LAVORAZIONE 
	From #TempAnag e 
		where e.idAnagrafica = ISNULL(@IdCliente,e.idAnagrafica) 
	
	--Drop Temp Table--
	drop table #TempAnag
	drop table #TempEsposizioni
	drop table #TempEsposizioni2
	drop table #TempEsposizioni3
	
END
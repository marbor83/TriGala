USE [dbDatamaxGALA]
GO
/****** Object:  StoredProcedure [GALA_CB].[CB_Sp_SetEsposizione]    Script Date: 09/05/2015 20:07:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ISTRUZIONI SQL SENZA GO */
ALTER PROCEDURE [GALA_CB].[CB_Sp_SetEsposizione]
	@DataDa Datetime,
	@DataA  Datetime,
	@IdCliente INT
AS
BEGIN
	
	create table #TempEsposizioni
	(
		idAnagrafica INT,
		SaldoScaduto Numeric(18,2),
		SaldoAScadenza Numeric(18,2),
		SaldoExtra Numeric(18,2),
		STATO_LAVORAZIONE INT
	)
	
	create table #TempEsposizioni2
	(
		idAnagrafica INT,
		SaldoAScadenza Numeric(18,2)
	)
	
		create table #TempEsposizioni3
	(
		idAnagrafica INT,
		SaldoExtra Numeric(18,2)
	)

	
	insert into #TempEsposizioni (idAnagrafica,SaldoScaduto, STATO_LAVORAZIONE)
	
	select    s.IDAnagrafica,
                sum(m.Importo) SaldoScaduto,
                (Case WHEN (Select COUNT(*) from Reclami r where r.IDAnagrafica = s.IdAnagrafica and r.IDMotivoReclamo in (Select IDMotivoReclamo from Ticket_SospensioneCredito)) > 0 THEN 1 ELSE 0 END) as STATO_LAVORAZIONE 
                
		from      Tes.Movimenti m
			inner join Scadenzario s on s.IDFattura=m.IDFattura
		where  m.IDAnagrafica=s.IDAnagrafica 
                and m.IDStato>=0 
                                and s.DataScad < getdate()
        
		group by s.IDAnagrafica order by s.IDAnagrafica
	
	
	insert into #TempEsposizioni2 (idAnagrafica, SaldoAScadenza)
			select    s.IDAnagrafica,
							sum(m.Importo) SaldoAScadenza
			from      Tes.Movimenti m
			inner join Scadenzario s on s.IDFattura=m.IDFattura  
			where  m.IDAnagrafica=s.IDAnagrafica 
							and m.IDStato>=0 
											and s.DataScad >= getdate()
			group by s.IDAnagrafica
	
	update T  set T.SaldoAScadenza = OT.SaldoAScadenza
		from #TempEsposizioni T inner join #TempEsposizioni2 OT on T.idAnagrafica = OT.idAnagrafica
	
	 
	insert into #TempEsposizioni3 (idAnagrafica, SaldoExtra)
			select    IDAnagrafica,
							sum(Importo) SaldoExtra
			from      Tes.Movimenti
			where  IDStato>=0 
							and IDFattura is null
			group by IDAnagrafica
	
	update T  set T.SaldoExtra = OT.SaldoExtra
		from #TempEsposizioni T inner join #TempEsposizioni3 OT on T.idAnagrafica = OT.idAnagrafica
	
	
	select 'IT10' as ID_AZIENDA, e.idAnagrafica as ID_CLIENTE,( e.SaldoScaduto + ISNULL(e.SaldoAScadenza, 0) + ISNULL(e.SaldoExtra, 0)) as Saldo , ISNULL(e.SaldoExtra, 0) as Extra_Saldo, e.STATO_LAVORAZIONE From #TempEsposizioni e 
		where e.idAnagrafica = ISNULL(@IdCliente,e.idAnagrafica) --   122952
		
	drop table #TempEsposizioni
	drop table #TempEsposizioni2
	drop table #TempEsposizioni3
	
END

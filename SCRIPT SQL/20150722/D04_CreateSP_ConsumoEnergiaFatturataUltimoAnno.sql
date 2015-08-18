SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [GALA_CB].[ConsumoEnergiaFatturataUltimoAnno]	
	@IdCliente INT	
AS

--DECLARE @IDAnagrafica INT SET @IDAnagrafica = 100338

-- PUNTI DI PRELIEVO FATTURABILI PER ANAGRAFICA --
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT		D.IDAnagrafica AS 'Conto DATAMAX',
			(CASE WHEN D.IDTERP Is Null THEN '' ELSE D.IDTERP END) AS 'Conto SAP',
			UPPER(D.RagSoc) AS 'Ragione Sociale',
			A.IDSede,
			E.POD
INTO		#PODFatturati
FROM		dbDatamaxGALA.dbo.ContrattiRighe A
LEFT JOIN	dbDatamaxGALA.dbo.TipiMovimento B			ON A.IDTipoMovimento = B.IDTipoMovimento
LEFT JOIN	dbDatamaxGALA.dbo.Contratti C				ON A.IDContratto_cnt = C.IDContratto_cnt
LEFT JOIN	dbDatamaxGALA.dbo.Anagrafica D				ON C.IDAnagrafica = D.IDAnagrafica
LEFT JOIN	dbDatamaxGALA.dbo.eneclientesediToday E		ON A.IDSede = E.IDSede
WHERE		B.CodUtility In ('EE')
AND			A.DataInizioValidita < (CASE WHEN A.DataCessazione Is Null THEN A.DataFineValidita ELSE A.DataCessazione END)
AND			D.IDAnagrafica = ISNULL(@IdCliente,D.IDAnagrafica)
AND			D.IDStatoAnagrafica = 1
AND			D.IDTipoCapogruppo Not In ('29')
AND			A.IDStatoRiga Not In ('11')
AND			A.IDMacroStatoRiga In (2,3)
AND			(CASE WHEN A.DataCessazione Is Null THEN A.DataFineValidita ELSE A.DataCessazione END) >= CURRENT_TIMESTAMP
AND			E.POD Is Not Null
GROUP BY	D.IDAnagrafica, D.IDTERP, D.RagSoc, A.IDSede, E.POD
-- DROP TABLE #PODFatturati

-- FATTURE CICLO ATTIVO --
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT		A.[Conto DATAMAX],
			A.[Conto SAP],
			A.[Ragione Sociale],
			B.IDSede,
			A.POD,
			dbDatamaxGALA.dbo.FirstOfMonth(B.PeriodoDal) AS PeriodoDal
INTO		#SediPeriodi
FROM		#PODFatturati A
INNER JOIN	dbDatamaxGALA.dbo.eneClienteSediAgg B		ON A.IDSede = B.IDSede
WHERE		B.IDeneOrigineDati = 6
GROUP BY	A.[Conto DATAMAX], A.[Conto SAP], A.[Ragione Sociale], B.IDSede, A.POD, dbDatamaxGALA.dbo.FirstOfMonth(B.PeriodoDal)
ORDER BY	B.IDSede, dbDatamaxGALA.dbo.FirstOfMonth(B.PeriodoDal) DESC
-- DROP TABLE #SediPeriodi

-- ULTIME 12 MESI DI FATTURE CICLO ATTIVO --
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT		A.[Conto DATAMAX],
			A.[Conto SAP],
			A.[Ragione Sociale],
			A.IDSede,
			A.POD,
			A.PeriodoDal
INTO		#Last12
FROM (		SELECT		[Conto DATAMAX], [Conto SAP], [Ragione Sociale], RANK()OVER(PARTITION BY IDSede ORDER BY PeriodoDal DESC) AS ID, IDSede, POD, PeriodoDal
			FROM		#SediPeriodi) A
WHERE		A.ID <= 12
GROUP BY	A.[Conto DATAMAX], A.[Conto SAP], A.[Ragione Sociale], A.IDSede, A.POD, A.PeriodoDal
-- DROP TABLE #Last12

-- CONSUMI FATTURATI GLI ULTIMI 12 MESI --
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT		--A.[Conto DATAMAX],
			--A.[Conto SAP],
			--A.[Ragione Sociale],
			--A.IDSede,
			A.POD,
			SUM(A.F1 + A.F2 + A.F3 + A.F0) AS 'kWh_Fatturati_Ultimi_12_mesi'
INTO		#ConsumiFatturati
FROM (		SELECT		A.[Conto DATAMAX],
						A.[Conto SAP],
						A.[Ragione Sociale],
						A.IDSede,
						A.POD,
						(CASE WHEN B.EneAttF1 Is Null THEN 0 ELSE B.EneAttF1 END) AS F1,
						(CASE WHEN B.EneAttF2 Is Null THEN 0 ELSE B.EneAttF2 END) AS F2,
						(CASE WHEN B.EneAttF3 Is Null THEN 0 ELSE B.EneAttF3 END) AS F3,
						(CASE WHEN B.EneAttF4 Is Null THEN 0 ELSE B.EneAttF4 END) AS F0
			FROM		#Last12 A
			INNER JOIN	dbDatamaxGALA.dbo.eneClienteSediAgg B		ON A.IDSede = B.IDSede AND A.PeriodoDal = dbDatamaxGALA.dbo.FirstOfMonth(B.PeriodoDal)
			WHERE		B.IDeneOrigineDati = 6
			GROUP BY	A.[Conto DATAMAX], A.[Conto SAP], A.[Ragione Sociale], A.IDSede, A.POD, B.EneAttF1, B.EneAttF2, B.EneAttF3, B.EneAttF4) A
GROUP BY	A.[Conto DATAMAX], A.[Conto SAP], A.[Ragione Sociale], A.IDSede, A.POD
--	DROP TABLE #ConsumiFatturati

-- ESTRAZIONE CONSUMI FATTURATI NEGLI ULTIMI 12 MESI --
SELECT		*
FROM		#ConsumiFatturati
--ORDER BY	3,4


DROP TABLE #ConsumiFatturati
DROP TABLE #Last12
DROP TABLE #SediPeriodi
DROP TABLE #PODFatturati
GO
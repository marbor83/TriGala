SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [GALA_CB].[ConsumoGASFatturatoUltimoAnno]	
AS

--DECLARE @IDAnagrafica INT SET @IDAnagrafica = 158705

-- PUNTI DI PRELIEVO FATTURABILI PER ANAGRAFICA --
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT		D.IDAnagrafica AS 'Conto DATAMAX',
			(CASE WHEN D.IDTERP Is Null THEN '' ELSE D.IDTERP END) AS 'Conto SAP',
			UPPER(D.RagSoc) AS 'Ragione Sociale',
			A.IDSede,
			(CASE WHEN E.CodPDR Is Null THEN 'Sede di Trasporto diretta' ELSE E.CodPDR END) AS PDR
INTO		#PODFatturati
FROM		dbDatamaxGALA.dbo.ContrattiRighe A
LEFT JOIN	dbDatamaxGALA.dbo.TipiMovimento B			ON A.IDTipoMovimento = B.IDTipoMovimento
LEFT JOIN	dbDatamaxGALA.dbo.Contratti C				ON A.IDContratto_cnt = C.IDContratto_cnt
LEFT JOIN	dbDatamaxGALA.dbo.Anagrafica D				ON C.IDAnagrafica = D.IDAnagrafica
LEFT JOIN	dbDatamaxGALA.dbo.GasClienteSediToday E		ON A.IDSede = E.idSede
LEFT JOIN	dbDatamaxGALA.dbo.AnaSediTipoMatch G		ON E.idSede = G.IDSede
WHERE		B.CodUtility In ('GAS')
AND			G.IDTipoSede = 6
AND			A.DataInizioValidita < (CASE WHEN A.DataCessazione Is Null THEN A.DataFineValidita ELSE A.DataCessazione END)
--AND			D.IDAnagrafica = @IDAnagrafica
AND			D.IDStatoAnagrafica = 1
AND			D.IDTipoCapogruppo Not In ('29')
AND			A.IDStatoRiga Not In ('11')
AND			A.IDMacroStatoRiga In (2,3)
AND			(CASE WHEN A.DataCessazione Is Null THEN A.DataFineValidita ELSE A.DataCessazione END) >= CURRENT_TIMESTAMP
GROUP BY	D.IDAnagrafica, D.IDTERP, D.RagSoc, A.IDSede, E.CodPDR
-- DROP TABLE #PODFatturati

-- FATTURE CICLO ATTIVO --
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT		A.[Conto DATAMAX],
			A.[Conto SAP],
			A.[Ragione Sociale],
			B.IDSede,
			A.PDR,
			dbDatamaxGALA.dbo.FirstOfMonth(B.DtDal) AS PeriodoDal
INTO		#SediPeriodi
FROM		#PODFatturati A
INNER JOIN	dbDatamaxGALA.dbo.gasConsumi B		ON A.IDSede = B.IDSede
WHERE		B.IDGasOrigineDati = 6
GROUP BY	A.[Conto DATAMAX], A.[Conto SAP], A.[Ragione Sociale], B.IDSede, A.PDR, dbDatamaxGALA.dbo.FirstOfMonth(B.DtDal)
ORDER BY	B.IDSede, dbDatamaxGALA.dbo.FirstOfMonth(B.DtDal) DESC
-- DROP TABLE #SediPeriodi

-- ULTIME 12 MESI DI FATTURE CICLO ATTIVO --
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT		A.[Conto DATAMAX],
			A.[Conto SAP],
			A.[Ragione Sociale],
			A.IDSede,
			A.PDR,
			A.PeriodoDal
INTO		#Last12
FROM (		SELECT		[Conto DATAMAX], [Conto SAP], [Ragione Sociale], RANK()OVER(PARTITION BY IDSede ORDER BY PeriodoDal DESC) AS ID, IDSede, PDR, PeriodoDal
			FROM		#SediPeriodi) A
WHERE		A.ID <= 12
GROUP BY	A.[Conto DATAMAX], A.[Conto SAP], A.[Ragione Sociale], A.IDSede, A.PDR, A.PeriodoDal
-- DROP TABLE #Last12

-- CONSUMI FATTURATI GLI ULTIMI 12 MESI --
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT		--A.[Conto DATAMAX],
			--A.[Conto SAP],
			--A.[Ragione Sociale],
			--A.IDSede,
			A.PDR,
			SUM(A.SMC) AS 'SMC_Fatturati_Ultimi_12_mesi'
INTO		#ConsumiFatturati
FROM (		SELECT		A.[Conto DATAMAX],
						A.[Conto SAP],
						A.[Ragione Sociale],
						A.IDSede,
						A.PDR,
						(CASE WHEN B.PrelieviSMCAdeguato Is Null THEN 0 ELSE B.PrelieviSMCAdeguato END) AS SMC
			FROM		#Last12 A
			INNER JOIN	dbDatamaxGALA.dbo.gasConsumi B		ON A.IDSede = B.IDSede AND A.PeriodoDal = dbDatamaxGALA.dbo.FirstOfMonth(B.DtDal)
			WHERE		B.IDGasOrigineDati = 6
			GROUP BY	A.[Conto DATAMAX], A.[Conto SAP], A.[Ragione Sociale], A.IDSede, A.PDR, B.PrelieviSMCAdeguato) A
GROUP BY	A.[Conto DATAMAX], A.[Conto SAP], A.[Ragione Sociale], A.IDSede, A.PDR
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
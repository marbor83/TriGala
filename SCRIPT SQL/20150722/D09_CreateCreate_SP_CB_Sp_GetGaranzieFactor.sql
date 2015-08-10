CREATE PROC GALA_CB.CB_Sp_GetGaranzieFactor
	@DataDa Datetime,
	@DataA  Datetime,
	@IdCliente INT
AS
BEGIN

select  'IT' as ID_COUNTRY,
		'IT10' as ID_AZIENDA,
		acc.IDAnagrafica as ID_CLIENTE,
		acc.IDCreditCheck as ID_GARANZIA,
		acc.IDIstituto as ID_GAR_ENTE,
		ci.Descrizione as DESCR_GAR_ENTE,
		acc.FidoAssegnato as PLAFOND,
		acc.DataInizioValidita as DATA_INIZIO,
		acc.DataFineValidita as DATA_FINE,
		cmc.Descrizione DESC_GAR_TIPO,
		cmc.IDModalitaCopertura as ID_GAR_TIPO,
		'N' as PERSONALE
from AnaCreditCheck acc
inner join CCheckIstituti ci on acc.IDIstituto = ci.IDIstituto
inner join CCheckModalitaCopertura cmc on acc.IDModalitaCopertura = cmc.IDModalitaCopertura
WHERE acc.DatUMO between @DataDa and @DataA
and acc.IDAnagrafica = ISNULL(@IdCliente, acc.IDAnagrafica)	


END
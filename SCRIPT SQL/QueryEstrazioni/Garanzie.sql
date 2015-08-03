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

/*
ELIMINA DUPLICATI
WITH cte AS (
  SELECT id_cliente, id_gar_ente, plafond, data_inizio, data_fine, id_gar_tipo, 
     row_number() OVER(PARTITION BY id_cliente, id_gar_ente, plafond, data_inizio, data_fine, id_gar_tipo ORDER BY id_cliente, id_gar_ente, plafond, data_inizio, data_fine, id_gar_tipo) AS [rn]
  FROM GALA_GARANZIE_FACTOR
)
DELETE cte WHERE [rn] > 1
*/


CREATE PROC GALA_Sp_EliminaDuplicatiGaranzieFactor
AS
BEGIN
	--ELIMINA DUPLICATI
	WITH cte AS (
	  SELECT id_cliente, id_gar_ente, plafond, data_inizio, data_fine, id_gar_tipo, 
		 row_number() OVER(PARTITION BY id_cliente, id_gar_ente, plafond, data_inizio, data_fine, id_gar_tipo ORDER BY id_cliente, id_gar_ente, plafond, data_inizio, data_fine, id_gar_tipo) AS [rn]
	  FROM GALA_GARANZIE_FACTOR
	)
	DELETE cte WHERE [rn] > 1

END
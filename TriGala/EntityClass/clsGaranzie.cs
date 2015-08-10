using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Log4NetLibrary;
using System.Data;

namespace TriGala.EntityClass
{
    class clsGaranzie
    {
        private ILogService logService = new FileLogService(typeof(frmMain));

        public bool RowIsValid(DataRow myRow, ref String sMessaggio)
        {
            try
            {
                string ValoreCampoPersonale = myRow["PERSONALE"] == DBNull.Value ? String.Empty : myRow["PERSONALE"].ToString().ToUpper();

                //ID_GAR_ENTE obligatorio se PERSONALE è uguale a 'N'
                if (ValoreCampoPersonale == "N" & myRow["ID_GAR_ENTE"] == DBNull.Value)
                {
                    sMessaggio = "ID_GAR_ENTE: campo obligatorio se PERSONALE è uguale a 'N'";
                    return false;
                }

                //DESCR_GAR_ENTE obligatorio se PERSONALE è uguale a 'N'
                if (ValoreCampoPersonale == "N" & myRow["DESCR_GAR_ENTE"] == DBNull.Value)
                {
                    sMessaggio = "DESCR_GAR_ENTE: campo obligatorio se PERSONALE è uguale a 'N'";
                    return false;
                }
             

            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message));
                throw (ex);
            }



            return true;
        }
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Log4NetLibrary;
using System.Data;

namespace TriGala.EntityClass
{
    class clsContratti
    {
        private ILogService logService = new FileLogService(typeof(frmMain));

        public bool RowIsValid(DataRow myRow, ref String sMessaggio)
        {
            try
            {
                //DESCR_BU obbligatorio se presente ID_BU
                if (myRow["ID_BU"] != DBNull.Value & myRow["DESCR_BU"] == DBNull.Value)
                {
                    sMessaggio = "DESCR_BU: campo obligatorio se impostato ID_BU";
                    return false;
                }


                //DESCR_AREA obbligatorio se presente ID_AREA
                if (myRow["ID_AREA"] != DBNull.Value & myRow["DESCR_AREA"] == DBNull.Value)
                {
                    sMessaggio = "DESCR_AREA: campo obligatorio se impostato ID_AREA";
                    return false;
                }


                //Descrizione Agente obbligatorio se presente id_Agente
                if (myRow["ID_AGENTE"] != DBNull.Value & myRow["DESCR_AGENTE"] == DBNull.Value)
                {
                    sMessaggio = "DESCR_AGENTE: campo obligatorio se impostato ID_AGENTE";
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

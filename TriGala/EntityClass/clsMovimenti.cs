using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Log4NetLibrary;
using System.Data;

namespace TriGala.EntityClass
{
    class clsMovimenti
    {
        private ILogService logService = new FileLogService(typeof(frmMain));

        public bool RowIsValid(DataRow myRow, ref String sMessaggio)
        {
            try
            {
                //DESCR_PAG_MOD obbligatorio se presente ID_PAG_MOD
                if (myRow["ID_PAG_MOD"] != DBNull.Value && myRow["DESCR_PAG_MOD"] == DBNull.Value)
                {
                    sMessaggio = "DESCR_PAG_MOD: campo obligatorio se impostato ID_PAG_MOD";
                    return false;
                }


                //DESCR_PAG_TER obbligatorio se presente ID_PAG_TER
                if (myRow["ID_PAG_TER"] != DBNull.Value && myRow["DESCR_PAG_TER"] == DBNull.Value)
                {
                    sMessaggio = "DESCR_PAG_TER: campo obligatorio se impostato ID_PAG_TER";
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

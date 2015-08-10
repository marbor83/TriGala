using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Log4NetLibrary;
using StagingGalaModel;

namespace TriGala.EntityClass
{
    class clsClienti
    {
        private ILogService logService = new FileLogService(typeof(frmMain));

        public bool RowIsValid(DataRow myRow, ref String sMessaggio)
        {
            try
            {
                //Tipo Cliente obbligatorio se presente id_Tipo_Cliente
                if (myRow["ID_TIPO_CLIENTE"] != DBNull.Value & myRow["DESCR_TIPO_CLIENTE"] == DBNull.Value)
                {
                    sMessaggio = "DESCR_TIPO_CLIENTE: campo obligatorio se impostato ID_TIPO_CLIENTE";
                    return false;
                }


                if (myRow["ID_TIPO_PERSONA"].ToString() == Common.PERSONA_GIURIDICA)
                {
                    //Partita IVA obbligatorio per persona Giuridica
                    if (myRow["PIVA"] == DBNull.Value)
                    {
                        sMessaggio = "PARTITA IVA: campo obligatorio per persona Giuridica";
                        return false;
                    }

                    //Forma Giuridica per persona Giuridica
                    if (myRow["FORMA_GIURIDICA"] == DBNull.Value)
                    {
                        sMessaggio = "FORMA GIURIDICA: campo obligatorio per persona Giuridica";
                        return false;
                    }
                }

                if (myRow["ID_TIPO_PERSONA"].ToString() == Common.PERSONA_FISICA)
                {
                    //Codice Fiscale obbligatorio per persona Fisica
                    if (myRow["CODFISC"] == DBNull.Value)
                    {
                        sMessaggio = "CODICE FISCALE: campo obligatorio per persona Fisica";
                        return false;
                    }

                    //Nome obbligatorio per persona Fisica
                    if (myRow["NOME"] == DBNull.Value)
                    {
                        sMessaggio = "NOME: campo obligatorio per persona Fisica";
                        return false;
                    }

                    //Cognome obbligatorio per persona Fisica
                    if (myRow["COGNOME"] == DBNull.Value)
                    {
                        sMessaggio = "COGNOME: campo obligatorio per persona Fisica";
                        return false;
                    }

                }


                //Descrizione Agente obbligatorio se presente id_Agente
                if (myRow["ID_AGENTE"] != DBNull.Value & myRow["DESCR_AGENTE"] == DBNull.Value)
                {
                    sMessaggio = "DESCR_AGENTE: campo obligatorio se impostato ID_AGENTE";
                    return false;
                }

                //Descrizione Agenzia obbligatorio se presente id_Agenzia
                if (myRow["ID_AGENZIA"] != DBNull.Value & myRow["DESCR_AGENZIA"] == DBNull.Value)
                {
                    sMessaggio = "DESCR_AGENZIA: campo obligatorio se impostato ID_AGENZIA";
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

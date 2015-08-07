using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Log4NetLibrary;
using DataMaxModel;
using StagingGalaModel;
using System.Reflection;
using System.Data.SqlClient;
using System.Configuration;
using TriGala.EntityClass;


namespace TriGala
{
    public partial class frmMain : Form
    {
        private bool bFormVisible;

        private ILogService logService = new FileLogService(typeof(frmMain));

        public frmMain(string[] args)
        {
            InitializeComponent();

            if (args.Length > 0 && args[0] == "-A")
                StartCBProcess();
        }



        private void btn_Start_Click(object sender, EventArgs e)
        {
            StartCBProcess();
        }

        private void StartCBProcess()
        {

            try
            {

                using (DataMaxDBEntities dme = new DataMaxDBEntities())
                {
                    DateTime UltimaElaborazione;
                    List<CB_Entita> cbe = new List<CB_Entita>();

                    logService.Info(String.Format("Processo avviato: {0}", DateTime.Now.ToString()));

                    //leggi entità da lavorare
                    cbe = ReadCBEntity();

                    foreach (CB_Entita entity in cbe)
                    {
                        //Prende l'ultima data di elaborazione per l'entità
                        UltimaElaborazione = GetDateLastElaborazioneByEntity(entity);

                        //Verifica che la relativa tabella di Storage sia vuota
                        if (StorageTableIsEmpty(entity.NomeTabellaDestinazione))
                        {
                            //Memorizza data lancio elaborazione
                            DateTime DataElaborazione = DateTime.Now;

                            //Avvia l'elaborazione per l'entità corrente
                            Common.Esito_Elaborazione EsitoElab = AvviaElaborazioneEntita(entity.id, UltimaElaborazione, DataElaborazione);

                            //Aggiorna l'esito dell'elaborazione
                            UpdateEsitoElaborazione(entity.id, Common.Tipo_Elaborazione.Automatica, UltimaElaborazione, DataElaborazione, EsitoElab);
                        }
                        else
                        {
                            //Aggiorna l'esito dell'elaborazione con "Tabella piena"
                            UpdateEsitoElaborazione(entity.id, Common.Tipo_Elaborazione.Automatica, UltimaElaborazione, Common.Esito_Elaborazione.TabellaPiena);
                        }
                    }
                }



            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private Common.Esito_Elaborazione AvviaElaborazioneEntita(int idEntita, DateTime DataDa, DateTime DataA)
        {
            return AvviaElaborazioneEntita(idEntita, DataDa, DataA, -1);
        }

        private Common.Esito_Elaborazione AvviaElaborazioneEntita(int idEntita, DateTime DataDa, DateTime DataA, int idCliente)
        {
            Common.Esito_Elaborazione retValue = Common.Esito_Elaborazione.Errore;
            String StoreProcedureName = String.Empty;
            DataTable dtQueryResult = new DataTable();
            DataTable dtRigheOk = new DataTable();
            DataTable dtRigheScarti = new DataTable();

            try
            {

                using (DataMaxDBEntities dbDataMax = new DataMaxDBEntities())
                {

                    //Ricavo la Procedura di Estrazione
                    CB_Entita myEntity = dbDataMax.CB_Entita.Where(e => e.id == idEntita).SingleOrDefault();

                    StoreProcedureName = myEntity.ProceduraEstrazione;

                    //Creazione DataTable risutati
                    dtQueryResult = CreateResultDataTable(idEntita);
                    dtRigheOk = dtQueryResult;

                    //Creazione DataTable scarti
                    dtRigheScarti = dtQueryResult;
                    dtRigheScarti.Columns.Add("Messaggio");

                    //Esgue la Store per recuperare i dati
                    dtQueryResult = ExecuteStore(StoreProcedureName, DataDa, DataA, idCliente);

                    //Verificare obligatorietà e congruenza dei dati
                    VerifcaDati(idEntita, dtQueryResult, ref dtRigheOk, ref dtRigheScarti);

                    //Scivere dati nella tabella di Storage

                    //Salvare il file CSV dei dati
                }
            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message));
                throw (ex);
            }

            return retValue;
        }

        private DataTable CreateResultDataTable(int idEntita)
        {
            DataTable retValue = new DataTable();

            try
            {
                using (DataMaxDBEntities DMdb = new DataMaxDBEntities())
                {
                    List<CB_EntitaCampi> campi = DMdb.CB_EntitaCampi.Where(c => c.id_Entita == idEntita && c.Attivo).ToList();

                    foreach (CB_EntitaCampi c in campi)
                    {
                        retValue.Columns.Add(c.NomeCampoDestinazione);
                    }

                }
            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message));
                throw (ex);
            }

            return retValue;
        }

        private void VerifcaDati(int idEntita, DataTable dtQueryResult, ref DataTable dtRigheOk, ref DataTable dtRigheScarti)
        {
            String sMessagio = String.Empty;

            try
            {
                Common.Entita myEntity = (Common.Entita)Enum.ToObject(typeof(Common.Entita), idEntita);

                switch (myEntity)
                {
                    //Anagrafica Clienti
                    case Common.Entita.Anagrafica_Clienti:
                        clsClienti objClienti = new clsClienti();

                        foreach (DataRow r in dtQueryResult.Rows)
                        {
                            //Validazione generica della riga
                            if (GenericValidationRow(r, idEntita, ref sMessagio))
                            {
                                //Validazione specifica della riga
                                if (objClienti.RowIsValid(r, ref sMessagio))
                                {
                                    dtRigheOk.Rows.Add(r);
                                }
                                else
                                {
                                    r["Messaggio"] = sMessagio;
                                    dtRigheScarti.Rows.Add(r);
                                }
                            }
                            else
                            {
                                r["Messaggio"] = sMessagio;
                                dtRigheScarti.Rows.Add(r);
                            }
                        }
                        break;
                    //Anagrafica Contratti
                    case Common.Entita.Anagrafica_Contratti:
                        break;
                    //Dati POD PDR
                    case Common.Entita.POD_PDR:
                        break;
                    //Anagrafica Movimenti
                    case Common.Entita.Anagrafica_Movimenti:
                        break;
                    //Anagrafica Contatti
                    case Common.Entita.Anagrafica_Contatti:
                        break;
                    //Garanzie Factor
                    case Common.Entita.Garanzie_Factor:
                        break;
                    //Esposizione
                    case Common.Entita.Esposizione:
                        break;
                    default:
                        break;
                }
            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message));
                throw (ex);
            }
        }

        private bool GenericValidationRow(DataRow r, int idEntita, ref string sMessagio)
        {
            bool retValue = false;

            using (DataMaxDBEntities DMdb = new DataMaxDBEntities())
            {
                List<CB_EntitaCampi> campi = DMdb.CB_EntitaCampi.Where(c => c.id_Entita == idEntita && c.Attivo).ToList();

                foreach (CB_EntitaCampi c in campi)
                {
                    String ValoreCampo = r[c.NomeCampoOrigine] == DBNull.Value ? String.Empty : r[c.NomeCampoOrigine].ToString();

                    //Controllo obbligatorietà del campo
                    if (String.IsNullOrEmpty(ValoreCampo) & c.Obbligatorio)
                    {
                        sMessagio = String.Format("Il Campo: {0} è obbligatorio", c.NomeCampoOrigine);
                        return false;
                    }

                    if (!String.IsNullOrEmpty(ValoreCampo))
                    {

                        switch (c.CB_TipoCampo.Nome.ToUpper())
                        {
                            case "STRING":
                                break;
                            case "INT":
                                int i;
                                if (!Int32.TryParse(ValoreCampo, out i))
                                {
                                    sMessagio = String.Format("Il Campo: {0} deve essere di tipo {1}", c.NomeCampoOrigine, c.CB_TipoCampo.Nome.ToUpper());
                                    return false;
                                }
                                break;
                            case "DATE":
                                DateTime dt;
                                if (!DateTime.TryParse(ValoreCampo, out dt))
                                {
                                    sMessagio = String.Format("Il Campo: {0} deve essere di tipo {1}", c.NomeCampoOrigine, c.CB_TipoCampo.Nome.ToUpper());
                                    return false;
                                }

                                break;
                            case "DECIMAL2":
                                int idx = ValoreCampo.IndexOf(",");

                                if (ValoreCampo.Length != idx + 2)
                                {
                                    sMessagio = String.Format("Il Campo: {0} deve avere due cifre decimali", c.NomeCampoOrigine, c.CB_TipoCampo.Nome.ToUpper());
                                    return false;
                                }

                                decimal dd;                                
                                if (!Decimal.TryParse(ValoreCampo, out dd))
                                {
                                    sMessagio = String.Format("Il Campo: {0} deve essere di tipo Number con 2 cifre decimali", c.NomeCampoOrigine);
                                    return false;
                                }

                                break;
                            default:
                                break;
                        }

                        //Controllo tipologia campo
                        if (!String.IsNullOrEmpty(ValoreCampo))
                        {
                            sMessagio = String.Format("Il Campo: {0} è obbligatorio", c.NomeCampoOrigine);
                            return false;
                        }

                        //Controllo lunghezza campo
                        if (ValoreCampo.Length > c.Lunghezza)
                        {
                            sMessagio = String.Format("Il Campo: {0} è di lunghezza {1} valore ammesso {2}", c.NomeCampoOrigine, ValoreCampo.Length.ToString(), c.Lunghezza.ToString());
                            retValue = false;
                        }
                    }

                }

            }

            return retValue;
        }

        private DataTable ExecuteStore(string StoreProcedureName, DateTime DataDa, DateTime DataA, int IdCliente)
        {

            DataTable retValue = new DataTable();

            try
            {
                using (SqlConnection mySQLConn = new SqlConnection(ConfigurationManager.ConnectionStrings["DataMaxDB"].ToString()))
                {
                    SqlCommand mySqlCommand = new SqlCommand();
                    mySqlCommand.CommandText = StoreProcedureName;
                    mySqlCommand.CommandType = CommandType.StoredProcedure;
                    mySqlCommand.Connection = mySQLConn;

                    SqlParameter p = new SqlParameter();
                    p.ParameterName = "DataDa";
                    p.SqlDbType = SqlDbType.DateTime;
                    p.Value = DataDa;
                    mySqlCommand.Parameters.Add(p);

                    p = new SqlParameter();
                    p.ParameterName = "DataA";
                    p.SqlDbType = SqlDbType.DateTime;
                    p.Value = DataA;
                    mySqlCommand.Parameters.Add(p);

                    p = new SqlParameter();
                    p.ParameterName = "idCliente";
                    p.SqlDbType = SqlDbType.Int;
                    if (IdCliente > 0)
                        p.Value = IdCliente;
                    else
                        p.Value = DBNull.Value;
                    mySqlCommand.Parameters.Add(p);

                    mySQLConn.Open();

                    SqlDataReader dr = mySqlCommand.ExecuteReader();

                    retValue.Load(dr);

                }
            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message));
                throw (ex);
            }

            return retValue;
        }


        private DateTime GetDateLastElaborazioneByEntity(CB_Entita entity)
        {
            DateTime retValue = DateTime.Now;
            int idEsitoElaborazioe = Common.Esito_Elaborazione.OK.GetHashCode();

            try
            {
                using (DataMaxDBEntities dme = new DataMaxDBEntities())
                {
                    retValue = (from elb in dme.CB_Elaborazioni where elb.id_Entita == entity.id & elb.id_Esito == idEsitoElaborazioe select elb.DataElaborazione).Max();
                }
            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message));
                throw (ex);
            }

            return retValue;

        }


        private List<CB_Entita> ReadCBEntity()
        {
            List<CB_Entita> retValue = new List<CB_Entita>();
            try
            {
                using (DataMaxDBEntities dme = new DataMaxDBEntities())
                {
                    retValue = dme.CB_Entita.Where(x => x.Attivo.Equals(true)).ToList();
                }
            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message));
                throw (ex);
            }

            return retValue;
        }

        private bool StorageTableIsEmpty(string TableName)
        {
            bool retValue = false;

            try
            {
                using (StagingGalaDBEntities sge = new StagingGalaDBEntities())
                {
                    switch (TableName)
                    {
                        case "GALA_ANAGRAFICA_CLIENTI":
                            if (sge.GALA_ANAGRAFICA_CLIENTI.Count() == 0)
                                retValue = true;
                            break;
                        case "GALA_ANAGRAFICA_CONTRATTI":
                            if (sge.GALA_ANAGRAFICA_CONTRATTI.Count() == 0)
                                retValue = true;
                            break;
                        case "GALA_ANAGRAFICA_MOVIMENTI":
                            if (sge.GALA_ANAGRAFICA_MOVIMENTI.Count() == 0)
                                retValue = true;
                            break;
                        case "GALA_CONTATTI":
                            if (sge.GALA_CONTATTI.Count() == 0)
                                retValue = true;
                            break;
                        case "GALA_ESPOSIZIONE":
                            if (sge.GALA_ESPOSIZIONE.Count() == 0)
                                retValue = true;
                            break;
                        case "GALA_GARANZIE_FACTOR":
                            if (sge.GALA_GARANZIE_FACTOR.Count() == 0)
                                retValue = true;
                            break;
                        case "GALA_POD_PDR":
                            if (sge.GALA_POD_PDR.Count() == 0)
                                retValue = true;
                            break;
                        default:
                            break;
                    }

                }
            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message));
                throw (ex);
            }
            return retValue;
        }


        #region UpdateEsitoElaborazione
        /// <summary>
        /// Aggiorna l'esito dell'elaborazione eseguita
        /// </summary>
        /// <param name="entityID">Id Entità elaborata</param>
        /// <param name="TipoElaborazione">Manuale / Automatica</param>
        /// <param name="DataDa">>Data passata per l'elaborazione</param>
        /// <param name="esito_Elaborazione">>Esito Elaborazione</param>
        private void UpdateEsitoElaborazione(int entityID, Common.Tipo_Elaborazione TipoElaborazione, DateTime DataDa, Common.Esito_Elaborazione esito_Elaborazione)
        {
            UpdateEsitoElaborazione(entityID, TipoElaborazione, DataDa, DateTime.Now, esito_Elaborazione);
        }
        /// <summary>
        /// Aggiorna l'esito dell'elaborazione eseguita
        /// </summary>
        /// <param name="entityID">Id Entità elaborata</param>
        /// <param name="TipoElaborazione">Manuale / Automatica</param>
        /// <param name="DataDa">Data inizio elaborata</param>
        /// <param name="DataElaborazione">Data dell'esecuzione elaborazione</param>
        /// <param name="esito_Elaborazione">Esito Elaborazione</param>
        private void UpdateEsitoElaborazione(int entityID, Common.Tipo_Elaborazione TipoElaborazione, DateTime DataDa, DateTime DataElaborazione, Common.Esito_Elaborazione esito_Elaborazione)
        {
            UpdateEsitoElaborazione(entityID, TipoElaborazione, DataDa, DateTime.Now, DateTime.Now, esito_Elaborazione);
        }
        /// <summary>
        /// Aggiorna l'esito dell'elaborazione eseguita
        /// </summary>
        /// <param name="entityID">Id Entità elaborata</param>
        /// <param name="TipoElaborazione">Manuale / Automatica</param>
        /// <param name="DataDa">Data inizio elaborata</param>
        /// <param name="DataA">Data fine elaborata</param>
        /// <param name="DataElaborazione">Data dell'esecuzione elaborazione</param>
        /// <param name="esito_Elaborazione">Esito Elaborazione</param>
        private void UpdateEsitoElaborazione(int entityID, Common.Tipo_Elaborazione TipoElaborazione, DateTime DataDa, DateTime DataA, DateTime DataElaborazione, Common.Esito_Elaborazione esito_Elaborazione)
        {

            try
            {
                using (DataMaxDBEntities dme = new DataMaxDBEntities())
                {
                    CB_Elaborazioni myElab = new CB_Elaborazioni();
                    myElab.id_Entita = entityID;
                    myElab.id_Esito = esito_Elaborazione.GetHashCode();
                    myElab.id_Tipologia = TipoElaborazione.GetHashCode();
                    myElab.DataDa = DataDa;
                    myElab.DataA = DataA;
                    myElab.DataElaborazione = DataElaborazione;

                    dme.CB_Elaborazioni.Add(myElab);

                    dme.SaveChanges();
                }
            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message));
                throw (ex);
            }
        }
        #endregion


        #region Prova Reflection
        private String GetTableName(string TableName)
        {
            string retValue = string.Empty;

            using (StagingGalaDBEntities StagingDBEntity = new StagingGalaDBEntities())
            {

                PropertyInfo[] properties = StagingDBEntity.GetType().GetProperties();

                foreach (PropertyInfo my_property in properties)
                {
                    if (!(my_property.GetValue(StagingDBEntity, null) == null))
                    {

                        retValue = my_property.Name;

                        //retValue = my_property.GetValue(StagingDBEntity, null).ToString();
                        if (retValue == TableName)
                        {
                            var countryList = StagingDBEntity.GetType().GetProperty(TableName).GetValue(StagingDBEntity, null) as System.Data.Objects.ObjectQuery;
                        }
                    }
                }
            }
            return retValue;
        }
        #endregion

    }
}

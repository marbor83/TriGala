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
using ExporterClass;
using System.IO;


namespace TriGala
{
    public partial class frmMain : Form
    {
        
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
                    String sMessaggio = String.Empty;

                    logService.Info(String.Format("Processo avviato: {0}", DateTime.Now.ToString()));

                    //leggi entità da lavorare
                    cbe = ReadCBEntity();

                    foreach (CB_Entita entity in cbe)
                    {
                        logService.Info(String.Format("Inizio elaborazione entità: {0}", entity.Nome));

                        //Prende l'ultima data di elaborazione per l'entità
                        UltimaElaborazione = GetDateLastElaborazioneByEntity(entity);

                        //Verifica che la relativa tabella di Storage sia vuota
                        int Esito = StorageTableIsEmpty(entity.NomeTabellaDestinazione);

                        if (Esito > 0)
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
                            if (Esito == -1)
                                UpdateEsitoElaborazione(entity.id, Common.Tipo_Elaborazione.Automatica, UltimaElaborazione, Common.Esito_Elaborazione.Errore);
                            else
                                //Aggiorna l'esito dell'elaborazione con "Tabella piena"
                                UpdateEsitoElaborazione(entity.id, Common.Tipo_Elaborazione.Automatica, UltimaElaborazione, Common.Esito_Elaborazione.TabellaPiena);
                        }

                        logService.Info(String.Format("Fine elaborazione entità: {0}", entity.Nome));
                    }

                    logService.Info(String.Format("Processo terminato: {0}", DateTime.Now.ToString()));
                }



            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message));
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
            String path_to_save = String.Empty;
            bool exists = false;

            try
            {

                using (DataMaxDBEntities dbDataMax = new DataMaxDBEntities())
                {

                    //Ricavo la Procedura di Estrazione
                    CB_Entita myEntity = dbDataMax.CB_Entita.Where(e => e.id == idEntita).SingleOrDefault();

                    StoreProcedureName = myEntity.ProceduraEstrazione;

                    //Creazione DataTable risutati
                    dtQueryResult = CreateResultDataTable(idEntita);
                    dtRigheOk = dtQueryResult.Clone();

                    //Creazione DataTable scarti
                    dtRigheScarti = dtQueryResult.Clone();
                    dtRigheScarti.Columns.Add("Messaggio");

                    //Esgue la Store per recuperare i dati
                    dtQueryResult = ExecuteStore(StoreProcedureName, DataDa, DataA, idCliente);

                    //Verificare obligatorietà e congruenza dei dati
                    if (dtQueryResult.Rows.Count > 0)
                        VerifcaDati(idEntita, dtQueryResult, ref dtRigheOk, ref dtRigheScarti);

                    //Scive dati nella tabella di Storage
                    if (dtRigheOk.Rows.Count > 0)
                        retValue = InsertIntoStorage(idEntita, dtRigheOk);

                    //Salva i file CSV dei dati
                    Exporter objExporter = new Exporter();
                    objExporter.ExportType = ExportFormat.EXCEL;
                    objExporter.CSV_WithHeader = true;

                    if (dtRigheOk.Rows.Count > 0)
                    {
                        byte[] csvOK = objExporter.ExportDataTable(dtRigheOk);
                        path_to_save = ConfigurationManager.AppSettings["PathCSV_OK"].ToString();
                        exists = System.IO.Directory.Exists(path_to_save);
                        if (!exists)
                            System.IO.Directory.CreateDirectory(path_to_save);
                        File.WriteAllBytes(String.Format("{0}{1}_{2}_RigheOk{3}", path_to_save, DateTime.Now.ToString("yyyMMddHHmmssfff"), myEntity.Nome, ".xlsx"), csvOK);
                    }

                    if (dtRigheScarti.Rows.Count > 0)
                    {
                        byte[] csvScarti = objExporter.ExportDataTable(dtRigheScarti);

                        path_to_save = ConfigurationManager.AppSettings["PathCSV_Scarti"].ToString();
                        exists = System.IO.Directory.Exists(path_to_save);
                        if (!exists)
                            System.IO.Directory.CreateDirectory(path_to_save);
                        File.WriteAllBytes(String.Format("{0}{1}_{2}_RigheScarti{3}", path_to_save, DateTime.Now.ToString("yyyMMddHHmmssfff"), myEntity.Nome, ".csv"), csvScarti);
                    }

                    retValue = Common.Esito_Elaborazione.OK;
                }
            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1} ENTITA: {2}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message, idEntita.ToString()));
                throw (ex);
            }

            return retValue;
        }

        private Common.Esito_Elaborazione InsertIntoStorage(int idEntita, DataTable dtRigheOk)
        {
            Common.Esito_Elaborazione retValue = Common.Esito_Elaborazione.Errore;
            int EsitoControlloTabella = 0;

            try
            {

                String tabela_destinazione = String.Empty;

                //Prima di procedere con la insert verifico nuovamente che le tabelle di Storage siano vuote
                using (DataMaxDBEntities DMdb = new DataMaxDBEntities())
                {
                    tabela_destinazione = DMdb.CB_Entita.Where(e => e.id == idEntita).SingleOrDefault().NomeTabellaDestinazione;

                    EsitoControlloTabella = StorageTableIsEmpty(tabela_destinazione);

                    switch (EsitoControlloTabella)
                    {
                        case 1:
                            //Do nothing Esito ok!
                            break;
                        case 0:
                            return Common.Esito_Elaborazione.TabellaPiena;                          
                        case -1:
                            return Common.Esito_Elaborazione.Errore;                           
                        default:
                            return Common.Esito_Elaborazione.Errore;
                    }
                }

                SqlConnection connection = new SqlConnection(ConfigurationManager.ConnectionStrings["StagingGalaDB"].ToString());

                using (SqlBulkCopy bulkCopy = new SqlBulkCopy(connection))
                {
                    connection.Open();
                    bulkCopy.DestinationTableName = tabela_destinazione;
                    // Write from the source to the destination.
                    bulkCopy.WriteToServer(dtRigheOk);
                }


                retValue = Common.Esito_Elaborazione.OK;

            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1} ENTITA: {2}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message, idEntita.ToString()));
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
                logService.Error(String.Format("METODO: {0} ERRORE: {1} ENTITA: {2}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message, idEntita.ToString()));
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
                                    dtRigheOk.Rows.Add(AggiungiRigheOK(idEntita, r, dtRigheOk));
                                }
                                else
                                {
                                    dtRigheScarti.Rows.Add(AggiungiRigaScarti(idEntita, r, dtRigheScarti, sMessagio));
                                }
                            }
                            else
                            {
                                dtRigheScarti.Rows.Add(AggiungiRigaScarti(idEntita, r, dtRigheScarti, sMessagio));
                            }
                        }

                        break;

                    //Anagrafica Contratti
                    case Common.Entita.Anagrafica_Contratti:

                        clsContratti objContratti = new clsContratti();

                        foreach (DataRow r in dtQueryResult.Rows)
                        {
                            //Validazione generica della riga
                            if (GenericValidationRow(r, idEntita, ref sMessagio))
                            {
                                //Validazione specifica della riga
                                if (objContratti.RowIsValid(r, ref sMessagio))
                                {
                                    dtRigheOk.Rows.Add(AggiungiRigheOK(idEntita, r, dtRigheOk));
                                }
                                else
                                {
                                    dtRigheScarti.Rows.Add(AggiungiRigaScarti(idEntita, r, dtRigheScarti, sMessagio));
                                }
                            }
                            else
                            {
                                dtRigheScarti.Rows.Add(AggiungiRigaScarti(idEntita, r, dtRigheScarti, sMessagio));
                            }
                        }
                        break;

                    //Dati POD PDR
                    case Common.Entita.POD_PDR:

                        //Per l'entità POD_PDR al momento non sono previste validazione specifiche
                        //clsPOD_PDR objPOD_PDR = new clsPOD_PDR();

                        foreach (DataRow r in dtQueryResult.Rows)
                        {
                            //Validazione generica della riga
                            if (GenericValidationRow(r, idEntita, ref sMessagio))
                            {
                                dtRigheOk.Rows.Add(AggiungiRigheOK(idEntita, r, dtRigheOk));

                                //Validazione specifica della riga
                                //if (objPOD_PDR.RowIsValid(r, ref sMessagio))
                                //{                                    
                                //    dtRigheOk.Rows.Add(AggiungiRigheOK(idEntita,r,dtRigheOk));
                                //}
                                //else
                                //{
                                //    dtRigheScarti.Rows.Add(AggiungiRigaScarti(idEntita, r, dtRigheScarti, sMessagio));
                                //}
                            }
                            else
                            {
                                dtRigheScarti.Rows.Add(AggiungiRigaScarti(idEntita, r, dtRigheScarti, sMessagio));
                            }
                        }
                        break;
                    //Anagrafica Movimenti
                    case Common.Entita.Anagrafica_Movimenti:
                        clsMovimenti objMovimenti = new clsMovimenti();

                        foreach (DataRow r in dtQueryResult.Rows)
                        {
                            //Validazione generica della riga
                            if (GenericValidationRow(r, idEntita, ref sMessagio))
                            {
                                //Validazione specifica della riga
                                if (objMovimenti.RowIsValid(r, ref sMessagio))
                                {
                                    dtRigheOk.Rows.Add(AggiungiRigheOK(idEntita, r, dtRigheOk));
                                }
                                else
                                {
                                    dtRigheScarti.Rows.Add(AggiungiRigaScarti(idEntita, r, dtRigheScarti, sMessagio));
                                }
                            }
                            else
                            {
                                dtRigheScarti.Rows.Add(AggiungiRigaScarti(idEntita, r, dtRigheScarti, sMessagio));
                            }
                        }

                        break;

                    //Anagrafica Contatti
                    case Common.Entita.Anagrafica_Contatti:
                        //Per l'entità Contatti al momento non sono previste validazione specifiche
                        //clsContatti objContatti = new clsContatti();

                        foreach (DataRow r in dtQueryResult.Rows)
                        {
                            //Validazione generica della riga
                            if (GenericValidationRow(r, idEntita, ref sMessagio))
                            {
                                dtRigheOk.Rows.Add(AggiungiRigheOK(idEntita, r, dtRigheOk));

                                //Validazione specifica della riga
                                //if (objContatti.RowIsValid(r, ref sMessagio))
                                //{                                    
                                //    dtRigheOk.Rows.Add(AggiungiRigheOK(idEntita,r,dtRigheOk));
                                //}
                                //else
                                //{
                                //    dtRigheScarti.Rows.Add(AggiungiRigaScarti(idEntita, r, dtRigheScarti, sMessagio));
                                //}
                            }
                            else
                            {
                                dtRigheScarti.Rows.Add(AggiungiRigaScarti(idEntita, r, dtRigheScarti, sMessagio));
                            }
                        }
                        break;

                    //Garanzie Factor
                    case Common.Entita.Garanzie_Factor:

                        clsGaranzie objGaranzie = new clsGaranzie();

                        foreach (DataRow r in dtQueryResult.Rows)
                        {
                            //Validazione generica della riga
                            if (GenericValidationRow(r, idEntita, ref sMessagio))
                            {
                                //Validazione specifica della riga
                                if (objGaranzie.RowIsValid(r, ref sMessagio))
                                {
                                    dtRigheOk.Rows.Add(AggiungiRigheOK(idEntita, r, dtRigheOk));
                                }
                                else
                                {
                                    dtRigheScarti.Rows.Add(AggiungiRigaScarti(idEntita, r, dtRigheScarti, sMessagio));
                                }
                            }
                            else
                            {
                                dtRigheScarti.Rows.Add(AggiungiRigaScarti(idEntita, r, dtRigheScarti, sMessagio));
                            }
                        }

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
                logService.Error(String.Format("METODO: {0} ERRORE: {1} ENTITA: {2}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message, idEntita.ToString()));
                throw (ex);
            }
        }

        private DataRow AggiungiRigheOK(int idEntita, DataRow r, DataTable dtRigheOk)
        {
            DataRow retValue = dtRigheOk.NewRow();

            try
            {
                using (DataMaxDBEntities DMdb = new DataMaxDBEntities())
                {
                    List<CB_EntitaCampi> campi = DMdb.CB_EntitaCampi.Where(c => c.id_Entita == idEntita && c.Attivo).ToList();

                    foreach (CB_EntitaCampi c in campi)
                    {
                        retValue[c.NomeCampoDestinazione] = r[c.NomeCampoDestinazione];
                    }
                }
            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1} ENTITA: {2}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message, idEntita.ToString()));
                throw (ex);
            }

            return retValue;
        }

        private DataRow AggiungiRigaScarti(int idEntita, DataRow r, DataTable dtRigheScarti, string sMessagio)
        {
            DataRow retValue = dtRigheScarti.NewRow();

            try
            {
                using (DataMaxDBEntities DMdb = new DataMaxDBEntities())
                {
                    List<CB_EntitaCampi> campi = DMdb.CB_EntitaCampi.Where(c => c.id_Entita == idEntita && c.Attivo).ToList();

                    foreach (CB_EntitaCampi c in campi)
                    {
                        retValue[c.NomeCampoDestinazione] = r[c.NomeCampoDestinazione];
                    }

                    retValue["Messaggio"] = sMessagio;
                }
            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1} ENTITA: {2}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message, idEntita.ToString()));
                throw (ex);
            }

            return retValue;
        }

        private bool GenericValidationRow(DataRow r, int idEntita, ref string sMessagio)
        {

            using (DataMaxDBEntities DMdb = new DataMaxDBEntities())
            {
                List<CB_EntitaCampi> campi = DMdb.CB_EntitaCampi.Where(c => c.id_Entita == idEntita && c.Attivo).ToList();

                foreach (CB_EntitaCampi c in campi)
                {
                    String ValoreCampo = r[c.NomeCampoDestinazione] == DBNull.Value ? String.Empty : r[c.NomeCampoDestinazione].ToString();

                    //Controllo obbligatorietà del campo
                    if (String.IsNullOrEmpty(ValoreCampo) & c.Obbligatorio)
                    {
                        sMessagio = String.Format("Il Campo: {0} è obbligatorio", c.NomeCampoDestinazione);
                        return false;
                    }

                    if (!String.IsNullOrEmpty(ValoreCampo))
                    {

                        //Controllo tipo CAMPO
                        switch (c.CB_TipoCampo.Nome.ToUpper())
                        {
                            case "STRING":
                                break;
                            case "INT":
                                int i;
                                if (!Int32.TryParse(ValoreCampo, out i))
                                {
                                    sMessagio = String.Format("Il Campo: {0} deve essere di tipo {1}", c.NomeCampoDestinazione, c.CB_TipoCampo.Nome.ToUpper());
                                    return false;
                                }
                                break;
                            case "DATE":
                                DateTime dt;
                                if (!DateTime.TryParse(ValoreCampo, out dt))
                                {
                                    sMessagio = String.Format("Il Campo: {0} deve essere di tipo {1}", c.NomeCampoDestinazione, c.CB_TipoCampo.Nome.ToUpper());
                                    return false;
                                }

                                break;
                            case "DECIMAL2":

                                //int idx = ValoreCampo.IndexOf(",");

                                //if (ValoreCampo.Length != idx + 2)
                                //{
                                //    sMessagio = String.Format("Il Campo: {0} deve avere due cifre decimali", c.NomeCampoDestinazione, c.CB_TipoCampo.Nome.ToUpper());
                                //    return false;
                                //}

                                decimal dd;
                                if (!Decimal.TryParse(ValoreCampo, out dd))
                                {
                                    sMessagio = String.Format("Il Campo: {0} deve essere di tipo Number con 2 cifre decimali", c.NomeCampoDestinazione);
                                    return false;
                                }

                                break;
                            default:
                                break;
                        }

                        //Controllo lunghezza campo
                        if (ValoreCampo.Length > c.Lunghezza)
                        {
                            sMessagio = String.Format("Il Campo: {0} è di lunghezza {1} valore ammesso {2}", c.NomeCampoDestinazione, ValoreCampo.Length.ToString(), c.Lunghezza.ToString());
                            return false;
                        }
                    }
                }

            }

            return true;
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
                    mySqlCommand.CommandTimeout = Int32.Parse(ConfigurationManager.AppSettings["CommandTimeOut"].ToString());
                    

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
                logService.Error(String.Format("METODO: {0} ERRORE: {1} StoreProcdure: {2}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message, StoreProcedureName));
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
                logService.Error(String.Format("METODO: {0} ERRORE: {1} ENTITA: {2}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message, entity.id.ToString()));
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
                    retValue = dme.CB_Entita.Where(x => x.Attivo.Equals(true)).OrderBy(o => o.OrdineElaborazione).ToList();
                }
            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message));
                throw (ex);
            }

            return retValue;
        }

        private int StorageTableIsEmpty(string TableName)
        {
            int retValue = 0;

            try
            {
                using (StagingDBEntities sge = new StagingDBEntities())
                {
                    switch (TableName)
                    {
                        case "GALA_ANAGRAFICA_CLIENTI":                            
                            if (sge.GALA_ANAGRAFICA_CLIENTI.Count() == 0)
                                retValue = 1;
                            break;
                        case "GALA_ANAGRAFICA_CONTRATTI":
                            if (sge.GALA_ANAGRAFICA_CONTRATTI.Count() == 0)
                                retValue = 1;
                            break;
                        case "GALA_ANAGRAFICA_MOVIMENTI":
                            if (sge.GALA_ANAGRAFICA_MOVIMENTI.Count() == 0)
                                retValue = 1;
                            break;
                        case "GALA_CONTATTI":
                            if (sge.GALA_CONTATTI.Count() == 0)
                                retValue = 1;
                            break;
                        case "GALA_ESPOSIZIONE":
                            if (sge.GALA_ESPOSIZIONE.Count() == 0)
                                retValue = 1;
                            break;
                        case "GALA_GARANZIE_FACTOR":
                            if (sge.GALA_GARANZIE_FACTOR.Count() == 0)
                                retValue = 1;
                            break;
                        case "GALA_POD_PDR":
                            if (sge.GALA_POD_PDR.Count() == 0)
                                retValue = 1;
                            break;
                        default:
                            retValue = -1;
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
                logService.Error(String.Format("METODO: {0} ERRORE: {1} ENTITA: {2}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message, entityID.ToString()));
                throw (ex);
            }
        }
        #endregion


        #region Prova Reflection
        private String GetTableName(string TableName)
        {
            string retValue = string.Empty;

            using (StagingDBEntities StagingDBEntity = new StagingDBEntities())
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

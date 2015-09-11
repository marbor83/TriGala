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
        Dictionary<string, string> dicEsiti = new Dictionary<string, string>();

        public frmMain(string[] args)
        {
            InitializeComponent();

            if (args.Length > 0 && args[0] == "-A")
                StartCBProcess();
        }

        private void frmMain_Load(object sender, EventArgs e)
        {
            try
            {
                using (DataMaxDBEntities dme = new DataMaxDBEntities())
                {
                    List<CB_Entita> cbe = new List<CB_Entita>();

                    //leggi entità
                    cbe = ReadCBEntity();

                    foreach (CB_Entita entity in cbe)
                    {
                        clbEntita.Items.Add(entity.NomeTabellaDestinazione);
                    }

                }
            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message));
                MessageBox.Show(ex.Message);
            }
        }


        private void btnManuale_Click(object sender, EventArgs e)
        {
            DateTime dtControllo = new DateTime();
            bool bSelect = false;

            if (String.IsNullOrEmpty(txtDataA.Text) || String.IsNullOrEmpty(txtDataDa.Text))
            {
                MessageBox.Show("Valorizzare le date per l'elaborazione");
                return;
            }

            if (!DateTime.TryParse(txtDataDa.Text, out dtControllo))
            {
                MessageBox.Show("DataDa non valida");
                return;
            }

            if (!DateTime.TryParse(txtDataA.Text, out dtControllo))
            {
                MessageBox.Show("DataA non valida");
                return;
            }


            if (DateTime.Parse(txtDataDa.Text) > DateTime.Parse(txtDataA.Text))
            {
                MessageBox.Show("Intervallo di date non valido");
                return;
            }


            for (int i = 0; i < clbEntita.Items.Count; i++)
            {
                if (clbEntita.GetItemChecked(i))
                {
                    bSelect = true;
                    break;
                }
            }

            if (!bSelect)
            {
                MessageBox.Show("Selezionare un'entità");
                return;
            }


            if (!String.IsNullOrEmpty(txtIdCliente.Text))
            {
                int j;

                if (!Int32.TryParse(txtIdCliente.Text, out j))
                {
                    MessageBox.Show("Id Cliente non valido");
                    return;
                }
            }


            if (!StartProcessoManuale())
                MessageBox.Show("Errore nell'elaborazione controlare il file di LOG");
            else
            {
                MessageBox.Show("Elaborazione terminata per ulteriori dettagli consultare il LOG");
            }

            SetInterface(true);
        }

        private bool StartProcessoManuale()
        {
            bool retValue = false;
            Common.Esito_Elaborazione EsitoElab = Common.Esito_Elaborazione.Default;
            String result = String.Empty;
            int Esito = -1;

            try
            {
                SetInterface(false);

                dicEsiti.Clear();
                CB_Entita entity;

                for (int i = 0; i < clbEntita.Items.Count; i++)
                {
                    if (clbEntita.GetItemChecked(i))
                    {
                        string NomeTabella = (string)clbEntita.Items[i];

                        using (DataMaxDBEntities dme = new DataMaxDBEntities())
                        {
                            entity = dme.CB_Entita.Where(e => e.NomeTabellaDestinazione == NomeTabella).SingleOrDefault();
                        }

                        logService.Info(String.Format("Inizio elaborazione entità: {0}", entity.Nome));

                        //Data partenza Elaborazione
                        DateTime DataDa = DateTime.Parse(txtDataDa.Text);

                        //Data fien Elaborazione
                        DateTime DataA = DateTime.Parse(txtDataA.Text).AddDays(1).AddSeconds(-1);

                        try
                        {

                            //Verifica che la relativa tabella di Storage sia vuota
                            Esito = StorageTableIsEmpty(NomeTabella);

                            if (Esito > 0)
                            {
                                if (String.IsNullOrEmpty(txtIdCliente.Text))
                                    //Avvia l'elaborazione per l'entità corrente
                                    EsitoElab = AvviaElaborazioneEntita(entity.id, DataDa, DataA);
                                else
                                    EsitoElab = AvviaElaborazioneEntita(entity.id, DataDa, DataA, Convert.ToInt32(txtIdCliente.Text));

                                result = "Elaborazione completata";
                            }
                            else
                            {
                                if (Esito == -1)
                                {
                                    EsitoElab = Common.Esito_Elaborazione.Errore;
                                    result = "Elaborazione in errore";
                                }
                                else
                                {
                                    //Aggiorna l'esito dell'elaborazione con "Tabella piena"
                                    EsitoElab = Common.Esito_Elaborazione.TabellaPiena;
                                    result = "Elaborazione annullata causa tabella piena";
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            result = "errore";
                            EsitoElab = Common.Esito_Elaborazione.Errore;
                        }

                        //Aggiorna l'esito dell'elaborazione
                        UpdateEsitoElaborazione(entity.id, Common.Tipo_Elaborazione.Manuale, DataDa, DataA, EsitoElab);

                        dicEsiti.Add(entity.NomeTabellaDestinazione, result);

                        if (Esito >= 0)
                        {
                            AggiornaTabellaStorageElaborazioni(entity.NomeTabellaDestinazione);
                        }

                        logService.Info(String.Format("Fine elaborazione entità: {0} Terminata con esito: {1}", entity.Nome, result));
                    }
                }

                logService.Info("Riepilogo:");
                foreach (KeyValuePair<string, string> el in dicEsiti)
                {
                    logService.Info(String.Format("Elaborazione Entità: {0} Terminata con esito: {1} ", el.Key, el.Value));
                }

                logService.Info(String.Format("Processo terminato: {0}", DateTime.Now.ToString()));

                retValue = true;

            }
            catch (Exception ex)
            {
                throw (ex);
            }



            return retValue;
        }

        private void AggiornaTabellaStorageElaborazioni(string NomeTabellaDestinazione)
        {

            try
            {
                using (SqlConnection mySQLConn = new SqlConnection(ConfigurationManager.ConnectionStrings["StagingGalaDB"].ToString()))
                {
                    String mySQL = String.Format("INSERT INTO GALA_CB_ELABORAZIONI (DataElaborazione,Entita,Flag) VALUES(GETDATE(),'{0}',0)", NomeTabellaDestinazione);

                    SqlCommand mySqlCommand = new SqlCommand();
                    mySqlCommand.CommandText = mySQL;
                    mySqlCommand.CommandType = CommandType.Text;
                    mySqlCommand.Connection = mySQLConn;

                    mySQLConn.Open();

                    mySqlCommand.ExecuteNonQuery();

                }
            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1}  STACK TRACE: {2}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message, ex.StackTrace));
                throw (ex);
            }

        }

        private void SetInterface(bool bset)
        {
            txtDataA.Enabled = bset;
            txtDataDa.Enabled = bset;
            txtIdCliente.Enabled = bset;
            clbEntita.Enabled = bset;
            btnManuale.Enabled = bset;
        }

        private void btn_Start_Click(object sender, EventArgs e)
        {
            StartCBProcess();
        }

        private void StartCBProcess()
        {

            try
            {
                dicEsiti.Clear();
                int Esito = -1;

                using (DataMaxDBEntities dme = new DataMaxDBEntities())
                {
                    DateTime UltimaElaborazione;
                    List<CB_Entita> cbe = new List<CB_Entita>();
                    //String sMessaggio = String.Empty;
                    Common.Esito_Elaborazione EsitoElab = Common.Esito_Elaborazione.Default;
                    String result = String.Empty;

                    logService.Info(String.Format("Processo avviato: {0}", DateTime.Now.ToString()));

                    //leggi entità da lavorare
                    cbe = ReadCBEntity();

                    foreach (CB_Entita entity in cbe)
                    {
                        logService.Info(String.Format("Inizio elaborazione entità: {0}", entity.Nome));

                        //Prende l'ultima data di elaborazione per l'entità
                        UltimaElaborazione = GetDateLastElaborazioneByEntity(entity);

                        //Memorizza data lancio elaborazione
                        DateTime DataElaborazione = DateTime.Now;
                        DateTime DataA = DateTime.Parse(DateTime.Now.ToShortDateString()).AddSeconds(-1);

                        try
                        {
                            //Verifica che la relativa tabella di Storage sia vuota
                            Esito = StorageTableIsEmpty(entity.NomeTabellaDestinazione);

                            if (Esito > 0)
                            {
                                //Avvia l'elaborazione per l'entità corrente
                                EsitoElab = AvviaElaborazioneEntita(entity.id, UltimaElaborazione, DataA);
                                result = "Elaborazione completata";
                            }
                            else
                            {
                                if (Esito == -1)
                                {
                                    EsitoElab = Common.Esito_Elaborazione.Errore;
                                    result = "Elaborazione in errore";
                                }
                                else
                                {
                                    //Aggiorna l'esito dell'elaborazione con "Tabella piena"
                                    EsitoElab = Common.Esito_Elaborazione.TabellaPiena;
                                    result = "Elaborazione annullata causa tabella piena";
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            EsitoElab = Common.Esito_Elaborazione.Errore;
                        }

                        //Aggiorna l'esito dell'elaborazione
                        UpdateEsitoElaborazione(entity.id, Common.Tipo_Elaborazione.Automatica, UltimaElaborazione,DataA, DataElaborazione, EsitoElab);

                        dicEsiti.Add(entity.NomeTabellaDestinazione, result);

                        if (Esito >= 0)
                        {
                            AggiornaTabellaStorageElaborazioni(entity.NomeTabellaDestinazione);
                        }

                        logService.Info(String.Format("Fine elaborazione entità: {0} Terminata con esito: {1}", entity.Nome, result));
                    }

                    logService.Info("Riepilogo:");
                    foreach (KeyValuePair<string, string> el in dicEsiti)
                    {
                        logService.Info(String.Format("Elaborazione Entità: {0} Terminata con esito: {1} ", el.Key, el.Value));
                    }

                    logService.Info(String.Format("Processo terminato: {0}", DateTime.Now.ToString()));
                }



            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message));
                //MessageBox.Show(ex.Message);
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
            String TipoFile = String.Empty;
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
                    logService.Info(String.Format("Escuzione Store recupero dati. Parametri: DataDa: {0} DataA {1} idCliente {2}", DataDa.ToString(), DataA.ToString(), idCliente.ToString()));
                    dtQueryResult = ExecuteStore(StoreProcedureName, DataDa, DataA, idCliente);

                    if (myEntity.id == Common.Entita.Garanzie_Factor.GetHashCode())
                        ExecuteRimuoviDuplicati();

                    //Verificare obligatorietà e congruenza dei dati
                    if (dtQueryResult.Rows.Count > 0)
                        VerifcaDati(idEntita, dtQueryResult, ref dtRigheOk, ref dtRigheScarti);
                    else
                        retValue = Common.Esito_Elaborazione.OK;

                    //Scive dati nella tabella di Storage
                    if (dtRigheOk.Rows.Count > 0)
                        retValue = InsertIntoStorage(idEntita, dtRigheOk);

                    if (retValue != Common.Esito_Elaborazione.OK)
                        return retValue;

                    //Salva i file CSV dei dati
                    Exporter objExporter = new Exporter();

                    switch (ConfigurationManager.AppSettings["ExportFormat"].ToString().ToUpper())
                    {
                        case "CSV":
                            objExporter.ExportType = ExportFormat.CSV;
                            objExporter.CSV_WithHeader = false;
                            TipoFile = "csv";
                            break;
                        case "XLS":
                            objExporter.ExportType = ExportFormat.EXCEL;
                            TipoFile = "xls";
                            break;
                        case "XLSX":
                            objExporter.ExportType = ExportFormat.EXCEL;
                            TipoFile = "xls";
                            break;
                        default:
                            objExporter.ExportType = ExportFormat.EXCEL;
                            TipoFile = "xls";
                            break;
                    }

                    if (dtRigheOk.Rows.Count > 0)
                    {
                        logService.Info("Creazione File righe esportate");
                        byte[] csvOK = objExporter.ExportDataTable(dtRigheOk);
                        path_to_save = String.Format("{0}\\{1}\\", ConfigurationManager.AppSettings["PathCSV_OK"].ToString(), myEntity.NomeTabellaDestinazione);
                        //path_to_save = myEntity.PathCSV;
                        exists = System.IO.Directory.Exists(path_to_save);
                        if (!exists)
                            System.IO.Directory.CreateDirectory(path_to_save);
                        File.WriteAllBytes(String.Format("{0}{1}_{2}_RigheOk.{3}", path_to_save, DateTime.Now.ToString("yyyMMddHHmmssfff"), myEntity.Nome, TipoFile), csvOK);
                    }

                    if (dtRigheScarti.Rows.Count > 0)
                    {
                        logService.Info("Creazione File righe scartate");
                        byte[] csvScarti = objExporter.ExportDataTable(dtRigheScarti);

                        path_to_save = String.Format("{0}\\{1}\\", ConfigurationManager.AppSettings["PathCSV_OK"].ToString(), myEntity.NomeTabellaDestinazione);
                        //path_to_save = myEntity.PathCSVscarti;
                        exists = System.IO.Directory.Exists(path_to_save);
                        if (!exists)
                            System.IO.Directory.CreateDirectory(path_to_save);
                        File.WriteAllBytes(String.Format("{0}{1}_{2}_RigheScarti.{3}", path_to_save, DateTime.Now.ToString("yyyMMddHHmmssfff"), myEntity.Nome, TipoFile), csvScarti);
                    }

                    retValue = Common.Esito_Elaborazione.OK;
                }
            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1} ENTITA: {2} STACK TRACE: {3}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message, idEntita.ToString(), ex.StackTrace));
                throw (ex);
            }

            return retValue;
        }

        private void ExecuteRimuoviDuplicati()
        {
            try
            {
                using (SqlConnection mySQLConn = new SqlConnection(ConfigurationManager.ConnectionStrings["StagingGalaDB"].ToString()))
                {
                    SqlCommand mySqlCommand = new SqlCommand();
                    mySqlCommand.CommandText = "GALA_Sp_EliminaDuplicatiGaranzieFactor";
                    mySqlCommand.CommandType = CommandType.StoredProcedure;
                    mySqlCommand.Connection = mySQLConn;

                    mySQLConn.Open();

                    mySqlCommand.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1} StoreProcdure: {2} STACK TRACE: {3}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message, "GALA_Sp_EliminaDuplicatiGaranzieFactor", ex.StackTrace));
                throw (ex);
            }
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

                logService.Info("Inserimento nella tabella di Storage");

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
                logService.Error(String.Format("METODO: {0} ERRORE: {1} ENTITA: {2} STACK TRACE: {3}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message, idEntita.ToString(), ex.StackTrace));
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
                logService.Error(String.Format("METODO: {0} ERRORE: {1} ENTITA: {2} STACK TRACE: {3}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message, idEntita.ToString(), ex.StackTrace));
                throw (ex);
            }

            return retValue;
        }

        private void VerifcaDati(int idEntita, DataTable dtQueryResult, ref DataTable dtRigheOk, ref DataTable dtRigheScarti)
        {
            String sMessagio = String.Empty;
            int j = 0;
            Dictionary<string, bool> dicObbligatorieta = new Dictionary<string, bool>();
            Dictionary<string, string> dicTipoCampo = new Dictionary<string, string>();
            Dictionary<string, int> dicLunghezzaCampo = new Dictionary<string, int>();

            try
            {
                logService.Info("Inizio Validazione Campi");
                Common.Entita myEntity = (Common.Entita)Enum.ToObject(typeof(Common.Entita), idEntita);

                switch (myEntity)
                {
                    //Anagrafica Clienti
                    case Common.Entita.Anagrafica_Clienti:
                        clsClienti objClienti = new clsClienti();

                        //Caricamento Dictionary Campi
                        dicObbligatorieta = LoadDicObligatorieta(idEntita);
                        dicTipoCampo = LoadDicTipo(idEntita);
                        dicLunghezzaCampo = LoadDicLunghezza(idEntita);

                        foreach (DataRow r in dtQueryResult.Rows)
                        {
                            j++;
                            //Validazione generica della riga
                            if (GenericValidationRow(r, dicObbligatorieta, dicTipoCampo, dicLunghezzaCampo, ref sMessagio))
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

                        //Caricamento Dictionary Campi
                        dicObbligatorieta = LoadDicObligatorieta(idEntita);
                        dicTipoCampo = LoadDicTipo(idEntita);
                        dicLunghezzaCampo = LoadDicLunghezza(idEntita);

                        foreach (DataRow r in dtQueryResult.Rows)
                        {
                            j++;
                            //Validazione generica della riga
                            if (GenericValidationRow(r, dicObbligatorieta, dicTipoCampo, dicLunghezzaCampo, ref sMessagio))
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

                        //Caricamento Dictionary Campi
                        dicObbligatorieta = LoadDicObligatorieta(idEntita);
                        dicTipoCampo = LoadDicTipo(idEntita);
                        dicLunghezzaCampo = LoadDicLunghezza(idEntita);

                        foreach (DataRow r in dtQueryResult.Rows)
                        {
                            j++;
                            //Validazione generica della riga
                            if (GenericValidationRow(r, dicObbligatorieta, dicTipoCampo, dicLunghezzaCampo, ref sMessagio))
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

                        //Caricamento Dictionary Campi
                        dicObbligatorieta = LoadDicObligatorieta(idEntita);
                        dicTipoCampo = LoadDicTipo(idEntita);
                        dicLunghezzaCampo = LoadDicLunghezza(idEntita);

                        foreach (DataRow r in dtQueryResult.Rows)
                        {

                            if (r["ID_CAUSALE"].ToString() == "99999")
                            {
                                dtRigheOk.Rows.Add(AggiungiRigheOK(idEntita, r, dtRigheOk));
                                continue;
                            }

                            j++;
                            //Validazione generica della riga
                            if (GenericValidationRow(r, dicObbligatorieta, dicTipoCampo, dicLunghezzaCampo, ref sMessagio))
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

                        //Caricamento Dictionary Campi
                        dicObbligatorieta = LoadDicObligatorieta(idEntita);
                        dicTipoCampo = LoadDicTipo(idEntita);
                        dicLunghezzaCampo = LoadDicLunghezza(idEntita);

                        foreach (DataRow r in dtQueryResult.Rows)
                        {
                            j++;
                            //Validazione generica della riga
                            if (GenericValidationRow(r, dicObbligatorieta, dicTipoCampo, dicLunghezzaCampo, ref sMessagio))
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

                        //Caricamento Dictionary Campi
                        dicObbligatorieta = LoadDicObligatorieta(idEntita);
                        dicTipoCampo = LoadDicTipo(idEntita);
                        dicLunghezzaCampo = LoadDicLunghezza(idEntita);

                        foreach (DataRow r in dtQueryResult.Rows)
                        {
                            j++;
                            //Validazione generica della riga
                            if (GenericValidationRow(r, dicObbligatorieta, dicTipoCampo, dicLunghezzaCampo, ref sMessagio))
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
                        dtRigheOk = dtQueryResult.Copy();
                        break;
                    default:
                        break;
                }

                logService.Info("Fine Validazione Campi");
            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1} ENTITA: {2} STACK TRACE: {3}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message, idEntita.ToString(), ex.StackTrace));
                throw (ex);
            }
        }

        #region Caricamento Dictionary Campi
        private Dictionary<string, int> LoadDicLunghezza(int idEntita)
        {
            Dictionary<string, int> retValue = new Dictionary<string, int>();

            try
            {

                using (DataMaxDBEntities DMdb = new DataMaxDBEntities())
                {
                    List<CB_EntitaCampi> campi = DMdb.CB_EntitaCampi.Where(c => c.id_Entita == idEntita && c.Attivo).ToList();

                    foreach (CB_EntitaCampi c in campi)
                    {
                        retValue.Add(c.NomeCampoDestinazione, c.Lunghezza);
                    }
                }
            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1} ENTITA: {2} STACK TRACE: {3}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message, idEntita.ToString(), ex.StackTrace));
                throw (ex);
            }

            return retValue;
        }

        private Dictionary<string, string> LoadDicTipo(int idEntita)
        {
            Dictionary<string, string> retValue = new Dictionary<string, string>();

            try
            {

                using (DataMaxDBEntities DMdb = new DataMaxDBEntities())
                {
                    List<CB_EntitaCampi> campi = DMdb.CB_EntitaCampi.Where(c => c.id_Entita == idEntita && c.Attivo).ToList();

                    foreach (CB_EntitaCampi c in campi)
                    {
                        retValue.Add(c.NomeCampoDestinazione, c.CB_TipoCampo.Nome);
                    }
                }
            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1} ENTITA: {2} STACK TRACE: {3}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message, idEntita.ToString(), ex.StackTrace));
                throw (ex);
            }

            return retValue;
        }

        private Dictionary<string, bool> LoadDicObligatorieta(int idEntita)
        {
            Dictionary<string, bool> retValue = new Dictionary<string, bool>();


            try
            {

                using (DataMaxDBEntities DMdb = new DataMaxDBEntities())
                {
                    List<CB_EntitaCampi> campi = DMdb.CB_EntitaCampi.Where(c => c.id_Entita == idEntita && c.Attivo).ToList();

                    foreach (CB_EntitaCampi c in campi)
                    {
                        retValue.Add(c.NomeCampoDestinazione, c.Obbligatorio);
                    }
                }
            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1} ENTITA: {2} STACK TRACE: {3}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message, idEntita.ToString(), ex.StackTrace));
                throw (ex);
            }

            return retValue;
        }
        #endregion


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
                logService.Error(String.Format("METODO: {0} ERRORE: {1} ENTITA: {2} STACK TRACE: {3}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message, idEntita.ToString(), ex.StackTrace));
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
                logService.Error(String.Format("METODO: {0} ERRORE: {1} ENTITA: {2} STACK TRACE: {3}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message, idEntita.ToString(), ex.StackTrace));
                throw (ex);
            }

            return retValue;
        }

        private bool GenericValidationRow(DataRow r, Dictionary<string, bool> dicObbligatorieta, Dictionary<string, string> dicTipoCampo, Dictionary<string, int> dicLunghezza, ref string sMessagio)
        {

            foreach (KeyValuePair<string, bool> c in dicObbligatorieta)
            {
                String ValoreCampo = r[c.Key] == DBNull.Value ? String.Empty : r[c.Key].ToString();

                //Controllo obbligatorietà del campo
                if (String.IsNullOrEmpty(ValoreCampo) && c.Value)
                {
                    sMessagio = String.Format("Il Campo: {0} è obbligatorio", c.Key);
                    return false;
                }

                //Legge la cofigurazione per sapere se deve fare solo i controlli di obbligatorietà o anche di tipo e lunghezza
                if (ConfigurationManager.AppSettings["ControlloSoloRequired"].ToString().ToUpper() != "Y")
                {

                    if (!String.IsNullOrEmpty(ValoreCampo))
                    {
                        string _tipo = dicTipoCampo.Where(ca => ca.Key == c.Key).SingleOrDefault().Value;

                        //Controllo tipo CAMPO
                        switch (_tipo.ToUpper())
                        {
                            case "STRING":
                                break;
                            case "INT":
                                int i;
                                if (!Int32.TryParse(ValoreCampo, out i))
                                {
                                    sMessagio = String.Format("Il Campo: {0} deve essere di tipo {1}", c.Value, _tipo.ToUpper());
                                    return false;
                                }
                                break;
                            case "DATE":
                                DateTime dt;
                                if (!DateTime.TryParse(ValoreCampo, out dt))
                                {
                                    sMessagio = String.Format("Il Campo: {0} deve essere di tipo {1}", c.Value, _tipo.ToUpper());
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
                                    sMessagio = String.Format("Il Campo: {0} deve essere di tipo Number con 2 cifre decimali", c.Value);
                                    return false;
                                }

                                break;
                            default:
                                break;
                        }

                        int _lunghezza = dicLunghezza.Where(l => l.Key == c.Key).SingleOrDefault().Value;

                        //Controllo lunghezza campo
                        if (ValoreCampo.Length > _lunghezza)
                        {
                            sMessagio = String.Format("Il Campo: {0} è di lunghezza {1} valore ammesso {2}", c.Value, ValoreCampo.Length.ToString(), _lunghezza.ToString());
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
                logService.Error(String.Format("METODO: {0} ERRORE: {1} StoreProcdure: {2} STACK TRACE: {3}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message, StoreProcedureName, ex.StackTrace));
                throw (ex);
            }

            return retValue;
        }


        private DateTime GetDateLastElaborazioneByEntity(CB_Entita entity)
        {
            DateTime retValue = DateTime.Now;
            int idEsitoElaborazione = Common.Esito_Elaborazione.OK.GetHashCode();
            int idTipoElaborazione = Common.Tipo_Elaborazione.Automatica.GetHashCode();

            try
            {
                using (DataMaxDBEntities dme = new DataMaxDBEntities())
                {
                    retValue = (from elb in dme.CB_Elaborazioni where elb.id_Entita == entity.id && elb.id_Esito == idEsitoElaborazione && elb.id_Tipologia == idTipoElaborazione select (DateTime)elb.DataA).Max();
                    logService.Info(String.Format("Data Ultima Elaborazione ricavate {0} per l'entità {1}", retValue.ToString(), entity.Nome));
                }
            }
            catch (Exception ex)
            {
                logService.Error(String.Format("METODO: {0} ERRORE: {1} ENTITA: {2} STACK TRACE: {3}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message, entity.ToString(), ex.StackTrace));
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
                logService.Error(String.Format("METODO: {0} ERRORE: {1} STACK TRACE: {2}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message, ex.StackTrace));
                throw (ex);
            }

            return retValue;
        }

        private int StorageTableIsEmpty(string TableName)
        {
            int retValue = 0;

            logService.Info(String.Format("Verifica tabella di storage {0} vuota.", TableName));

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
                logService.Error(String.Format("METODO: {0} ERRORE: {1} ENTITA: {2} STACK TRACE: {3}", System.Reflection.MethodBase.GetCurrentMethod().Name, ex.Message, entityID.ToString(), ex.StackTrace));
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

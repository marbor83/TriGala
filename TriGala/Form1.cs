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


namespace TriGala
{
    public partial class frmMain : Form
    {
        private bool bFormVisible;

        private ILogService logService = new FileLogService(typeof(frmMain));

        public frmMain(string[] args)
        {
            InitializeComponent();

            if (args != null && args[0] == "-A")
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
                    DateTime LastElaborazione;
                    List<CB_Entita> cbe = new List<CB_Entita>();

                    logService.Info(String.Format("Processo avviato: {0}", DateTime.Now.ToString()));

                    //leggi entità da lavorare
                    cbe = ReadCBEntity();

                    foreach (CB_Entita entity in cbe)
                    {
                        //Prende l'ultima data di elaborazione per l'entità
                        LastElaborazione = GetDateLastElaborazioneByEntity(entity);

                        //Verifica che la relativa tabella di Storage sia vuota
                        if (StorageTableIsEmpty(entity.NomeTabellaDestinazione))
                        {
                            //Memorizza data lancio elaborazione
                            DateTime DataElaborazione = DateTime.Now;

                            //Avvia l'elaborazione per l'entità corrente
                            Common.Esito_Elaborazione EsitoElab = AvviaElaborazioneEntita(entity.id, DataElaborazione);

                            //Aggiorna l'esito dell'elaborazione
                            UpdateEsitoElaborazione(entity.id, Common.Tipo_Elaborazione.Automatica, LastElaborazione, DataElaborazione, EsitoElab);
                        }
                        else
                        {
                            //Aggiorna l'esito dell'elaborazione con "Tabella piena"
                            UpdateEsitoElaborazione(entity.id, Common.Tipo_Elaborazione.Automatica, LastElaborazione, Common.Esito_Elaborazione.TabellaPiena);
                        }
                    }
                }



            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private Common.Esito_Elaborazione AvviaElaborazioneEntita(int idEntita, DateTime DataElaborazione)
        {
            Common.Esito_Elaborazione retValue = Common.Esito_Elaborazione.Errore;

            try
            {

            }
            catch (Exception ex)
            {

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

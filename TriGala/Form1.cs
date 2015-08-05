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


namespace TriGala
{
    public partial class frmMain : Form
    {

        private ILogService logService = new FileLogService(typeof(frmMain));

        public frmMain()
        {
            InitializeComponent();
        }

        private void btn_Start_Click(object sender, EventArgs e)
        {
            StartCBProcess();
        }

        private void StartCBProcess()
        {

            try
            {
                DataMaxDBEntities dme = new DataMaxDBEntities();
                DateTime LastElaborazione;
                List<CB_Entita> cbe = new List<CB_Entita>();

                logService.Info(String.Format("Processo avviato: {0}", DateTime.Now.ToString()));

                //leggi entità da lavorare
                cbe = ReadCBEntity();

                foreach (CB_Entita entity in cbe)
                {
                    LastElaborazione = GetDateLastElaborazioneByEntity(entity);
                    if (StorageTableIsEmpty(entity.NomeTabellaDestinazione))
                    { }
                }

            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private DateTime GetDateLastElaborazioneByEntity(CB_Entita entity)
        {
            DateTime retValue = DateTime.Now;

            try
            {
                DataMaxDBEntities dme = new DataMaxDBEntities();
                retValue = (from elb in dme.CB_Elaborazioni where elb.id_Entita == entity.id & elb.id_Esito == Common.Esito_Elaborazione.OK.GetHashCode() select elb.DataElaborazione).Max();
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
                DataMaxDBEntities dme = new DataMaxDBEntities();

                retValue = dme.CB_Entita.Where(x => x.Attivo).ToList();
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

            StagingGalaDBEntities sge = new StagingGalaDBEntities();

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


            return retValue;
        }





    }
}

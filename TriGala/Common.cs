using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TriGala
{
    public static class Common
    {

        public const string PERSONA_FISICA = "F";
        public const string PERSONA_GIURIDICA = "G";

        public enum Esito_Elaborazione
        {
            OK = 10,
            TabellaPiena = -98,
            Errore = -99,
            Default = -1
        }

        public enum Tipo_Elaborazione
        {
            Automatica = 100,
            Manuale = 200
        }

        public enum Entita
        {
            Anagrafica_Clienti = 1001,
            Anagrafica_Contratti = 1002,
            POD_PDR = 1003,
            Anagrafica_Movimenti = 1004,
            Anagrafica_Contatti = 1005,
            Garanzie_Factor = 1006,
            Esposizione = 1007
        }

    }
}

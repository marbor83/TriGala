using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TriGala
{
    public static class Common
    {
        public enum Esito_Elaborazione
        {
            OK = 10,
            TabellaPiena = -98,
            Errore = -99
        }

        public enum Tipo_Elaborazione
        {
            Automatica = 100,
            Manulae = 200
        }
    }
}

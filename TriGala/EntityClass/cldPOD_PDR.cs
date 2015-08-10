using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Log4NetLibrary;
using System.Data;

namespace TriGala.EntityClass
{
    class clsPOD_PDR
    {
        private ILogService logService = new FileLogService(typeof(frmMain));

        public bool RowIsValid(DataRow myRow, ref String sMessaggio)
        {
            //Al Momento non sono previsti controlli
            return true;
        }

    }
}

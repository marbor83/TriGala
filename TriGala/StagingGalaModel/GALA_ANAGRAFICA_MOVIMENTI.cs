//------------------------------------------------------------------------------
// <auto-generated>
//    This code was generated from a template.
//
//    Manual changes to this file may cause unexpected behavior in your application.
//    Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace StagingGalaModel
{
    using System;
    using System.Collections.Generic;
    
    public partial class GALA_ANAGRAFICA_MOVIMENTI
    {
        public int ID_RECORD { get; set; }
        public string ID_AZIENDA { get; set; }
        public string ID_CLIENTE { get; set; }
        public string N_DOC { get; set; }
        public System.DateTime DATA_DOC { get; set; }
        public System.DateTime DATA_REG { get; set; }
        public System.DateTime DATA_ACQ { get; set; }
        public Nullable<System.DateTime> DATA_UPD { get; set; }
        public System.DateTime DATA_SCAD { get; set; }
        public string SEGNO { get; set; }
        public string VALUTA { get; set; }
        public decimal IMPORTO { get; set; }
        public string ID_CAUSALE { get; set; }
        public string DESCR_CAUSALE { get; set; }
        public string ID_PAG_MOD { get; set; }
        public string DESCR_PAG_MOD { get; set; }
        public string ID_PAG_TER { get; set; }
        public string DESCR_PAG_TER { get; set; }
        public string COMMODITY { get; set; }
        public string CODICE_PARTITA { get; set; }
        public string FACTOR { get; set; }
        public string Tipologia_fattura { get; set; }
        public string Desscrizione_tipologia_fattura { get; set; }
        public string URL { get; set; }
        public Nullable<decimal> IMPONIBILE { get; set; }
    }
}

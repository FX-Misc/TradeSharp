//------------------------------------------------------------------------------
// <auto-generated>
//    This code was generated from a template.
//
//    Manual changes to this file may cause unexpected behavior in your application.
//    Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace TradeSharp.Linq
{
    using System;
    using System.Collections.Generic;
    
    public partial class BROKER_RESPONSE
    {
        public int ID { get; set; }
        public int RequestID { get; set; }
        public Nullable<decimal> Price { get; set; }
        public Nullable<decimal> Swap { get; set; }
        public int Status { get; set; }
        public Nullable<int> RejectReason { get; set; }
        public string RejectReasonString { get; set; }
        public System.DateTime ValueDate { get; set; }
    }
}

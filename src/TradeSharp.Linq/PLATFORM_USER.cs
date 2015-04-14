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
    
    public partial class PLATFORM_USER
    {
        public PLATFORM_USER()
        {
            this.ACCOUNT_SHARE = new HashSet<ACCOUNT_SHARE>();
            this.ACCOUNT_SHARE_HISTORY = new HashSet<ACCOUNT_SHARE_HISTORY>();
            this.PLATFORM_USER_ACCOUNT = new HashSet<PLATFORM_USER_ACCOUNT>();
            this.SERVICE = new HashSet<SERVICE>();
            this.SUBSCRIPTION = new HashSet<SUBSCRIPTION>();
            this.TRANSFER = new HashSet<TRANSFER>();
            this.USER_EVENT = new HashSet<USER_EVENT>();
            this.USER_PAYMENT_SYSTEM = new HashSet<USER_PAYMENT_SYSTEM>();
            this.TOP_PORTFOLIO = new HashSet<TOP_PORTFOLIO>();
            this.USER_TOP_PORTFOLIO = new HashSet<USER_TOP_PORTFOLIO>();
        }
    
        public int ID { get; set; }
        public string Title { get; set; }
        public string Name { get; set; }
        public string Surname { get; set; }
        public string Patronym { get; set; }
        public string Description { get; set; }
        public string Email { get; set; }
        public string Phone1 { get; set; }
        public string Phone2 { get; set; }
        public string Login { get; set; }
        public string Password { get; set; }
        public int RoleMask { get; set; }
        public System.DateTime RegistrationDate { get; set; }
    
        public virtual ICollection<ACCOUNT_SHARE> ACCOUNT_SHARE { get; set; }
        public virtual ICollection<ACCOUNT_SHARE_HISTORY> ACCOUNT_SHARE_HISTORY { get; set; }
        public virtual ICollection<PLATFORM_USER_ACCOUNT> PLATFORM_USER_ACCOUNT { get; set; }
        public virtual ICollection<SERVICE> SERVICE { get; set; }
        public virtual ICollection<SUBSCRIPTION> SUBSCRIPTION { get; set; }
        public virtual ICollection<TRANSFER> TRANSFER { get; set; }
        public virtual ICollection<USER_EVENT> USER_EVENT { get; set; }
        public virtual USER_INFO USER_INFO { get; set; }
        public virtual ICollection<USER_PAYMENT_SYSTEM> USER_PAYMENT_SYSTEM { get; set; }
        public virtual ICollection<TOP_PORTFOLIO> TOP_PORTFOLIO { get; set; }
        public virtual ICollection<USER_TOP_PORTFOLIO> USER_TOP_PORTFOLIO { get; set; }
        public virtual WALLET WALLET { get; set; }
    }
}

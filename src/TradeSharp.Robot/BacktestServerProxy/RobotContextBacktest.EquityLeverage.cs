﻿using System;
using System.Collections.Generic;
using TradeSharp.Util;

namespace TradeSharp.Robot.BacktestServerProxy
{
    /*
     кривая доходности и экспозиция
     */
    public partial class RobotContextBacktest
    {
        /// <summary>
        /// дата, средства, экспозиция
        /// - по дням
        /// </summary>
        public List<Cortege3<DateTime, float, float>> dailyEquityExposure = new List<Cortege3<DateTime, float, float>>();
    
        private void UpdateDailyEquityExposure(DateTime date)
        {
            decimal reservedMargin, exposure, equity;
            if (Positions.Count > 0)
            {
                // средства
                var quotes = quotesStorage.ReceiveAllData();
                AccountInfo.Equity = profitCalculator.CalculateAccountEquity(AccountInfo.ID,
                    AccountInfo.Balance, AccountInfo.Currency, quotes, this);
                // плечо                
                profitCalculator.CalculateAccountExposure(AccountInfo.ID,
                    out equity, out reservedMargin, out exposure, quotes, this, GetAccountGroup);
            }
            else
            {
                AccountInfo.Equity = AccountInfo.Balance;
                equity = AccountInfo.Equity;
                exposure = 0;
                reservedMargin = 0;
            }

            if (dailyEquityExposure.Count > 0)
                if (dailyEquityExposure[dailyEquityExposure.Count - 1].a == date) return;

            // проредить до 1 дня
            dailyEquityExposure.Add(new Cortege3<DateTime, float, float>(date, (float)equity, (float)exposure));
        }
    }
}

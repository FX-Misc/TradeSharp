//+------------------------------------------------------------------+
//|                                            TrailExpertSimple.mq4 |
//|                                                    Andrey Sitaev |
//|                                        http://www.forexinvest.ru |
//+------------------------------------------------------------------+
#property copyright "Andrey Sitaev"
#property link      "http://www.forexinvest.ru"

#define deals_max 50

// ��� ���� ��������� ������
extern int        commonLevel = 500;
extern int        commonTarget = 100;
// TP ��� ���� ������, �������������� ����� ��������� (�� �����)
extern int        commonTP = 0;
extern int        maxCloseSlippage = 200;

void ProtectDeal(int ticket, double sl)
{
    Print("������ ������ ", ticket, " - ������� ����� �� ", sl);
    if (!OrderModify(ticket, OrderOpenPrice(), sl, OrderTakeProfit(), 0, Blue))
    {
        Print("���������� �������� �����: ", GetLastError());
    }
}

void CloseDeal(int ticket, string reason)
{
    double curPrice;
    int priceMode = MODE_BID, error;
    Print("�������� ������ ", ticket, " TrailExpertSimple (", reason, ")");
    
    if (OrderType() == OP_SELL) priceMode = MODE_ASK;
    curPrice = MarketInfo(OrderSymbol(), priceMode);
    
    if (!OrderClose(ticket, OrderLots(), curPrice, maxCloseSlippage))
    {
        error = GetLastError();
        Print("������ �������� ������ (", error, ")");
    }
}

void CheckDeals()
{
    int orderType, orderSide;
    double pipCost, curPrice, stop, tpPrice;
    double controlLevel, targetLevel;
    
    for (int i = 0; i < 1000; i++)
    {
        if (!OrderSelect(i, SELECT_BY_POS))
        {// ����� ����� �� ������ - ��������� ���
            break;
        }
        orderType = OrderType();
        if (orderType != OP_BUY && orderType != OP_SELL) continue;
        orderSide = 1;
        if (orderType == OP_SELL) orderSide = -1;
        
        pipCost = MarketInfo(OrderSymbol(), MODE_POINT);
        controlLevel = OrderOpenPrice() + orderSide * commonLevel * pipCost;
        targetLevel = OrderOpenPrice() + orderSide * commonTarget * pipCost;            
        curPrice = MarketInfo(OrderSymbol(), MODE_BID);
                             
        // ��������� ������� TP
        if (commonTP > 0)
        {
            tpPrice = OrderOpenPrice() + orderSide * commonTP * pipCost;
            if (orderType == OP_BUY && curPrice >= tpPrice) CloseDeal(OrderTicket(), "TP");
            if (orderType == OP_SELL && curPrice <= tpPrice) CloseDeal(OrderTicket(), "TP");
        }
        
        // ��������� ������� �������� ����� - ���������� ����, ���� �� ���������� ����        
        stop = OrderStopLoss();
        
        if (orderType == OP_BUY && curPrice >= controlLevel)
        {
            // �� ��������� �� ������ � ������ ������� �� �����?
            if (targetLevel > stop)            
                ProtectDeal(OrderTicket(), targetLevel);
            continue;
        }
        if (orderType == OP_SELL && curPrice <= controlLevel)
        {
            // �� ��������� �� ������ � ������ ������� �� �����?
            if (targetLevel < stop || stop == 0)            
                ProtectDeal(OrderTicket(), targetLevel);            
            continue;
        }
    }
}

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{    
    return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
    return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
    CheckDeals();
    return (0);
}
//+------------------------------------------------------------------+
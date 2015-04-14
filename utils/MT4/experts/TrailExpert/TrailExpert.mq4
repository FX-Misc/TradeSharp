//+------------------------------------------------------------------+
//|                                                  TrailExpert.mq4 |
//|                                                    Andrey Sitaev |
//|                                        http://www.forexinvest.ru |
//+------------------------------------------------------------------+
#property copyright "Andrey Sitaev"
#property link      "http://www.forexinvest.ru"

#define deals_max 50

// ��������� ����: "71738290:40,5;71738296:35,8;"
extern string     sets;

int     dealTickets[deals_max];
int     controlLevels[deals_max];
int     targetLevels[deals_max];
int     dealsCount = 0;

double  controlLevelAbs[deals_max];
double  targetLevelAbs[deals_max];

void Purge()
{
   Print("Purge");
   dealsCount = 0;
   ArrayInitialize(controlLevelAbs, 0);
   ArrayInitialize(targetLevelAbs, 0);
}

void ExcludeDeal(int dealTicket)
{
    int excludeIndex = 0;
    for (int i = 0; i < dealsCount; i++)    
    {
        if (dealTickets[i] == dealTicket)
        {
            Print("Excluding order ", dealTicket);
        
            for (int j = i + 1; j < dealsCount; j++)
            {
                dealTickets[j - 1] = dealTickets[j];
                controlLevels[j - 1] = controlLevels[j];
                targetLevels[j - 1] = targetLevels[j];
                controlLevelAbs[j - 1] = controlLevelAbs[j];
                targetLevelAbs[j - 1] = targetLevelAbs[j - 1];
            }
            dealsCount = dealsCount - 1;
            return;
        }
    }
}

void AddDeal(int dealTicket, int controlLevel, int targetLevel)
{
    dealTickets[dealsCount] = dealTicket;
    controlLevels[dealsCount] = controlLevel;
    targetLevels[dealsCount] = targetLevel;
    dealsCount = dealsCount + 1;
    
    Print("TCL: ", dealTicket, " ", controlLevel, " ", targetLevel);
}

void ParseSettings()
{// "4510:50,5;4511:45,5;"
    int index = 0, prevIndex = 0, len = StringLen(sets);
    string ticket, control, target;
    
    while (true)
    {
        // N ������� (4510)        
        if (index >= len) break;
        index = StringFind(sets, ":", index);
        if (index < 0) break;
        ticket = StringSubstr(sets, prevIndex, index - prevIndex);
        index = index + 1;
        prevIndex = index;
        
        // �������
        if (index >= len) break;
        index = StringFind(sets, ",", index);
        if (index < 0) break;
        control = StringSubstr(sets, prevIndex, index - prevIndex);
        index = index + 1;
        prevIndex = index;
        
        // �������
        if (index >= len) break;
        index = StringFind(sets, ";", index);
        if (index < 0) break;
        target = StringSubstr(sets, prevIndex, index - prevIndex);
        index = index + 1;
        prevIndex = index;
        
        AddDeal(StrToInteger(ticket), StrToInteger(control), StrToInteger(target));
    }
}


void ProtectDeal(int ticket, double sl)
{
    Print("������ ������ ", ticket, " - ������� ����� �� ", sl);
    if (!OrderModify(ticket, OrderOpenPrice(), sl, OrderTakeProfit(), 0, Blue))
    {
        Print("���������� �������� �����: ", GetLastError());
    }
    // ��������� �� ��������
    ExcludeDeal(ticket);
}

void CheckDeals()
{
    int orderType, orderSide;
    double pipCost, curPrice, stop;
    
    for (int i = 0; i < dealsCount; i++)
    {
        if (!OrderSelect(dealTickets[i], SELECT_BY_TICKET))
        {// ����� ����� �� ������ - ��������� ���
            ExcludeDeal(dealTickets[i]);
            i = i - 1;
            continue;
        }
        orderType = OrderType();
        if (orderType != OP_BUY && orderType != OP_SELL) continue;
        orderSide = 1;
        if (orderType == OP_SELL) orderSide = -1;
        
        // ��������� - ������ �� ��� ���� ���. ������
        // �������� � �������� �����
        if (controlLevelAbs[i] == 0)
        {
            pipCost = MarketInfo(OrderSymbol(), MODE_POINT);
            controlLevelAbs[i] = OrderOpenPrice() + orderSide * controlLevels[i] * pipCost;
            // ������� �����
            targetLevelAbs[i] = OrderOpenPrice() + orderSide * targetLevels[i] * pipCost;
            Print("����� #", dealTickets[i], ": level ", 
                controlLevelAbs[i], ", target ", targetLevelAbs[i]);
        }
        
        // ��������� ������� �������� ����� - ���������� ����, ���� �� ���������� ����
        curPrice = MarketInfo(OrderSymbol(), MODE_BID);
        stop = OrderStopLoss();
        
        if (orderType == OP_BUY && curPrice >= controlLevelAbs[i])
        {
            // �� ��������� �� ������ � ������ ������� �� �����?
            if (targetLevelAbs[i] > stop)
                { ProtectDeal(dealTickets[i], targetLevelAbs[i]); i = i - 1; }
            continue;
        }
        if (orderType == OP_SELL && curPrice <= controlLevelAbs[i])
        {
            // �� ��������� �� ������ � ������ ������� �� �����?
            if (targetLevelAbs[i] < stop || stop == 0)
                { ProtectDeal(dealTickets[i], targetLevelAbs[i]); i = i - 1; }
            continue;
        }
    }
}

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
    Purge();
    ParseSettings();
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
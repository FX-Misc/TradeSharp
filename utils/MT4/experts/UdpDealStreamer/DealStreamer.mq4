//+------------------------------------------------------------------+
//|                                                 DealStreamer.mq4 |
//|                        Copyright 2012, A.S.                      |
//| �������� ����������� ������ �� UDP ���������� "DealAcceptor"     |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, A.S."
#property link      "http://www.1.net"

//#import "udpsender.dll"  
//void SendToPort(string ip, int port, string message);

// ������� ���������
// �����������, �� ������� ���������� ����� ������
extern double    leverageK = 1.0;
// ������ ������ ��� �������� ������ (���� 7000,7001,...)
extern string    ports = "7000";
// �������� ������ ������
extern int slipMilliseconds = 150;
// ���� ���� ������� - ��������� ������� - �������� ������, ��������� �� ������
// ������� ���������
extern bool translateOldDeals = true;

// ������ ������
int portsArray[];
// ��������� Id ������
int processedDealIds[500];

void toIntArray(int& arr[], string str, string sym) 
{
   ArrayResize(arr, 0);

   string item;
   int pos, size;

   int len = StringLen(str);
   for (int i = 0; i < len;) 
   {
      pos = StringFind(str, sym, i);
      if (pos == -1) pos = len;

      item = StringSubstr(str, i, pos - i);
      item = StringTrimLeft(item);
      item = StringTrimRight(item);

      size = ArraySize(arr);
      ArrayResize(arr, size + 1);
      arr[size] = StrToInteger(item);

      i = pos + 1;
   }
}

void InitProcessed()
{
   int i;
   // �������� ������
   for (i = 0; i < 500; i++) processedDealIds[i] = 0;
   int curProcessed = 0;

   // ��������� ��������� ������
   if (!translateOldDeals)
   {
      for (i = 0; i < 500; i++)
      {
         if (OrderSelect(i, SELECT_BY_POS) == false) break;
         processedDealIds[curProcessed] = OrderTicket();
         curProcessed++;
         processedDealIds[curProcessed] = 0;
      }
      Print("DealStreaming: found ", curProcessed, " deals");
   }
   return(0);
}

bool IsProcessed(int dealId)
{
   for (int i = 0; i < 500; i++)
   {
      if (processedDealIds[i] == 0) break;
      if (processedDealIds[i] == dealId) return (TRUE);
   }
   return (FALSE);
}

void MarkAsProcessed(int dealId)
{
   for (int j = 0; j < 500; j++)
   {
      if (processedDealIds[j] != 0) continue;
      processedDealIds[j] = dealId;
      processedDealIds[j + 1] = 0;
      break;
   }
}

void StreamDeal(int dealId)
{
   int orderType = OrderType();
   if (orderType != OP_BUY && orderType != OP_SELL) return;
   string ticker = OrderSymbol();
   int lots = OrderLots();
   double leverage = lots * 10000 / AccountEquity();
   //Print("DealStreaming: stream deal ", dealId, " (type: ", orderType, ", symbol: ", ticker,
   //   ", volume: ", lots, ", leverage: ", leverage, ")");
   // ��������� ������� ���� BUY_EURUSD_Leverage_666
   string sideStr = "BUY";
   if (orderType == OP_SELL) sideStr = "SELL";
   string cmdStr = StringConcatenate(sideStr, "_", ticker, "_", leverage, "_", dealId);
   //SendToPort(address, port, cmdStr);
   Print(cmdStr);
}

void CheckNewDeals()
{
   int curId;
   for (int i = 0; i < 500; i++)
   {
      if (OrderSelect(i, SELECT_BY_POS) == false) break;
      curId = OrderTicket();
      if (IsProcessed(curId)) 
      {
         //Print("deal processed");
         continue;
      }
      //Print("deal is not processed");
      // ������� ���������� ������
      StreamDeal(curId);
      // �������� ��� ��������
      MarkAsProcessed(curId);
    }
}

// ���������� ������ processedDealIds �� "�����" (�����)
void PackArray(int totalItems)
{
   int arTemp[1];
   ArrayResize(arTemp, totalItems);
   int nextIndex = 0;
   int i;

   for (i = 0; i < 500; i++)
   {
      if (processedDealIds[i] == 0) continue;
      arTemp[nextIndex] = processedDealIds[i];
      nextIndex = nextIndex + 1;
      if (nextIndex == totalItems) break;
   }
   
   for (i = 0; i < 500; i++)
   {
      if (i < totalItems)
         processedDealIds[i] = arTemp[i];
      else
         processedDealIds[i] = 0;
   }
}

void CheckClosedDeals()
{
   bool hasClosedDeals = FALSE;
   string cmdStr;
   int totalItems = 0;
   
   for (int i = 0; i < 500; i++)
   {
      totalItems = totalItems + 1;
      if (processedDealIds[i] == 0) break;
      if (OrderSelect(processedDealIds[i], SELECT_BY_TICKET)) continue;
      // ������ ��������� - ��������� ������� ���� CLOSE_666
      cmdStr = StringConcatenate("CLOSE_", processedDealIds[i]);
      //SendToPort(address, port, cmdStr);
      Print(cmdStr);
      hasClosedDeals = TRUE;
      processedDealIds[i] = 0;
      totalItems = totalItems - 1;
   }
   
   // � ������� ��������� "�����" ?
   if (hasClosedDeals) PackArray(totalItems);
}

int init()
{
   toIntArray(portsArray, ports, ",");
   for (int i = 0; i < ArraySize(portsArray); i++)
      Print("DealStreamer: feeds ports ", portsArray[i]);
   InitProcessed();
   return(0);
}

int deinit()
{
   return(0);
}

int start()
{
   int curId;
   Print("Started");
   while (true)
   {      
      // �������� ����� ������
      CheckNewDeals();
      Sleep(slipMilliseconds);
      // ��������� ���������� ������ �� ������� ��������
      CheckClosedDeals();
      Sleep(slipMilliseconds);
   }
   return(0);
}


//+------------------------------------------------------------------+
//|                                               DealsGenerator.mq4 |
//|                                                  ForexInvest LTD |
//|                                            http://forexinvest.ru |
//+------------------------------------------------------------------+
#property copyright "ForexInvest LTD"
#property link      "http://forexinvest.ru"

#include <stderror.mqh>

extern string p0 = "���������� ��������� ���������:";
extern int Magic_num = 124458;
extern int Slippage = 30;
extern int TradeAttempts = 5;
extern int BarsShiftForClose = 2;

datetime timeCurrBar;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
      if (timeCurrBar != iTime(NULL, 0, 0))
      {
         // ������� ����� ���, ��������� ��� �������
         int op = 0;
         if (iClose(NULL, 0, 0) > iClose(NULL, 0, 1))
            op = OP_SELL;
         else   
            op = OP_BUY;
         OpenPosition(Symbol(), op, AmountToLots(AccountBalance(), Symbol()), 0, 0, "DealsGenerator");
         timeCurrBar = iTime(NULL, 0, 0);
      }
      ActivePosManager();
//----
   return(0);
  }
//+------------------------------------------------------------------+

void ActivePosManager()
{
    
   for (int i = 1; i <= OrdersTotal(); i++)          
   {
      if (OrderSelect(i - 1, SELECT_BY_POS) == true)
      {
         if (OrderMagicNumber() == Magic_num)
         {
            if (iBarShift(NULL, 0, OrderOpenTime()) >= BarsShiftForClose)
            {
               ClosePosition(OrderTicket());  
               i = i - 1;
            }
         }
      }
   }
}

void OpenPosition(string currency, int deal_type, double lots, double sl, double tp, string comment)
{

	
	// ��� ������
	int err = 0;
	// ��������� �������
	int ticket = -1;
	// ���� ��������� �������
	int attempt = 1;
	
	double slipp = Slippage;
	
	while (ticket < 0 && attempt <= TradeAttempts)
	{
	  // ��������� �������� ����������
	  RefreshRates();
	  Comment(attempt + " ������� ������� �������...");
	  GetTradeContext();
	  if (deal_type == OP_BUY)
	    ticket = OrderSend(currency, deal_type, lots, MarketInfo(currency, MODE_ASK), slipp, 0, 0, comment, Magic_num, 0, Red);
	  else
	    ticket = OrderSend(currency, deal_type, lots, MarketInfo(currency, MODE_BID), slipp, 0, 0, comment, Magic_num, 0, Red);
	  attempt = attempt + 1;
	  if (ticket < 0)
     {
         err = GetLastError();
         switch(err)
         {
            case ERR_INVALID_TRADE_PARAMETERS:  
            case ERR_ACCOUNT_DISABLED:
            case ERR_INVALID_ACCOUNT:
            //case ERR_INVALID_PRICE:
            case ERR_INVALID_STOPS:
            case ERR_INVALID_TRADE_VOLUME:
            case ERR_MARKET_CLOSED:
            case ERR_TRADE_DISABLED:
            case ERR_NOT_ENOUGH_MONEY:
            case ERR_TRADE_EXPIRATION_DENIED:
            case ERR_TRADE_TOO_MANY_ORDERS:
            Print("������ �������� �������: " + ErrorDescription(err));
            return;
            break;
         }
      }
  	}
  	if (OrderSelect(ticket, SELECT_BY_TICKET) == true)
  	{
  	   double OrderPrice = OrderOpenPrice();
  	
  	   // ������ ���������� ���� � ���� ���� ��� ����
  	   if (tp != 0 || sl != 0)
  	   {
  	      double stoploss = NormalizeDouble(sl, MarketInfo(currency, MODE_DIGITS));
	      double takeprofit = NormalizeDouble(tp, MarketInfo(currency, MODE_DIGITS));
  	      
   	   Sleep(400);
  	      bool res = false;
  	   
	     // ���� ��������� �������
	     attempt = 1;
	     while (res == false && attempt <= TradeAttempts)
	     {
	       // ��������� �������� ����������
	       RefreshRates();
	       Comment(attempt + " attempt to change Stop Loss & Take Profit for opened position ...");
	       GetTradeContext(); 
	       res = OrderModify(ticket, OrderOpenPrice(), stoploss, takeprofit, OrderExpiration());
	  
	       attempt = attempt + 1;
	       if (res == false)
          {
              err = GetLastError();
              switch(err)
              {
                 case ERR_INVALID_TRADE_PARAMETERS:  
                 case ERR_ACCOUNT_DISABLED:
                 case ERR_INVALID_ACCOUNT:
                 //case ERR_INVALID_PRICE:
                 case ERR_INVALID_STOPS:
                 case ERR_INVALID_TRADE_VOLUME:
                 case ERR_MARKET_CLOSED:
                 case ERR_TRADE_DISABLED:
                 case ERR_NOT_ENOUGH_MONEY:
                 case ERR_TRADE_EXPIRATION_DENIED:
                 case ERR_TRADE_TOO_MANY_ORDERS:
                 Print("������ ��������� ������ �������: " + ErrorDescription(err)); 
                 return;
                 break;
              } 
          }
  	     }
      }
   }
   else
      Print("�� ���� ������� ����� �" + ticket);
}

void ClosePosition(int ticket)
{
   bool res = false;
   int err;
      if (OrderSelect(ticket, SELECT_BY_TICKET) == true) 
      {  
         if (OrderMagicNumber() == Magic_num && (OrderType() == OP_BUY || OrderType() == OP_SELL))
         {  
            double price = 0;
            res = false;
            // ���� ��������� �������
            int attempt = 1;
            while (res == false && attempt <= TradeAttempts)
            {

              Comment(attempt + " ������� ������� �������...");
              RefreshRates();
              if (OrderType() == OP_BUY)
                 price = MarketInfo(OrderSymbol(), MODE_BID);
              else
                 price = MarketInfo(OrderSymbol(), MODE_ASK);
              GetTradeContext();
              res = OrderClose(OrderTicket(), OrderLots(), price, Slippage, Violet);
              Sleep(200);
              attempt = attempt + 1;
              if (res == false)
              {
                  err = GetLastError();
                  Print("�� ��������� �������: " + ErrorDescription(err));
                  switch(err)
                  {
                     case ERR_INVALID_TRADE_PARAMETERS:  
                     case ERR_ACCOUNT_DISABLED:
                     case ERR_INVALID_ACCOUNT:
                     //case ERR_INVALID_PRICE:
                     case ERR_INVALID_STOPS:
                     case ERR_INVALID_TRADE_VOLUME:
                     case ERR_MARKET_CLOSED:
                     case ERR_TRADE_DISABLED:
                     case ERR_NOT_ENOUGH_MONEY:
                     case ERR_TRADE_EXPIRATION_DENIED:
                     case ERR_TRADE_TOO_MANY_ORDERS:
                 
                     
                     break;
                  }
               }
            }
            
  	          
         }
       }
   
}

// ������� ����������� ����������� ������ � ���������� �����
double AmountToLots(double amount, string pair)
{
   double FI_Minlot = MarketInfo(pair, MODE_MINLOT); 
   double FI_Lotsize = MarketInfo(pair, MODE_LOTSIZE);
   double FI_Lotstep = MarketInfo(pair, MODE_LOTSTEP);
   Print("������� amount = ", amount);
   Print("MinLot = " + FI_Minlot);
   Print("LotSize = " + FI_Lotsize);
   Print("LotStep = " + FI_Lotstep);
   
   double lots = MathRound(amount/FI_Lotsize/FI_Lotstep) * FI_Lotstep;
   Print("�������� ��� lots = ", lots);
   //Comment("lots="+ lots); Print("lots="+ lots);
   if (lots >= FI_Minlot)
      return (lots);
   else
      return (FI_Minlot);
}

bool GetTradeContext()
{
   while(true)
   {
      if (IsTradeAllowed( ))
        return (true);
      Sleep(200);
   }
   return (false);
}

string ErrorDescription(int err)
 {
   switch (err)
   {
       
         case ERR_NO_ERROR:                     return ("��� ������");
         case ERR_NO_RESULT:                    return ("��� ������, �� ��������� ����������"); 
         case ERR_COMMON_ERROR:                 return ("����� ������"); 
         case ERR_INVALID_TRADE_PARAMETERS:     return ("������������ ���������"); 
         case ERR_SERVER_BUSY:                  return ("�������� ������ �����"); 
         case ERR_OLD_VERSION:                  return ("������ ������ ����������� ���������"); 
         case ERR_NO_CONNECTION:                return ("��� ����� � �������� ��������"); 
         case ERR_NOT_ENOUGH_RIGHTS:            return ("������������ ����"); 
         case ERR_TOO_FREQUENT_REQUESTS:        return ("������� ������ �������"); 
         case ERR_MALFUNCTIONAL_TRADE:          return ("������������ �������� ���������� ���������������� �������"); 
         case ERR_ACCOUNT_DISABLED:             return ("���� ������������"); 
         case ERR_INVALID_ACCOUNT:              return ("������������ ����� �����"); 
         case ERR_TRADE_TIMEOUT:                return ("����� ���� �������� ���������� ������"); 
         case ERR_INVALID_PRICE:                return ("������������ ����"); 
         case ERR_INVALID_STOPS:                return ("������������ �����"); 
         case ERR_INVALID_TRADE_VOLUME:         return ("������������ �����"); 
         case ERR_MARKET_CLOSED:                return ("����� ������"); 
         case ERR_TRADE_DISABLED:               return ("�������� ���������"); 
         case ERR_NOT_ENOUGH_MONEY:             return ("������������ ����� ��� ���������� ��������"); 
         case ERR_PRICE_CHANGED:                return ("���� ����������"); 
         case ERR_OFF_QUOTES:                   return ("��� ���"); 
         case ERR_BROKER_BUSY:                  return ("������ �����"); 
         case ERR_REQUOTE:                      return ("����� ����"); 
         case ERR_ORDER_LOCKED:                 return ("����� ������������ � ��� ��������������"); 
         case ERR_LONG_POSITIONS_ONLY_ALLOWED:  return ("��������� ������ �������"); 
         case ERR_TOO_MANY_REQUESTS:            return ("������� ����� ��������"); 
         case ERR_TRADE_MODIFY_DENIED:          return ("����������� ���������, ��� ��� ����� ������� ������ � �����"); 
         case ERR_TRADE_CONTEXT_BUSY:           return ("���������� �������� ������"); 
         case ERR_TRADE_EXPIRATION_DENIED:      return ("������������� ���� ��������� ������ ��������� ��������"); 
         case ERR_TRADE_TOO_MANY_ORDERS:        return ("���������� �������� � ���������� ������� �������� �������, �������������� ��������");
         
         case ERR_NO_MQLERROR:                  return ("��� ������"); 
         case ERR_WRONG_FUNCTION_POINTER:       return ("������������ ��������� �������");
         case ERR_ARRAY_INDEX_OUT_OF_RANGE:     return ("������ ������� - ��� ���������");
         case ERR_NO_MEMORY_FOR_CALL_STACK:     return ("��� ������ ��� ����� �������");
         case ERR_RECURSIVE_STACK_OVERFLOW:     return ("������������ ����� ����� ������������ ������");
         case ERR_NOT_ENOUGH_STACK_FOR_PARAM:   return ("�� ����� ��� ������ ��� �������� ����������");
         case ERR_NO_MEMORY_FOR_PARAM_STRING:   return ("��� ������ ��� ���������� ���������");
         case ERR_NO_MEMORY_FOR_TEMP_STRING:    return ("��� ������ ��� ��������� ������");
         case ERR_NOT_INITIALIZED_STRING:       return ("�������������������� ������");
         case ERR_NOT_INITIALIZED_ARRAYSTRING:  return ("�������������������� ������ � �������");
         case ERR_NO_MEMORY_FOR_ARRAYSTRING:    return ("��� ������ ��� ���������� �������");
         case ERR_TOO_LONG_STRING:              return ("������� ������� ������");
         case ERR_REMAINDER_FROM_ZERO_DIVIDE:   return ("������� �� ������� �� ����");
         case ERR_ZERO_DIVIDE:                  return ("������� �� ����");
         case ERR_UNKNOWN_COMMAND:              return ("����������� �������");
         case ERR_WRONG_JUMP:                   return ("������������ �������");
         case ERR_NOT_INITIALIZED_ARRAY:        return ("�������������������� ������");
         case ERR_DLL_CALLS_NOT_ALLOWED:        return ("������ DLL �� ���������");
         case ERR_CANNOT_LOAD_LIBRARY:          return ("���������� ��������� ����������");
         case ERR_CANNOT_CALL_FUNCTION:         return ("���������� ������� �������");
         case ERR_EXTERNAL_CALLS_NOT_ALLOWED:   return ("������ ������� ������������ ������� �� ���������");
         case ERR_NO_MEMORY_FOR_RETURNED_STR:   return ("������������ ������ ��� ������, ������������ �� �������");
         case ERR_SYSTEM_BUSY:                  return ("������� ������");
         case ERR_INVALID_FUNCTION_PARAMSCNT:   return ("������������ ���������� ���������� �������");
         case ERR_INVALID_FUNCTION_PARAMVALUE:  return ("������������ �������� ��������� �������");
         case ERR_STRING_FUNCTION_INTERNAL:     return ("���������� ������ ��������� �������");
         case ERR_SOME_ARRAY_ERROR:             return ("������ �������");
         case ERR_INCORRECT_SERIESARRAY_USING:  return ("������������ ������������� �������-���������");
         case ERR_CUSTOM_INDICATOR_ERROR:       return ("������ ����������������� ����������");
         case ERR_INCOMPATIBLE_ARRAYS:          return ("������� ������������");
         case ERR_GLOBAL_VARIABLES_PROCESSING:  return ("������ ��������� ����������� ����������");
         case ERR_GLOBAL_VARIABLE_NOT_FOUND:    return ("���������� ���������� �� ����������");
         case ERR_FUNC_NOT_ALLOWED_IN_TESTING:  return ("������� �� ��������� � �������� ������");
         case ERR_FUNCTION_NOT_CONFIRMED:       return ("������� �� ���������");
         case ERR_SEND_MAIL_ERROR:              return ("������ �������� �����");
         case ERR_STRING_PARAMETER_EXPECTED:    return ("��������� �������� ���� string");
         case ERR_INTEGER_PARAMETER_EXPECTED:   return ("��������� �������� ���� integer");
         case ERR_DOUBLE_PARAMETER_EXPECTED:    return ("��������� �������� ���� double");
         case ERR_ARRAY_AS_PARAMETER_EXPECTED:  return ("� �������� ��������� ��������� ������");
         case ERR_HISTORY_WILL_UPDATED:         return ("����������� ������������ ������ � ��������� ����������");
         case ERR_TRADE_ERROR:                  return ("������ ��� ���������� �������� ��������");
         case ERR_END_OF_FILE:                  return ("����� �����");
         case ERR_SOME_FILE_ERROR:              return ("������ ��� ������ � ������");
         case ERR_WRONG_FILE_NAME:              return ("������������ ��� �����");
         case ERR_TOO_MANY_OPENED_FILES:        return ("������� ����� �������� ������");
         case ERR_CANNOT_OPEN_FILE:             return ("���������� ������� ����");
         case ERR_INCOMPATIBLE_FILEACCESS:      return ("������������� ����� ������� � �����");
         case ERR_NO_ORDER_SELECTED:            return ("�� ���� ����� �� ������");
         case ERR_UNKNOWN_SYMBOL:               return ("����������� ������");
         case ERR_INVALID_PRICE_PARAM:          return ("������������ �������� ���� ��� �������� �������");
         case ERR_INVALID_TICKET:               return ("�������� ����� ������");
         case ERR_TRADE_NOT_ALLOWED:            return ("�������� �� ���������. ���������� �������� ����� \"��������� ��������� ���������\" � ��������� ��������.");
         case ERR_LONGS_NOT_ALLOWED:            return ("������� ������� �� ���������. ���������� ��������� �������� ��������.");
         case ERR_SHORTS_NOT_ALLOWED:           return ("�������� ������� �� ���������. ���������� ��������� �������� ��������.");
         case ERR_OBJECT_ALREADY_EXISTS:        return ("������ ��� ����������");
         case ERR_UNKNOWN_OBJECT_PROPERTY:      return ("��������� ����������� �������� �������");
         case ERR_OBJECT_DOES_NOT_EXIST:        return ("������ �� ����������");
         case ERR_UNKNOWN_OBJECT_TYPE:          return ("����������� ��� �������");
         case ERR_NO_OBJECT_NAME:               return ("��� ����� �������");
         case ERR_OBJECT_COORDINATES_ERROR:     return ("������ ��������� �������");
         case ERR_NO_SPECIFIED_SUBWINDOW:       return ("�� ������� ��������� �������");
         case ERR_SOME_OBJECT_ERROR:            return ("������ ��� ������ � ��������");
     
         default: 
         return ("��� ������: " + err);
   }
}


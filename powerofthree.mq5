//+------------------------------------------------------------------+
//|                                                 powerofthree.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.01"

//--- Input parameters
input int SessionStart = 2;  // London session start (2 AM server time)
input int SessionEnd = 5;    // London session end (5 AM server time)

//--- Global variables
datetime LastSessionDate = 0;     // Tracks the last session's date
double SessionOpenPrice = 0.0;    // Opening price of the session
bool TradeExecuted = false;       // Indicates if a trade has been executed
double StopLoss = 0.0;            // Stop-loss level
double TakeProfit = 0.0;          // Take-profit level

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   EventSetTimer(60); // Timer event every 60 seconds
   Print("Power of 3 Gold Scalping initialized.");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   Print("Power of 3 Gold Scalping deinitialized.");
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   datetime currentTime = TimeCurrent(); // Get the current server time
   MqlDateTime currentStruct, lastStruct;
   TimeToStruct(currentTime, currentStruct);
   TimeToStruct(LastSessionDate, lastStruct);

   if (currentStruct.day != lastStruct.day)
   {
      ResetSession();
      LastSessionDate = currentTime;
   }

   if (currentStruct.hour >= SessionStart && currentStruct.hour <= SessionEnd && !TradeExecuted)
   {
      MonitorSession();
   }
}

//+------------------------------------------------------------------+
//| Reset session function                                           |
//+------------------------------------------------------------------+
void ResetSession()
{
   TradeExecuted = false;
   SessionOpenPrice = 0.0;
   StopLoss = 0.0;
   TakeProfit = 0.0;
   Print("Session reset.");
}

//+------------------------------------------------------------------+
//| Monitor session function                                         |
//+------------------------------------------------------------------+
void MonitorSession()
{
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   if (SessionOpenPrice == 0.0)
   {
      SessionOpenPrice = currentPrice;
      Print("Session opening price set: ", SessionOpenPrice);
   }

   if (DetectMarketStructureShift())
   {
      PlaceTrade();
   }
}

//+------------------------------------------------------------------+
//| Detect market structure shift                                    |
//+------------------------------------------------------------------+
bool DetectMarketStructureShift()
{
   static int shiftCounter = 0;
   shiftCounter++;
   if (shiftCounter % 5 == 0)
   {
      Print("Market structure shift detected.");
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Place trade function                                             |
//+------------------------------------------------------------------+
void PlaceTrade()
{
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
  // StopLoss = SessionOpenPrice - 100 * Point; 
   TakeProfit = currentPrice + 3 * (currentPrice - StopLoss);

   MqlTradeRequest request;
   MqlTradeResult result;

   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = 0.1;
   request.price = currentPrice;
   request.sl = StopLoss;
   request.tp = TakeProfit;
   request.type = ORDER_TYPE_BUY;
   request.deviation = 10;

   if (OrderSend(request, result))
   {
      Print("Trade executed successfully. Entry: ", currentPrice, ", SL: ", StopLoss, ", TP: ", TakeProfit);
      TradeExecuted = true;
   }
   else
   {
      Print("Trade execution failed. Error: ", GetLastError());
   }
}

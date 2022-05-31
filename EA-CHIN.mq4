//+------------------------------------------------------------------+
//|                                                      EA-CHIN.mq4 |
//|                                            Copyright 2018, Jiunn |
//|                                            https://www.jiunn.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Jiunn"
#property link      "https://www.jiunn.com"
#property version   "1.00"
#property strict

input int POINTS_TP = 10;   // Take Profit Points 
input int POINTS_SL = 100;  // Stop Loss Points


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   SetSLTPForNewOrders();
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+





//+------------------------------------------------------------------+
//| Set TP & SL for New Open Orders                   |
//+------------------------------------------------------------------+
void SetSLTPForNewOrders(int MagicNum = 0)
{
   
   
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        continue;
      if(OrderMagicNumber()!=MagicNum || OrderSymbol()!=Symbol()) continue;
     
     
      if(OrderType() == OP_SELL)
      {
         double newTP = OrderOpenPrice() - (POINTS_TP*Point);
         double newSL = OrderOpenPrice() + (POINTS_SL*Point);
                  
         if(OrderTakeProfit()==0) {bool b = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),newTP,0,clrBlack);}      
         if(OrderStopLoss  ()==0) {bool b = OrderModify(OrderTicket(),OrderOpenPrice(),newSL,OrderTakeProfit(),0,clrBlack);}
      }      
      if(OrderType() == OP_BUY)
      {

         double newTP = OrderOpenPrice() + (POINTS_TP*Point);
         double newSL = OrderOpenPrice() - (POINTS_SL*Point);
      
         if(OrderTakeProfit()==0) {bool b = OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),newTP,0,clrBlack);}      
         if(OrderStopLoss  ()==0) {bool b = OrderModify(OrderTicket(),OrderOpenPrice(),newSL,OrderTakeProfit(),0,clrBlack);}
      }



   }
}

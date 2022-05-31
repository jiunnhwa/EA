//+------------------------------------------------------------------+
//|                                                    EA-Classy.mq4 |
//|                                            Copyright 2016, Jiunn |
//|                                            https://www.jiunn.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Jiunn"
#property link      "https://www.jiunn.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
class INFO_RATES 
{

   public:
      double ASK;
      double BID;
      double MID;
      double MIDS[5];
      double MIDS_AVG;
      double SPREAD;
      int    SPREAD_POINT;
      int SPREAD_POINTS[5] ;
      double SPREAD_POINTS_AVG;
      int    VOL;
      long   TICK_COUNT;
	  
      struct MYORDERS
        {
            string CCY;
            int    COUNT;
        };
      
      void RefreshInfo()
      {
         TICK_COUNT++;
         RefreshRates();
         ASK=NormalizeDouble(MarketInfo(NULL,MODE_ASK),MarketInfo(NULL,MODE_DIGITS));
         BID=NormalizeDouble(MarketInfo(NULL,MODE_BID),MarketInfo(NULL,MODE_DIGITS));
         MID=NormalizeDouble(((BID+ASK)/2),MarketInfo(NULL,MODE_DIGITS));
         SPREAD=NormalizeDouble(MathAbs(ASK-BID),MarketInfo(NULL,MODE_DIGITS));
         SPREAD_POINT=SPREAD/Point;

      }
      
	  void ResetInfo()
      {
         TICK_COUNT = 0;
         ZeroMemory(MIDS);
      }
	  
      void ComputeStats()
      {
         
         SPREAD_POINTS[4]=SPREAD_POINTS[3];
         SPREAD_POINTS[3]=SPREAD_POINTS[2];
         SPREAD_POINTS[2]=SPREAD_POINTS[1];
         SPREAD_POINTS[1]=SPREAD_POINTS[0];
         SPREAD_POINTS[0]=SPREAD_POINT;
         
         SPREAD_POINTS_AVG = (SPREAD_POINTS[0]+SPREAD_POINTS[1]+SPREAD_POINTS[2]+SPREAD_POINTS[3]+SPREAD_POINTS[4])/5;
         
         MIDS[4]=MIDS[3];
         MIDS[3]=MIDS[2];
         MIDS[2]=MIDS[1];
         MIDS[1]=MIDS[0];
         MIDS[0]=MID;
         
         MIDS_AVG = (MIDS[0]+MIDS[1]+MIDS[2]+MIDS[3]+MIDS[4])/5;
      }
};
//+------------------------------------------------------------------+

class RulesBase
{
   public:
      int SIGKILL_PRICEBOX(int sig, bool ispricelevelOK)
      {
         if(sig==OP_SELL&&(ispricelevelOK==false))   {return (-1211);}  //not in outside zone/trade levels. {-1211,"P2HI","MID not > LEVEL_SELL1 price."},   //OP_SELL->1 
         if(sig==OP_BUY &&(ispricelevelOK==false))   {return (-1210);}  //not in outside zone/trade levels. {-1210,"P2LO","MID not < LEVEL_BUY1 price."},    //OPBUY  ->0
         return (0);    //OK;
      }
            RulesBase(void){};
           ~RulesBase(void){};
};

RulesBase RULES;

class PEAKBASE
{
   public:
      string Name;
      datetime NewHighTime; 
      double NewHighValue;
      double OldHighValue;
      void CheckNewHILO(string name,double val=0,datetime t0=0)
      {
         if(val>NewHighValue)
         {
            NewHighValue=NormalizeDouble(val,4);
            NewHighTime=t0;
            Alert("__FUNC_LOGGER__", "New High:", Name,",",NewHighValue,",",NewHighTime,"localtime:", TimeLocal());
         }

      }
      
      
                  PEAKBASE(void){NewHighValue=0;};
                 ~PEAKBASE(void){};
};


class PEAKEQUITY: public  PEAKBASE
{
   public:

                  PEAKEQUITY(void){Name = "PEAKEQUITY";};
                 ~PEAKEQUITY(void){};
};
PEAKEQUITY PeakEquity;
//+------------------------------------------------------------------+


class TradeLocker
   {
      public:
      int NoTradeMins;
      int NoTradePoints;
      double NoTradePrice;
      
      void SetNext()
      {
      
      }
      
      
                     TradeLocker(void){};
                    ~TradeLocker(void){};
   };

TradeLocker TRADELOCKER;
//+------------------------------------------------------------------+

class OrderSetter
{
   double Lots;
   
   public:
                  OrderSetter(void){};
                 ~OrderSetter(void){};
};
OrderSetter ORDERSETTER;



//+------------------------------------------------------------------+


class SignalBase
{
   public:
   string Name;
   int Sig;
                  SignalBase(void){};
                 ~SignalBase(void){};
};

class SignalTest: public SignalBase
{
   public:
   int STRATEGY_TEST01()
   {
      //on every 15 mins, returns BUY on even mins, and SELL on ODD
      if(TimeMinute(TimeCurrent())%15==0)  //every 15 mins
      {
         if( IsEvenNum(TimeMinute(TimeCurrent()))) 
         {
            return OP_BUY;      
         }
         else
         {
            return OP_SELL;      
         }
      }
   
   
      return -1;
   }
                  SignalTest(void){};
                 ~SignalTest(void){};
};
bool     IsEvenNum(int x){return(x&1)==0;};  //returns true if Even and false if Odd. http://mindprod.com/jgloss/modulus.html#EVEN
SignalTest SIGNALTEST;
//+------------------------------------------------------------------+



class IntegerBufferBase
{
   public:
      int Values[10];
      
      void Update()
      {
         //push queue
         //update
      }
                  IntegerBufferBase(void){};
                 ~IntegerBufferBase(void){};
};
//+------------------------------------------------------------------+


MYORDERS o;
INFO_RATES RATES  ;

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

	MqlTick last_tick; 

   //INFO_RATES RATES  ;
   //RATES = new INFO_RATES();
   RATES.RefreshInfo();
   RATES.ComputeStats();
   o.COUNT = 11;
   o.CCY = "EU";

   PeakEquity.CheckNewHILO("test",1);
   PeakEquity.CheckNewHILO("test",0);
   PeakEquity.CheckNewHILO("test",10);;
   
   TRADELOCKER.SetNext();
   
   int sig = SIGNALTEST.STRATEGY_TEST01();
   if(sig>-1)
   {
      if(SymbolInfoTick(Symbol(),last_tick)) 
      { 
      Print(last_tick.time,": Bid = ",last_tick.bid, 
         " Ask = ",last_tick.ask,"  Volume = ",last_tick.volume); 
      } 
      Alert("sig:", sig, " lasttick:", last_tick.bid);
      if(OrdersTotal()==0)
      {
         int ticket=OrderSend(Symbol(),sig,1,sig==OP_BUY?Ask:Bid,3,0.0,0.0,"My order",16384,0,clrGreen); 

      }         
   }
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+



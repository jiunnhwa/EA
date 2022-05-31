//+------------------------------------------------------------------+
//|                                                       EA-SMA.mq4 |
//|                                            Copyright 2016, Jiunn |
//|                                            https://www.jiunn.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Jiunn"
#property link      "https://www.jiunn.com"
#property version   "1.00"
#property strict

#define VER "0824A"

//********************************************************************
/* 20170723

- Input Setting RiskPercentage with 1% as default
- LotSize = 1% VAR
- OrderPricePlot - Plots the order entry price on screen
- TrailingStop - Lowest of 2 Bars(D1)

Entry on New Bar when
IF
	(13SMA(D1) > 26SMA (D1)) by X%(configurable with default = 1)
AND
	(40SMA(D1) > 40SMA (D1)) by X%(configurable with default = 1)

ALSO,
	40SMA[0]>40SMA[1]>40SMA[2] AND
	26SMA[0]>26SMA[1]>26SMA[2] AND
	13SMA[0]>13SMA[1]>13SMA[2] 

THEN
	ON(H4) NewBarOpen
	Trigger entry When MA2 > MA10,

	With SL is Lowest of Lowest of 2 Bars(D1)

*/
//********************************************************************
/*
CHANGE LOG

0728A:
Added Started Time, and Version text.
Added SIG1: 1% rule
Added SIG2: all TF up for the 3 MA
Added SIG3: EMA2(H4) cut SMA10(H4)

*/

//********************************************************************

#define MAGICMA  8888

input double RiskPercentage   = 1;
int WIND_jHUDx = 0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   string sc;
   sc +="Started(SGT): " + TimeToStr(TimeLocal()) + " Ver: " + VER;
   Comment(sc);      
   
   WIND_jHUDx=WindowFind("jPanel")==-1?0:WindowFind("jPanel");  //choosing display panel window
   
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
   
   ObjectsDeleteAll(0,"jINFO_");
      
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
//| OnTick function                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

   if(Bars<100 || IsTradeAllowed()==false)      return;        //--- check for history and trading
   ComputeIndicators();
   CalculateCurrentOrders(Symbol(),MAGICMA);
   CheckForOpen();
   CheckForClose();
   Reporter();
//---
  }
//+------------------------------------------------------------------+
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//********************************************************************
//                CUSTOM FUNCTION
//********************************************************************  

//+------------------------------------------------------------------+
//| Calculate open positions                                         |
//+------------------------------------------------------------------+
int BUYS=0,SELLS=0;
void CalculateCurrentOrders(string symbol, int MagicNum=0)
  {
   
//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNum)
        {
         if(OrderType()==OP_BUY)  BUYS++;
         if(OrderType()==OP_SELL) SELLS++;
        }
     }
  }
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
{
   //if(Volume[0]>1) return; //on 1st tick
   long   volM1 = iVolume(NULL,PERIOD_M1,0);
   long   volH4 = iVolume(NULL,PERIOD_H4,0);
   //Comment(vol);
   {
      C=CORNER_LEFT_UPPER;
      F="ARIAL";FS=7;
      COLORB=clrAntiqueWhite;
      X=4;Y=25;
      DisplayText("jINFO_Vol" ,IntegerToString(volH4)+"."+IntegerToString(volM1) ,0,C,X,Y+00     ,F,FS, clrWhite );
   }

   if(volH4 <=1)
     {
         if(AccountNumber()==2089499786)
         {
          Alert   ("New H4 tickvol is", volH4, " at: ", TimeToStr( TimeLocal()));
          ObjectCreate("EA-SMA"+IntegerToString(Bars), OBJ_VLINE,0, TimeCurrent(),NULL);
       }

     }
   if(TREND_D1_A==BULLTREND&&TREND_D1_B==BULLTREND)
   {
      if(EMA02H4[0]>SMA10H4[0])
      {
         if(BUYS!=0)return;
         int ticket=OrderSend(Symbol(),OP_BUY,GetLotSize(RiskPercentage,OP_BUY),Ask,3,GetSL(OP_BUY),0,"",MAGICMA,0,Blue);
         if(ticket>0)
         {
            drawarrowOrderTicket(IntegerToString(ticket),Ask,3,Blue,"");  
         }
      }
   }
   else
   if(TREND_D1_A==BEARTREND&&TREND_D1_B==BEARTREND)
   {
      if(EMA02H4[0]<SMA10H4[0])
      {
         if(SELLS!=0)return;
         int ticket=OrderSend(Symbol(),OP_SELL,GetLotSize(RiskPercentage,OP_SELL),Bid,3,GetSL(OP_SELL),0,"",MAGICMA,0,Red);
         if(ticket>0)
         {
            drawarrowOrderTicket(IntegerToString(ticket),Bid,3,Red,"");  
         }   
      }
   }
}
//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
void CheckForClose()
{
   TrailBy2BarD1(MAGICMA);
}
 
void Reporter()
{
   ScreenInfo();
}
  
//********************************************************************
//             END CUSTOM FUNCTION
//********************************************************************  


//********************************************************************
//             HELPER FUNCTION
//********************************************************************  
void ComputeIndicators()
{
   ComputeMA();
   ComputeSignal();
}

#define BARSTOTAL3   3 
double SMA13D1[BARSTOTAL3],SMA26D1[BARSTOTAL3],SMA40D1[BARSTOTAL3];  //Bar0,1,2
double EMA02H4[BARSTOTAL3],SMA10H4[BARSTOTAL3];                      //Bar0,1,2

double RatioSMA1326D1[BARSTOTAL3],RatioSMA2640D1[BARSTOTAL3];
 
void ComputeMA()                                                     
{
   for(int i=0;i<BARSTOTAL3;i++) //From current bar[0] to N previous bars
   {
      SMA13D1[i]=iMA(NULL,PERIOD_D1,13,0,MODE_SMA,PRICE_CLOSE,i);
      SMA26D1[i]=iMA(NULL,PERIOD_D1,26,0,MODE_SMA,PRICE_CLOSE,i);
      SMA40D1[i]=iMA(NULL,PERIOD_D1,40,0,MODE_SMA,PRICE_CLOSE,i);

      EMA02H4[i]=iMA(NULL,PERIOD_H4, 2,0,MODE_EMA,PRICE_CLOSE,i);
      SMA10H4[i]=iMA(NULL,PERIOD_H4,10,0,MODE_SMA,PRICE_CLOSE,i); 
      
      RatioSMA1326D1[i]=SMA13D1[i]/SMA26D1[i];
      RatioSMA2640D1[i]=SMA26D1[i]/SMA40D1[i];
      
   }
   
}

enum trend 
{
   FLATTREND=0, BULLTREND=1, BEARTREND=-1
};

input double MASpreadPercent = 1; 

trend TREND_D1_A,TREND_D1_B;
trend TREND_H4_A;
void ComputeSignal()                                                     
{

   TREND_D1_A = GetTREND_D1_A(); //1% rule
   TREND_D1_B = GetTREND_D1_B(); //all pointing same direction
   TREND_H4_A = GetTREND_H4_A(); //EMA2(H4) cutting SMA10(H4)
}

double BULLRATIO, BEARRATIO;
trend GetTREND_D1_A()
{
   /*double bullratio*/BULLRATIO = 1 + (MASpreadPercent/100);
   /*double bearratio*/BEARRATIO = 1 - (MASpreadPercent/100);
   if(RatioSMA1326D1[0]>BULLRATIO && RatioSMA2640D1[0]>BULLRATIO) return BULLTREND;
   if(RatioSMA1326D1[0]<BEARRATIO && RatioSMA2640D1[0]<BEARRATIO) return BEARTREND;
   return FLATTREND;
}

trend GetTREND_D1_B()
{
     
   {
      bool c1 = (SMA13D1[0]>SMA13D1[1])&&(SMA13D1[1]>SMA13D1[2]);
      bool c2 = (SMA26D1[0]>SMA26D1[1])&&(SMA26D1[1]>SMA26D1[2]);
      bool c3 = (SMA40D1[0]>SMA40D1[1])&&(SMA40D1[1]>SMA40D1[2]);
      if(c1&&c2&&c3)return BULLTREND;
   }

   {
      bool c1 = (SMA13D1[0]<SMA13D1[1])&&(SMA13D1[1]<SMA13D1[2]);
      bool c2 = (SMA26D1[0]<SMA26D1[1])&&(SMA26D1[1]<SMA26D1[2]);
      bool c3 = (SMA40D1[0]<SMA40D1[1])&&(SMA40D1[1]<SMA40D1[2]);   
      if(c1&&c2&&c3)return BEARTREND;
   }
   return FLATTREND;
}

trend GetTREND_H4_A()
{
   if(EMA02H4[0]>SMA10H4[0]) return BULLTREND;
   if(EMA02H4[0]<SMA10H4[0]) return BEARTREND;
   return FLATTREND;
}

//+------------------------------------------------------------------+
//| Trail By iLowest/iHighest of Bars[2] of Daily                    |
//+------------------------------------------------------------------+
void TrailBy2BarD1(int MagicNum = 0)
{
   
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        continue;
      if(OrderMagicNumber()!=MagicNum || OrderSymbol()!=Symbol()) continue;
     
      if(OrderType() == OP_BUY)
      {
         {
            double newSL = GetSL(OP_BUY);
            if(OrderStopLoss()< newSL)  //trail by 
            {
               bool b = OrderModify(OrderTicket(),OrderOpenPrice(),newSL,0,0,clrBlack);
            }
         }
     }

      if(OrderType() == OP_SELL)
      {
         {
            double newSL = GetSL(OP_SELL);
            if(OrderStopLoss()> newSL)
            {
               bool b = OrderModify(OrderTicket(),OrderOpenPrice(),newSL,0,0,clrBlack);
            }
         }
         
      }
   }
}

double GetSL(int orderType)
{
   if(orderType==OP_BUY ){return Low [iLowest (NULL,PERIOD_D1,MODE_LOW ,2,0)];}
   if(orderType==OP_SELL){return High[iHighest(NULL,PERIOD_D1,MODE_HIGH,2,0)];}
   return 0;
}

double GetLotSize(double RiskPerCent = 1 /* 1% */, int orderType = -1)
{
   string AcctCurrency = AccountCurrency();
   string QuotedCurrency = StringSubstr(Symbol(),3,3);
   string BaseCurrency = StringSubstr(Symbol(),0,3);
   double PipSize = MarketInfo(Symbol(), MODE_TICKSIZE)*10;
      
   //Calculate risk 
   double DollarRisk = AccountBalance()*(double)RiskPerCent/100;
   double SLPipValue;
   if(AcctCurrency == BaseCurrency) {
      SLPipValue = Close[0] * DollarRisk;
   } else if(AcctCurrency == QuotedCurrency) {
      SLPipValue = DollarRisk;
   } else {
      if(SymbolSelect(QuotedCurrency+AcctCurrency, true)) { //Countercurrency
         SLPipValue = DollarRisk / iClose(QuotedCurrency+AcctCurrency, PERIOD_M1, 1);
      } else {
         SLPipValue = DollarRisk * iClose(AcctCurrency+QuotedCurrency, PERIOD_M1, 1);
      }
   }
   double SLPips=Point;//avoid divBy0
   double Units = SLPipValue/SLPips/PipSize;   
   double Lots = Units/MarketInfo(Symbol(), MODE_LOTSIZE)/10;
   //Draw information
   if(Digits == 3) { //JPY Currency Modification
      SLPipValue = SLPipValue/100;
   }
   //DrawLabel(Lots, SLPips, Risk, SLPipValue);
   
   double BROKER_MINLOT              = MarketInfo(Symbol(),MODE_MINLOT);
   
   return NormalizeDouble( MathMax(BROKER_MINLOT,Lots),2); 
}

//+------------------------------------------------------------------+
//| Draw Label function                                              |
//+------------------------------------------------------------------+
const string LABEL_NAME = "EA-SMA";
ENUM_BASE_CORNER DrawCorner = CORNER_RIGHT_UPPER; //Corner for display
int x_coord = 5;                                  //X axis display offset 
int y_coord = 16;                                 //Y axis display offset 
color text_color = clrDodgerBlue;                 //Text color
int txt_size = 10;                                //Text size

void DrawLabel(double lots, int slpips, double risk, double pipRisk) {
   string text1 = StringFormat("********%s********", Symbol());
   string text2 = StringFormat("Lot Size %.2f", lots);
   string text3 = StringFormat("%d Pip Stop Loss", slpips);
   string text4 = StringFormat("$%.2f (~%.1f%%) Risk", pipRisk, risk);
   string text5 = "**************************";
   if (ObjectFind(LABEL_NAME) == -1) {
      for(int i = 1; i <= 5; i++) {
         string label_name = LABEL_NAME + "_" + IntegerToString(i);
         ObjectCreate(label_name, OBJ_LABEL, 0, 0, 0);
         ObjectSet(label_name, OBJPROP_CORNER, DrawCorner);
         ObjectSet(label_name, OBJPROP_XDISTANCE, x_coord);
         if(DrawCorner == CORNER_LEFT_LOWER || DrawCorner == CORNER_RIGHT_LOWER) {
            ObjectSet(label_name, OBJPROP_YDISTANCE, y_coord + (3 - i)*(txt_size+2));
         } else {
            ObjectSet(label_name, OBJPROP_YDISTANCE, y_coord + i*(txt_size+2));
         }
      }
   }
   ObjectSetText(LABEL_NAME + "_1", text1, txt_size, "Arial", text_color);
   ObjectSetText(LABEL_NAME + "_2", text2, txt_size, "Arial", text_color);
   ObjectSetText(LABEL_NAME + "_3", text3, txt_size, "Arial", text_color);
   ObjectSetText(LABEL_NAME + "_4", text4, txt_size, "Arial", text_color);
   ObjectSetText(LABEL_NAME + "_5", text5, txt_size, "Arial", text_color);
}
//+------------------------------------------------------------------+
//| Clear Label function                                             |
//+------------------------------------------------------------------+
void ClearLabel(){for(int i = 0; i < ObjectsTotal(); i++ ){if(StringFind(ObjectName(i), LABEL_NAME) == 0){ObjectDelete(ObjectName(i));i--;}}}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#define WIND0               0
void DisplayText(string objName,string strText,int subWindow=WIND0,int objCorner=CORNER_LEFT_UPPER,int xPos=10,int YPos=10,string FontName="ARIAL",int fontSize=10,color textColor=clrBlack)
{
   DrawLabel(objName,subWindow,strText,NULL,objCorner,xPos,YPos,FontName,fontSize,textColor);
}


void DrawLabel   	(string objName,int subWindow=WIND0,string strText="",color objColor=clrDarkOrange, int objCorner=CORNER_LEFT_UPPER,int xDist=10,int yDist=10,string font_type="ARIAL",int font_size=12,color text_color=clrBlue)
{
   CreateObject(objName,OBJ_LABEL,NULL,NULL,NULL,NULL,NULL,NULL,subWindow,true,false); 
   ObjectSet(objName,OBJPROP_CORNER,objCorner);
   ObjectSet(objName,OBJPROP_XDISTANCE,xDist);
   ObjectSet(objName,OBJPROP_YDISTANCE,yDist);
   ObjectSetText(objName,strText,font_size,font_type,text_color); 
}

void CreateObject(string objName,ENUM_OBJECT objType,datetime t0,double p0,datetime t1=0,double p1=0,datetime t2=0,double p2=0,int subWindow=0,bool isBackground=true,bool reDraw=false)
{
   if(reDraw==true) ObjectDelete(objName);                              //redraw?
   ObjectCreate(objName,objType,subWindow,t0,p0,t1,p1,t2,p2);           //create
   ObjectSet(objName,OBJPROP_BACK,isBackground);                        //set
}
//********************************************************************
//             END HELPER FUNCTION
//********************************************************************  


//+------------------------------------------------------------------+
void drawarrowOrderTicket(string objName,double p0,int objWidth=1,color objColor=clrDarkSlateGray,string strText="")
{
   ObjectCreate   (objName,OBJ_ARROW,0,dtTIME_SVR,p0);
   ObjectSet      (objName,OBJPROP_WIDTH,objWidth);
   ObjectSet      (objName,OBJPROP_ARROWCODE,SYMBOL_LEFTPRICE); 
   ObjectSet      (objName,OBJPROP_COLOR,objColor);
   ObjectSetText  (objName,strText,10);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
MqlDateTime TIME_LOC,TIME_SVR; datetime dtTIME_LOC,dtTIME_SVR;
int DAY_LOC,DAY_SVR;
void refreshInfoTime()
{
   dtTIME_LOC=TimeLocal();dtTIME_SVR=TimeCurrent();
   TimeToStruct(dtTIME_LOC,TIME_LOC);
   TimeToStruct(dtTIME_SVR,TIME_SVR);
   DAY_LOC=TimeDay(dtTIME_LOC);
   DAY_SVR=TimeDay(dtTIME_SVR);
}
//+------------------------------------------------------------------+


#define  WIN0  0
int X=1;int Y=1;int C=CORNER_RIGHT_UPPER;string F="ARIAL";int FS=10;color COLORB=clrBlack;
void ScreenInfo()
{
   //+------------------------------------------------------------------+
   //|                     CORNER_RIGHT_LOWER                           |
   //+------------------------------------------------------------------+
   C=CORNER_RIGHT_UPPER;
   F="ARIAL BLACK";FS=8;
   COLORB=clrBlueViolet;

   X=25;Y=10;
   DisplayText("jINFO_SMA13D1[2,1,0]" ,"SMA13D1[2,1,0]" + DoubleToString(SMA13D1[2],5) + ", " + DoubleToString(SMA13D1[1],5)  + ", " + DoubleToString(SMA13D1[0],5) ,WIND_jHUDx,C,X,Y+00     ,F,FS, clrLime );        
   DisplayText("jINFO_SMA26D1[2,1,0]" ,"SMA26D1[2,1,0]" + DoubleToString(SMA26D1[2],5) + ", " + DoubleToString(SMA26D1[1],5)  + ", " + DoubleToString(SMA26D1[0],5) ,WIND_jHUDx,C,X,Y+10     ,F,FS, clrLime );        
   DisplayText("jINFO_SMA40D1[2,1,0]" ,"SMA40D1[2,1,0]" + DoubleToString(SMA40D1[2],5) + ", " + DoubleToString(SMA40D1[1],5)  + ", " + DoubleToString(SMA40D1[0],5) ,WIND_jHUDx,C,X,Y+20     ,F,FS, clrLime );        
   //DisplayText("jINFO_MAH4" ,"EMA02H4=" + DoubleToString(EMA02H4[0],5) + ", SMA10H4=" + DoubleToString(SMA10H4[0],5)  ,WIND_jHUDx,C,X,Y+30     ,F,FS, clrLime );        

   X=25;Y=50;
   DisplayText("jINFO_SIG_0" ,"S0:" + IntegerToString(TREND_D1_A) ,WIND_jHUDx,C,X,Y+00     ,F,FS, clrDarkGray );        
   DisplayText("jINFO_SIG_1" ,"S1:" + IntegerToString(TREND_D1_B) ,WIND_jHUDx,C,X,Y+10     ,F,FS, clrDarkGray );        
   DisplayText("jINFO_SIG_2" ,"S2:" + IntegerToString(TREND_H4_A) ,WIND_jHUDx,C,X,Y+20     ,F,FS, clrDarkGray );        

   X=100;Y=50;
   DisplayText("jINFO_SIGCALC_0" ,"RatioSMA1326D1=" + DoubleToString(RatioSMA1326D1[0],4) + " && RatioSMA2640D1=" + DoubleToString(RatioSMA2640D1[0],4)    ,WIND_jHUDx,C,X,Y+00     ,F,FS, clrDarkGray );        
   DisplayText("jINFO_SIGCALC_2" ,"EMA02H4[0]=" + DoubleToString(EMA02H4[0],4) + " && SMA10H4=" + DoubleToString(SMA10H4[0],4)    ,WIND_jHUDx,C,X,Y+20     ,F,FS, clrDarkGray );        



   X=25;Y=100;
   DisplayText("jINFO_BULLBEARRATIO" ,"Bull>" + DoubleToString(BULLRATIO,2) + " Bear<" +  DoubleToString(BEARRATIO,2),WIND_jHUDx,C,X,Y+00     ,F,FS, clrDarkGray );   

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//---
//---

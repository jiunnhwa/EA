//+------------------------------------------------------------------+
//|                                                 EA-BBAND2020.mq4 |
//|                                            Copyright 2018, Jiunn |
//|                                            https://www.jiunn.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Jiunn"
#property link      "https://www.jiunn.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
#property version     "10.0.0"      // Current version of the Expert Advisor 
#property description "Pre-JSF11 - BBANDH4 Trader"
//+------------------------------------------------------------------+
#define VER "0323A"
//+------------------------------------------------------------------+

/*
- Input Setting RiskPercentage with 1% as default
- OrderPricePlot - Plots the order entry price on screen
- TrailingStop - Lowest of 2 Bars(D1)

- Entry when MID is OS BBANDH4
- With SL is Lowest of Lowest of 2 Bars(D1)
- LotSize = 1% VAR

*/
//********************************************************************
/*
CHANGE LOG


*/



//********************************************************************

#import "jUtil.ex4"
   double   ND(double val);
   double   ND2(double val);
#import


#define MAGICMA  1065

input double RiskPercentage   = 1;
int WIND_jHUDx = 0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//************************************************************************************************
//                                     MAIN                                                      *
//************************************************************************************************
int OnInit()                        {RunInitManager();return(INIT_SUCCEEDED);}
//+----------------------------------------------------------------------------------------------+
void OnDeinit(const int reason)     {RunDeInitManager(reason);}
//+----------------------------------------------------------------------------------------------+
void OnTick()                       {RunTickManager();}
//+----------------------------------------------------------------------------------------------+
void OnTimer()                      {RunTimerManager();}
//+----------------------------------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam) {}
//+----------------------------------------------------------------------------------------------+
//void OnBookChange()                 {RunBookManager();}
//+----------------------------------------------------------------------------------------------+
//
int RunInitManager()
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
void RunDeInitManager(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   ObjectsDeleteAll(0,"jINFO_");
  }
//+------------------------------------------------------------------+
void RunTimerManager()
  {
//---

  }
//+------------------------------------------------------------------+
//| OnTick function                                                  |
//+------------------------------------------------------------------+
void RunTickManager()
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

   BUYS=SELLS=0; //RESET!!!
   
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
   if(Volume[0]>1) return; //on 1st tick only
   long   volM1 = iVolume(NULL,PERIOD_M1,0);
   long   volH4 = iVolume(NULL,PERIOD_H4,0);
   {
      C=CORNER_LEFT_UPPER;
      F="ARIAL";FS=7;
      COLORB=clrAntiqueWhite;
      X=4;Y=25;
      DisplayText("jINFO_Vol" ,IntegerToString(volH4)+"."+IntegerToString(volM1) ,0,C,X,Y+00     ,F,FS, clrBrown );
   }

   bool bTRADABLE_HH = (TimeHour(TimeLocal())==23)||(TimeHour(TimeLocal())<6);
   
   //TIME
   if(!bTRADABLE_HH) return;
   
   //ATR
   if(D1_ATRRATIO_CURR<1)return;
   
   
   if(MID<BBAND1420H4_LOWER)
   {
      if(BUYS!=0)return;
      
      Print("BUYING. GetLotSize(RiskPercentage,OP_BUY)=", GetLotSize(RiskPercentage,OP_BUY) );
      int ticket=OrderSend(Symbol(),OP_BUY,   GetLotSize(0,0.01)/* GetLotSize(RiskPercentage,OP_BUY)*//*LotsOptimized()*/,Ask,3,GetSL(OP_BUY),BBAND1420H4_UPPER,"EA-BBAND2020 LONG-"+IntegerToString(MAGICMA),MAGICMA,0,Blue);
      if(ticket>0)
      {
         drawarrowOrderTicket(IntegerToString(ticket),Ask,3,Blue,"");  
      }
   }
   else
   if(MID>BBAND1420H4_UPPER)
   {
      if(SELLS!=0)return;
      
      Print("SELLING. GetLotSize(RiskPercentage,OP_SELL)=", GetLotSize(RiskPercentage,OP_SELL) );
      int ticket=OrderSend(Symbol(),OP_SELL,  GetLotSize(0,0.01)/*GetLotSize(RiskPercentage,OP_SELL)*//*LotsOptimized()*/,Bid,3,GetSL(OP_SELL),BBAND1420H4_LOWER,"EA-BBAND2020 SHORT-"+IntegerToString(MAGICMA),MAGICMA,0,Red);
      if(ticket>0)
      {
         drawarrowOrderTicket(IntegerToString(ticket),Bid,3,Red,"");  
      }   
   }

}
//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
void CheckForClose()
{
   if(iVolume(NULL,PERIOD_H1,0)<=10 /*new H1*/)
   {
      Print("TrailBy2BarD1...");
      TrailBy2BarD1(MAGICMA);
   }
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

double ASK,BID,MID;
void ComputeIndicators()
{
   ASK=NormalizeDouble(MarketInfo(NULL,MODE_ASK),(int)MarketInfo(NULL,MODE_DIGITS));
   BID=NormalizeDouble(MarketInfo(NULL,MODE_BID),(int)MarketInfo(NULL,MODE_DIGITS));
   MID=NormalizeDouble(((BID+ASK)/2),(int)MarketInfo(NULL,MODE_DIGITS));
   
   ComputeATR();
   ComputeBBAND();
   ComputeSignal();
}

//+------------------------------------------------------------------+
//|ATR4                                                              |
//+------------------------------------------------------------------+

double   D1_RANGE;
double   D1_ATR,D1_ATRRATIO,D1_ATRRATIO_CURR; 

void ComputeATR() 
{
   double DIST2TOD_LO = MathAbs(MID-iLow (NULL, PERIOD_D1,0));
   double DIST2TOD_HI = MathAbs(MID-iHigh(NULL, PERIOD_D1,0));
   D1_ATR =iATR(NULL,PERIOD_D1,4,0);
   D1_RANGE = iHigh(NULL, PERIOD_D1,0) - iLow (NULL, PERIOD_D1,0);
   D1_ATRRATIO = D1_RANGE/(D1_ATR+Point); //Prevent DivBy0
   D1_ATRRATIO_CURR = MathMax(DIST2TOD_HI,DIST2TOD_LO)/(D1_ATR+Point); //Prevent DivBy0
}

//---
double   BBAND1420H4_UPPER; //   =iBands(NULL,PERIOD_H4,14,2.0,0,PRICE_MEDIAN,MODE_UPPER,0);
double   BBAND1420H4_LOWER; //   =iBands(NULL,PERIOD_H4,14,2.0,0,PRICE_MEDIAN,MODE_LOWER,0);      
void ComputeBBAND()                                                     
{
   BBAND1420H4_UPPER=iBands(NULL,PERIOD_H4,14,2.0,0,PRICE_MEDIAN,MODE_UPPER,0);
   BBAND1420H4_LOWER=iBands(NULL,PERIOD_H4,14,2.0,0,PRICE_MEDIAN,MODE_LOWER,0);      
}

enum trend 
{
   FLATTREND=0, BULLTREND=1, BEARTREND=-1
};

input double MASpreadPercent = 1; 


trend TREND_H4_BBAND1420H4;
void ComputeSignal()                                                     
{
   TREND_H4_BBAND1420H4 = GetTREND_BBAND1420H4();
}

trend GetTREND_BBAND1420H4()
{
   if(MID<BBAND1420H4_LOWER) return BULLTREND;
   if(MID>BBAND1420H4_UPPER) return BEARTREND;
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
         if((Bid-OrderOpenPrice()) > (Point*100))   //Minimum Profit Distance before trail
         {
            double newSL = GetSL(OP_BUY);
            double newTP = (BBAND1420H4_UPPER);
            if((OrderStopLoss()< newSL)||(OrderStopLoss()==0))  //trail by 
            {
               bool b = OrderModify(OrderTicket(),OrderOpenPrice(),newSL,ND2(BBAND1420H4_UPPER)/*new*/,0,clrBlack);
            }
            
            if((OrderTakeProfit()==0))
            {
               
               bool b = OrderModify(OrderTicket(),OrderOpenPrice(),newSL,newTP/*new*/,0,clrBlack);
            }              
         }
      
     }

      if(OrderType() == OP_SELL)
      {
         if(OrderOpenPrice()-Ask>Point*100)        //Minimum Profit Distance before trail
         {
            
            double newSL = GetSL(OP_SELL);
            double newTP = (BBAND1420H4_LOWER);
            if((OrderStopLoss()> newSL)||(OrderStopLoss()==0))
            {
               bool b = OrderModify(OrderTicket(),OrderOpenPrice(),newSL,ND2(BBAND1420H4_LOWER)/*new*/,0,clrBlack);
            }
            
            if((OrderTakeProfit()==0))
            {
               bool b = OrderModify(OrderTicket(),OrderOpenPrice(),newSL,newTP/*new*/,0,clrBlack);
            }            
         }
         
      }
   }
}

double GetSL(int orderType)
{

   //Highest/Lowest of last 3 Days
   double Highest3DY = iHigh(NULL,PERIOD_D1,iHighest(NULL,PERIOD_D1,MODE_HIGH,3,1)); //  High[iHighest(NULL,PERIOD_D1,MODE_HIGH,5,0)];
   double Lowest3DY  = iLow (NULL,PERIOD_D1,iLowest (NULL,PERIOD_D1,MODE_LOW ,3,1)); //  Low[iHighest(NULL,PERIOD_D1,MODE_LOW,5,0)];

   if(orderType==OP_SELL){return MathMax(Highest3DY, MID+(1000*Point));} 
   if(orderType==OP_BUY ){return MathMin(Lowest3DY,  MID-(1000*Point));}
   
   return 0;
}

double GetLotSize(double AcctBal=0, double minlot=0.01)
{
   if(EXTERN.LOTS>0) return EXTERN.LOTS; //override

   AcctBal = AcctBal>0?AcctBal:AccountInfoDouble(ACCOUNT_BALANCE);
   double NormBal = (double)5000; //must cast to double!!!
   double Multiplier = 0.1; // 5000 => 0.1 lot
   return MathMax(NormalizeDouble(((AcctBal/NormBal)*Multiplier),2), minlot); //in case of account less than 1000, will get 0.01
   //return NormalizeDouble(((AccountInfoDouble(ACCOUNT_BALANCE)/5000)*0.1),2);
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

   X=25;Y=100;
   DisplayText("jINFO_TREND_H4_BBAND1420H4" ,"TREND_H4_BBAND1420H4=" + EnumToString(TREND_H4_BBAND1420H4),WIND_jHUDx,C,X,Y+00     ,F,FS, clrDarkGray );   


   DisplayText("jINFO_PRICE" ,"MID=" + DoubleToStr(MID,Digits) + " " + "BBAND1420H4_UPPER=" + DoubleToStr(BBAND1420H4_UPPER,Digits) + " " + "BBAND1420H4_LOWER=" + DoubleToStr(BBAND1420H4_LOWER,Digits),WIND_jHUDx,C,X,Y+20     ,F,FS, clrDarkGray );   

   DisplayText("jINFO_ATR4" ,"D1_ATRRATIO=" + DoubleToStr(D1_ATRRATIO,2) + " " + "D1_ATRRATIO_CURR=" + DoubleToStr(D1_ATRRATIO_CURR,2),WIND_jHUDx,C,X,Y+40     ,F,FS, clrBlueViolet );   

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//---
//---

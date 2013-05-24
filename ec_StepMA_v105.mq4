//+------------------------------------------------------------------+
//|                                               ec_StepMA_v105.mq4 |
//|                            Copyright 2013, elfcobe Software Ink. |
//|                                   http://d.hatena.ne.jp/elfcobe/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, elfcobe Software Ink."
#property link      "http://d.hatena.ne.jp/elfcobe/"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 DimGray
#property indicator_color2 DimGray
#property indicator_color3 DimGray
#property indicator_color4 RoyalBlue
#property indicator_color5 Red
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 2
#property indicator_width5 2
#property indicator_style2 4
#property indicator_style3 4

extern double Kv         = 4.4;   // Sensivity Factor
extern int    Length     = 14400; // Volty Length
extern bool   SignalMode = true;  // Signal Mode switch
extern bool   AlertMode  = true;  // Alert Mode switch
string sIndName  = "StepMA";
bool LineUpAlert = false;
bool LineDwAlert = false;

double MidLine[];
double UppLine[];
double LowLine[];
double UpSign[];
double DwSign[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(5);
   SetIndexBuffer(0, MidLine);
   SetIndexBuffer(1, UppLine);
   SetIndexBuffer(2, LowLine);
   SetIndexBuffer(3, UpSign);
   SetIndexBuffer(4, DwSign);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexStyle(3, DRAW_LINE);
   SetIndexStyle(4, DRAW_LINE);

   SetIndexDrawBegin(0, Length);
   SetIndexDrawBegin(1, Length);
   SetIndexDrawBegin(2, Length);
   SetIndexDrawBegin(3, Length);
   SetIndexDrawBegin(4, Length);

   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS));
   IndicatorShortName(sIndName);
   SetIndexLabel(0, sIndName);
   SetIndexLabel(1, "Upper");
   SetIndexLabel(2, "Lower");
   SetIndexLabel(3, NULL);
   SetIndexLabel(4, NULL);

   if(!SignalMode && AlertMode){
      Alert("Please set both the SignalMode and AlertMode to true.");
   }

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   Comment("");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   if(Bars < Length){
      int MBars=Bars;
      Alert("MaxBars="+MBars+"_  The number of Length is over the number of MaxBars.");
      return(0);
   }

   int i, limit, counted_bars=IndicatorCounted();
   double WS=0;
   limit=Bars-counted_bars;

   for(i=limit-1; i>=0; i--){
//----------StepMA
      if((Close[i] <= UppLine[i+1]) && (Close[i] >= LowLine[i+1])){
         MidLine[i]=MidLine[i+1];
         UppLine[i]=UppLine[i+1];
         LowLine[i]=LowLine[i+1];
      } else {
         WS=iATR(NULL, 0, Length, i)*Kv;
         double MidLevel=MidLine[i+1];
         if(Close[i] > UppLine[i+1]){
            UppLine[i]=Close[i];
            double MidtestU=UppLine[i]-WS;
            if(MidLevel >= MidtestU){
               MidLine[i]=MidLevel+(0.001*Point);
               LowLine[i]=MidLine[i]-(UppLine[i]-MidLine[i]);
            } else {
               MidLine[i]=MidtestU;
               LowLine[i]=MidLine[i]-WS;
            }
         }
         if(Close[i] < LowLine[i+1]){
            LowLine[i]=Close[i];
            double MidtestD=LowLine[i]+WS;
            if(MidLevel <= MidtestD){
               MidLine[i]=MidLevel-(0.001*Point);
               UppLine[i]=MidLine[i]+(MidLine[i]-LowLine[i]);
            } else {
               MidLine[i]=MidtestD;
               UppLine[i]=MidLine[i]+WS;
            }
         }
      }
      Comment("StepSize (Upp-Low) = ", (UppLine[i]-LowLine[i])/10.0/Point);
//----------Signal
      if(SignalMode){
         if(MidLine[i+1] == MidLine[i]){
            UpSign[i]=UpSign[i+1];
            DwSign[i]=DwSign[i+1];
            if(MidLine[i+2] == MidLine[i+1]){
               if(UpSign[i+2] != UpSign[i+1]){
                  UpSign[i+1]=UpSign[i+2];
                  UpSign[i]=UpSign[i+1];
               }
               if(DwSign[i+2] != DwSign[i+1]){
                  DwSign[i+1]=DwSign[i+2];
                  DwSign[i]=DwSign[i+1];
               }
            }
         } else {
            if(MidLine[i+1] < MidLine[i]){
               UpSign[i]=MidLine[i];
               DwSign[i]=EMPTY_VALUE;
               if(UpSign[i] != EMPTY_VALUE && UpSign[i+1] == EMPTY_VALUE) UpSign[i+1]=MidLine[i+1];
            }
            if(MidLine[i+1] > MidLine[i]){
               UpSign[i]=EMPTY_VALUE;
               DwSign[i]=MidLine[i];
               if(DwSign[i] != EMPTY_VALUE && DwSign[i+1] == EMPTY_VALUE) DwSign[i+1]=MidLine[i+1];
            }
         }
      }
   }
//----------Alert
   if(AlertMode){
      if(UpSign[3] == EMPTY_VALUE && UpSign[2] != EMPTY_VALUE && !LineUpAlert){
         Alert(sIndName+"  Trend Up   "+ Symbol() + Period() +"M ["+DoubleToStr(Bid,Digits)+"]");
         LineUpAlert = true; LineDwAlert = false;
      }
      if(DwSign[3] == EMPTY_VALUE && DwSign[2] != EMPTY_VALUE && !LineDwAlert){
         Alert(sIndName+"  Trend Down   "+ Symbol() + Period() +"M ["+DoubleToStr(Bid,Digits)+"]");
         LineUpAlert = false; LineDwAlert = true;
      }
   }

   return(0);
  }
//+------------------------------------------------------------------+
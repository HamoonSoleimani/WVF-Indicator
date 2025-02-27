//+------------------------------------------------------------------+
//| VIX Indicator (Based on Williams VIX Fix)                        |
//| Copyright © 2024, Hamoon                                         |
//| website: Hamoon.net                                              |
//+------------------------------------------------------------------+

#property copyright "Hamoon"
#property link      "Hamoon.net"
#property version   "1.00"
#property description "VIX Indicator"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots 1

//--- plot VIX
#property indicator_label1  "VIX Indicator"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrFireBrick,clrGold,clrGreen
#property indicator_style1  STYLE_DASHDOTDOT
#property indicator_width1  3

//--- input parameters
input int inpVixPeriod = 14; // VIX period

//--- indicator buffers
double vixVal[];
double vixColor[];

//--- global variables
bool showPopupMessage = true; // Flag to show the popup message only once
double lastValue = 0.0; // Variable to store the last calculated value

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,vixVal,INDICATOR_DATA);
   SetIndexBuffer(1,vixColor,INDICATOR_COLOR_INDEX);

//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"VIX Indicator ("+(string)inpVixPeriod+")");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_LINE);

//--- setting buffer arrays as timeseries
   ArraySetAsSeries(vixVal,true);
   ArraySetAsSeries(vixColor,true);

//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- Check for the minimum number of bars required for calculation
   if(rates_total<inpVixPeriod) return 0;

//--- Set arrays as timeseries
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);

//--- Check and calculate the number of bars to be processed
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-inpVixPeriod-2;
      ArrayInitialize(vixVal,EMPTY_VALUE);
     }

//--- Calculate the indicator
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      int h=iHighest(NULL,PERIOD_CURRENT,MODE_CLOSE,inpVixPeriod,i);
      if(h==WRONG_VALUE) continue;
      double max=close[h];
      vixVal[i]=(max>0 ? 100*(max-low[i])/max : 0);
      vixColor[i]=(vixVal[i]>vixVal[i+1] ? 1 : 0);

      // Store the last calculated value
      if (i == limit)
        lastValue = vixVal[i];
     }

//--- Show the popup message with the last calculated value
   if (showPopupMessage)
     {
      Alert("VIX Indicator value: " + DoubleToStr(lastValue, 2));
      showPopupMessage = false; // Set the flag to false to avoid showing the popup again
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                 ExactZZ_Plus.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property version   "1.0"
#property copyright "2018, Anatoli Kazharski"
#property link      "https://www.mql5.com/en/users/tol64"
//---
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   5
//---
#property indicator_color1  clrRed
#property indicator_color2  clrCornflowerBlue
#property indicator_color3  clrGold
#property indicator_color4  clrOrange
#property indicator_color5  clrSkyBlue

//--- External parameters
input int   NumberOfBars   =0;       // Number of bars
input int   MinImpulseSize =200;     // Minimum points in a ray
input bool  ShowAskBid     =false;   // Show ask/bid
input bool  ShowAllPoints  =false;   // Show all points
input color RayColor       =clrGold; // Ray color

//--- Indicator buffers:
double low_ask_buffer[];    // Minimum Ask price
double high_bid_buffer[];   // Maximum Bid price
double zz_H_buffer[];       // Highs
double zz_L_buffer[];       // Lows
double total_zz_h_buffer[]; // All highs
double total_zz_l_buffer[]; // All lows

//--- To define a bar to perform calculation from
int start=0;
//--- ZZ variables
int    last_zz_max  =0;
int    last_zz_min  =0;
int    direction_zz =0;
double min_low_ask  =0;
double max_high_bid =0;
//---
int      check_bars_calc =0;
datetime first_date      =(_Period==PERIOD_D1 || _Period==PERIOD_W1 || _Period==PERIOD_MN1) ? 0 : D'01.01.2000';
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   ChartSetInteger(0,CHART_SHOW_GRID,false); // false to remove grid
//--- Set indicator properties
   SetPropertiesIndicator();
//--- Initialization completed successfully
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],const double &high[],const double &low[],const double &close[],
                const long &tick_volume[],const long &volume[],const int &spread[])
  {
//--- Disable calculation on each tick
   if(prev_calculated==rates_total)
      return(rates_total);
//--- If this is the first calculation
   if(prev_calculated==0)
     {
      //--- Reset indicator buffers
      ZeroIndicatorBuffers();
      //--- Reset variables
      ZeroIndicatorData();
      //--- Check the amount of available data
      if(!CheckDataAvailable())
         return(0);
      //--- If more data specified for copying, the current amount is used
      DetermineNumberData();
      //--- Define the bar plotting for each symbol starts from
      DetermineBeginForCalculate(rates_total);
     }
   else
     {
      //--- Calculate the last value only
      start=prev_calculated-1;
      ZeroIndex(start);
      ZeroIndex(prev_calculated);
     }
//--- Fill in the High Bid and Low Ask indicator buffers
   for(int i=start; i<rates_total; i++)
      FillAskBidBuffers(i,time,high,low,spread);
//--- Fill the indicator buffers with data
   for(int i=start; i<rates_total-1; i++)
      FillIndicatorBuffers(i,time);
//--- Return the data array size
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Reset the indicator buffers                                      |
//+------------------------------------------------------------------+
void ZeroIndicatorBuffers(void)
  {
   ArrayInitialize(zz_H_buffer,0);
   ArrayInitialize(zz_L_buffer,0);
   ArrayInitialize(low_ask_buffer,0);
   ArrayInitialize(high_bid_buffer,0);
   ArrayInitialize(total_zz_h_buffer,0);
   ArrayInitialize(total_zz_l_buffer,0);
  }
//+------------------------------------------------------------------+
//| Reset the variables                                              |
//+------------------------------------------------------------------+
void ZeroIndicatorData(void)
  {
   start       =0;
   last_zz_max =0;
   last_zz_min =0;
  }
//+------------------------------------------------------------------+
//| Reset a specified buffer element                                 |
//+------------------------------------------------------------------+
void ZeroIndex(const int index)
  {
   zz_H_buffer[index]       =0;
   zz_L_buffer[index]       =0;
   total_zz_h_buffer[index] =0;
   total_zz_l_buffer[index] =0;
   low_ask_buffer[index]    =0;
   high_bid_buffer[index]   =0;
  }
//+------------------------------------------------------------------+
//| Set the indicator properties                                     |
//+------------------------------------------------------------------+
void SetPropertiesIndicator(void)
  {
//--- Set a short name
   IndicatorSetString(INDICATOR_SHORTNAME,"ExactZZ_Plus");
//--- Set a number of decimal places
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- Define buffers for drawing
   SetIndexBuffer(0,high_bid_buffer,INDICATOR_DATA);
   SetIndexBuffer(1,low_ask_buffer,INDICATOR_DATA);
   SetIndexBuffer(2,zz_H_buffer,INDICATOR_DATA);
   SetIndexBuffer(3,zz_L_buffer,INDICATOR_DATA);
   SetIndexBuffer(4,total_zz_h_buffer,INDICATOR_DATA);
   SetIndexBuffer(5,total_zz_l_buffer,INDICATOR_DATA);
//--- Set the labels
   string text[]= {"High Bid","Low Ask","ZZ","Total High ZZ","Total Low ZZ"};
   for(int i=0; i<indicator_plots; i++)
      PlotIndexSetString(i,PLOT_LABEL,text[i]);
//--- Set the type
   ENUM_DRAW_TYPE draw_type_askbid    =(ShowAskBid)? DRAW_LINE : DRAW_NONE;
   ENUM_DRAW_TYPE draw_type_allpoints =(ShowAllPoints)? DRAW_ARROW : DRAW_NONE;
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,draw_type_askbid);
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,draw_type_askbid);
   PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_ZIGZAG);
   PlotIndexSetInteger(3,PLOT_DRAW_TYPE,draw_type_allpoints);
   PlotIndexSetInteger(4,PLOT_DRAW_TYPE,draw_type_allpoints);
//--- Disk
   PlotIndexSetInteger(3,PLOT_ARROW,159);
   PlotIndexSetInteger(4,PLOT_ARROW,159);
//--- Color
   PlotIndexSetInteger(2,PLOT_LINE_COLOR,RayColor);
//--- Set a style
   for(int i=0; i<indicator_plots; i++)
      PlotIndexSetInteger(i,PLOT_LINE_STYLE,STYLE_SOLID);
//--- Set a width
   for(int i=0; i<indicator_plots; i++)
      PlotIndexSetInteger(i,PLOT_LINE_WIDTH,1);//PlotIndexSetInteger(i,PLOT_LINE_WIDTH,(i<2)? 1 : 2);
//--- Empty value for plotting where nothing will be drawn
   for(int i=0; i<indicator_plots; i++)
      PlotIndexSetDouble(i,PLOT_EMPTY_VALUE,0.0);
  }
//+------------------------------------------------------------------+
//| Check the amount of available data for all symbols               |
//+------------------------------------------------------------------+
bool CheckDataAvailable(void)
  {
//--- Reset the last error in memory
   ResetLastError();
//--- Get the number of bars on the current timeframe
   check_bars_calc=TerminalInfoInteger(TERMINAL_MAXBARS);
//--- Try again in case of a data retrieval error
   if(check_bars_calc<=0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Define the number of days for display                            |
//+------------------------------------------------------------------+
void DetermineNumberData(void)
  {
//--- If not all bars are needed
   if(NumberOfBars>0)
     {
      //--- If specified more than the current amount, inform of that
      if(NumberOfBars>check_bars_calc)
         printf("%s: Not enough data to calculate! NumberOfBars: %d; Indicator data: %d",
                _Symbol,NumberOfBars,check_bars_calc);
      else
         check_bars_calc=NumberOfBars;
     }
  }
//+------------------------------------------------------------------+
//| Define the index of the first bar to plot                        |
//+------------------------------------------------------------------+
void DetermineBeginForCalculate(const int rates_total)
  {
//--- If there is more indicator data than there is on the current symbol, then
//    plot from the first one available on the current symbol
   if(check_bars_calc>rates_total)
      start=1;
   else
      start=rates_total-check_bars_calc;
  }
//+------------------------------------------------------------------+
//| Fill in the High Bid and Low Ask indicator buffers               |
//+------------------------------------------------------------------+
void FillAskBidBuffers(const int i,const datetime &time[],const double &high[],const double &low[],const int &spread[])
  {
//--- Exit if the start date is not reached
   if(time[i]<first_date)
      return;
//---
   high_bid_buffer[i] =high[i];
   low_ask_buffer[i]  =low[i];//+(spread[i]*_Point);
  }
//+------------------------------------------------------------------+
//| Fill in ZZ indicator buffers                                     |
//+------------------------------------------------------------------+
void FillIndicatorBuffers(const int i,const datetime &time[])
  {
   if(time[i]<first_date)
      return;
//--- If ZZ is directed upwards
   if(direction_zz>0)
     {
      //--- In case of a new high
      if(high_bid_buffer[i]>=max_high_bid)
        {
         //-- modificado; atualizar a máxima somente se realmente for uma nova máxima
         //if(high_bid_buffer[i]==max_high_bid)
         //   return;

         zz_H_buffer[last_zz_max] =0;
         last_zz_max              =i;
         max_high_bid             =high_bid_buffer[i];
         zz_H_buffer[i]           =high_bid_buffer[i];
         total_zz_h_buffer[i]     =high_bid_buffer[i];

        }
      //--- If direction has changed (downwards)
      else
        {
         if(low_ask_buffer[i]<max_high_bid &&
            fabs(low_ask_buffer[i]-zz_H_buffer[last_zz_max])>MinImpulseSize*_Point)
           {
            last_zz_min          =i;
            direction_zz         =-1;
            min_low_ask          =low_ask_buffer[i];
            zz_L_buffer[i]       =low_ask_buffer[i];
            total_zz_l_buffer[i] =low_ask_buffer[i];
           }
        }
     }
//--- If ZZ is directed downwards
   else
     {
      //--- In case of a new low
      if(low_ask_buffer[i]<=min_low_ask)
        {
         //-- modificado;atualizar a mínima somente se realmente for uma nova mínima
         //if(low_ask_buffer[i]==min_low_ask)
           // return;

         zz_L_buffer[last_zz_min] =0;
         last_zz_min              =i;
         min_low_ask              =low_ask_buffer[i];
         zz_L_buffer[i]           =low_ask_buffer[i];
         total_zz_l_buffer[i]     =low_ask_buffer[i];
        }
      //--- If direction has changed (upwards)
      else
        {
         if(high_bid_buffer[i]>min_low_ask &&
            fabs(high_bid_buffer[i]-zz_L_buffer[last_zz_min])>MinImpulseSize*_Point)
           {
            last_zz_max          =i;
            direction_zz         =1;
            max_high_bid         =high_bid_buffer[i];
            zz_H_buffer[i]       =high_bid_buffer[i];
            total_zz_h_buffer[i] =high_bid_buffer[i];
           }
        }
     }
  }
//+------------------------------------------------------------------+

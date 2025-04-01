//+------------------------------------------------------------------+
//|                                        EntryRompimentoCandle.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\Signal\Dunnigan\Entry\EntryBase.mqh>
#include <TradeManager\Utility\Series.mqh>
#include <TradeManager\Signal\Dunnigan\ParamsConfig.mqh>
#include <Trade\SymbolInfo.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EntryBreakCandle: public EntryBase
  {
private:
   Series            *m_series;
   ParamsConfig      m_params;
   CSymbolInfo       *m_symbol;

public:
                     EntryBreakCandle(Series *series, ParamsConfig &params, CSymbolInfo *symbol);

   bool              IsNewBar();
   bool              EntryBuy(double &price,double &sl,double &tp,datetime &expiration) override;
   bool              EntrySell(double &price,double &sl,double &tp,datetime &expiration) override;
  };
//+------------------------------------------------------------------+
EntryBreakCandle::EntryBreakCandle(Series *series, ParamsConfig &params, CSymbolInfo *symbol)
  {
   m_series = series;
   m_params = &params;
   m_symbol = symbol;
  }
//+------------------------------------------------------------------+
bool EntryBreakCandle::EntryBuy(double &price,double &sl,double &tp,datetime &expiration)
  {
   if(IsNewBar())
     {
      price = m_symbol.NormalizePrice(m_series.High(1));
      if(m_params.m_stop_loss > 0)
         sl = price - m_params.m_stop_loss;
      if(m_params.m_take_profit > 0)
         tp = price + m_params.m_take_profit;
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
bool EntryBreakCandle::EntrySell(double &price,double &sl,double &tp,datetime &expiration)
  {
   if(IsNewBar())
     {
      price = m_symbol.NormalizePrice(m_series.Low(1));
      if(m_params.m_stop_loss > 0)
         sl = price +  m_params.m_stop_loss;
      if(m_params.m_take_profit > 0)
         tp = price -  m_params.m_take_profit;
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
static datetime last_time_1=0;
//--
bool EntryBreakCandle::IsNewBar()
  {
//--- memorize the time of opening of the last bar in the static variable
//--- current time
   datetime lastbar_timed=SeriesInfoInteger(Symbol(),m_params.m_period,SERIES_LASTBAR_DATE);
//--- if it is the first call of the function
   if(last_time_1==0)
     {
      //--- set the time and exit
      last_time_1=lastbar_timed;
      return(false);
     }
//--- if the time differs
   if(last_time_1!=lastbar_timed)
     {
      //--- memorize the time and return true
      last_time_1=lastbar_timed;
      return(true);
     }
//--- if we passed to this line, then the bar is not new; return false
   return(false);
  }
//+------------------------------------------------------------------+

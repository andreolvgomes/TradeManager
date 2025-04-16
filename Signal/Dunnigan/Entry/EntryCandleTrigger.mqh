//+------------------------------------------------------------------+
//|                                                EntryCandleTrigger.mqh |
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
class EntryCandleTrigger : public EntryBase
  {
private:
   Series            *m_series;
   ParamsConfig      m_params;
   CSymbolInfo       *m_symbol;

public:
                     EntryCandleTrigger(Series *series, ParamsConfig &params, CSymbolInfo *symbol);

   bool              EntryBuy(double &price,double &sl,double &tp,datetime &expiration) override;
   bool              EntrySell(double &price,double &sl,double &tp,datetime &expiration) override;
  };
//+------------------------------------------------------------------+
EntryCandleTrigger::EntryCandleTrigger(Series *series, ParamsConfig &params, CSymbolInfo *symbol)
  {
   m_series = series;
   m_params = &params;
   m_symbol = symbol;
  }
//+------------------------------------------------------------------+
bool EntryCandleTrigger::EntryBuy(double &price,double &sl,double &tp,datetime &expiration)
  {
   price = m_symbol.NormalizePrice(m_series.Low(0)+m_params.m_stop_loss-m_params.m_level_stoploss);
   if(m_params.m_stop_loss > 0)
      sl = price - m_params.m_stop_loss;
   if(m_params.m_take_profit > 0)
      tp = price + m_params.m_take_profit;
   return true;
  }
//+------------------------------------------------------------------+
bool EntryCandleTrigger::EntrySell(double &price,double &sl,double &tp,datetime &expiration)
  {
   price = m_symbol.NormalizePrice(m_series.High(0)-m_params.m_stop_loss+m_params.m_level_stoploss);
   if(m_params.m_stop_loss > 0)
      sl = price + m_params.m_stop_loss;
   if(m_params.m_take_profit > 0)
      tp = price - m_params.m_take_profit;
   return true;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                               AmplitudeRules.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\Signal\Dunnigan\Rules\ConfirmationBase.mqh>
#include <TradeManager\Signal\Dunnigan\ParamsConfig.mqh>
#include <Trade\SymbolInfo.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CheckAlvosRules : public ConfirmationBase
  {
private:
   ParamsConfig      m_params;

public:
                     CheckAlvosRules(ParamsConfig &params)  {m_params  = &params;}

   bool              IsBuyValid();
   bool              IsSellValid();
  };

//--
bool CheckAlvosRules::IsBuyValid()
  {
   double price = m_symbol.NormalizePrice(m_series.Low(1)+m_params.m_stop_loss-m_params.m_level_stoploss);
   double lastHigh = m_series.High(m_params.m_number_barras);
   double amplitude = lastHigh - price;
   if(amplitude >= 500)
      return true;
   return false;
  }
//--
bool CheckAlvosRules::IsSellValid()
  {
   double price = m_symbol.NormalizePrice(m_series.High(1)-m_params.m_stop_loss+m_params.m_level_stoploss);
   double lastLow = m_series.Low(m_params.m_number_barras);
   double amplitude = price - lastLow;
   if(amplitude >= 500)
      return true;
   return false;
  }
//+------------------------------------------------------------------+

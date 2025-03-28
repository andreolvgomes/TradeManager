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
class GatilhoViolouCandleAnteriorRules : public ConfirmationBase
  {
private:
   ParamsConfig      m_params;

public:
                     GatilhoViolouCandleAnteriorRules(ParamsConfig &params) {   m_params  = &params;};

   bool              IsBuyValid();
   bool              IsSellValid();
   string            Message() {return "Gatilho violou contrário o último candle";};
  };

//+------------------------------------------------------------------+
bool GatilhoViolouCandleAnteriorRules::IsBuyValid()
  {
   if(m_series.Low(0) < m_series.Low(1))
      return(false);
   return true;
  }
//+------------------------------------------------------------------+
bool GatilhoViolouCandleAnteriorRules::IsSellValid()
  {
   if(m_series.High(0) > m_series.High(1))
      return(false);
   return true;
  }
//+------------------------------------------------------------------+

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
#include <TradeManager\Utility\CandlePattern.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class AmplitudeAlvosMaxBarsRules : public ConfirmationBase
  {
private:
   ParamsConfig      m_params;
   CandlePattern     m_candler_pattern;

public:
                     AmplitudeAlvosMaxBarsRules(ParamsConfig &params);

   bool              IsBuyValid();
   bool              IsSellValid();
   string            Message() {return "Não atendeu a amplitude de alvos entre as máximas/mínimas das barras";};
  };
//+------------------------------------------------------------------+
AmplitudeAlvosMaxBarsRules::AmplitudeAlvosMaxBarsRules(ParamsConfig &params)
  {
   m_params  = &params;
   m_candler_pattern.Init(Symbol(), m_params.m_period);
  }
//--
bool AmplitudeAlvosMaxBarsRules::IsBuyValid()
  {
   if(m_params.m_amplitude_alvos == 0)
      return true;

   int lastBar = m_candler_pattern.NumSequencialDown(1);

   double price = m_symbol.NormalizePrice(m_series.Low(1)+m_params.m_stop_loss-m_params.m_level_stoploss);
   double lastHigh = m_series.High(lastBar);
   double amplitude = lastHigh - price;

   if(amplitude >= m_params.m_amplitude_alvos)
      return true;
   return false;
  }
//--
bool AmplitudeAlvosMaxBarsRules::IsSellValid()
  {
   if(m_params.m_amplitude_alvos == 0)
      return true;

   int lastBar = m_candler_pattern.NumSequencialUp(1);

   double price = m_symbol.NormalizePrice(m_series.High(1)-m_params.m_stop_loss+m_params.m_level_stoploss);
   double lastLow = m_series.Low(lastBar);
   double amplitude = price - lastLow;

   if(amplitude >= m_params.m_amplitude_alvos)
      return true;
   return false;
  }
//+------------------------------------------------------------------+

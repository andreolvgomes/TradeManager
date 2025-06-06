//+------------------------------------------------------------------+
//|                                    AmplitudeDoMovimentoRules.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\Signal\Dunnigan\Rules\ConfirmationBase.mqh>
#include <TradeManager\Signal\Dunnigan\ParamsConfig.mqh>
#include <TradeManager\Utility\CandlePattern.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class AmplitudeDoMovimentoMaxBarsRules: public ConfirmationBase
  {
private:
   ParamsConfig      m_params;
   CandlePattern     m_candler_pattern;

public:
                     AmplitudeDoMovimentoMaxBarsRules(ParamsConfig &params);

   bool              IsBuyValid();
   bool              IsSellValid();
   string            Message() {return "Não atendeu a amplitude de movimento das máximas/mínimas das barras";};
  };
//+------------------------------------------------------------------+
AmplitudeDoMovimentoMaxBarsRules::AmplitudeDoMovimentoMaxBarsRules(ParamsConfig &params)
  {
   m_params  = &params;
   m_candler_pattern.Init(Symbol(), m_params.m_period);
  }
//--
bool AmplitudeDoMovimentoMaxBarsRules::IsBuyValid()
  {
// verifica se a amplitude das Máximas atende a condição
   if(m_params.m_amplitude_movimento > 0)
     {
      int lastBar = m_candler_pattern.NumSequencialDown(1);

      double ampli = m_series.DistanceBetweenHigh(1, lastBar);
      if(ampli < m_params.m_amplitude_movimento)
         return false;
     }
   return true;
  }
//--
bool AmplitudeDoMovimentoMaxBarsRules::IsSellValid()
  {
// verifica se a amplitude das Mínimas atende a condição
   if(m_params.m_amplitude_movimento > 0)
     {
      int lastBar = m_candler_pattern.NumSequencialUp(1);

      double ampli = m_series.DistanceBetweenLow(1, lastBar);
      if(ampli < m_params.m_amplitude_movimento)
         return false;
     }
   return true;
  }
//+------------------------------------------------------------------+

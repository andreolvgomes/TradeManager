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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class AmplitudeAlvosRules : public ConfirmationBase
  {
private:
   ParamsConfig      m_params;

public:
                     AmplitudeAlvosRules(ParamsConfig &params)  {m_params  = &params;}

   bool              IsBuyValid();
   bool              IsSellValid();
  };

//--
bool AmplitudeAlvosRules::IsBuyValid()
  {
   if(m_params.m_amplitude_alvo > 0)
     {
      double ampli = m_series.DistanceBetweenHigh(1, m_params.m_number_barras);
      if(ampli < m_params.m_amplitude_alvo)
         return SetMessage("Compra;Invalidada não atendeu alvo");
     }
   return true;
  }
//--
bool AmplitudeAlvosRules::IsSellValid()
  {
   if(m_params.m_amplitude_alvo > 0)
     {
      double ampli = m_series.DistanceBetweenLow(1, m_params.m_number_barras);
      if(ampli < m_params.m_amplitude_alvo)
         return SetMessage("Venda;Invalidada não atendeu alvo");
     }
   return true;
  }
//+------------------------------------------------------------------+

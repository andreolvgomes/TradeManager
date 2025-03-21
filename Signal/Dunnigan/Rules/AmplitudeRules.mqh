//+------------------------------------------------------------------+
//|                                               AmplitudeRules.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\Signal\Dunnigan\Rules\RulesBase.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class AmplitudeRules : public RulesBase
  {
private:
   int               m_number_barras;
   int               m_amplitude_alvo;

public:
   bool              IsBuyValid();
   bool              IsSellValid();

   void              SetNumberBarras(int number_barras) {m_number_barras = number_barras;}
   void              SetAmplitude_alvo(int amplitude_alvo) {m_amplitude_alvo = amplitude_alvo;}
  };

//--
bool AmplitudeRules::IsBuyValid()
  {
   if(m_amplitude_alvo > 0)
     {
      double ampli = m_series.DistanceBetweenHigh(1, m_number_barras);
      if(ampli < m_amplitude_alvo)
         return SetMessage("Compra;Invalidada não atendeu alvo");
     }
   return true;
  }
//--
bool AmplitudeRules::IsSellValid()
  {
   if(m_amplitude_alvo > 0)
     {
      double ampli = m_series.DistanceBetweenLow(1, m_number_barras);
      if(ampli < m_amplitude_alvo)
         return SetMessage("Venda;Invalidada não atendeu alvo");
     }
   return true;
  }
//+------------------------------------------------------------------+

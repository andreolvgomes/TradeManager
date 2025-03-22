//+------------------------------------------------------------------+
//|                                   DunninganConfirmacao2Rules.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\Signal\Dunnigan\ParamsConfig.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\RulesBase.mqh>
#include <TradeManager\Signal\Dunnigan\SetupDunnigan.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class DunninganConfirmacao2Rules: public RulesBase
  {
private:
   ParamsConfig      m_params;
   SetupDunnigan     m_dunnigan2;

public:
                     DunninganConfirmacao2Rules(ParamsConfig &params);

public:
   bool              IsBuyValid();
   bool              IsSellValid();
  };
//--
DunninganConfirmacao2Rules::DunninganConfirmacao2Rules(ParamsConfig &params)
  {
   m_params  = &params;

   m_dunnigan2.Init(Symbol(), m_params.m_period2);
   m_dunnigan2.SetEntryConfirmation(false);
  }
//--
bool DunninganConfirmacao2Rules::IsBuyValid()
  {
   if(m_params.m_analisar2 && m_dunnigan2.Buy()==false)
      return false;
   return true;
  }
//--
bool DunninganConfirmacao2Rules::IsSellValid()
  {
   if(m_params.m_analisar2 && m_dunnigan2.Sell()==false)
      return false;
   return true;
  }
//+------------------------------------------------------------------+

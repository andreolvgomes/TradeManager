//+------------------------------------------------------------------+
//|                                        DunninganConfirmacao1.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\Signal\Dunnigan\ParamsConfig.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\ConfirmationBase.mqh>
#include <TradeManager\Signal\Dunnigan\SetupDunnigan.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class DunninganConfirmacao1Rules : public ConfirmationBase
  {
private:
   ParamsConfig      m_params;
   SetupDunnigan     m_dunnigan1;

public:
                     DunninganConfirmacao1Rules(ParamsConfig &params);

public:
   bool              IsBuyValid();
   bool              IsSellValid();
  };

//--
DunninganConfirmacao1Rules::DunninganConfirmacao1Rules(ParamsConfig &params)
  {
   m_params  = &params;

   m_dunnigan1.Init(Symbol(), m_params.m_period1);
   m_dunnigan1.SetEntryConfirmation(false);
  }
//--
bool DunninganConfirmacao1Rules::IsBuyValid()
  {
   if(m_params.m_analisar1 && m_dunnigan1.Buy()==false)
      return false;
   return true;
  }
//--
bool DunninganConfirmacao1Rules::IsSellValid()
  {
   if(m_params.m_analisar1 && m_dunnigan1.Sell()==false)
      return false;
   return true;
  }
//+------------------------------------------------------------------+

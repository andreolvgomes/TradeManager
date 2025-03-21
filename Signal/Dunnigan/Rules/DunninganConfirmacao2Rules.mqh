//+------------------------------------------------------------------+
//|                                   DunninganConfirmacao2Rules.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\Signal\Dunnigan\Rules\RulesBase.mqh>

class DunninganConfirmacao2Rules: public RulesBase
  {
public:
   bool              IsBuyValid();
   bool              IsSellValid();
  };
//--
bool DunninganConfirmacao2Rules::IsBuyValid()
  {
   return true;
  }
//--
bool DunninganConfirmacao2Rules::IsSellValid()
  {
   return true;
  }
//+------------------------------------------------------------------+

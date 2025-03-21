//+------------------------------------------------------------------+
//|                               SequencialTimerFrameMaiorRules.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\Signal\Dunnigan\Rules\RulesBase.mqh>

class SequencialTimerFrameMaiorRules : public RulesBase
  {
public:
   bool              IsBuyValid();
   bool              IsSellValid();
  };
//--
bool SequencialTimerFrameMaiorRules::IsBuyValid()
  {
   return true;
  }
//--
bool SequencialTimerFrameMaiorRules::IsSellValid()
  {
   return true;
  }
//+------------------------------------------------------------------+

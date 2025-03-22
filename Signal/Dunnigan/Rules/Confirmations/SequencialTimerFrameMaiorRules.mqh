//+------------------------------------------------------------------+
//|                               SequencialTimerFrameMaiorRules.mqh |
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
class SequencialTimerFrameMaiorRules : public ConfirmationBase
  {
private:
   ParamsConfig      m_params;
   CandlePattern     m_candler_pattern_big;

public:
                     SequencialTimerFrameMaiorRules(ParamsConfig &params);

public:
   bool              IsBuyValid();
   bool              IsSellValid();
  };
//--
SequencialTimerFrameMaiorRules::SequencialTimerFrameMaiorRules(ParamsConfig &params)
  {
   m_params  = &params;
   m_candler_pattern_big.Init(Symbol(), m_params.m_perdiodMaior);
  }
//--
bool SequencialTimerFrameMaiorRules::IsBuyValid()
  {
   if(m_params.m_number_barras_maior == 0)
      return true;
   if(m_candler_pattern_big.SequencialDown(m_params.m_number_barras_maior, 1))
      return true;
   return false;
  }
//--
bool SequencialTimerFrameMaiorRules::IsSellValid()
  {
   if(m_params.m_number_barras_maior == 0)
      return true;
   if(m_candler_pattern_big.SequencialUp(m_params.m_number_barras_maior, 1))
      return true;
   return false;
  }
//+------------------------------------------------------------------+

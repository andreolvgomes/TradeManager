//+------------------------------------------------------------------+
//|                               HorarioDeOperacaoRules.mqh |
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
class HorarioDeOperacaoRules : public ConfirmationBase
  {
private:
   ParamsConfig      m_params;

public:
                     HorarioDeOperacaoRules(ParamsConfig &params);

public:
   bool              IsBuyValid();
   bool              IsSellValid();
   string            Message() {return "Fora do horário de operação";};
  };
//--
HorarioDeOperacaoRules::HorarioDeOperacaoRules(ParamsConfig &params)
  {
   m_params  = &params;
  }
//--
bool HorarioDeOperacaoRules::IsBuyValid()
  {
   return true;
  }
//--
bool HorarioDeOperacaoRules::IsSellValid()
  {
   return true;
  }
//+------------------------------------------------------------------+

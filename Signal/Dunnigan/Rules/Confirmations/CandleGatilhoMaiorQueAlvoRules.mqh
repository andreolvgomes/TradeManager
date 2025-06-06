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
#include <TradeManager\Utility\Series.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CandleGatilhoMaiorQueAlvoRules : public ConfirmationBase
  {
private:
   ParamsConfig      m_params;
   Series            *m_series;

public:
                     CandleGatilhoMaiorQueAlvoRules(ParamsConfig &params, Series *series);

public:
   bool              IsBuyValid();
   bool              IsSellValid();
   string            Message() {return "Candle gatilho maior que alvo";};
  };
//--
CandleGatilhoMaiorQueAlvoRules::CandleGatilhoMaiorQueAlvoRules(ParamsConfig &params, Series *series)
  {
   m_params  = &params;
   m_series = series;
  }
//--
bool CandleGatilhoMaiorQueAlvoRules::IsBuyValid()
  {
   if(m_series.Amp(0)>= m_params.m_take_profit)
      return false;
   return true;
  }
//--
bool CandleGatilhoMaiorQueAlvoRules::IsSellValid()
  {
   if(m_series.Amp(0)>= m_params.m_take_profit)
      return false;
   return true;
  }
//+------------------------------------------------------------------+

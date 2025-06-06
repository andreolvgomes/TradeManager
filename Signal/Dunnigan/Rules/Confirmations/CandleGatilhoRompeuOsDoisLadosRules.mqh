//+------------------------------------------------------------------+
//|                               CandleGatilhoRompeuOsDoisLadosRules.mqh |
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
class CandleGatilhoRompeuOsDoisLadosRules : public ConfirmationBase
  {
private:
   ParamsConfig      m_params;

public:
                     CandleGatilhoRompeuOsDoisLadosRules(ParamsConfig &params);

public:
   bool              IsBuyValid();
   bool              IsSellValid();
   string            Message() {return "Candle gatilho rompeu os dois lados";};
  };
//--
CandleGatilhoRompeuOsDoisLadosRules::CandleGatilhoRompeuOsDoisLadosRules(ParamsConfig &params)
  {
   m_params  = &params;
  }
//--
bool CandleGatilhoRompeuOsDoisLadosRules::IsBuyValid()
  {
   if(m_series.Low(0) < m_series.Low(1))
      return false;
   return true;
  }
//--
bool CandleGatilhoRompeuOsDoisLadosRules::IsSellValid()
  {
   if(m_series.High(0) > m_series.High(1))
      return false;
   return true;
  }
//+------------------------------------------------------------------+

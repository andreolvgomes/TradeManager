//+------------------------------------------------------------------+
//|                                GatilhoRompeuAnterioresCancel.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\Signal\Dunnigan\Rules\CancellationBase.mqh>
#include <TradeManager\Signal\Dunnigan\ParamsConfig.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CandleGatilhoViolouAnterioresCancel : public CancellationBase
  {
private:
   ParamsConfig      m_params;

public:
                     CandleGatilhoViolouAnterioresCancel(ParamsConfig &params)  {m_params  = &params;}

   bool              IsCancelBuy();
   bool              IsCancelSell();
   string            Message() {return "Candle gatilho rompeu todos os outros";};
  };
//+------------------------------------------------------------------+
bool CandleGatilhoViolouAnterioresCancel::IsCancelBuy()
  {
// cancela se o gatilho romper a máxima de todos os outros candles
   for(int i=m_params.m_number_barras;i>=2;i--)
     {
      if(m_series.High(0) > m_series.High(i))
         return(true);
     }
   return false;
  }
//+------------------------------------------------------------------+
bool CandleGatilhoViolouAnterioresCancel::IsCancelSell()
  {
// cancela se o gatilho romper a mínima de todos os outros candles
   for(int i=m_params.m_number_barras;i>=2;i--)
     {
      if(m_series.Low(0) < m_series.Low(i))
         return(true);
     }
   return false;
  }
//+------------------------------------------------------------------+

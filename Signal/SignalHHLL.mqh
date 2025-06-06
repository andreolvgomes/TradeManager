//+------------------------------------------------------------------+
//|                                               SignalDunnigan.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\ManagerSignal.mqh>
#include <TradeManager\Utility\CandlePattern.mqh>
#include <TradeManager\Utility\Functions.mqh>


//-- Sinal de entrada Dunnigan
class SignalHHLL : public ManagerSignal
  {
private:
   CandlePattern     m_candlePattern;

protected:

public:
   void              InitSignal();
   bool              CheckOpenBuy(double &price,double &sl,double &tp,datetime &expiration);
   bool              CheckOpenSell(double &price,double &sl,double &tp,datetime &expiration);
  };
//+------------------------------------------------------------------+
void SignalHHLL::InitSignal()
  {
   m_candlePattern.Init(m_symbol.Name(), m_period);
  }
//+------------------------------------------------------------------+
//-- Verifica condições de Compra
bool SignalHHLL::CheckOpenBuy(double &price,double &sl,double &tp,datetime &expiration)
  {
   if(m_candlePattern.SequencialDown(2, 1))
     {
      int num = m_candlePattern.LowHigh(1);
      if(num>=5)
        {
         double dis = m_series.DistanceBetweenHigh(1, num);
         if(dis >= 400)
           {
            if(m_series.High(0) > m_series.High(1))
              {
               price = m_symbol.NormalizePrice(m_series.Low(1)+m_stop_loss);
               sl = StopLoss(price, false);
               tp = TakeProfit(price, false);
               return true;
              }
           }
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//-- Verifica condições de Venda
bool SignalHHLL::CheckOpenSell(double &price,double &sl,double &tp,datetime &expiration)
  {
   if(m_candlePattern.SequencialUp(2, 1))
     {
      int num = m_candlePattern.HighLow(1);
      if(num >= 5)
        {
         double dis = m_series.DistanceBetweenLow(1, num);
         if(dis >= 400)
           {
            if(m_series.Low(0) < m_series.Low(1))
              {
               price = m_symbol.NormalizePrice(m_series.High(1)-m_stop_loss);
               sl = StopLoss(price, true);
               tp = TakeProfit(price, true);
               return true;
              }
           }
        }
     }
   return false;
  }
//+------------------------------------------------------------------+

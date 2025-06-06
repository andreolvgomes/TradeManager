//+------------------------------------------------------------------+
//|                                               OneTwoInvertido.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\ManagerSignal.mqh>
#include <TradeManager\Utility\CandlePattern.mqh>

//-- Sinal de entrada Dunnigan
class OneTwoInvertido : public ManagerSignal
  {
private:
   CandlePattern     m_pattern;

public:
                     OneTwoInvertido();

   bool              CheckOpenBuy(double &price,double &sl,double &tp,datetime &expiration);
   bool              CheckOpenSell(double &price,double &sl,double &tp,datetime &expiration);
   bool              CheckCloseOrderSell();
   bool              CheckCloseOrderBuy();

  };
//--
OneTwoInvertido::OneTwoInvertido()
  {
  }
//-- Verifica condições para cancelamento de Sell Order Stop/Limit
bool OneTwoInvertido::CheckCloseOrderSell()
  {
   return(false);
  }

//-- Verifica condições para cancelamento de Buy Order Stop/Limit
bool OneTwoInvertido::CheckCloseOrderBuy()
  {
   return(false);
  }
//-- Verifica condições de Compra
bool OneTwoInvertido::CheckOpenBuy(double &price,double &sl,double &tp,datetime &expiration)
  {
   //if(m_pattern.SequencialUp(2,1))
     //{
      //double amplitude = MathAbs(m_series.Low(1) - m_series.Low(2));
      //if(amplitude >= 300)
       // {
         price = m_symbol.NormalizePrice(m_series.Low(1)+m_stop_loss-20);
         sl = StopLoss(price, false);
         tp = TakeProfit(price, false);
         return true;
        //}
    // }
   //return false;
  }

//-- Verifica condições de Venda
bool OneTwoInvertido::CheckOpenSell(double &price,double &sl,double &tp,datetime &expiration)
  {
   //if(m_pattern.SequencialDown(2,1))
    // {
      //double amplitude = MathAbs(m_series.High(1) - m_series.High(2));
      //if(amplitude >= 300)
        //{
         price = m_symbol.NormalizePrice(m_series.High(1)-m_stop_loss+20);
         sl = StopLoss(price, true);
         tp = TakeProfit(price, true);
         return true;
        //}
    // }
   //return false;
  }
//--
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                               SignalDunnigan.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\ManagerSignal.mqh>

//-- Sinal de entrada Dunnigan
class SignalMedio : public ManagerSignal
  {
public:
                     SignalMedio();

   bool              CheckOpenBuy(double &price,double &sl,double &tp,datetime &expiration);
   bool              CheckOpenSell(double &price,double &sl,double &tp,datetime &expiration);
   bool              CheckCloseOrderSell();
   bool              CheckCloseOrderBuy();

  };
//--
SignalMedio::SignalMedio()
  {
  }
//-- Verifica condições para cancelamento de Sell Order Stop/Limit
bool SignalMedio::CheckCloseOrderSell()
  {
   return(false);
  }

//-- Verifica condições para cancelamento de Buy Order Stop/Limit
bool SignalMedio::CheckCloseOrderBuy()
  {   
   return(false);
  }
//-- Verifica condições de Compra
bool SignalMedio::CheckOpenBuy(double &price,double &sl,double &tp,datetime &expiration)
  {
  //return(false);
   price = m_symbol.NormalizePrice(m_series.Low(0));
   sl = StopLoss(price, false);
   tp = TakeProfit(price, false);
   return true;
  }

//-- Verifica condições de Venda
bool SignalMedio::CheckOpenSell(double &price,double &sl,double &tp,datetime &expiration)
  {
   price = m_symbol.NormalizePrice(m_series.High(0));
   sl = StopLoss(price, true);
   tp = TakeProfit(price, true);
   return true;
  }
//--
//+------------------------------------------------------------------+

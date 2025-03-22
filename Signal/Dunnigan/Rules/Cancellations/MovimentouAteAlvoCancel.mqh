//+------------------------------------------------------------------+
//|                                           AlcancouAlvoCancel.mqh |
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
class MovimentouAteAlvoCancel : public CancellationBase
  {
private:
   ParamsConfig      m_params;

public:
                     MovimentouAteAlvoCancel(ParamsConfig &params)  {m_params  = &params;}

   bool              IsCancelBuy();
   bool              IsCancelSell();
  };
//--
bool MovimentouAteAlvoCancel::IsCancelBuy()
  {
   double tp = m_order.TakeProfit();
   if(tp == 0)
      return false;
      
   double ask = m_symbol.Ask();
   if(ask >= tp)
      return true;
   return false;
  }
//--
bool MovimentouAteAlvoCancel::IsCancelSell()
  {
   double tp = m_order.TakeProfit();
   if(tp == 0)
      return false;
      
   double bid = m_symbol.Bid();
   if(bid <= tp)
      return true;
   return false;
  }
//+------------------------------------------------------------------+

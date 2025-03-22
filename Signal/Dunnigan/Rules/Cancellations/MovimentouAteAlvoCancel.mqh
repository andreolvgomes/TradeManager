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
   return false;
  }
  //--
bool MovimentouAteAlvoCancel::IsCancelSell()
  {
   return false;
  }
//+------------------------------------------------------------------+

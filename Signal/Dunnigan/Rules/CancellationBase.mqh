//+------------------------------------------------------------------+
//|                                             CancellationBase.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\Utility\Series.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CancellationBase
  {
protected:
   string            m_message;
   Series            *m_series;

public:
   virtual bool      IsCancelBuy() { return false; }
   virtual bool      IsCancelSell() { return false; }

   void              Init(Series *series) {m_series = series;};
   bool              SetMessage(string message) {m_message = message; return false;}
   string            SetMessage() {return m_message;}
  };
//--

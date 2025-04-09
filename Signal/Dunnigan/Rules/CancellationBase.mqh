//+------------------------------------------------------------------+
//|                                             CancellationBase.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\Utility\Series.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\SymbolInfo.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CancellationBase
  {
protected:
   string            m_message;
   Series            *m_series;
   COrderInfo        m_order;
   CSymbolInfo       *m_symbol;

public:
   virtual bool      IsCancelBuy() { return false; }
   virtual bool      IsCancelSell() { return false; }
   virtual string    Message() { return "Message default"; }

   void              Init(Series *series, COrderInfo &order);
   void              SetSymbol(CSymbolInfo *symbol) {m_symbol = symbol;}
  };
//--
void CancellationBase::Init(Series *series,COrderInfo &order)
  {
   m_series = series;
   m_order = &order;
  }
//+------------------------------------------------------------------+

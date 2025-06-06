//+------------------------------------------------------------------+
//|                                                    RulesBase.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\Utility\Series.mqh>
#include <Trade\SymbolInfo.mqh>

//--
class ConfirmationBase
  {
protected:
   string            m_message;
   Series            *m_series;
   CSymbolInfo       *m_symbol;

public:
   virtual bool      IsBuyValid() { return false; }
   virtual bool      IsSellValid() { return false; }
   virtual string    Message() { return "Message default"; }

   void              Init(Series *series) {m_series = series;};
   void              SetSymbol(CSymbolInfo *symbol) {m_symbol = symbol;}
  };
//--

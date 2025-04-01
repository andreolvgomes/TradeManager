//+------------------------------------------------------------------+
//|                                                    EntryBase.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EntryBase
  {
public:
   virtual bool      EntryBuy(double &price,double &sl,double &tp,datetime &expiration) { return false; }
   virtual bool      EntrySell(double &price,double &sl,double &tp,datetime &expiration) { return false; }
  };
//+------------------------------------------------------------------+

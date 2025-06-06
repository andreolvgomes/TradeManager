//+------------------------------------------------------------------+
//|                                                        Trade.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include  <Trade\Trade.mqh>

//-- Classe responsável por execução de ordens no mercado
class ManagerTrade: public CTrade
  {
private:
   CSymbolInfo       *m_symbol;          // symbol object
public:
                     ManagerTrade();

   bool              SetSymbol(CSymbolInfo *symbol);
   bool              Buy(double volume,double price,double sl,double tp,const string comment="");
   bool              Sell(double volume,double price,double sl,double tp,const string comment="");
  };
//-- ManagerTrade
ManagerTrade::ManagerTrade()
  {
  }

//-- Define o Symbol dentro desta classe em m_symbol
bool ManagerTrade::SetSymbol(CSymbolInfo *symbol)
  {
   if(symbol!=NULL)
     {
      m_symbol=symbol;
      return(true);
     }

   return(false);
  }
//-- Executa operação de Compra
bool ManagerTrade::Buy(double volume,double price,double sl,double tp,const string comment="")
  {
   double ask,stops_level;
//--- checking
   if(m_symbol==NULL)
      return(false);

   string symbol=m_symbol.Name();
   if(symbol=="")
      return(false);
//---
   ask=m_symbol.Ask();
   stops_level=m_symbol.StopsLevel()*m_symbol.Point();
   if(price!=0.0)
     {
      //--- send "BUY_STOP" order
      if(price>ask+stops_level)
         return(OrderOpen(symbol,ORDER_TYPE_BUY_STOP,volume,0.0,price,sl,tp,0,0,comment));

      //--- send "BUY_LIMIT" order
      if(price<ask-stops_level)
         return(OrderOpen(symbol,ORDER_TYPE_BUY_LIMIT,volume,0.0,price,sl,tp,0,0,comment));
     }

   return(PositionOpen(symbol,ORDER_TYPE_BUY,volume,ask,sl,tp,comment));
  }

//-- Executa operação de Venda
bool ManagerTrade::Sell(double volume,double price,double sl,double tp,const string comment="")
  {
   double bid,stops_level;

//--- checking
   if(m_symbol==NULL)
      return(false);

   string symbol=m_symbol.Name();
   if(symbol=="")
      return(false);

   bid=m_symbol.Bid();
   stops_level=m_symbol.StopsLevel()*m_symbol.Point();
   if(price!=0.0)
     {
      //--- send "SELL_LIMIT" order
      if(price>bid+stops_level)
         return(OrderOpen(symbol,ORDER_TYPE_SELL_LIMIT,volume,0.0,price,sl,tp,0,0,comment));

      //--- send "SELL_STOP" order
      if(price<bid-stops_level)
         return(OrderOpen(symbol,ORDER_TYPE_SELL_STOP,volume,0.0,price,sl,tp, 0,0,comment));
     }

   return(PositionOpen(symbol,ORDER_TYPE_SELL,volume,bid,sl,tp,comment));
  }
//+------------------------------------------------------------------+

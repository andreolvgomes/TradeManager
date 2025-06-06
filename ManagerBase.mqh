//+------------------------------------------------------------------+
//|                                                 ManagerMoney.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\PositionInfo.mqh>
#include <Trade\SymbolInfo.mqh>

//-- Classe base para implementação de novas classe de Gerenciamento de Risco
class ManagerBase
  {
public:
   ENUM_TIMEFRAMES   m_period;
   CSymbolInfo       *m_symbol;

public:
                     ManagerBase(void);

   //--
   void              InitBase(ENUM_TIMEFRAMES period, CSymbolInfo *symbol)
     {
      m_period = period;
      m_symbol=symbol;
     }
  };
//-- Construtor
void ManagerBase::ManagerBase() : m_symbol(NULL)
  {
  }
//+------------------------------------------------------------------+

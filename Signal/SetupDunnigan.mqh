//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\ManagerSignal.mqh>

//--
class SetupDunnigan
  {
public:
                     SetupDunnigan();

   bool              SetupDown();
   bool              SetupUp();
  };
//--
SetupDunnigan::SetupDunnigan()
  {
  }

//-- Verifica condições de Compra
bool SetupDunnigan::SetupDown()
  {
   return true;
  }

//-- Verifica condições de Venda
bool SetupDunnigan::SetupUp()
  {
   return true;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\ManagerSignal.mqh>
#include <TradeManager\Utility\Series.mqh>
#include <TradeManager\Utility\Functions.mqh>
#include <TradeManager\Utility\CandlePattern.mqh>

//--
class SetupDunnigan
  {
private:
   bool              m_alvo;
   bool              m_entry_confirmation;
   int               m_num_barras;
   ENUM_TIMEFRAMES   m_period;
   string            m_symbol;

   Series            m_series;
   CandlePattern     m_candle_pattern;
   Functions         m_utils;

public:
                     SetupDunnigan();
   void              Init(string symbol, ENUM_TIMEFRAMES period);
   void              SetAlvo(bool alvo) {m_alvo=alvo;}
   void              SetNumBarras(int numBarras) {m_num_barras=numBarras;}
   void              SetEntryConfirmation(bool entry_confirmation) {m_entry_confirmation = entry_confirmation;}
   bool              Sell();
   bool              Buy();
   bool              IsNewBar();
   bool              EntryConfirmation() {return m_entry_confirmation;}
  };
//+------------------------------------------------------------------+
SetupDunnigan::SetupDunnigan()
  {
   m_num_barras = 3;
   m_entry_confirmation = true;
  }
//+------------------------------------------------------------------+
void SetupDunnigan::Init(string symbol, ENUM_TIMEFRAMES period)
  {
   m_symbol = symbol;
   m_period = period;

   m_utils.Init(Symbol(), period);
   m_series.Init(Symbol(), m_period);
   m_candle_pattern.Init(Symbol(), m_period);
  }
//+------------------------------------------------------------------+
//-- Verifica condições de Compra
bool SetupDunnigan::Buy()
  {
   int index_candle=1;
   int bar_current=0;

   if(m_entry_confirmation)
     {
      if(m_utils.IsNewBar() ==false)
         return false;

      index_candle = 2;
      bar_current = 1;
     }

   if(m_candle_pattern.SequencialDown(m_num_barras, index_candle))
     {
      // gatilho de Compra:
      if(m_series.High(bar_current) > m_series.High(bar_current+1))
        {
         // desconfigurou:
         // candle gatilho rompeu a mínima do anterior
         if(m_series.Low(bar_current) < m_series.Low(bar_current+1))
            return(false);

         if(m_entry_confirmation)
           {
            for(int i=3;i<=m_num_barras+1;i++)
              {
               // candle gatilho rompeu a máxima de todos os outros
               if(m_series.High(bar_current) > m_series.High(i))
                  return(false);
              }
           }
         return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//-- Verifica condições de Venda
bool SetupDunnigan::Sell()
  {
   int index_candle=1;
   int bar_current=0;

   if(m_entry_confirmation)
     {
      if(m_utils.IsNewBar() ==false)
         return false;

      index_candle = 2;
      bar_current = 1;
     }

   if(m_candle_pattern.SequencialUp(m_num_barras, index_candle))
     {
      // gatilho de Venda
      if(m_series.Low(bar_current) < m_series.Low(bar_current+1))
        {
         // desconfigurou:
         // candle gatilho rompeu a máxima do anterior
         if(m_series.High(bar_current) > m_series.High(bar_current+1))
            return(false);

         if(m_entry_confirmation)
           {
            for(int i=3;i<=m_num_barras+1;i++)
              {
               // candle gatilho rompeu a mínima de todos os outros
               if(m_series.Low(bar_current) < m_series.Low(i))
                  return(false);
              }
           }
         return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+

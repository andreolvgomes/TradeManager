//+------------------------------------------------------------------+
//|                                               SignalDunnigan.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\ManagerSignal.mqh>
#include <TradeManager\Utility\CandlePattern.mqh>
#include <TradeManager\Utility\Functions.mqh>
#include <TradeManager\Signal\SetupDunnigan.mqh>

//-- Sinal de entrada Dunnigan
class SignalDunnigan : public ManagerSignal
  {
private:
   int               m_number_barras;
   int               m_number_barras_maior;
   bool              m_analisar1;
   bool              m_analisar2;
   int               m_amplitude_alvo;

   bool              CheckBuy15m();
   bool              CheckSell15m();

   CandlePattern     m_candler_pattern_big;
   SetupDunnigan     m_dunnigan;
   SetupDunnigan     m_dunnigan1;
   SetupDunnigan     m_dunnigan2;

protected:

public:
                     SignalDunnigan();

   void              AnalisarDunnigan(bool analisar1,bool analisar2)     {      m_analisar1 = analisar1;      m_analisar2 = analisar2;     }

   void              InitDunnigan(ENUM_TIMEFRAMES period1,ENUM_TIMEFRAMES period2);
   void              SetNumberBars(int value)   {     m_number_barras = value;      };
   void              SetAmplitudeAlvo(int value) {m_amplitude_alvo = value;}
   void              SetEntryConfirmation(bool value)   {     m_dunnigan.SetEntryConfirmation(value);      };
   void              InitMaior(ENUM_TIMEFRAMES period, int number_barras_maior);

   bool              CheckOpenBuy(double &price,double &sl,double &tp,datetime &expiration);
   bool              CheckOpenSell(double &price,double &sl,double &tp,datetime &expiration);
   bool              CheckCloseOrderSell();
   bool              CheckCloseOrderBuy();

   bool              IsSell();
   bool              IsBuy();
  };
//--
SignalDunnigan::SignalDunnigan()
  {
   m_number_barras = 3;
   m_candler_pattern_big = new CandlePattern;

   m_dunnigan = new SetupDunnigan;
   m_dunnigan1 = new SetupDunnigan;
   m_dunnigan2 = new SetupDunnigan;
  }
//--
void SignalDunnigan::InitDunnigan(ENUM_TIMEFRAMES period1,ENUM_TIMEFRAMES period2)
  {
   m_dunnigan.Init(m_symbol.Name(), m_period);
   m_dunnigan.SetNumBarras(m_number_barras);
   m_dunnigan.SetAlvo(true);

   m_dunnigan1.Init(m_symbol.Name(), period1);
   m_dunnigan1.SetEntryConfirmation(false);

   m_dunnigan2.Init(m_symbol.Name(), period2);
   m_dunnigan2.SetEntryConfirmation(false);
  }
//--
void SignalDunnigan::InitMaior(ENUM_TIMEFRAMES period, int number_barras_maior)
  {
   m_number_barras_maior = number_barras_maior;
   m_candler_pattern_big.Init(Symbol(), period);
  }
//-- Verifica condições para cancelamento de Sell Order Stop/Limit
bool SignalDunnigan::CheckCloseOrderSell()
  {
   if(m_dunnigan.EntrySellIsValidaYet())
      return true;
   return(false);
  }

//-- Verifica condições para cancelamento de Buy Order Stop/Limit
bool SignalDunnigan::CheckCloseOrderBuy()
  {
   if(m_dunnigan.EntryBuyIsValidaYet())
      return true;
   return(false);
  }
//-- Verifica condições de Compra
bool SignalDunnigan::CheckOpenBuy(double &price,double &sl,double &tp,datetime &expiration)
  {
   if(IsBuy())
     {
      if(m_dunnigan.EntryConfirmation())
        {
         price = m_symbol.NormalizePrice(m_series.High(1)+10);
         sl = m_symbol.NormalizePrice(m_series.Low(1)-20);
         tp = TakeProfit(price, false);
        }
      else
        {
         price = m_symbol.NormalizePrice(m_series.Low(1)+m_stop_loss-20);
         sl = StopLoss(price, false);
         tp = TakeProfit(price, false);
        }

      return true;
     }
   return false;
  }

//-- Verifica condições de Venda
bool SignalDunnigan::CheckOpenSell(double &price,double &sl,double &tp,datetime &expiration)
  {
   if(IsSell())
     {
      if(m_dunnigan.EntryConfirmation())
        {
         price = m_symbol.NormalizePrice(m_series.Low(1)-10);
         sl = m_symbol.NormalizePrice(m_series.High(1)+20);
         tp = TakeProfit(price, true);
        }
      else
        {
         price = m_symbol.NormalizePrice(m_series.High(1)-m_stop_loss+20);
         sl = StopLoss(price, true);
         tp = TakeProfit(price, true);
        }
      return true;
     }

   return false;
  }
//--
bool SignalDunnigan::IsBuy()
  {
   if(m_dunnigan.Buy()==false)
      return false;

   if(CheckCloseOrderBuy())
      return SetMensagem("Compra;Não é mais válida, entrada cancelada");

   if(CheckBuy15m()==false)
      return SetMensagem("Compra;Não pode abrir orders, CheckBuy15m()");

   if(m_amplitude_alvo > 0)
     {
      double ampli = m_series.DistanceBetweenHigh(1, m_number_barras);
      if(ampli < m_amplitude_alvo)
         return SetMensagem("Compra;Invalidada não atendeu alvo");
     }

   if(m_analisar1 && m_dunnigan1.Buy()==false)
      return false;

   if(m_analisar2 && m_dunnigan2.Buy()==false)
      return false;

   return true;
  }
//--
bool SignalDunnigan::IsSell()
  {
   if(m_dunnigan.Sell()==false)
      return false;

   if(this.CheckCloseOrderSell())
      return SetMensagem("Venda;Não é mais válida, entrada cancelada");

   if(this.CheckSell15m()==false)
      return SetMensagem("Venda;Não pode abrir orders, CheckSell15m()");

   if(m_amplitude_alvo > 0)
     {
      double ampli = m_series.DistanceBetweenLow(1, m_number_barras);
      if(ampli < m_amplitude_alvo)
         return SetMensagem("Venda;Invalidada não atendeu alvo");
     }

   if(m_analisar1 && m_dunnigan1.Sell()==false)
      return false;

   if(m_analisar2 && m_dunnigan2.Sell()==false)
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalDunnigan::CheckBuy15m()
  {
   if(m_number_barras_maior == 0 || m_candler_pattern_big.SequencialDown(m_number_barras_maior, 1))
      return true;
   return false;
  }
//--
bool SignalDunnigan::CheckSell15m()
  {
   if(m_number_barras_maior == 0 || m_candler_pattern_big.SequencialUp(m_number_barras_maior, 1))
      return true;
   return false;
  }
//+------------------------------------------------------------------+

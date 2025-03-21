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
#include <TradeManager\Signal\Dunnigan\SetupDunnigan.mqh>

#include <TradeManager\Signal\Dunnigan\Rules\AmplitudeRules.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\DunninganConfirmacao1Rules.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\DunninganConfirmacao2Rules.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\SequencialTimerFrameMaiorRules.mqh>

struct BotConfig
  {
   int               number_barras;
   int               number_barras_maior;
   bool              entryWithConfirmation;
   bool              analisar1;
   bool              analisar2;
   int               amplitude_alvo;
   ENUM_TIMEFRAMES   period1;
   ENUM_TIMEFRAMES   period2;
   ENUM_TIMEFRAMES   perdiodMaior;
  };

//-- Sinal de entrada Dunnigan
class SignalDunnigan : public ManagerSignal
  {
private:
   BotConfig         m_config;
   bool              CheckBuy15m();
   bool              CheckSell15m();

   CandlePattern     m_candler_pattern_big;
   SetupDunnigan     m_dunnigan;
   SetupDunnigan     m_dunnigan1;
   SetupDunnigan     m_dunnigan2;

   AmplitudeRules    *amplitudeRules;
   DunninganConfirmacao1Rules    *dunninganConfirmacao1Rules;
   DunninganConfirmacao2Rules    *dunninganConfirmacao2Rules;
   SequencialTimerFrameMaiorRules    *sequencialTimerFrameMaiorRules;

protected:

public:
                     SignalDunnigan();

   void              SetConfig(const BotConfig &config)
     {
      m_config = config;
      m_dunnigan.SetEntryConfirmation(config.entryWithConfirmation);
     };

   void              InitDunnigan();

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
   m_candler_pattern_big = new CandlePattern;

   m_dunnigan = new SetupDunnigan;
   m_dunnigan1 = new SetupDunnigan;
   m_dunnigan2 = new SetupDunnigan;

   amplitudeRules = new AmplitudeRules;
   AddRules(amplitudeRules);

   dunninganConfirmacao1Rules = new DunninganConfirmacao1Rules;
   AddRules(dunninganConfirmacao1Rules);

   dunninganConfirmacao2Rules = new DunninganConfirmacao2Rules;
   AddRules(dunninganConfirmacao2Rules);

   sequencialTimerFrameMaiorRules = new SequencialTimerFrameMaiorRules;
   AddRules(sequencialTimerFrameMaiorRules);
  }
//--
void SignalDunnigan::InitDunnigan()
  {
   m_dunnigan.Init(Symbol(), m_period);
   m_dunnigan.SetNumBarras(m_config.number_barras);
   m_dunnigan.SetAlvo(true);

   m_dunnigan1.Init(Symbol(), m_config.period1);
   m_dunnigan1.SetEntryConfirmation(false);

   m_dunnigan2.Init(Symbol(), m_config.period2);
   m_dunnigan2.SetEntryConfirmation(false);
   
   m_candler_pattern_big.Init(Symbol(), m_config.perdiodMaior);
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
   if(CheckRulesBuy() == false)
     {
      return false;
     }

   if(m_dunnigan.Buy()==false)
      return false;

   if(CheckCloseOrderBuy())
      return SetMensagem("Compra;Não é mais válida, entrada cancelada");

   if(CheckBuy15m()==false)
      return SetMensagem("Compra;Não pode abrir orders, CheckBuy15m()");

   if(m_config.amplitude_alvo > 0)
     {
      double ampli = m_series.DistanceBetweenHigh(1, m_config.number_barras);
      if(ampli < m_config.amplitude_alvo)
         return SetMensagem("Compra;Invalidada não atendeu alvo");
     }

   if(m_config.analisar1 && m_dunnigan1.Buy()==false)
      return false;

   if(m_config.analisar2 && m_dunnigan2.Buy()==false)
      return false;

   return true;
  }
//--
bool SignalDunnigan::IsSell()
  {
   if(CheckRulesSell() == false)
     {
      return false;
     }

   if(m_dunnigan.Sell()==false)
      return false;

   if(this.CheckCloseOrderSell())
      return SetMensagem("Venda;Não é mais válida, entrada cancelada");

   if(this.CheckSell15m()==false)
      return SetMensagem("Venda;Não pode abrir orders, CheckSell15m()");

   if(m_config.amplitude_alvo > 0)
     {
      double ampli = m_series.DistanceBetweenLow(1, m_config.number_barras);
      if(ampli < m_config.amplitude_alvo)
         return SetMensagem("Venda;Invalidada não atendeu alvo");
     }

   if(m_config.analisar1 && m_dunnigan1.Sell()==false)
      return false;

   if(m_config.analisar2 && m_dunnigan2.Sell()==false)
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalDunnigan::CheckBuy15m()
  {
   if(m_config.number_barras_maior == 0 || m_candler_pattern_big.SequencialDown(m_config.number_barras_maior, 1))
      return true;
   return false;
  }
//--
bool SignalDunnigan::CheckSell15m()
  {
   if(m_config.number_barras_maior == 0 || m_candler_pattern_big.SequencialUp(m_config.number_barras_maior, 1))
      return true;
   return false;
  }
//+------------------------------------------------------------------+

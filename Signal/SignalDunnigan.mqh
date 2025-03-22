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
#include <TradeManager\Signal\Dunnigan\ParamsConfig.mqh>

#include <TradeManager\Signal\Dunnigan\ParamsConfig.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\AmplitudeRules.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\DunninganConfirmacao1Rules.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\DunninganConfirmacao2Rules.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\SequencialTimerFrameMaiorRules.mqh>

//-- Sinal de entrada Dunnigan
class SignalDunnigan : public ManagerSignal
  {
private:
   bool              CheckBuy15m();
   bool              CheckSell15m();
   ParamsConfig      m_params;   
   SetupDunnigan     m_dunnigan;

protected:

public:
                     SignalDunnigan();

   void              InitDunnigan();
   void              SetParams(ParamsConfig &params) {m_params = &params;}
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
  }
//--
void SignalDunnigan::InitDunnigan()
  {
   AddRules(new AmplitudeRules(&m_params));
   AddRules(new DunninganConfirmacao1Rules(&m_params));
   AddRules(new DunninganConfirmacao2Rules(&m_params));
   AddRules(new SequencialTimerFrameMaiorRules(&m_params));

   m_dunnigan.SetEntryConfirmation(m_params.m_entryWithConfirmation);

   m_dunnigan.Init(Symbol(), m_period);
   m_dunnigan.SetNumBarras(m_params.m_number_barras);
   m_dunnigan.SetAlvo(true);   
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

   if(CheckRulesBuy() == false)
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

   if(CheckRulesSell() == false)
      return false;

   return true;
  }
//+------------------------------------------------------------------+

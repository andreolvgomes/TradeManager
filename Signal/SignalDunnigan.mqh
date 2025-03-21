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

#include <TradeManager\Signal\Dunnigan\Rules\Confirmations\AmplitudeAlvosRules.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\Confirmations\DunninganConfirmacao1Rules.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\Confirmations\DunninganConfirmacao2Rules.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\Confirmations\SequencialTimerFrameMaiorRules.mqh>

#include <TradeManager\Signal\Dunnigan\Rules\Cancellations\MovimentouAteAlvoCancel.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\Cancellations\CandleGatilhoViolouAnterioresCancel.mqh>

//-- Sinal de entrada Dunnigan
class SignalDunnigan : public ManagerSignal
  {
private:
   ParamsConfig      m_params;
   SetupDunnigan     m_dunnigan;

protected:

public:
   void              InitDunnigan();
   void              SetParams(ParamsConfig &params) {m_params = &params;}
   bool              CheckOpenBuy(double &price,double &sl,double &tp,datetime &expiration);
   bool              CheckOpenSell(double &price,double &sl,double &tp,datetime &expiration);
   bool              CheckCloseOrderSell();
   bool              CheckCloseOrderBuy();

   bool              IsSell();
   bool              IsBuy();
  };
//+------------------------------------------------------------------+
void SignalDunnigan::InitDunnigan()
  {
   AddConfirmations(new AmplitudeAlvosRules(&m_params));
   AddConfirmations(new DunninganConfirmacao1Rules(&m_params));
   AddConfirmations(new DunninganConfirmacao2Rules(&m_params));
   AddConfirmations(new SequencialTimerFrameMaiorRules(&m_params));

   AddCancellations(new MovimentouAteAlvoCancel(&m_params));
   if(m_params.m_entryWithConfirmation==false)
      AddCancellations(new CandleGatilhoViolouAnterioresCancel(&m_params));

   m_dunnigan.SetEntryConfirmation(m_params.m_entryWithConfirmation);
   m_dunnigan.Init(Symbol(), m_period);
   m_dunnigan.SetNumBarras(m_params.m_number_barras);
   m_dunnigan.SetAlvo(true);
  }
//+------------------------------------------------------------------+
//-- Verifica condições para cancelamento de Sell Order Stop/Limit
bool SignalDunnigan::CheckCloseOrderSell()
  {
   return CheckCancelSell();
  }
//+------------------------------------------------------------------+
//-- Verifica condições para cancelamento de Buy Order Stop/Limit
bool SignalDunnigan::CheckCloseOrderBuy()
  {
   return CheckCancelBuy();
  }
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
bool SignalDunnigan::IsBuy()
  {
   if(m_dunnigan.Buy()==false)
      return false;

   return CheckConfirmationsBuy();
  }
//+------------------------------------------------------------------+
bool SignalDunnigan::IsSell()
  {
   if(m_dunnigan.Sell()==false)
      return false;

   return CheckConfirmationsSell();
  }
//+------------------------------------------------------------------+

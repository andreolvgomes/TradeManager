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
#include <TradeManager\Signal\Dunnigan\Rules\Confirmations\AmplitudeDoMovimentoRules.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\Confirmations\AmplitudeDoMovimentoMaxBarsRules.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\Confirmations\AmplitudeAlvosMaxBarsRules.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\Confirmations\GatilhoViolouCandleAnteriorRules.mqh>

#include <TradeManager\Signal\Dunnigan\Rules\Cancellations\MovimentouAteAlvoCancel.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\Cancellations\CandleGatilhoViolouAnterioresCancel.mqh>

//-- Sinal de entrada Dunnigan
class SignalDunnigan : public ManagerSignal
  {
private:
   ParamsConfig      m_params;
   SetupDunnigan     m_dunnigan;

   bool              Candlebloqueado();

protected:

public:
   void              InitSignal();
   void              SetParams(ParamsConfig &params) {m_params = &params;}
   bool              CheckOpenBuy(double &price,double &sl,double &tp,datetime &expiration);
   bool              CheckOpenSell(double &price,double &sl,double &tp,datetime &expiration);
   bool              CheckCloseOrderSell();
   bool              CheckCloseOrderBuy();

   bool              IsSell();
   bool              IsBuy();
  };
//+------------------------------------------------------------------+
void SignalDunnigan::InitSignal()
  {
// confirmations
   AddConfirmations(new DunninganConfirmacao1Rules(&m_params));
   AddConfirmations(new DunninganConfirmacao2Rules(&m_params));
   AddConfirmations(new SequencialTimerFrameMaiorRules(&m_params));
   AddConfirmations(new AmplitudeDoMovimentoRules(&m_params));
   AddConfirmations(new AmplitudeAlvosRules(&m_params));
   AddConfirmations(new GatilhoViolouCandleAnteriorRules(&m_params));
//AddConfirmations(new AmplitudeDoMovimentoMaxBarsRules(&m_params));
//AddConfirmations(new AmplitudeAlvosMaxBarsRules(&m_params));

// cancelletions
   AddCancellations(new MovimentouAteAlvoCancel(&m_params));
   if(m_params.m_entryWithConfirmation==false)
      AddCancellations(new CandleGatilhoViolouAnterioresCancel(&m_params));

   m_dunnigan.Init(Symbol(), m_period);
   m_dunnigan.SetNumBarras(m_params.m_number_barras);
// não usar a análise no setup, criado uma Rule especifica para isso
   m_dunnigan.SetAnalisaViolacaoUltimoCandle(false);
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
      price = m_symbol.NormalizePrice(m_series.Low(1)+m_stop_loss-m_params.m_level_stoploss);
      sl = StopLoss(price, false);
      tp = TakeProfit(price, false);

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
      price = m_symbol.NormalizePrice(m_series.High(1)-m_stop_loss+m_params.m_level_stoploss);
      sl = StopLoss(price, true);
      tp = TakeProfit(price, true);

      return true;
     }

   return false;
  }
static datetime entrada_desconfigurada=0;
//+------------------------------------------------------------------+
bool SignalDunnigan::IsBuy()
  {
   if(Candlebloqueado())
      return false;

   if(m_dunnigan.Buy()==false)
      return false;

   bool check =  CheckConfirmationsBuy();
   if(check == false)
      entrada_desconfigurada = m_series.Time(0);
   return check;
  }
//+------------------------------------------------------------------+
bool SignalDunnigan::IsSell()
  {
   if(Candlebloqueado())
      return false;

   if(m_dunnigan.Sell()==false)
      return false;

   bool check = CheckConfirmationsSell();
   if(check == false)
      entrada_desconfigurada = m_series.Time(0);
   return check;
  }
//+------------------------------------------------------------------+
bool SignalDunnigan::Candlebloqueado()
  {
   if(entrada_desconfigurada == 0)
      return false;

   datetime current=m_series.Time(0);
   if(current==entrada_desconfigurada)
      return true;

   entrada_desconfigurada = 0;
   return false;
  }
//+------------------------------------------------------------------+

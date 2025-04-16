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

#include <TradeManager\Signal\Dunnigan\Entry\EntryBase.mqh>
#include <TradeManager\Signal\Dunnigan\Entry\EntryPullBack.mqh>
#include <TradeManager\Signal\Dunnigan\Entry\EntryBreakCandle.mqh>
#include <TradeManager\Signal\Dunnigan\Entry\EntryCandleTrigger.mqh>

#include <TradeManager\Signal\Dunnigan\Rules\Confirmations\AmplitudeAlvosRules.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\Confirmations\DunninganConfirmacao1Rules.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\Confirmations\DunninganConfirmacao2Rules.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\Confirmations\SequencialTimerFrameMaiorRules.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\Confirmations\AmplitudeDoMovimentoRules.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\Confirmations\AmplitudeDoMovimentoMaxBarsRules.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\Confirmations\AmplitudeAlvosMaxBarsRules.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\Confirmations\CandleMesmoDiaRules.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\Confirmations\CandleGatilhoRompeuOsDoisLadosRules.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\Confirmations\CandleGatilhoMaiorQueAlvoRules.mqh>

#include <TradeManager\Signal\Dunnigan\Rules\Cancellations\MovimentouAteAlvoCancel.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\Cancellations\CandleGatilhoViolouAnterioresCancel.mqh>

enum EntryType
  {
   ENTRY_NONE = 0,
   ENTRY_PULLBACK=1,
   ENTRY_BREAKOUT=2,
   ENTRY_CANDLE_TRIGGER=3,
   ENTRY_REVERSAL=4
  };

static datetime entrada_desconfigurada=0;

//-- Sinal de entrada Dunnigan
class SignalDunnigan : public ManagerSignal
  {
private:
   ParamsConfig      m_params;
   SetupDunnigan     m_dunnigan;
   EntryBase         *m_entry;
   CandlePattern     m_candle_pattern;
   EntryType         currentEntryType;

   bool              Candlebloqueado();

private:
   EntryBase*        SetEntry();

public:
   bool              m_entry_all;

   bool              isBuy;
   bool              isSell;
   void              InitSignal();
   void              SetParams(ParamsConfig &params) {m_params = &params;}
   bool              CheckOpenBuy(double &price,double &sl,double &tp,datetime &expiration);
   bool              CheckOpenSell(double &price,double &sl,double &tp,datetime &expiration);
   bool              CheckCloseOrderSell();
   bool              CheckCloseOrderBuy();
   datetime          TimeCurrentBar();
   void              GetValues(double &price, double &sl, double &tp);
   bool              IsSell();
   bool              IsBuy();
  };
//+------------------------------------------------------------------+
void SignalDunnigan::InitSignal()
  {
   currentEntryType =  ENTRY_NONE;
   m_candle_pattern.Init(Symbol(), m_params.m_period);

// regras de confirmações
   AddConfirmations(new DunninganConfirmacao1Rules(&m_params));
   AddConfirmations(new DunninganConfirmacao2Rules(&m_params));
   AddConfirmations(new SequencialTimerFrameMaiorRules(&m_params));
   AddConfirmations(new AmplitudeDoMovimentoRules(&m_params));
   AddConfirmations(new AmplitudeAlvosRules(&m_params));
   AddConfirmations(new CandleMesmoDiaRules(&m_params));
//AddConfirmations(new CandleGatilhoRompeuOsDoisLadosRules(&m_params));
   AddConfirmations(new CandleGatilhoMaiorQueAlvoRules(&m_params, GetPointer(m_series)));
//AddConfirmations(new AmplitudeDoMovimentoMaxBarsRules(&m_params));
//AddConfirmations(new AmplitudeAlvosMaxBarsRules(&m_params));

// regras de cancelamentos
   AddCancellations(new MovimentouAteAlvoCancel(&m_params));
   AddCancellations(new CandleGatilhoViolouAnterioresCancel(&m_params));

   m_dunnigan.Init(Symbol(), m_period);
   m_dunnigan.SetNumBarras(m_params.m_number_barras);
  }
//+------------------------------------------------------------------+
datetime SignalDunnigan::TimeCurrentBar()
  {
   return m_series.Time(0);
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
      return SetEntry().EntryBuy(price, sl, tp, expiration);
   return false;
  }
//+------------------------------------------------------------------+
//-- Verifica condições de Venda
bool SignalDunnigan::CheckOpenSell(double &price,double &sl,double &tp,datetime &expiration)
  {
   if(IsSell())
      return SetEntry().EntrySell(price, sl, tp, expiration);
   return false;
  }
//+------------------------------------------------------------------+
bool SignalDunnigan::IsBuy()
  {
   if(Candlebloqueado())
      return false;

   isBuy = m_dunnigan.Buy();
   if(isBuy==false)
      return false;

   bool check =  CheckConfirmationsBuy();

   if(check)
      check = PodeEntrarNovaOrdem();

   if(check == false)
      entrada_desconfigurada = m_series.Time(0);

   return check;
  }
//+------------------------------------------------------------------+
bool SignalDunnigan::IsSell()
  {
   if(Candlebloqueado())
      return false;

   isSell=m_dunnigan.Sell();
   if(isSell==false)
      return false;

   bool check = CheckConfirmationsSell();

   if(check)
      check = PodeEntrarNovaOrdem();

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
void SignalDunnigan::GetValues(double &price, double &sl, double &tp)
  {
   datetime ex;
   if(isBuy)
      m_entry.EntryBuy(price, sl, tp, ex);
   if(isSell)
      m_entry.EntryBuy(price, sl, tp, ex);
  }
//+------------------------------------------------------------------+
EntryBase* SignalDunnigan::SetEntry()
  {
   if(m_dunnigan.Rompeu_dois_lados())
     {
      if(currentEntryType != ENTRY_CANDLE_TRIGGER)
        {
         if(m_entry != NULL)
            delete m_entry;

         m_entry = new EntryCandleTrigger(GetPointer(m_series), &m_params, GetPointer(m_symbol));
         currentEntryType = ENTRY_CANDLE_TRIGGER;
        }
     }
   else
     {
      if(currentEntryType != ENTRY_PULLBACK)
        {
         if(m_entry != NULL)
            delete m_entry;

         m_entry = new EntryPullBack(GetPointer(m_series), &m_params, GetPointer(m_symbol));
         currentEntryType = ENTRY_PULLBACK;
        }
     }
   return m_entry;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                 ManageSignal.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\PositionInfo.mqh>
#include <TradeManager\Utility\Series.mqh>
#include <TradeManager\Utility\Logs.mqh>
#include <TradeManager\ManagerBase.mqh>

#include <TradeManager\Signal\Dunnigan\Rules\ConfirmationBase.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\CancellationBase.mqh>
//#include <NewRobot\Utility\Functions.mqh>

//-- Classe base para implementação de Sinais/Técnicas de Entradas
class ManagerSignal : public ManagerBase
  {
protected:
   Series            *m_series;
   double            m_stop_loss;
   double            m_take_profit;
   double            m_price_level;
   bool              m_reserve;
   string            m_mensagem;
   ConfirmationBase  *m_confirmations[];
   CancellationBase  *m_cancellations[];

public:
                     ManagerSignal();
   bool              IsNewBar();

   CLog*             Log;                 // Logging
   void              Init(ENUM_TIMEFRAMES period, CSymbolInfo *m_symbol);

   //-- funções para injetar valores p/ dentro da classe/objeto
   void              SetStopLoss(double value)     { m_stop_loss=value;       }
   void              SetTakeProfit(double value)   { m_take_profit=value;     }
   void              SetPriceLevel(double value)   { m_price_level=value;     }
   void              SetIsReserve(bool value) {this.m_reserve=value;}
   bool              SetMensagem(string mensagem);
   string            GetMensagem() {return m_mensagem; }

   //-- obtem valores definidos de Take Profit e Stop Loss
   double            TakeProfit()                  {  return(m_take_profit);  };
   double            StopLoss()                    {  return(m_stop_loss);    };

   //-- funções para checar sinal de entrada buy/sell
   //-- virtuais para serem reescritas pela nova classe de sinais/técnicas
   virtual bool      CheckOpenBuy(double &price,double &sl,double &tp,datetime &expiration)        {  return (false);   };
   virtual bool      CheckOpenSell(double &price,double &sl,double &tp,datetime &expiration)       {  return (false);   };

   //-- funções para checar sinal de cancelamento de ordens pendentes
   //-- virtuais para serem reescritas pela nova classe de sinais/técnicas
   virtual bool      CheckCloseOrderSell() {  return (false);   };
   virtual bool      CheckCloseOrderBuy()  {  return (false);   };

   void              AddConfirmations(ConfirmationBase *confirmation);
   bool              CheckConfirmationsBuy();
   bool              CheckConfirmationsSell();

   void              AddCancellations(CancellationBase *cancellation);
   bool              ManagerSignal::CheckCancelBuy();
   bool              ManagerSignal::CheckCancelSell();

   //-- função para reversão de posição
   //-- virtuais para serem reescritas pela nova classe de sinais/técnicas
   virtual bool      CheckReverseSell(double &price,double &sl,double &tp,datetime &expiration)
     {
      if(!m_reserve)
         return false;
      return (CheckOpenBuy(price,sl, tp, expiration));
     };
   virtual bool      CheckReverseBuy(double &price,double &sl,double &tp,datetime &expiration)
     {
      if(!m_reserve)
         return false;
      return (CheckOpenSell(price, sl, tp, expiration));
     };

protected:
   double            TakeProfit(double price, bool isSell);
   double            StopLoss(double price, bool isSell);
   //Functions         *function;
  };

//--Construtor
ManagerSignal::ManagerSignal()
  {
   Log=CLog::GetLog();
   m_series = new Series;
   m_stop_loss = 0;
   m_take_profit = 0;
   m_reserve = true;
  }
//-- Inicialização de objetos default da classe
void ManagerSignal::Init(ENUM_TIMEFRAMES period, CSymbolInfo *symbol)
  {
   m_series.Init(symbol.Name(), period);
   InitBase(period, symbol);
  }
//-- Cálcula preço para posicionamento do Take Profit seguindo o que foi definido pela função
//-- SetTakeProfit(double value)
double ManagerSignal::TakeProfit(double price, bool isSell)
  {
   if(m_take_profit==0)
      return 0;

   if(isSell)
      return price-m_take_profit;
   return price+m_take_profit;
  }
//-- Cálcula preço para posicionamento do Stop Loss seguindo o que foi definido pela função
//-- SetStopLoss(double value)
double ManagerSignal::StopLoss(double price, bool isSell)
  {
   if(m_stop_loss== 0)
      return 0;
   if(isSell)
      return price+m_stop_loss;
   return price-m_stop_loss;
  }
//--
//+------------------------------------------------------------------+
//--
static datetime last_time_=0;
//--
bool ManagerSignal::IsNewBar()
  {
//--- memorize the time of opening of the last bar in the static variable
//--- current time
   datetime lastbar_timed=SeriesInfoInteger(this.m_symbol.Name(),m_period,SERIES_LASTBAR_DATE);
//--- if it is the first call of the function
   if(last_time_==0)
     {
      //--- set the time and exit
      last_time_=lastbar_timed;
      return(false);
     }
//--- if the time differs
   if(last_time_!=lastbar_timed)
     {
      //--- memorize the time and return true
      last_time_=lastbar_timed;
      return(true);
     }
//--- if we passed to this line, then the bar is not new; return false
   return(false);
  }
//+------------------------------------------------------------------+
bool ManagerSignal::SetMensagem(string mensagem)
  {
   datetime barCurrent = m_series.Time(0);
   string formattedTime = TimeToString(barCurrent, TIME_DATE|TIME_MINUTES);
   m_mensagem= "Candle: " + formattedTime + " => "+mensagem;
   return false;
  }
//+------------------------------------------------------------------+
void ManagerSignal::AddConfirmations(ConfirmationBase *confirmation)
  {
   confirmation.Init(m_series);
   int size = ArraySize(m_confirmations);
   ArrayResize(m_confirmations, size + 1);
   m_confirmations[size] = confirmation;
  }
//+------------------------------------------------------------------+
bool ManagerSignal::CheckConfirmationsBuy()
  {
   for(int i = 0; i < ArraySize(m_confirmations); i++)
     {
      if(!m_confirmations[i].IsBuyValid())
         return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
bool ManagerSignal::CheckConfirmationsSell()
  {
   for(int i = 0; i < ArraySize(m_confirmations); i++)
     {
      if(!m_confirmations[i].IsSellValid())
         return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
void ManagerSignal::AddCancellations(CancellationBase *cancellation)
  {
   cancellation.Init(m_series);
   int size = ArraySize(m_cancellations);
   ArrayResize(m_cancellations, size + 1);
   m_cancellations[size] = cancellation;
  }
//+------------------------------------------------------------------+
bool ManagerSignal::CheckCancelBuy()
  {
   for(int i = 0; i < ArraySize(m_cancellations); i++)
     {
      if(m_cancellations[i].IsCancelBuy())
         return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
bool ManagerSignal::CheckCancelSell()
  {
   for(int i = 0; i < ArraySize(m_cancellations); i++)
     {
      if(m_cancellations[i].IsCancelSell())
         return true;
     }
   return false;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                 ManageSignal.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\OrderInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <TradeManager\Utility\Series.mqh>
#include <TradeManager\Utility\Logs.mqh>
#include <TradeManager\ManagerBase.mqh>
#include <Arrays/ArrayObj.mqh>
#include <Arrays/ArrayString.mqh>

#include <TradeManager\Signal\Dunnigan\Rules\ConfirmationBase.mqh>
#include <TradeManager\Signal\Dunnigan\Rules\CancellationBase.mqh>
//#include <NewRobot\Utility\Functions.mqh>

//-- Classe base para implementação de Sinais/Técnicas de Entradas
class ManagerSignal : public ManagerBase
  {
public:
   Series            *m_series;
protected:
   COrderInfo        m_order;
   double            m_stop_loss;
   double            m_take_profit;
   double            m_price_level;
   bool              m_reserve;
   string            m_mensagem;
   ConfirmationBase  *m_confirmations[];
   CancellationBase  *m_cancellations[];
   bool              order_cancelled;
   int               m_minutes_last_operation;
   bool              IsNewBar();

public:
                     ManagerSignal();

   CLog*             Log;                 // Logging
   void              Init(ENUM_TIMEFRAMES period, CSymbolInfo *m_symbol, COrderInfo &order);

   //-- funções para injetar valores p/ dentro da classe/objeto
   void              SetStopLoss(double value)     { m_stop_loss=value;       }
   void              SetTakeProfit(double value)   { m_take_profit=value;     }
   void              SetPriceLevel(double value)   { m_price_level=value;     }
   void              SetIsReserve(bool value) {this.m_reserve=value;}
   bool              SetMensagem(string mensagem);
   string            GetMensagem() {return m_mensagem; }
   void              SetMinutesLastOperation(int value) {m_minutes_last_operation = value;}

   //-- obtem valores definidos de Take Profit e Stop Loss
   double            TakeProfit()                  {  return(m_take_profit);  };
   double            StopLoss()                    {  return(m_stop_loss);    };

   virtual void      InitSignal() {};

   virtual bool      CheckOpenBuy(double &price,double &sl,double &tp,datetime &expiration)        {  return (false);   };
   virtual bool      CheckOpenSell(double &price,double &sl,double &tp,datetime &expiration)       {  return (false);   };

   bool              CheckSignalBuy(double &price,double &sl,double &tp,datetime &expiration);
   bool              CheckSignalSell(double &price,double &sl,double &tp,datetime &expiration);

   virtual bool      CheckCloseOrderSell() {  return (false);   };
   virtual bool      CheckCloseOrderBuy()  {  return (false);   };

   bool              CheckDeleteOrderSell();
   bool              CheckDeleteOrderBuy();

   void              AddConfirmations(ConfirmationBase *confirmation);
   bool              CheckConfirmationsBuy();
   void              MessagesConfirmationsBuy(CArrayString &mensagens);
   bool              CheckConfirmationsSell();
   void              MessagesConfirmationsSell(CArrayString &mensagens);

   void              AddCancellations(CancellationBase *cancellation);
   bool              CheckCancelBuy();
   bool              CheckCancelSell();

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
   bool              PodeEntrarNovaOrdem();
   //Functions         *function;

private:
   bool              IsNewBarOrderCancelled();
   datetime          GetUltimaPosicaoAberta();
   bool              Timer(datetime ultima);
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
void ManagerSignal::Init(ENUM_TIMEFRAMES period, CSymbolInfo *symbol, COrderInfo &order)
  {
   m_order = &order;
   m_series.Init(symbol.Name(), period);
   InitBase(period, symbol);

   InitSignal();
   for(int i = 0; i < ArraySize(m_cancellations); i++)
      m_cancellations[i].SetSymbol(GetPointer(m_symbol));
   for(int i = 0; i < ArraySize(m_confirmations); i++)
      m_confirmations[i].SetSymbol(GetPointer(m_symbol));
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
   CArrayString mensagens;
   MessagesConfirmationsBuy(&mensagens);
   printf("---Buy;Candle:"+m_series.Time(0)+";M"+m_period+"--------------------------------");

   if(mensagens.Total() > 0)
     {
      for(int i=0;i<mensagens.Total();i++)
         printf(mensagens.At(i));
     }
   else
     {
      printf("Regras: Atendidas!");
     }

   return mensagens.Total() == 0;
  }
//+------------------------------------------------------------------+
void ManagerSignal::MessagesConfirmationsBuy(CArrayString &mensagens)
  {
   mensagens.Clear();
   for(int i = 0; i < ArraySize(m_confirmations); i++)
     {
      if(!m_confirmations[i].IsBuyValid())
         mensagens.Add(m_confirmations[i].Message());
     }
  }
//+------------------------------------------------------------------+
bool ManagerSignal::CheckConfirmationsSell()
  {
   CArrayString mensagens;
   MessagesConfirmationsSell(&mensagens);
   printf("---Sell;Candle:"+m_series.Time(0)+";M"+m_period+"--------------------------------");
   if(mensagens.Total() > 0)
     {
      for(int i=0;i<mensagens.Total();i++)
         printf(mensagens.At(i));
     }
   else
     {
      printf("Regras: Atendidas!");
     }
   return mensagens.Total() == 0;
  }
//+------------------------------------------------------------------+
void ManagerSignal::MessagesConfirmationsSell(CArrayString &mensagens)
  {
   mensagens.Clear();
   for(int i = 0; i < ArraySize(m_confirmations); i++)
     {
      if(!m_confirmations[i].IsSellValid())
         mensagens.Add(m_confirmations[i].Message());
     }
  }
//+------------------------------------------------------------------+
void ManagerSignal::AddCancellations(CancellationBase *cancellation)
  {
   cancellation.Init(m_series, &m_order);
   int size = ArraySize(m_cancellations);
   ArrayResize(m_cancellations, size + 1);
   m_cancellations[size] = cancellation;
  }
//+------------------------------------------------------------------+
bool ManagerSignal::CheckCancelBuy()
  {
   CArrayString mensagens;
   for(int i = 0; i < ArraySize(m_cancellations); i++)
     {
      if(m_cancellations[i].IsCancelBuy())
         mensagens.Add(m_cancellations[i].Message());
     }
   if(mensagens.Total() > 0)
     {
      printf("---Sell;Cancel;Candle:"+m_series.Time(0)+"--------------------------------");
      for(int i=0;i<mensagens.Total();i++)
         printf(mensagens.At(i));
      printf("--------------------------------------------------------------");

      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
bool ManagerSignal::CheckCancelSell()
  {
   CArrayString mensagens;
   for(int i = 0; i < ArraySize(m_cancellations); i++)
     {
      if(m_cancellations[i].IsCancelSell())
         mensagens.Add(m_cancellations[i].Message());
     }
   if(mensagens.Total() > 0)
     {
      printf("---Buy;Cancel;Candle:"+m_series.Time(0)+"--------------------------------");
      for(int i=0;i<mensagens.Total();i++)
         printf(mensagens.At(i));
      printf("--------------------------------------------------------------");

      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
bool ManagerSignal::CheckDeleteOrderSell()
  {
   order_cancelled = CheckCloseOrderSell();
   return order_cancelled;
  }
//+------------------------------------------------------------------+
bool ManagerSignal::CheckDeleteOrderBuy()
  {
   order_cancelled = CheckCloseOrderBuy();
   return order_cancelled;
  }
//+------------------------------------------------------------------+
bool ManagerSignal::CheckSignalBuy(double &price,double &sl,double &tp,datetime &expiration)
  {
   if(order_cancelled)
     {
      if(IsNewBar())
         order_cancelled = false;
      else
         return false;
     }

   if(CheckOpenBuy(price, sl, tp, expiration))
      return PodeEntrarNovaOrdem();
   return false;
  }
//+------------------------------------------------------------------+
bool ManagerSignal::CheckSignalSell(double &price,double &sl,double &tp,datetime &expiration)
  {
   if(order_cancelled)
     {
      if(IsNewBar())
         order_cancelled = false;
      else
         return false;
     }

   if(CheckOpenSell(price, sl, tp, expiration))
      return PodeEntrarNovaOrdem();
   return false;
  }
//+------------------------------------------------------------------+
static datetime lastBarTime = 0; // Armazena o tempo da última barra processada
bool ManagerSignal::IsNewBarOrderCancelled()
  {
//--- memorize the time of opening of the last bar in the static variable
//--- current time
   datetime lastbar_timed=SeriesInfoInteger(this.m_symbol.Name(),m_period,SERIES_LASTBAR_DATE);
//--- if it is the first call of the function
   if(lastBarTime==0)
     {
      //--- set the time and exit
      lastBarTime=lastbar_timed;
      return(false);
     }
//--- if the time differs
   if(lastBarTime!=lastbar_timed)
     {
      //--- memorize the time and return true
      lastBarTime=lastbar_timed;
      return(true);
     }
//--- if we passed to this line, then the bar is not new; return false
   return(false);
  }
//+------------------------------------------------------------------+
datetime ManagerSignal::GetUltimaPosicaoAberta()
  {
   datetime ultimaAbertura = 0;

   int total = HistoryDealsTotal();
   for(int i = total - 1; i >= 0; i--)
     {
      ulong ticket = HistoryDealGetTicket(i);

      if(HistoryDealGetString(ticket, DEAL_SYMBOL) !=m_symbol.Name())
         continue;

      ulong entryType = HistoryDealGetInteger(ticket, DEAL_ENTRY);

      // considera apenas as ordens de entrada (não encerramento)
      if(entryType == DEAL_ENTRY_IN)
        {
         ultimaAbertura = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
         break;
        }
     }

   return ultimaAbertura;
  }
//+------------------------------------------------------------------+
static datetime lastUltimaPosicaoAberta1 = 0;
bool ManagerSignal::PodeEntrarNovaOrdem()
  {
   if(m_minutes_last_operation == 0)
      return true;

   if(lastUltimaPosicaoAberta1 != 0 && Timer(lastUltimaPosicaoAberta1)==false)
      return false;

   lastUltimaPosicaoAberta1 = GetUltimaPosicaoAberta();
   if(lastUltimaPosicaoAberta1 == 0)
      return true;

   return Timer(lastUltimaPosicaoAberta1);
  }
//+------------------------------------------------------------------+
bool ManagerSignal::Timer(datetime ultima)
  {
   datetime agora = TimeCurrent();
   return (agora - ultima) >= (m_minutes_last_operation * 60);
  }
//+------------------------------------------------------------------+

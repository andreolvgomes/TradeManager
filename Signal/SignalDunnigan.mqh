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

//-- Sinal de entrada Dunnigan
class SignalDunnigan : public ManagerSignal
  {
private:
   int               m_number_barras;
   int               m_number_barras_maior;

   bool              CheckBuy15m();
   bool              CheckSell15m();
   CandlePattern     candlePattern;

protected:
   Series            m_series_m30;

public:
                     SignalDunnigan();

   void              SetNumberBars(int value)   {     m_number_barras = value;      };
   void              InitMaior(ENUM_TIMEFRAMES period, int number_barras_maior);
   bool              CheckOpenBuy(double &price,double &sl,double &tp,datetime &expiration);
   bool              CheckOpenSell(double &price,double &sl,double &tp,datetime &expiration);
   bool              CheckCloseOrderSell();
   bool              CheckCloseOrderBuy();
  };
//--
SignalDunnigan::SignalDunnigan()
  {
   m_number_barras = 3;
   m_series_m30 = new Series;
   candlePattern = new CandlePattern;
  }
//--
void SignalDunnigan::InitMaior(ENUM_TIMEFRAMES period, int number_barras_maior)
  {
   m_number_barras_maior = number_barras_maior;
   CSymbolInfo *symbol=new CSymbolInfo;
   symbol.Name(Symbol());
   m_series_m30.Init(symbol.Name(), period);
  }
//-- Verifica condições para cancelamento de Sell Order Stop/Limit
bool SignalDunnigan::CheckCloseOrderSell()
  {
   for(int i=this.m_number_barras;i>=2;i--)
     {
      if(m_series.Low(0) < m_series.Low(i))
         return(true);
     }
   return(false);
  }

//-- Verifica condições para cancelamento de Buy Order Stop/Limit
bool SignalDunnigan::CheckCloseOrderBuy()
  {
   for(int i=this.m_number_barras;i>=2;i--)
     {
      if(m_series.High(0) > m_series.High(i))
         return(true);
     }
   return(false);
  }
//-- Verifica condições de Compra
bool SignalDunnigan::CheckOpenBuy(double &price,double &sl,double &tp,datetime &expiration)
  {
   int index_candle = 1;
   int bar_current = 0;
   bool apos= false;

   if(apos)
     {
      if(IsNewBar() ==false)
         return false;
      index_candle=2;
      bar_current=1;
     }

// candle atual já rompeu a mínima do anterior
   if(m_series.Low(bar_current) < m_series.Low(bar_current+1))
      return(false);

// candle atual ainda não rompeu a máxima do anterior
   if(m_series.High(bar_current) < m_series.High(bar_current+1))
      return(false);

   if(candlePattern.SequencialDown(m_number_barras, index_candle))
     {
      if(this.CheckCloseOrderBuy())
        {
         Print("Não pode abrir orders, CheckCloseOrderBuy()");
         return(false);
        }
      if(this.CheckBuy15m()==false)
        {
         Print("Não pode abrir orders, CheckBuy15m()");
         return(false);
        }
      //price = m_symbol.NormalizePrice(m_series.High(1)+m_price_level);
      //price = m_symbol.NormalizePrice(m_series.Low(1)+m_stop_loss-20);
      price = m_symbol.Ask()-10;
      sl = StopLoss(price, false);
      tp = TakeProfit(price, false);
      return true;
     }
   return false;
  }

//-- Verifica condições de Venda
bool SignalDunnigan::CheckOpenSell(double &price,double &sl,double &tp,datetime &expiration)
  {
   int quantity= 0;
   int index_candle = 1;
   int bar_current = 0;
   bool apos = false;

   if(apos)
     {
      if(IsNewBar() ==false)
         return false;
      index_candle=2;
      bar_current=1;
     }

// candle atual já rompeu a máxima do anterior, cancela
   if(m_series.High(bar_current) > m_series.High(bar_current+1))
      return(false);

// candle corrente ainda não rompeu mínima do anterior, cancela
   if(m_series.Low(bar_current) > m_series.Low(bar_current+1))
      return(false);

   if(candlePattern.SequencialUp(m_number_barras, index_candle))
     {
      if(this.CheckCloseOrderSell())
        {
         Print("Não pode abrir orders, CheckCloseOrderSell()");
         return(false);
        }
      if(this.CheckSell15m()==false)
        {
         Print("Não pode abrir orders, CheckSell15m()");
         return(false);
        }
      //price = m_symbol.NormalizePrice(m_series.Low(1)-m_price_level);
      //price = m_symbol.NormalizePrice(m_series.High(1)-m_stop_loss+20);
      price = m_symbol.Bid()+10;
      sl = StopLoss(price, true);
      tp = TakeProfit(price, true);
      return true;
     }

   return false;
  }
//--
bool SignalDunnigan::CheckBuy15m()
  {
   if(m_number_barras_maior == 0)
      return true;

   int quantity = 0;
   int index_candle = 1;

//-- vamos analisar 6 candles a partir do index 1, ou seja, a partir candle anterior
   for(int i=0; i<6; i++)
     {
      if(m_series_m30.Low(index_candle)<m_series_m30.Low(index_candle+1)&& m_series_m30.High(index_candle)<m_series_m30.High(index_candle+1))
         quantity++;
      else
         break;
      index_candle++;
     }

   quantity++;//-- incrementa mais, pois o primeiro candle da sequencia também deve ser levado em consideração

//-- agora verifica se a quantidade de candles identificados no FOR é maior ou igual a quantidade esperada
   if(quantity>=m_number_barras_maior)
      return(true);
   return(false);
  }
//--
bool SignalDunnigan::CheckSell15m()
  {
   if(m_number_barras_maior == 0)
      return true;

   int quantity= 0;
   int index_candle = 1;

   for(int i=0; i<=6; i++)
     {
      if(m_series_m30.Low(index_candle)>m_series_m30.Low(index_candle+1)&& m_series_m30.High(index_candle)>m_series_m30.High(index_candle+1))
         quantity++;
      else
         break;
      index_candle++;
     }

   quantity++;//-- incrementa mais, pois o primeiro candle da sequencia também deve ser levado em consideração

//-- agora verifica se a quantidade de candles identificados no FOR é maior ou igual a quantidade esperada
   if(quantity>=m_number_barras_maior)
      return(true);
   return(false);
  }

//+------------------------------------------------------------------+

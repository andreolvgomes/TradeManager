//+------------------------------------------------------------------+
//|                                               SignalDunnigan.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\ManagerSignal.mqh>

//-- Sinal de entrada Dunnigan
class SignalDunnigan : public ManagerSignal
  {
private:
   int               m_number_barras;
   bool              CheckBuy15m();
   bool              CheckSell15m();

protected:
   Series            m_series_m30;

public:
                     SignalDunnigan();

   void              SetNumberBars(int value)   {     m_number_barras = value;      };
   void              Init30m();
   bool              CheckOpenBuy(double &price,double &sl,double &tp,datetime &expiration);
   bool              CheckOpenSell(double &price,double &sl,double &tp,datetime &expiration);
   bool              CheckCloseOrderSell();
   bool              CheckCloseOrderBuy();

  };
//--
SignalDunnigan::SignalDunnigan()
  {
   this.m_number_barras = 3;
   this.m_series_m30 = new Series;
  }
//--
void SignalDunnigan::Init30m()
  {
   CSymbolInfo *symbol=new CSymbolInfo;
   symbol.Name(Symbol());
   m_series_m30.Init(symbol.Name(), PERIOD_M30);
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
   int quantity = 0;
   int index_candle = 1;

// candle atual já rompeu a mínima do anterior
   if(m_series.Low(0) < m_series.Low(1))
      return(false);

// candle atual ainda não rompeu a máxima do anterior
   if(m_series.High(0) < m_series.High(1))
      return(false);

//-- vamos analisar 6 candles a partir do index 1, ou seja, a partir candle anterior
   for(int i=0; i<6; i++)
     {
      if(m_series.Low(index_candle)<m_series.Low(index_candle+1)&& m_series.High(index_candle)<m_series.High(index_candle+1))
         quantity++;
      else
         break;
      index_candle++;
     }

   quantity++;//-- incrementa mais, pois o primeiro candle da sequencia também deve ser levado em consideração

//-- agora verifica se a quantidade de candles identificados no FOR é maior ou igual a quantidade esperada
   if(quantity>=m_number_barras)
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
      price = m_symbol.NormalizePrice(m_series.Low(1)+m_stop_loss-20);
      sl = StopLoss(price, false);
      tp = TakeProfit(price, false);
      return true;
     }
   return(false);
  }

//-- Verifica condições de Venda
bool SignalDunnigan::CheckOpenSell(double &price,double &sl,double &tp,datetime &expiration)
  {
   int quantity= 0;
   int index_candle = 1;

// candle atual já rompeu a máxima do anterior, cancela
   if(m_series.High(0) > m_series.High(1))
      return(false);

// candle corrente ainda não rompeu mínima do anterior, cancela
   if(m_series.Low(0) > m_series.Low(1))
      return(false);

//-- vamos analisar 6 candles a partir do index 1, ou seja, a partir candle anterior
   for(int i=0; i<=6; i++)
     {
      if(m_series.Low(index_candle)>m_series.Low(index_candle+1)&& m_series.High(index_candle)>m_series.High(index_candle+1))
         quantity++;
      else
         break;
      index_candle++;
     }

   quantity++;//-- incrementa mais, pois o primeiro candle da sequencia também deve ser levado em consideração

//-- agora verifica se a quantidade de candles identificados no FOR é maior ou igual a quantidade esperada
   if(quantity>=m_number_barras)
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
      price = m_symbol.NormalizePrice(m_series.High(1)-m_stop_loss+20);
      sl = StopLoss(price, true);
      tp = TakeProfit(price, true);
      return true;
     }
   return(false);
  }
//--
bool SignalDunnigan::CheckBuy15m()
  {
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
   if(quantity>=3)
      return(true);
   return(false);
  }
//--
bool SignalDunnigan::CheckSell15m()
  {
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
   if(quantity>=3)
      return(true);
   return(false);
  }

//+------------------------------------------------------------------+

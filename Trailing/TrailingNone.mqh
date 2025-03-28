//+------------------------------------------------------------------+
//|                                                  TralingNone.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\ManagerTrailing.mqh>

//-
class TrailingNone:public ManagerTrailing
  {
private:
   double            m_trai_level_pc_from_sl;
   double            m_trai_step;
   double            m_proteger_level;
   double            m_proteger_stop_gain;

public:
                     TrailingNone();
                    ~TrailingNone();

   void              SetTrailing(double level_pc_from_sl, double step) { m_trai_level_pc_from_sl = level_pc_from_sl; m_trai_step= step;};
   void              SetProteger(double level, double stopgain) {m_proteger_level = level; m_proteger_stop_gain = stopgain;};

   bool              CheckTrailingStopBuy(CPositionInfo *position,double &sl,double &tp);
   bool              CheckTrailingStopSell(CPositionInfo *position,double &sl,double &tp);

private:
   bool              ProtectPosition(CPositionInfo *position);

  };
TrailingNone::TrailingNone()
  {
  }
TrailingNone::~TrailingNone()
  {
  }
//--
bool TrailingNone::CheckTrailingStopBuy(CPositionInfo *position,double &sl,double &tp)
  {
   double profit=AccountInfoDouble(ACCOUNT_PROFIT);
   if(profit > 0)
     {
      double point=(profit/0.2)/position.Volume();
      //-- check se stop ainda tá abaixo do preço de entrada
      if(position.StopLoss() < position.PriceOpen())
        {
         if(ProtectPosition(position))
           {
            sl = position.PriceOpen()+m_proteger_stop_gain;
            return true;
           }
        }
      else //-- stop acima do preço de entrada, quer dizer que o primeiro trailing já foi feito
        {
         if(m_trai_level_pc_from_sl <= 0 && m_trai_step < 0)
            return(false);

         double diff =MathAbs(position.PriceCurrent() -position.StopLoss());
         if(diff >= m_trai_level_pc_from_sl)
           {
            sl = position.StopLoss()+m_trai_step;
            return true;
           }
        }
     }
   return false;
  }
//--
bool TrailingNone::CheckTrailingStopSell(CPositionInfo *position,double &sl,double &tp)
  {
//return false;

   double profit=AccountInfoDouble(ACCOUNT_PROFIT);
   if(profit > 0)
     {
      double p = m_symbol.Point();
      double point=(profit/0.2)/position.Volume();
      //-- check se stop ainda tá abaixo do preço de entrada
      if(position.StopLoss() > position.PriceOpen())
        {
         if(ProtectPosition(position))
           {
            //-- protege 10 pontos
            sl = position.PriceOpen()-m_proteger_stop_gain;
            return true;
           }
        }
      else //-- stop acima do preço de entrada, quer dizer que o primeiro trailing já foi feito
        {
         if(m_trai_level_pc_from_sl <= 0 && m_trai_step < 0)
            return(false);

         double diff =MathAbs(position.PriceCurrent() -position.StopLoss());
         if(diff >= m_trai_level_pc_from_sl)
           {
            sl = position.StopLoss()-m_trai_step;
            return true;
           }
        }
     }
   return false;
  }
//--
bool TrailingNone::ProtectPosition(CPositionInfo *position)
  {
//int minute = MathAbs(position.Time() - TimeCurrent())/60;
//if(minute >= 9)
// return(true);

   if(m_proteger_level <= 0 && m_proteger_stop_gain <= 0)
      return(false);

   double diff =MathAbs(position.PriceOpen() -position.PriceCurrent());
   if(diff >= m_proteger_level)
      return(true);

   return(false);
  }
//+------------------------------------------------------------------+

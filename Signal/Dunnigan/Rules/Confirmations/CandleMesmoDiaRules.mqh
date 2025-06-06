//+------------------------------------------------------------------+
//|                               CandleMesmoDiaRules.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\Signal\Dunnigan\Rules\ConfirmationBase.mqh>
#include <TradeManager\Signal\Dunnigan\ParamsConfig.mqh>
#include <TradeManager\Utility\CandlePattern.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CandleMesmoDiaRules : public ConfirmationBase
  {
private:
   ParamsConfig      m_params;

public:
                     CandleMesmoDiaRules(ParamsConfig &params);

public:
   bool              IsBuyValid();
   bool              IsSellValid();
   string            Message() {return "Candle não são todos do dia atual";};
  };
//--
CandleMesmoDiaRules::CandleMesmoDiaRules(ParamsConfig &params)
  {
   m_params  = &params;
  }
//--
bool CandleMesmoDiaRules::IsBuyValid()
  {
   datetime lasBar = m_series.Time(m_params.m_number_barras);
   datetime dayCurrent = TimeCurrent();
   if(IsSameDate(lasBar, dayCurrent))
      return true;
   return false;
  }
//--
bool CandleMesmoDiaRules::IsSellValid()
  {
   datetime lasBar = m_series.Time(m_params.m_number_barras);
   datetime dayCurrent = TimeCurrent();
   if(IsSameDate(lasBar, dayCurrent))
      return true;
   return false;
  }
//+------------------------------------------------------------------+
bool IsSameDate(datetime t1, datetime t2)
  {
   MqlDateTime dt1, dt2;
   TimeToStruct(t1, dt1);
   TimeToStruct(t2, dt2);

   return (dt1.year == dt2.year && dt1.mon == dt2.mon && dt1.day == dt2.day);
  }
//+------------------------------------------------------------------+

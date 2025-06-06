//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <TradeManager\Utility\Series.mqh>
#include <..\..\..\Include\Indicators\Trend.mqh>
//+------------------------------------------------------------------+
//| enumerators                                                      |
//+------------------------------------------------------------------+
enum ENUM_CANDLE_PATTERNS  // candlestick patterns
  {
   CANDLE_PATTERN_THREE_BLACK_CROWS     = 1,
   CANDLE_PATTERN_THREE_WHITE_SOLDIERS  = 2,
   CANDLE_PATTERN_DARK_CLOUD_COVER      = 3,
   CANDLE_PATTERN_PIERCING_LINE         = 4,
   CANDLE_PATTERN_MORNING_DOJI          = 5,
   CANDLE_PATTERN_EVENING_DOJI          = 6,
   CANDLE_PATTERN_BEARISH_ENGULFING     = 7,
   CANDLE_PATTERN_BULLISH_ENGULFING     = 8,
   CANDLE_PATTERN_EVENING_STAR          = 9,
   CANDLE_PATTERN_MORNING_STAR          = 10,
   CANDLE_PATTERN_HAMMER                = 11,
   CANDLE_PATTERN_HANGING_MAN           = 12,
   CANDLE_PATTERN_BEARISH_HARAMI        = 13,
   CANDLE_PATTERN_BULLISH_HARAMI        = 14,
   CANDLE_PATTERN_BEARISH_MEETING_LINES = 15,
   CANDLE_PATTERN_BULLISH_MEETING_LINES = 16
  };
//+------------------------------------------------------------------+
//| CandlePattern class.                                            |
//| Derived from CExpertSignal class.                                |
//+------------------------------------------------------------------+
class CandlePattern //: public CExpertSignal
  {
protected:
   //--- indicators
   CiMA              m_MA;
   //--- input parameters
   int               m_ma_period;
   Series            m_series;
   ENUM_TIMEFRAMES   m_timeframe;
   string            m_symbol;

public:
   //--- class constructor
                     CandlePattern();
   //--- input parameters initialization methods
   void              MAPeriod(int period) { m_ma_period=period;                 }
   //--- initialization
   //--- method for checking of a certiain candlestick pattern
   bool              CheckCandlestickPattern(ENUM_CANDLE_PATTERNS CandlePattern);
   //--- methods for checking of bullish/bearish candlestick pattern
   bool              CheckPatternAllBullish();
   bool              CheckPatternAllBearish();
   void              Init(string symbol, ENUM_TIMEFRAMES timeframe);

   bool              SequencialUp(int m_number_barras, int indexStart);
   bool              SequencialDown(int m_number_barras, int indexStart);
   int               NumSequencialDown(int indexStart);
   int               NumSequencialUp(int indexStart);
   int               HighLow(int indexStart);
   int               LowHigh(int indexStart);

public:
   //--- indicators initialization methods
   bool              InitMA();

   //--- methods, used for check of the candlestick pattern formation
   double            AvgBody(int ind);
   double            MA(int ind)                 { return(m_MA.Main(ind));             }
   double            Open(int ind)               { return(m_series.Open(ind));        }
   double            High(int ind)               { return(m_series.High(ind));        }
   double            Low(int ind)                { return(m_series.Low(ind));         }
   double            Close(int ind)              { return(m_series.Close(ind));       }
   double            CloseAvg(int ind)           { return(MA(ind));                    }
   double            MidPoint(int ind)           { return(0.5*(m_series.High(ind)+m_series.Low(ind)));   }
   double            MidOpenClose(int ind)       { return(0.5*(m_series.Open(ind)+m_series.Close(ind))); }

   //--- methods for checking of candlestick patterns
   bool              CheckPatternThreeBlackCrows();
   bool              CheckPatternThreeWhiteSoldiers();
   bool              CheckPatternDarkCloudCover();
   bool              CheckPatternPiercingLine();

   bool              CheckPatternMorningDoji();
   bool              CheckPatternEveningDoji();

   bool              CheckPatternBearishEngulfing();
   bool              CheckPatternBullishEngulfing();

   bool              CheckPatternEveningStar();
   bool              CheckPatternMorningStar();

   bool              CheckPatternHammer();
   bool              CheckPatternHangingMan();

   bool              CheckPatternBearishHarami();
   bool              CheckPatternBullishHarami();

   bool              CheckPatternBearishMeetingLines();
   bool              CheckPatternBullishMeetingLines();

   bool              PinbarUpperWick(int index);
   bool              PinbarLowerWick(int index);
  };
//+------------------------------------------------------------------+
//| CandlePattern class constructor.                                |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CandlePattern::CandlePattern()
  {
//--- set default inputs
   m_ma_period=20;
  }
//+------------------------------------------------------------------+
void CandlePattern::Init(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   m_symbol = symbol;
   m_timeframe = timeframe;
   m_series.Init(symbol, timeframe);
   InitMA();
  }
//+------------------------------------------------------------------+
//| Create MA indicators.                                            |
//| INPUT:  indicators -pointer of indicator collection.             |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CandlePattern::InitMA()
  {
//--- initialize MA indicator
   if(!m_MA.Create(m_symbol,m_timeframe,m_ma_period,0,MODE_SMA,PRICE_CLOSE))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
//--- resize MA buffer
   m_MA.BufferResize(50);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
bool CandlePattern::SequencialUp(int m_number_barras, int indexStart)
  {
   int  quantity = NumSequencialUp(indexStart);
   if(quantity>=m_number_barras)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
int CandlePattern::NumSequencialUp(int indexStart)
  {
   int index_candle = indexStart;
   int quantity= 0;

   for(int i=0; i<=6; i++)
     {
      if(m_series.Low(index_candle)>m_series.Low(index_candle+1)&& m_series.High(index_candle)>m_series.High(index_candle+1))
         quantity++;
      else
         break;
      index_candle++;
     }

   quantity++;
   return quantity;
  }
//+------------------------------------------------------------------+
bool CandlePattern::SequencialDown(int m_number_barras, int indexStart)
  {
   int quantity = NumSequencialDown(indexStart);
   if(quantity>=m_number_barras)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
int CandlePattern::NumSequencialDown(int indexStart)
  {
   int index_candle = indexStart;
   int quantity= 0;

   for(int i=0; i<6; i++)
     {
      if(m_series.Low(index_candle)<m_series.Low(index_candle+1)&& m_series.High(index_candle)<m_series.High(index_candle+1))
         quantity++;
      else
         break;
      index_candle++;
     }

   quantity++;
   return quantity;
  }
//+------------------------------------------------------------------+
int CandlePattern::HighLow(int indexStart)
  {
   int index_candle = indexStart;
   int quantity= 0;

   for(int i=0; i<6; i++)
     {
      if(m_series.Low(index_candle)>m_series.Low(index_candle+1))
         quantity++;
      else
         break;
      index_candle++;
     }

   quantity++;
   return quantity;
  }
//+------------------------------------------------------------------+
int CandlePattern::LowHigh(int indexStart)
  {
   int index_candle = indexStart;
   int quantity= 0;

   for(int i=0; i<6; i++)
     {
      if(m_series.High(index_candle)<m_series.High(index_candle+1))
         quantity++;
      else
         break;
      index_candle++;
     }

   quantity++;
   return quantity;
  }
//+------------------------------------------------------------------+
//| Returns the averaged value of candle body size                   |
//+------------------------------------------------------------------+
double CandlePattern::AvgBody(int ind)
  {
   double candle_body=0;
///--- calculate the averaged size of the candle's body
   for(int i=ind; i<ind+m_ma_period; i++)
     {
      candle_body+=MathAbs(Open(i)-Close(i));
     }
   candle_body=candle_body/m_ma_period;
///--- return body size
   return(candle_body);
  }
//+------------------------------------------------------------------+
//| Checks formation of bullish patterns                             |
//+------------------------------------------------------------------+
bool CandlePattern::CheckPatternAllBullish()
  {
   return(CheckPatternThreeWhiteSoldiers() ||
          CheckPatternPiercingLine() ||
          CheckPatternMorningDoji() ||
          CheckPatternBullishEngulfing() ||
          CheckPatternBullishHarami() ||
          CheckPatternMorningStar() ||
          CheckPatternBullishMeetingLines());
  }
//+------------------------------------------------------------------+
//| Checks formation of bearish patterns                             |
//+------------------------------------------------------------------+
bool CandlePattern::CheckPatternAllBearish()
  {
   return(CheckPatternThreeBlackCrows() ||
          CheckPatternDarkCloudCover() ||
          CheckPatternEveningDoji() ||
          CheckPatternBearishEngulfing() ||
          CheckPatternBearishHarami() ||
          CheckPatternEveningStar() ||
          CheckPatternBearishMeetingLines());
  }
//+------------------------------------------------------------------+
//| Checks formation of Three Black Crows candlestick pattern        |
//+------------------------------------------------------------------+
bool CandlePattern::CheckPatternThreeBlackCrows()
  {
//--- 3 Black Crows
   if((m_series.Open(3)-m_series.Close(3)>AvgBody(1)) && // long black
      (m_series.Open(2)-m_series.Close(2)>AvgBody(1)) &&
      (m_series.Open(1)-m_series.Close(1)>AvgBody(1)) &&
      (MidPoint(2)<MidPoint(3))     && // lower midpoints
      (MidPoint(1)<MidPoint(2)))
      return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Checks formation of Three White Soldiers candlestick pattern     |
//+------------------------------------------------------------------+
bool CandlePattern::CheckPatternThreeWhiteSoldiers()
  {
//--- 3 White Soldiers
   if((m_series.Close(3)-m_series.Open(3)>AvgBody(1)) && // long white
      (m_series.Close(2)-m_series.Open(2)>AvgBody(1)) &&
      (m_series.Close(1)-m_series.Open(1)>AvgBody(1)) &&
      (MidPoint(2)>MidPoint(3))     && // higher midpoints
      (MidPoint(1)>MidPoint(2)))
      return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Checks formation of Dark Cloud Cover candlestick pattern         |
//+------------------------------------------------------------------+
bool CandlePattern::CheckPatternDarkCloudCover()
  {
//--- Dark cloud cover
   if((m_series.Close(2)-m_series.Open(2)>AvgBody(1)) && // long white
      (m_series.Close(1)<m_series.Close(2))           && // close within previous body
      (m_series.Close(1)>m_series.Open(2))            &&
      (MidOpenClose(2)>CloseAvg(1)) && // uptrend
      (m_series.Open(1)>m_series.High(2)))               // open at new high
      return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Checks formation of Piercing Line candlestick pattern            |
//+------------------------------------------------------------------+
bool CandlePattern::CheckPatternPiercingLine()
  {
//--- Piercing Line
   if((m_series.Close(1)-m_series.Open(1)>AvgBody(1)) && // long white
      (m_series.Open(2)-m_series.Close(2)>AvgBody(1)) && // long black
      (m_series.Close(2)>m_series.Close(1))           && // close inside previous body
      (m_series.Close(1)<m_series.Open(2))            &&
      (MidOpenClose(2)<CloseAvg(2)) && // downtrend
      (m_series.Open(1)<m_series.Low(2)))                // close inside previous body
      return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Checks formation of Morning Doji candlestick pattern             |
//+------------------------------------------------------------------+
bool CandlePattern::CheckPatternMorningDoji()
  {
//--- Morning Doji
   if((m_series.Open(3)-m_series.Close(3)>AvgBody(1)) &&
      (AvgBody(2)<AvgBody(1)*0.1)   &&
      (m_series.Close(2)<m_series.Close(3))           &&
      (m_series.Open(2)<m_series.Open(3))             &&
      (m_series.Open(1)>m_series.Close(2))            &&
      (m_series.Close(1)>m_series.Close(2)))
      return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Checks formation of Evening Doji candlestick pattern             |
//+------------------------------------------------------------------+
bool CandlePattern::CheckPatternEveningDoji()
  {
//--- Evening Doji
   if((m_series.Close(3)-m_series.Open(3)>AvgBody(1)) &&
      (AvgBody(2)<AvgBody(1)*0.1)   &&
      (m_series.Close(2)>m_series.Close(3))           &&
      (m_series.Open(2)>m_series.Open(3))             &&
      (m_series.Open(1)<m_series.Close(2))            &&
      (m_series.Close(1)<m_series.Close(2)))
      return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Checks formation of Bearish Engulfing candlestick pattern        |
//+------------------------------------------------------------------+
bool CandlePattern::CheckPatternBearishEngulfing()
  {
//--- Bearish Engulfing
   if((m_series.Open(2)<m_series.Close(2))            &&
      (m_series.Open(1)-m_series.Close(1)>AvgBody(1)) &&
      (m_series.Close(1)<m_series.Open(2))            &&
      (MidOpenClose(2)>CloseAvg(2)) &&
      (m_series.Open(1)>m_series.Close(2)))
      return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Checks formation of Bullish Engulfing candlestick pattern        |
//+------------------------------------------------------------------+
bool CandlePattern::CheckPatternBullishEngulfing()
  {
//--- Bullish Engulfing
   if((m_series.Open(2)>m_series.Close(2))            &&
      (m_series.Close(1)-m_series.Open(1)>AvgBody(1)) &&
      (m_series.Close(1)>m_series.Open(2))            &&
      (MidOpenClose(2)<CloseAvg(2)) &&
      (m_series.Open(1)<m_series.Close(2)))
      return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Checks formation of Evening Star candlestick pattern             |
//+------------------------------------------------------------------+
bool CandlePattern::CheckPatternEveningStar()
  {
//--- Evening Star
   if((m_series.Close(3)-m_series.Open(3)>AvgBody(1))              &&
      (MathAbs(m_series.Close(2)-m_series.Open(2))<AvgBody(1)*0.5) &&
      (m_series.Close(2)>m_series.Close(3))                        &&
      (m_series.Open(2)>m_series.Open(3))                          &&
      (m_series.Close(1)<MidOpenClose(3)))
      return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Checks formation of Morning Star candlestick pattern             |
//+------------------------------------------------------------------+
bool CandlePattern::CheckPatternMorningStar()
  {
//--- Morning Star
   if((m_series.Open(3)-m_series.Close(3)>AvgBody(1))              &&
      (MathAbs(m_series.Close(2)-m_series.Open(2))<AvgBody(1)*0.5) &&
      (m_series.Close(2)<m_series.Close(3))                        &&
      (m_series.Open(2)<m_series.Open(3))                          &&
      (m_series.Close(1)>MidOpenClose(3)))
      return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Checks formation of Hammer candlestick pattern                   |
//+------------------------------------------------------------------+
bool CandlePattern::CheckPatternHammer()
  {
//--- Hammer
   if((MidPoint(1)<CloseAvg(2))                                  && // down trend
      (MathMin(m_series.Open(1),m_series.Close(1))>(m_series.High(1)-(m_series.High(1)-m_series.Low(1))/3.0)) && // body in upper 1/3
      (m_series.Close(1)<m_series.Close(2)) && (m_series.Open(1)<m_series.Open(2)))                     // body gap
      return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Checks formation of Hanging Man candlestick pattern              |
//+------------------------------------------------------------------+
bool CandlePattern::CheckPatternHangingMan()
  {
//--- Hanging man
   if((MidPoint(1)>CloseAvg(2))                                 && // up trend
      (MathMin(m_series.Open(1),m_series.Close(1)>(m_series.High(1)-(m_series.High(1)-m_series.Low(1))/3.0)) && // body in upper 1/3
       (m_series.Close(1)>m_series.Close(2)) && (m_series.Open(1)>m_series.Open(2))))                   // body gap
      return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Checks formation of Bearish Harami candlestick pattern           |
//+------------------------------------------------------------------+
bool CandlePattern::CheckPatternBearishHarami()
  {
//--- Bearish Harami
   if((m_series.Close(1)<m_series.Open(1))              && // black day
      ((m_series.Close(2)-m_series.Open(2))>AvgBody(1)) && // long white
      ((m_series.Close(1)>m_series.Open(2))             &&
       (m_series.Open(1)<m_series.Close(2)))             && // engulfment
      (MidPoint(2)>CloseAvg(2)))         // up trend
      return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Checks formation of Bullish Harami candlestick pattern           |
//+------------------------------------------------------------------+
bool CandlePattern::CheckPatternBullishHarami()
  {
//--- Bullish Harami
   if((m_series.Close(1)>m_series.Open(1))              && // white day
      ((m_series.Open(2)-m_series.Close(2))>AvgBody(1)) && // long black
      ((m_series.Close(1)<m_series.Open(2))             &&
       (m_series.Open(1)>m_series.Close(2)))             && // engulfment
      (MidPoint(2)<CloseAvg(2)))         // down trend
      return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Checks formation of Bearish Meeting Lines candlestick pattern    |
//+------------------------------------------------------------------+
bool CandlePattern::CheckPatternBearishMeetingLines()
  {
//--- Bearish MeetingLines
   if((m_series.Close(2)-m_series.Open(2)>AvgBody(1))                && // long white
      ((m_series.Open(1)-m_series.Close(1))>AvgBody(1))              && // long black
      (MathAbs(m_series.Close(1)-m_series.Close(2))<0.1*AvgBody(1)))    // doji close
      return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Checks formation of Bullish Meeting Lines candlestick pattern    |
//+------------------------------------------------------------------+
bool CandlePattern::CheckPatternBullishMeetingLines()
  {
//--- Bullish MeetingLines
   if((m_series.Open(2)-m_series.Close(2)>AvgBody(1))             && // long black
      ((m_series.Close(1)-m_series.Open(1))>AvgBody(1))           && // long white
      (MathAbs(m_series.Close(1)-m_series.Close(2))<0.1*AvgBody(1))) // doji close
      return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
bool CandlePattern::PinbarLowerWick(int index)
  {
   double open = Open(index);
   double close = Close(index);
   double high = High(index);
   double low = Low(index);

   double body = MathAbs(close - open);
   double candleRange = high - low;
   if(candleRange == 0)
      return false;

   double upperWick = high - MathMax(open, close);
   double lowerWick = MathMin(open, close) - low;
   double bodyPercent = body / candleRange;

   if(bodyPercent <= 0.35 &&
      lowerWick >= 2 * body &&
      upperWick <= body)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
bool CandlePattern::PinbarUpperWick(int index)
  {
   double open = Open(index);
   double close = Close(index);
   double high = High(index);
   double low = Low(index);

   double body = MathAbs(close - open);
   double candleRange = high - low;
   if(candleRange == 0)
      return false;

   double upperWick = high - MathMax(open, close);
   double lowerWick = MathMin(open, close) - low;
   double bodyPercent = body / candleRange;

// Critérios para pinbar com pavio superior
   if(bodyPercent <= 0.35 &&
      upperWick >= 2 * body &&
      lowerWick <= body)
      return true;

   return false;
  }
//-------------------------------------------------------------------+
//| Checks formation of a certain candlestick pattern                |
//+------------------------------------------------------------------+
bool CandlePattern::CheckCandlestickPattern(ENUM_CANDLE_PATTERNS CandlePattern)
  {
   switch(CandlePattern)
     {
      case CANDLE_PATTERN_THREE_BLACK_CROWS:
         return(CheckPatternThreeBlackCrows());
      case CANDLE_PATTERN_THREE_WHITE_SOLDIERS:
         return(CheckPatternThreeWhiteSoldiers());
      case CANDLE_PATTERN_DARK_CLOUD_COVER:
         return(CheckPatternDarkCloudCover());
      case CANDLE_PATTERN_PIERCING_LINE:
         return(CheckPatternPiercingLine());
      case CANDLE_PATTERN_MORNING_DOJI:
         return(CheckPatternMorningDoji());
      case CANDLE_PATTERN_EVENING_DOJI:
         return(CheckPatternEveningDoji());
      case CANDLE_PATTERN_BEARISH_ENGULFING:
         return(CheckPatternBearishEngulfing());
      case CANDLE_PATTERN_BULLISH_ENGULFING:
         return(CheckPatternBullishEngulfing());
      case CANDLE_PATTERN_EVENING_STAR:
         return(CheckPatternEveningStar());
      case CANDLE_PATTERN_MORNING_STAR:
         return(CheckPatternMorningStar());
      case CANDLE_PATTERN_HAMMER:
         return(CheckPatternHammer());
      case CANDLE_PATTERN_HANGING_MAN:
         return(CheckPatternHangingMan());
      case CANDLE_PATTERN_BEARISH_HARAMI:
         return(CheckPatternBearishHarami());
      case CANDLE_PATTERN_BULLISH_HARAMI:
         return(CheckPatternBullishHarami());
      case CANDLE_PATTERN_BEARISH_MEETING_LINES:
         return(CheckPatternBearishMeetingLines());
      case CANDLE_PATTERN_BULLISH_MEETING_LINES:
         return(CheckPatternBullishMeetingLines());
     }
//---
   return(false);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

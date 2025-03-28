//https://www.mql5.com/pt/articles/5543
//+------------------------------------------------------------------+
//|                                                 ZigZagModule.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <ChartObjects\ChartObjectsLines.mqh>
//+------------------------------------------------------------------+
//| Class for obtaining ZigZag indicator data                        |
//+------------------------------------------------------------------+
class CZigZagModule
  {
protected:
   //--- Segment lines
   CChartObjectTrend m_trend_lines[];
   //---
   int               m_copy_extremums;    // Number of saved highs/lows
   int               m_segments_total;    // Number of segments
   int               m_direction;         // Direction
   int               m_counter_lows;      // Low counter
   int               m_counter_highs;     // High counter

   //--- Extremum prices
   double            m_zz_low[];
   double            m_zz_high[];
   //--- Extremum bars' indices
   int               m_zz_low_bar[];
   int               m_zz_high_bar[];
   //--- Extremum bars' time
   datetime          m_zz_low_time[];
   datetime          m_zz_high_time[];
   //--- Segment lines color
   color             m_lines_color;
   //---
private:
   //--- Arrays for obtaining source data
   double            m_zz_lows_temp[];
   double            m_zz_highs_temp[];
   datetime          m_zz_time_temp[];
   //---
public:
                     CZigZagModule(void);
                    ~CZigZagModule(void);

   //--- Number of extremums for copying
   void              CopyExtremums(const int total);
   //--- Number of (1) extremums and (2) segments copied
   int               CopyExtremums(void) { return(m_copy_extremums); }
   int               SegmentsTotal(void) { return(m_segments_total); }

   //--- Get data
   void              GetZigZagData(const double &zz_h[],const double &zz_l[],const datetime &time[]);
   void              GetZigZagData(const int handle,int buffer_num_highs,int buffer_num_lows,
                                   const string symbol,const ENUM_TIMEFRAMES period,
                                   const datetime start_time,const datetime stop_time);

   //--- Update the structure
   void              ZeroZigZagData(void);
   //---
public:
   //--- Last segment direction
   int               Direction(void) const { return(m_direction); }

   //--- Index of an extremum bar by a specified index
   int               LowBar(const int index);
   int               HighBar(const int index);
   //--- Price of extremums by a specified index
   double            LowPrice(const int index);
   double            HighPrice(const int index);
   //--- Time of an extremum bar by a specified index
   datetime          LowTime(const int index);
   datetime          HighTime(const int index);

   //--- Segment size by a specified index
   double            SegmentSize(const int index);

   //--- Sum of all segments
   double            SegmentsSum(void);
   //--- Sum of segments directed (1) upwards and (2) downwards
   double            SumSegmentsUp(void);
   double            SumSegmentsDown(void);

   //--- Direction of a specified segment
   int               SegmentDirection(const int index);
   //--- Return the start and end bar of a specified segment
   bool              SegmentBars(const int index,int &start_bar,int &stop_bar);
   //--- Return the start and end prices of a specified segment
   bool              SegmentPrices(const int index,double &start_price,double &stop_price);
   //--- Return the start and end time of a specified segment
   bool              SegmentTimes(const int index,datetime &start_time,datetime &stop_time);
   //--- Return the start and end time of a specified segment considering a lower timeframe
   bool              SegmentTimes(const int handle,const int highs_buffer_index,const int lows_buffer_index,
                                  const string symbol,const ENUM_TIMEFRAMES period,const ENUM_TIMEFRAMES in_period,
                                  const int index,datetime &start_time,datetime &stop_time);

   //--- minhas
   long              SegmentsSeconds(int index);
   double            SizeRomp();
   string            StringPercent(double value);
   double            PercentDisruption(int index);

   //--- Percentage ratio of the segment sums to the total sum of all segments within a set
   double            PercentSumSegmentsUp(void);
   double            PercentSumSegmentsDown(void);
   //--- Difference between segment sums
   double            PercentSumSegmentsDifference(void);

   //--- Number of bars in a specified segment
   int               SegmentBars(const int index);
   //--- (1) Number of bars and (2) seconds in a set of segments
   int               SegmentsTotalBars(void);
   long              SegmentsTotalSeconds(void);

   //--- (1) Minimum and (2) maximum values in the set
   double            LowMinimum(void);
   double            HighMaximum(void);
   //--- Price range
   double            PriceRange(void);

   //--- Smallest minimum time
   datetime          SmallestMinimumTime(void);
   //--- Largest maximum time
   datetime          LargestMaximumTime(void);

   //--- Smallest segment in the set
   double            SmallestSegment(void);
   //--- Largest segment in the set
   double            LargestSegment(void);
   //--- Smallest number of segment bars in the set
   int               LeastNumberOfSegmentBars(void);
   //--- Largest number of segment bars in the set
   int               MostNumberOfSegmentBars(void);

   //--- Deviation in percentage
   double            PercentDeviation(const int index);
   //---
public:
   //--- Line color
   void              LinesColor(const color clr) { m_lines_color=clr; }

   //--- (1) Display and (2) delete objects
   void              ShowSegments(const string suffix="");
   void              DeleteSegments(void);

   //--- Comment on a chart
   void              CommentZigZagData();
   void              CommentShortZigZagData();
   void              CommentZigZagDataMy(string str);
   //---
private:
   //--- Copy source data to the passed arrays
   void              CopyData(const int handle,const int buffer_index,const string symbol,
                              const ENUM_TIMEFRAMES period,datetime start_time,datetime stop_time,
                              double &zz_array[],datetime &time_array[]);
   //--- Return index of the (1) minimum and (2) maximum values from the passed array
   int               GetMinValueIndex(double &zz_lows[]);
   int               GetMaxValueIndex(double &zz_highs[]);

   //--- Create objects
   void              CreateSegment(const int segment_index,const string suffix="");
   //--- Segment size to the string
   string            SegmentSizeToString(const int index);
   //---
public:
   //--- Pattern 1
   int               Pattern1(const double outer_dev,const double inner_dev);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CZigZagModule::CZigZagModule(void) : m_copy_extremums(1),
   m_segments_total(1),
   m_lines_color(clrGray)
  {
   CopyExtremums(m_copy_extremums);
   ZeroZigZagData();
//--- Set the reverse indexation order (... 3 2 1 0)
   ::ArraySetAsSeries(m_zz_lows_temp,true);
   ::ArraySetAsSeries(m_zz_highs_temp,true);
   ::ArraySetAsSeries(m_zz_time_temp,true);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CZigZagModule::~CZigZagModule(void)
  {
  }
//+------------------------------------------------------------------+
//| Number of extremums for work                                     |
//+------------------------------------------------------------------+
void CZigZagModule::CopyExtremums(const int total)
  {
   if(total<1)
      return;
//---
   m_copy_extremums =total;
   m_segments_total =total*2-1;
//---
   ::ArrayResize(m_zz_low,total);
   ::ArrayResize(m_zz_high,total);
   ::ArrayResize(m_zz_low_bar,total);
   ::ArrayResize(m_zz_high_bar,total);
   ::ArrayResize(m_zz_low_time,total);
   ::ArrayResize(m_zz_high_time,total);
   ::ArrayResize(m_trend_lines,m_segments_total);
  }
//+------------------------------------------------------------------+
//| Reset ZigZag variables                                           |
//+------------------------------------------------------------------+
void CZigZagModule::ZeroZigZagData(void)
  {
   m_counter_lows  =0;
   m_counter_highs =0;
//---
   ::ArrayInitialize(m_zz_low,0);
   ::ArrayInitialize(m_zz_high,0);
   ::ArrayInitialize(m_zz_low_bar,0);
   ::ArrayInitialize(m_zz_high_bar,0);
   ::ArrayInitialize(m_zz_low_time,0);
   ::ArrayInitialize(m_zz_high_time,0);
  }
//+------------------------------------------------------------------+
//| Get ZZ data from passed arrays                                   |
//+------------------------------------------------------------------+
void CZigZagModule::GetZigZagData(const double &zz_h[],const double &zz_l[],const datetime &time[])
  {
   int h_total =::ArraySize(zz_h);
   int l_total =::ArraySize(zz_l);
   int total   =h_total+l_total;
//--- Reset ZZ variables
   ZeroZigZagData();
//--- Move along the copied ZZ values in a loop
   for(int i=0; i<total; i++)
     {
      //--- If the necessary number of ZZ highs and lows is already received, exit the loop
      if(m_counter_highs==m_copy_extremums && m_counter_lows==m_copy_extremums)
         break;
      //--- Manage moving beyond the array
      if(i>=h_total || i>=l_total)
         break;
      //--- Fill in the high value array till the necessary amount is copied
      if(zz_h[i]>0 && m_counter_highs<m_copy_extremums)
        {
         m_zz_high[m_counter_highs]      =zz_h[i];
         m_zz_high_bar[m_counter_highs]  =i;
         m_zz_high_time[m_counter_highs] =time[i];
         //--- Increase the counter of highs
         m_counter_highs++;
        }
      //--- Fill in the array of lows till the necessary amount is copied
      if(zz_l[i]>0 && m_counter_lows<m_copy_extremums)
        {
         m_zz_low[m_counter_lows]      =zz_l[i];
         m_zz_low_bar[m_counter_lows]  =i;
         m_zz_low_time[m_counter_lows] =time[i];
         //--- Increase the counter of lows
         m_counter_lows++;
        }
     }
//--- Determine the price direction
   m_direction=(m_zz_high_time[0]>m_zz_low_time[0])? 1 : -1;
  }
//+------------------------------------------------------------------+
//| Get ZZ data from passed data                                     |
//+------------------------------------------------------------------+
void CZigZagModule::GetZigZagData(const int handle,int buffer_num_highs,int buffer_num_lows,
                                  const string symbol,const ENUM_TIMEFRAMES period,
                                  const datetime start_time,const datetime stop_time)
  {
//--- Get source data
   int times_total =::CopyTime(symbol,period,start_time,stop_time,m_zz_time_temp);
   int highs_total =::CopyBuffer(handle,buffer_num_highs,start_time,stop_time,m_zz_highs_temp);
   int lows_total  =::CopyBuffer(handle,buffer_num_lows,start_time,stop_time,m_zz_lows_temp);
//--- Maximum number of extremums
   int max_items =(int)::fmax((double)highs_total,(double)lows_total);
//--- If not enough, try again
   if(times_total<max_items)
     {
      while(true)
        {
         ::Sleep(100);
         times_total=::CopyTime(symbol,period,start_time,stop_time,m_zz_time_temp);
         if(times_total>=max_items)
            break;
        }
     }
//--- Counters
   int lows_counter  =0;
   int highs_counter =0;
//--- Calculate highs
   int h_total=::ArraySize(m_zz_highs_temp);
   for(int i=0; i<h_total; i++)
     {
      if(m_zz_highs_temp[i]>0)
         highs_counter++;
     }
//--- Calculate lows
   int l_total=::ArraySize(m_zz_lows_temp);
   for(int i=0; i<l_total; i++)
     {
      if(m_zz_lows_temp[i]>0)
         lows_counter++;
     }
//--- Get the number of extremums
   int copy_extremums=(int)::fmin((double)highs_counter,(double)lows_counter);
   CopyExtremums(copy_extremums);
//--- Move along the copied ZZ values in a loop
   GetZigZagData(m_zz_highs_temp,m_zz_lows_temp,m_zz_time_temp);
  }
//+------------------------------------------------------------------+
//| Low value by a specified index                                   |
//+------------------------------------------------------------------+
double CZigZagModule::LowPrice(const int index)
  {
   if(index>=::ArraySize(m_zz_low))
      return(0.0);
//---
   return(m_zz_low[index]);
  }
//+------------------------------------------------------------------+
//| High value by a specified index                                  |
//+------------------------------------------------------------------+
double CZigZagModule::HighPrice(const int index)
  {
   if(index>=::ArraySize(m_zz_high))
      return(0.0);
//---
   return(m_zz_high[index]);
  }
//+------------------------------------------------------------------+
//| Low bar number by a specified index                              |
//+------------------------------------------------------------------+
int CZigZagModule::LowBar(const int index)
  {
   if(index>=::ArraySize(m_zz_low_bar))
      return(0);
//---
   return(m_zz_low_bar[index]);
  }
//+------------------------------------------------------------------+
//| High bar number by a specified index                             |
//+------------------------------------------------------------------+
int CZigZagModule::HighBar(const int index)
  {
   if(index>=::ArraySize(m_zz_high_bar))
      return(0);
//---
   return(m_zz_high_bar[index]);
  }
//+------------------------------------------------------------------+
//| Low bar time by a specified index                                |
//+------------------------------------------------------------------+
datetime CZigZagModule::LowTime(const int index)
  {
   if(index>=::ArraySize(m_zz_low_time))
      return(0);
//---
   return(m_zz_low_time[index]);
  }
//+------------------------------------------------------------------+
//| High bar time by a specified index                               |
//+------------------------------------------------------------------+
datetime CZigZagModule::HighTime(const int index)
  {
   if(index>=::ArraySize(m_zz_high_time))
      return(0);
//---
   return(m_zz_high_time[index]);
  }
//+------------------------------------------------------------------+
//| Return segment size by index                                     |
//+------------------------------------------------------------------+
double CZigZagModule::SegmentSize(const int index)
  {
   if(index>=m_segments_total)
      return(-1);
//---
   double size=0;
//--- In case of an even number
   if(index%2==0)
     {
      int i=index/2;
      size=::fabs(m_zz_high[i]-m_zz_low[i]);
     }
//--- In case of an odd number
   else
     {
      int l=0,h=0;
      //---
      if(Direction()>0)
        {
         h=(index-1)/2+1;
         l=(index-1)/2;
        }
      else
        {
         h=(index-1)/2;
         l=(index-1)/2+1;
        }
      //---
      size=::fabs(m_zz_high[h]-m_zz_low[l]);
     }
//---
   return(size);
  }
//+------------------------------------------------------------------+
//| Sum of all segments                                              |
//+------------------------------------------------------------------+
double CZigZagModule::SegmentsSum(void)
  {
   double sum=0.0;
//---
   for(int i=0; i<m_segments_total; i++)
      sum+=SegmentSize(i);
//---
   return(sum);
  }
//+------------------------------------------------------------------+
//| Return the size of all upward segments                           |
//+------------------------------------------------------------------+
double CZigZagModule::SumSegmentsUp(void)
  {
   double sum=0.0;
//---
   for(int i=0; i<m_copy_extremums; i++)
     {
      if(Direction()>0)
         sum+=::fabs(m_zz_high[i]-m_zz_low[i]);
      else
        {
         if(i>0)
            sum+=::fabs(m_zz_high[i-1]-m_zz_low[i]);
        }
     }
//---
   return(sum);
  }
//+------------------------------------------------------------------+
//| Return the size of all downward segments                         |
//+------------------------------------------------------------------+
double CZigZagModule::SumSegmentsDown(void)
  {
   double sum=0.0;
//---
   for(int i=0; i<m_copy_extremums; i++)
     {
      if(Direction()<0)
         sum+=::fabs(m_zz_high[i]-m_zz_low[i]);
      else
        {
         if(i>0)
            sum+=::fabs(m_zz_high[i]-m_zz_low[i-1]);
        }
     }
//---
   return(sum);
  }
//+------------------------------------------------------------------+
//| Direction of a specified segment                                 |
//+------------------------------------------------------------------+
int CZigZagModule::SegmentDirection(const int index)
  {
   return((index%2==0)? Direction() : -Direction());
  }
//+------------------------------------------------------------------+
//| Return the start and end bar of a specified segment              |
//+------------------------------------------------------------------+
bool CZigZagModule::SegmentBars(const int index,int &start_bar,int &stop_bar)
  {
   if(index>=m_segments_total)
      return(false);
//--- In case of an even number
   if(index%2==0)
     {
      int i=index/2;
      //---
      start_bar =(Direction()>0)? m_zz_low_bar[i] : m_zz_high_bar[i];
      stop_bar  =(Direction()>0)? m_zz_high_bar[i] : m_zz_low_bar[i];
     }
//--- In case of an odd number
   else
     {
      int l=0,h=0;
      //---
      if(Direction()>0)
        {
         h=(index-1)/2+1;
         l=(index-1)/2;
         //---
         start_bar =m_zz_high_bar[h];
         stop_bar  =m_zz_low_bar[l];
        }
      else
        {
         h=(index-1)/2;
         l=(index-1)/2+1;
         //---
         start_bar =m_zz_low_bar[l];
         stop_bar  =m_zz_high_bar[h];
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Return the start and end prices of a specified segment           |
//+------------------------------------------------------------------+
bool CZigZagModule::SegmentPrices(const int index,double &start_price,double &stop_price)
  {
   if(index>=m_segments_total)
      return(false);
//--- In case of an even number
   if(index%2==0)
     {
      int i=index/2;
      //---
      start_price =(Direction()>0)? m_zz_low[i] : m_zz_high[i];
      stop_price  =(Direction()>0)? m_zz_high[i] : m_zz_low[i];
     }
//--- In case of an odd number
   else
     {
      int l=0,h=0;
      //---
      if(Direction()>0)
        {
         h=(index-1)/2+1;
         l=(index-1)/2;
         //---
         start_price =m_zz_high[h];
         stop_price  =m_zz_low[l];
        }
      else
        {
         h=(index-1)/2;
         l=(index-1)/2+1;
         //---
         start_price =m_zz_low[l];
         stop_price  =m_zz_high[h];
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Return the start and end time of a segment                       |
//+------------------------------------------------------------------+
bool CZigZagModule::SegmentTimes(const int index,datetime &start_time,datetime &stop_time)
  {
   if(index>=m_segments_total)
     {
      Print(__FUNCTION__," > index: ",index,"; m_segments_total: ",m_segments_total);
      return(false);
     }
//--- In case of an even number
   if(index%2==0)
     {
      int i=index/2;
      //---
      start_time =(Direction()>0)? m_zz_low_time[i] : m_zz_high_time[i];
      stop_time  =(Direction()>0)? m_zz_high_time[i] : m_zz_low_time[i];
     }
//--- In case of an odd number
   else
     {
      int l=0,h=0;
      //---
      if(Direction()>0)
        {
         h=(index-1)/2+1;
         l=(index-1)/2;
         //---
         start_time =m_zz_high_time[h];
         stop_time  =m_zz_low_time[l];
        }
      else
        {
         h=(index-1)/2;
         l=(index-1)/2+1;
         //---
         start_time =m_zz_low_time[l];
         stop_time  =m_zz_high_time[h];
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Retorna os segundos de um seguimento                             |
//+------------------------------------------------------------------+
long CZigZagModule::SegmentsSeconds(int index)
  {
   datetime begin =NULL;
   datetime end   =NULL;

   SegmentTimes(index, begin, end);
   return(long(end-begin));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CZigZagModule::SizeRomp()
  {
   double romp = 0;
   if(Direction() > 0)//-- subindo: check os rompimentos dos fundos
      romp = MathAbs(m_zz_low[1]-m_zz_low[2]);
   else//-- descendo: check os rompimentos dos topos
      romp = MathAbs(m_zz_high[1]-m_zz_high[2]);
   return(romp);
  }
//+------------------------------------------------------------------+
//| Return the start and end time of a specified segment             |
//| considering a lower timeframe                                    |
//+------------------------------------------------------------------+
bool CZigZagModule::SegmentTimes(const int handle,const int highs_buffer_index,const int lows_buffer_index,
                                 const string symbol,const ENUM_TIMEFRAMES period,const ENUM_TIMEFRAMES in_period,
                                 const int index,datetime &start_time,datetime &stop_time)
  {
//--- Get time without considering the current timeframe
   datetime l_start_time =NULL;
   datetime l_stop_time  =NULL;
   if(!SegmentTimes(index,l_start_time,l_stop_time))
      return(false);
//---
   double   zz_lows[];
   double   zz_highs[];
   datetime zz_lows_time[];
   datetime zz_highs_time[];
   datetime start =NULL;
   datetime stop  =NULL;
   int      period_seconds=::PeriodSeconds(period);
//--- Get source data in case of an upward direction
   if(SegmentDirection(index)>0)
     {
      //--- Data on the higher timeframe's first bar
      start =l_start_time;
      stop  =l_start_time+period_seconds;
      CopyData(handle,lows_buffer_index,symbol,in_period,start,stop,zz_lows,zz_lows_time);
      //--- Data on the higher timeframe's last bar
      start =l_stop_time;
      stop  =l_stop_time+period_seconds;
      CopyData(handle,highs_buffer_index,symbol,in_period,start,stop,zz_highs,zz_highs_time);
     }
//--- Get source data in case of a downward direction
   else
     {
      //--- Data on the higher timeframe's first bar
      start =l_start_time;
      stop  =l_start_time+period_seconds;
      CopyData(handle,highs_buffer_index,symbol,in_period,start,stop,zz_highs,zz_highs_time);
      //--- Data on the higher timeframe's last bar
      start =l_stop_time;
      stop  =l_stop_time+period_seconds;
      CopyData(handle,lows_buffer_index,symbol,in_period,start,stop,zz_lows,zz_lows_time);
     }
//--- Search for a high (maximum value) index
   int max_index=GetMaxValueIndex(zz_highs);
//--- Search for a low (minimum value) index
   int min_index=GetMinValueIndex(zz_lows);
//---
   if(min_index>=::ArraySize(zz_lows_time) || max_index>=::ArraySize(zz_highs_time))
      return(false);
//--- Get segment start and end time
   start_time =(SegmentDirection(index)>0)? zz_lows_time[min_index] : zz_highs_time[max_index];
   stop_time  =(SegmentDirection(index)>0)? zz_highs_time[max_index] : zz_lows_time[min_index];
//--- Successful
   return(true);
  }
//+------------------------------------------------------------------+
//| Copy source data to the passed arrays                            |
//+------------------------------------------------------------------+
void CZigZagModule::CopyData(const int handle,const int buffer_index,const string symbol,
                             const ENUM_TIMEFRAMES period,datetime start_time,datetime stop_time,
                             double &zz_array[],datetime &time_array[])
  {
   ::CopyBuffer(handle,buffer_index,start_time,stop_time,zz_array);
   ::CopyTime(symbol,period,start_time,stop_time,time_array);
  }
//+------------------------------------------------------------------+
//| Return a high index from the passed array                        |
//+------------------------------------------------------------------+
int CZigZagModule::GetMaxValueIndex(double &zz_highs[])
  {
   int    max_index =0;
   double max_value =0;
   int total=::ArraySize(zz_highs);
   for(int i=0; i<total; i++)
     {
      if(zz_highs[i]>0)
        {
         if(zz_highs[i]>max_value)
           {
            max_index =i;
            max_value =zz_highs[i];
           }
        }
     }
//---
   return(max_index);
  }
//+------------------------------------------------------------------+
//| Return a low index from the passed array                         |
//+------------------------------------------------------------------+
int CZigZagModule::GetMinValueIndex(double &zz_lows[])
  {
   int    min_index =0;
   double min_value =INT_MAX;
   int total=::ArraySize(zz_lows);
   for(int i=0; i<total; i++)
     {
      if(zz_lows[i]>0)
        {
         if(zz_lows[i]<min_value)
           {
            min_index =i;
            min_value =zz_lows[i];
           }
        }
     }
//---
   return(min_index);
  }
//+------------------------------------------------------------------+
//| Return the percentage of the sum of all upward segments          |
//+------------------------------------------------------------------+
double CZigZagModule::PercentSumSegmentsUp(void)
  {
   double sum=SegmentsSum();
   if(sum<=0)
      return(0);
//---
   return(SumSegmentsDown()/sum*100);
  }
//+------------------------------------------------------------------+
//| Return the percentage of the sum of all downward segments        |
//+------------------------------------------------------------------+
double CZigZagModule::PercentSumSegmentsDown(void)
  {
   double sum=SegmentsSum();
   if(sum<=0)
      return(0);
//---
   return(SumSegmentsUp()/sum*100);
  }
//+------------------------------------------------------------------+
//| Return the difference of the sum of all segments in percentage   |
//+------------------------------------------------------------------+
double CZigZagModule::PercentSumSegmentsDifference(void)
  {
   return(::fabs(PercentSumSegmentsUp()-PercentSumSegmentsDown()));
  }
//+------------------------------------------------------------------+
//| Return segment duration in bars by index                         |
//+------------------------------------------------------------------+
int CZigZagModule::SegmentBars(const int index)
  {
   if(index>=m_copy_extremums*2-1)
      return(-1);
//---
   int bars=0;
//--- In case of an even number
   if(index%2==0)
     {
      int i=index/2;
      bars=int(::fabs(m_zz_high_bar[i]-m_zz_low_bar[i]));
     }
//--- In case of an odd number
   else
     {
      int l=0,h=0;
      //---
      if(Direction()>0)
        {
         h=(index-1)/2+1;
         l=(index-1)/2;
        }
      else
        {
         h=(index-1)/2;
         l=(index-1)/2+1;
        }
      //---
      bars=int(::fabs(m_zz_high_bar[h]-m_zz_low_bar[l]));
     }
//---
   return(bars);
  }
//+------------------------------------------------------------------+
//| Number of bars of all segments                                   |
//+------------------------------------------------------------------+
int CZigZagModule::SegmentsTotalBars(void)
  {
   int begin =0;
   int end   =0;
   int l     =m_copy_extremums-1;
//---
   begin =(m_zz_high_bar[l]>m_zz_low_bar[l])? m_zz_high_bar[l] : m_zz_low_bar[l];
   end   =(m_zz_high_bar[0]>m_zz_low_bar[0])? m_zz_low_bar[0] : m_zz_high_bar[0];
//---
   return(begin-end);
  }
//+------------------------------------------------------------------+
//| Number of seconds of all segments                                |
//+------------------------------------------------------------------+
long CZigZagModule::SegmentsTotalSeconds(void)
  {
   datetime begin =NULL;
   datetime end   =NULL;
   int l=m_copy_extremums-1;
//---
   begin =(m_zz_high_time[l]<m_zz_low_time[l])? m_zz_high_time[l] : m_zz_low_time[l];
   end   =(m_zz_high_time[0]<m_zz_low_time[0])? m_zz_low_time[0] : m_zz_high_time[0];
//---
   return(long(end-begin));
  }
//+------------------------------------------------------------------+
//| Minimum value in a set                                           |
//+------------------------------------------------------------------+
double CZigZagModule::LowMinimum(void)
  {
   return(m_zz_low[::ArrayMinimum(m_zz_low)]);
  }
//+------------------------------------------------------------------+
//| Maximum value in a set                                           |
//+------------------------------------------------------------------+
double CZigZagModule::HighMaximum(void)
  {
   return(m_zz_high[::ArrayMaximum(m_zz_high)]);
  }
//+------------------------------------------------------------------+
//| Price range                                                      |
//+------------------------------------------------------------------+
double CZigZagModule::PriceRange(void)
  {
   return(HighMaximum()-LowMinimum());
  }
//+------------------------------------------------------------------+
//| Smallest minimum time                                            |
//+------------------------------------------------------------------+
datetime CZigZagModule::SmallestMinimumTime(void)
  {
   return(m_zz_low_time[::ArrayMinimum(m_zz_low)]);
  }
//+------------------------------------------------------------------+
//| Largest maximum time                                             |
//+------------------------------------------------------------------+
datetime CZigZagModule::LargestMaximumTime(void)
  {
   return(m_zz_high_time[::ArrayMaximum(m_zz_high)]);
  }
//+------------------------------------------------------------------+
//| Smallest segment in a set                                        |
//+------------------------------------------------------------------+
double CZigZagModule::SmallestSegment(void)
  {
   double min_size=0;
   for(int i=0; i<m_segments_total; i++)
     {
      if(i==0)
        {
         min_size=SegmentSize(0);
         continue;
        }
      //---
      double size=SegmentSize(i);
      min_size=(size<min_size)? size : min_size;
     }
//---
   return(min_size);
  }
//+------------------------------------------------------------------+
//| Largest segment in the set                                       |
//+------------------------------------------------------------------+
double CZigZagModule::LargestSegment(void)
  {
   double max_size=0;
   for(int i=0; i<m_segments_total; i++)
     {
      if(i==0)
        {
         max_size=SegmentSize(0);
         continue;
        }
      //---
      double size=SegmentSize(i);
      max_size=(size>max_size)? size : max_size;
     }
//---
   return(max_size);
  }
//+------------------------------------------------------------------+
//| Smallest number of segment bars in the set                       |
//+------------------------------------------------------------------+
int CZigZagModule::LeastNumberOfSegmentBars(void)
  {
   int min_bars=0;
   for(int i=0; i<m_segments_total; i++)
     {
      if(i==0)
        {
         min_bars=SegmentBars(0);
         continue;
        }
      //---
      int bars=SegmentBars(i);
      min_bars=(bars<min_bars)? bars : min_bars;
     }
//---
   return(min_bars);
  }
//+------------------------------------------------------------------+
//| Largest number of segment bars in the set                        |
//+------------------------------------------------------------------+
int CZigZagModule::MostNumberOfSegmentBars(void)
  {
   int max_bars=0;
   for(int i=0; i<m_segments_total; i++)
     {
      if(i==0)
        {
         max_bars=SegmentBars(0);
         continue;
        }
      //---
      int bars=SegmentBars(i);
      max_bars=(bars>max_bars)? bars : max_bars;
     }
//---
   return(max_bars);
  }
//+------------------------------------------------------------------+
//| Deviation in percentage                                          |
//+------------------------------------------------------------------+
double CZigZagModule::PercentDeviation(const int index)
  {
   return(SegmentSize(index)/SegmentSize(index+1)*100);
  }
//+------------------------------------------------------------------+
//| Show ZZ segments on a chart                                      |
//+------------------------------------------------------------------+
void CZigZagModule::ShowSegments(const string suffix="")
  {
   DeleteSegments();
   for(int i=0; i<m_segments_total; i++)
      CreateSegment(i,suffix);
  }
//+------------------------------------------------------------------+
//| Remove segments                                                  |
//+------------------------------------------------------------------+
void CZigZagModule::DeleteSegments(void)
  {
   for(int i=0; i<m_segments_total; i++)
     {
      string name="zz_"+string(::ChartID())+"_"+string(i);
      ::ObjectDelete(::ChartID(),name);
     }
  }
//+------------------------------------------------------------------+
//| Create a segment by index                                        |
//+------------------------------------------------------------------+
void CZigZagModule::CreateSegment(const int segment_index,const string suffix="")
  {
   if(segment_index>=m_segments_total)
      return;
//---
   double   hp=0.0,lp=0.0;
   datetime hd=NULL,ld=NULL;
//--- In case of an even number
   if(segment_index%2==0)
     {
      int i=segment_index/2;
      hp =m_zz_high[i];
      lp =m_zz_low[i];
      hd =m_zz_high_time[i];
      ld =m_zz_low_time[i];
     }
//--- In case of an odd number
   else
     {
      int h=0,l=0;
      if(Direction()>0)
        {
         h=(segment_index-1)/2+1;
         l=(segment_index-1)/2;
        }
      else
        {
         h=(segment_index-1)/2;
         l=(segment_index-1)/2+1;
        }
      //---
      hp =m_zz_high[h];
      lp =m_zz_low[l];
      hd =m_zz_high_time[h];
      ld =m_zz_low_time[l];
     }
//--- Set objects
   long id=::ChartID();
   string name="zz_"+string(id)+"_"+string(segment_index)+suffix;
//--- If an object is already present, simply update its location
   if(::ObjectFind(id,name)>=0)
     {
      ::ObjectSetDouble(id,name,OBJPROP_PRICE,0,hp);
      ::ObjectSetDouble(id,name,OBJPROP_PRICE,1,lp);
      ::ObjectSetInteger(id,name,OBJPROP_TIME,0,hd);
      ::ObjectSetInteger(id,name,OBJPROP_TIME,1,ld);
     }
//--- Create a new object
   else
     {
      m_trend_lines[segment_index].Create(id,name,0,hd,hp,ld,lp);
      m_trend_lines[segment_index].Background(false);
      m_trend_lines[segment_index].Width(1);
      m_trend_lines[segment_index].Color(m_lines_color);
      m_trend_lines[segment_index].Style(STYLE_SOLID);
      m_trend_lines[segment_index].Description("zz: "+string(segment_index));
     }
  }
//+------------------------------------------------------------------+
//| Display ZigZag data in a chart comment                           |
//+------------------------------------------------------------------+
void CZigZagModule::CommentZigZagData(void)
  {
   string comment="Current direction : "+string(m_direction)+"\n"+
                  "Copy extremums: "+string(m_copy_extremums)+"\n"+
                  "SegmentSize(0): "+::DoubleToString(SegmentSize(0),_Digits)+
                  "\n---\n"+
                  "HighPrice(0): "+::DoubleToString(HighPrice(0),_Digits)+"\n"+
                  "LowPrice(0): "+::DoubleToString(LowPrice(0),_Digits)+
                  "\n---\n"+
                  "HighBar(0): "+string(HighBar(0))+"\n"+
                  "LowBar(0): "+string(LowBar(0))+
                  "\n---\n"+
                  "HighTime(0): "+::TimeToString(HighTime(0),TIME_DATE|TIME_MINUTES)+"\n"+
                  "LowTime(0): "+::TimeToString(LowTime(0),TIME_DATE|TIME_MINUTES)+
                  "\n---\n"+
                  "SegmentsTotalBars(): "+string(SegmentsTotalBars())+"\n"+
                  "SegmentsTotalSeconds(): "+string(SegmentsTotalSeconds())+"\n"+
                  "SegmentsTotalMinutes(): "+string(SegmentsTotalSeconds()/60)+"\n"+
                  "SegmentsTotalHours(): "+string(SegmentsTotalSeconds()/60/60)+"\n"+
                  "SegmentsTotalDays(): "+string(SegmentsTotalSeconds()/60/60/24)+
                  "\n---\n"+
                  "SegmentsSeconds(0): "+string(SegmentsSeconds(0))+"\n"+
                  "SegmentsMinutes(0): "+string(SegmentsSeconds(0)/60)+"\n"+
                  "SegmentsHours(0): "+string(SegmentsSeconds(0)/60/60)+
                  "\n---\n"+
                  "SizeRomp: "+string(SizeRomp())+"\n"+
                  "SegmentDirection(0): "+string(SegmentDirection(0))+"\n"+
                  "SegmentDirection(1): "+string(SegmentDirection(1))+"\n"+
                  "SegmentDirection(2): "+string(SegmentDirection(2))+"\n"+
                  "\n---\n"+
                  "LowMinimum(): "+::DoubleToString(LowMinimum(),_Digits)+"\n"+
                  "HighMaximum(): "+::DoubleToString(HighMaximum(),_Digits)+"\n"+
                  "PriceRange(): "+::DoubleToString(PriceRange(),_Digits)+
                  "\n---\n"+
                  "SegmentsSum(): "+::DoubleToString(SegmentsSum()/_Point,0)+"\n"+
                  "SegmentsSumUp(): "+::DoubleToString(SumSegmentsUp()/_Point,0)+"\n"+
                  "SegmentsSumDown(): "+::DoubleToString(SumSegmentsDown()/_Point,0)+
                  "\n---\n"+
                  "PercentSumUp(): "+::DoubleToString(SumSegmentsUp()/SegmentsSum()*100,2)+"\n"+
                  "PercentSumDown(): "+::DoubleToString(SumSegmentsDown()/SegmentsSum()*100,2)+"\n"+
                  "PercentDifference(): "+::DoubleToString(PercentSumSegmentsDifference(),2);
//---
   if(m_copy_extremums>1)
     {
      comment+="\n---\n";
      for(int i=0; i<m_segments_total-1; i++)
         comment=comment+"segment_size["+string(i)+"]: "+SegmentSizeToString(i)+"; ("+string(SegmentBars(i))+"); "+::DoubleToString(PercentDeviation(i),2)+" %\n";
      //---
      comment+="...";
     }
//---
   ::Comment(comment);
  }
//+------------------------------------------------------------------+
//| Display ZigZag data in a chart comment                           |
//+------------------------------------------------------------------+
void CZigZagModule::CommentShortZigZagData(void)
  {
   string comment="Current direction : "+string(m_direction)+"\n"+
                  "Copy extremums: "+string(m_copy_extremums)+
                  "\n---\n"+
                  "SegmentsTotalBars(): "+string(SegmentsTotalBars())+"\n"+
                  "SegmentsTotalSeconds(): "+string(SegmentsTotalSeconds())+"\n"+
                  "SegmentsTotalMinutes(): "+string(SegmentsTotalSeconds()/60)+"\n"+
                  "SegmentsTotalHours(): "+string(SegmentsTotalSeconds()/60/60)+"\n"+
                  "SegmentsTotalDays(): "+string(SegmentsTotalSeconds()/60/60/24)+
                  "\n---\n"+
                  "PercentSumUp(): "+::DoubleToString(SumSegmentsUp()/SegmentsSum()*100,2)+"\n"+
                  "PercentSumDown(): "+::DoubleToString(SumSegmentsDown()/SegmentsSum()*100,2)+"\n"+
                  "PercentDifference(): "+::DoubleToString(PercentSumSegmentsDifference(),2)+
                  "\n---\n"+
                  "SmallestSegment(): "+::DoubleToString(SmallestSegment()/_Point,0)+"\n"+
                  "LargestSegment(): "+::DoubleToString(LargestSegment()/_Point,0)+"\n"+
                  "LeastNumberOfSegmentBars(): "+string(LeastNumberOfSegmentBars())+"\n"+
                  "MostNumberOfSegmentBars(): "+string(MostNumberOfSegmentBars());
//---
   ::Comment(comment);
  }
void CZigZagModule::CommentZigZagDataMy(string str)
  {
   string comment="Current direction : "+string(m_direction);

   if(str != "")
     {
      comment+="\n---\n";
      comment += str;
      comment+="\n";
     }
//---
   if(m_copy_extremums>1)
     {      
      comment+="\n---\n";
      for(int i=0; i<m_segments_total-1; i++)
         comment=comment+"segment_size["+string(i)+"]: "+SegmentSizeToString(i)+"; ("+string(SegmentBars(i))+"); "+::DoubleToString(PercentDeviation(i),2)+" %\n";
      //---
      comment+="...";
     }
//---
   ::Comment(comment);
  }
//+------------------------------------------------------------------+
//| Segment size to the string                                       |
//+------------------------------------------------------------------+
string CZigZagModule::SegmentSizeToString(const int index)
  {
   return((string)(int)(SegmentSize(index)/_Point));
  }
//+------------------------------------------------------------------+
//| Pattern 1                                                        |
//+------------------------------------------------------------------+
int CZigZagModule::Pattern1(const double outer_dev,const double inner_dev)
  {
   if(m_segments_total<4)
     {
      ::Print(__FUNCTION__," > Insufficient segments for defining a pattern! A minimum of 4 (5) segments (3 high/low extremums) required.");
      return(0);
     }
//---
   if(SegmentSize(1)<=0 || SegmentSize(2)<=0 || SegmentSize(3)<=0)
      return(0);
//---
   bool condition1=::fabs(SegmentSize(0)/SegmentSize(1)*100-100) > outer_dev;
   bool condition2=::fabs(SegmentSize(2)/SegmentSize(3)*100-100) > outer_dev;
   bool condition3=::fabs(SegmentSize(1)/SegmentSize(2)*100-100) < inner_dev;
//---
   if(m_direction<0)
     {
      bool condition4=m_zz_low[0]<m_zz_low[1] && m_zz_low[2]<m_zz_low[1];
      //---
      if(condition1 && condition2 && condition3 && condition4)
        {
         ::Print(__FUNCTION__,"(): >>> BUY SIGNAL");
         return(1);
        }
     }
   else
      if(m_direction>0)
        {
         bool condition4=m_zz_high[0]>m_zz_high[1] && m_zz_high[2]>m_zz_high[1];
         //---
         if(condition1 && condition2 && condition3 && condition4)
           {
            ::Print(__FUNCTION__,"(): >>> SELL SIGNAL");
            return(-1);
           }
        }
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Formata double para string + %                                   |
//+------------------------------------------------------------------+
string CZigZagModule::StringPercent(double value)
  {
   return DoubleToString(value,2)+" %";
  }
//+------------------------------------------------------------------+
//| Retorna o % do rompimento                                        |
//+------------------------------------------------------------------+
double CZigZagModule::PercentDisruption(int index)
  {
   double value = PercentDeviation(index)-100;
   if(value <= 0)
      return 0;
   return value;
  }
//+------------------------------------------------------------------+

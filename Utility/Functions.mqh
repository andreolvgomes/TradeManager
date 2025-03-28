//+------------------------------------------------------------------+
//|                                                    Functions.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <TradeManager\ManagerRisk.mqh>
#include <TradeManager\ManagerExpert.mqh>

#include <TradeManager\Utility\Series.mqh>
#include <TradeManager\Utility\Logs.mqh>
#include <TradeManager\Utility\Painel.mqh>

Painel painel;

//-- funções úteis
class Functions
  {
private:
   datetime          m_day_detected;
   ENUM_TIMEFRAMES   m_timeframe;
   string            m_symbol;

public:
                     Functions();
                    ~Functions();

   Series            m_series;
   void              Init(string symbol, ENUM_TIMEFRAMES timeframe);
   double            High(int index);
   double            Close(int index);
   datetime          Time(int index);
   double            Open(int index, ENUM_TIMEFRAMES timeframe = WRONG_VALUE);
   bool              IsNewDay();
   void              RemoveGrade();
   void              SaveCsv(string text);
   void              HistoryProfit(double &tottrades, double &dayProfit,double &weekProfit, double &monthProfit);
   bool              IsBackTest();
   void              CretaLine(string name, double price);
   void              LinesStartEnd(datetime start, datetime encerr_daytrade, datetime closeAll);
   void              RemoveLinesStartEnd();
   void              OnTradeRefresh(ManagerRisk *risk);
   void              TradeRefreshPainel(ManagerExpert *manager);
   void              HistoryProfit();
   void              RemoveAllObjects();
   void              CriaPainel();
   void              PainelNewDay();
   bool              IsNewBar();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Functions::Functions()
  {
   m_series = new Series;
   m_day_detected = 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Functions::~Functions()
  {
  }
//--start
void Functions::Init(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   m_series.Init(symbol, timeframe);
   m_timeframe = timeframe;
   m_symbol = symbol;
  }
//--
double Functions::Close(int index)
  {
   return m_series.Close(index);
  }
//--
double Functions::High(int index)
  {
   return m_series.High(index);
  }
//--
datetime Functions::Time(int index)
  {
   return m_series.Time(index);
  }
//--
double Functions::Open(int index, ENUM_TIMEFRAMES timeframe = WRONG_VALUE)
  {
   return m_series.Open(index, timeframe);
  }
//--É um novo dia
bool Functions::IsNewDay()
  {
   if(m_day_detected == 0)
     {
      m_day_detected = TimeCurrent();
      return(true);
     }
   if(TimeToString(m_day_detected, TIME_DATE) != TimeToString(TimeCurrent(), TIME_DATE))
     {
      m_day_detected = TimeCurrent();
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
void Functions::RemoveGrade()
  {
   ChartSetInteger(0,CHART_SHOW_GRID,false); // false to remove grid
  }
//+------------------------------------------------------------------+
void Functions::HistoryProfit(double &tottrades, double &dayProfit,double &weekProfit, double &monthProfit)
  {
   datetime histStart,monthStart,weekStart,todayStart,now;
   double dayBalanceChg=0;
   double weekBalanceChg=0;
   double monthBalanceChg= 0;
   double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   dayProfit=0;
   monthProfit=0;
   weekProfit=0;

// Hora atual
   now=TimeCurrent();
   histStart=monthStart=iTime(NULL,PERIOD_MN1,0);
   weekStart=iTime(NULL,PERIOD_W1,0);
   todayStart=StringToTime(TimeToString(TimeCurrent(),TIME_DATE));
   tottrades=0;
   long  idold=0;

   if(HistorySelect(histStart,now))
     {
      /*
       int hist_ord_tot=HistoryOrdersTotal();
       int ord_tot     =OrdersTotal();
       int deal_tot    =HistoryDealsTotal();
       int pos_tot     =PositionsTotal();
      */

      for(int hd=0; hd<HistoryDealsTotal(); hd++)
        {
         ulong histDealInTicket=HistoryDealGetTicket(hd);
         long  dealType=(ENUM_DEAL_TYPE) HistoryDealGetInteger(histDealInTicket,DEAL_TYPE);
         datetime dealtime   = (datetime) HistoryDealGetInteger(histDealInTicket, DEAL_TIME);
         double   dealProfit = HistoryDealGetDouble(histDealInTicket, DEAL_PROFIT);
         long  dealEntry;
         long  sss=0;
         switch((ENUM_DEAL_TYPE) dealType)
           {
            case DEAL_TYPE_BUY:
            case DEAL_TYPE_SELL:
               // Operacoes realizadas
               dealEntry=(ENUM_DEAL_ENTRY) HistoryDealGetInteger(histDealInTicket,DEAL_ENTRY);
               sss=HistoryDealGetInteger(histDealInTicket,DEAL_POSITION_ID);

               if(StringToTime(TimeToString(dealtime,TIME_DATE))==todayStart && sss!=idold)
                 {
                  tottrades++;
                  idold=sss;
                 }

               if((dealEntry==DEAL_ENTRY_OUT) || (dealEntry==DEAL_ENTRY_INOUT) || (dealEntry==DEAL_ENTRY_OUT_BY))
                 {
                  if(dealtime>=monthStart)
                     monthProfit+=dealProfit;
                  if(dealtime>=weekStart)
                     weekProfit+=dealProfit;
                  if(dealtime>=todayStart)
                     dayProfit+=dealProfit;
                 }
               break;

            case DEAL_TYPE_BALANCE:
            case DEAL_TYPE_CORRECTION:
            case DEAL_TYPE_BONUS:
            case DEAL_TYPE_CHARGE:
            case DEAL_TYPE_COMMISSION:
            case DEAL_TYPE_COMMISSION_AGENT_DAILY:
            case DEAL_TYPE_COMMISSION_AGENT_MONTHLY:
            case DEAL_TYPE_COMMISSION_DAILY:
            case DEAL_TYPE_COMMISSION_MONTHLY:
            case DEAL_TYPE_CREDIT:
            case DEAL_TYPE_INTEREST:

               // Mudancas no saldo
               if(dealtime>=monthStart)
                  monthBalanceChg+=dealProfit;
               if(dealtime>=weekStart)
                  weekBalanceChg+=dealProfit;
               if(dealtime>=todayStart)
                  dayBalanceChg+=dealProfit;

               break;
           }
        }
     }

   double dayInitialBalance   = currentBalance - dayBalanceChg - dayProfit;
   double weekInitialBalance  = currentBalance - weekBalanceChg - weekProfit;
   double monthInitialBalance = currentBalance - monthBalanceChg - monthProfit;
  }
//+------------------------------------------------------------------+
//--
bool Functions::IsBackTest()
  {
   return(MQL5InfoInteger(MQL5_TESTER));
  }
//+------------------------------------------------------------------+
//--Cria linha horizontal
void Functions::CretaLine(string name, double price)
  {
   ObjectDelete(0,name);

   ObjectCreate(0,name,OBJ_HLINE,0,0,price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrYellow);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DASHDOTDOT);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
  }
//
void Functions::RemoveLinesStartEnd()
  {
   ObjectDelete(0,"start_vline");
   ObjectDelete(0,"encerr_vline");
   ObjectDelete(0,"stopall_vline");
  }
//--
void Functions::LinesStartEnd(datetime start, datetime encerr_daytrade, datetime closeAll)
  {
   RemoveLinesStartEnd();

//-- Hora de início
   ObjectCreate(0,"start_vline",OBJ_VLINE,0,start,0.0);
   ObjectSetInteger(0,"start_vline",OBJPROP_COLOR,clrGreen);
   ObjectSetInteger(0,"start_vline",OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,"start_vline",OBJPROP_WIDTH,1);

//-- Hora de Encerramento do dia
   ObjectCreate(0,"encerr_vline",OBJ_VLINE,0,encerr_daytrade,0.0);
   ObjectSetInteger(0,"encerr_vline",OBJPROP_COLOR,clrOrange);
   ObjectSetInteger(0,"encerr_vline",OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,"encerr_vline",OBJPROP_WIDTH,1);

//-- Hora de Encerramento das posições
   ObjectCreate(0,"stopall_vline",OBJ_VLINE,0,closeAll,0.0);
   ObjectSetInteger(0,"stopall_vline",OBJPROP_COLOR,clrRed);
   ObjectSetInteger(0,"stopall_vline",OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,"stopall_vline",OBJPROP_WIDTH,1);
  }
//--
void Functions::OnTradeRefresh(ManagerRisk *risk)
  {
   painel.RefreshTrade(WRONG_VALUE,0,0,0);

   bool max_profit = false;
   bool max_loss = false;
   bool max_inputs = false;

   if(risk.CheckLimits(max_profit, max_loss, max_inputs))
      painel.MetaBatida(max_profit, max_loss, max_inputs);

   HistoryProfit();
  }
//--
void Functions::HistoryProfit()
  {
   double tottrades;
   double dayprofit;
   double weekprofit;
   double monthprofit;

   HistoryProfit(tottrades, dayprofit, weekprofit, monthprofit);
   painel.HistoryProfit(tottrades,dayprofit, weekprofit, monthprofit);
  }
//--
void Functions::RemoveAllObjects()
  {
   painel.DeletePanel();
   RemoveLinesStartEnd();
  }
//--
void Functions::CriaPainel()
  {
   painel.CriaPainel();
  }
//--
void Functions::TradeRefreshPainel(ManagerExpert *manager)
  {
   double profit = 0;
   double point = 0;
   double volume = 0;
   ENUM_POSITION_TYPE position_type;

   if(manager.StatePositionOpen(profit, point, volume, position_type))
      painel.RefreshTrade(position_type,profit, point,volume);
  }
//--
void Functions::PainelNewDay()
  {
   HistoryProfit();
   painel.MetaBatida(false, false, false);
  }

//+------------------------------------------------------------------+
//--
static datetime last_time=0;
//--
bool Functions::IsNewBar()
  {
//--- memorize the time of opening of the last bar in the static variable
//--- current time
   datetime lastbar_time=SeriesInfoInteger(m_symbol,m_timeframe,SERIES_LASTBAR_DATE);
//--- if it is the first call of the function
   if(last_time==0)
     {
      //--- set the time and exit
      last_time=lastbar_time;
      return(false);
     }
//--- if the time differs
   if(last_time!=lastbar_time)
     {
      //--- memorize the time and return true
      last_time=lastbar_time;
      return(true);
     }
//--- if we passed to this line, then the bar is not new; return false
   return(false);
  }
//+------------------------------------------------------------------+
void Functions::SaveCsv(string text)
  {
   string             InpDirectoryName=""; // nome do diretório
   string             InpFileName="dataset.csv";  // nome do arquivo

   int file_handle=FileOpen(InpDirectoryName+"//"+InpFileName,FILE_READ|FILE_WRITE|FILE_CSV);
   if(file_handle!=INVALID_HANDLE)
     {
      FileSeek(file_handle,0,SEEK_END);
      FileWrite(file_handle, text);
      FileClose(file_handle);
     }
   else
     {
      PrintFormat("Falha para abrir %s arquivo, Código de erro = %d",InpFileName,GetLastError());
     }
  }

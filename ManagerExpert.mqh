//+------------------------------------------------------------------+
//|                                                ManagerExpert.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include  <Trade\Trade.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\HistoryOrderInfo.mqh>
#include <Indicators\Indicators.mqh>

#include <TradeManager\ManagerSignal.mqh>
#include <TradeManager\ManagerTrailing.mqh>
#include <TradeManager\ManagerTrade.mqh>
#include <TradeManager\ManagerRisk.mqh>

struct SPartialEntry
  {
   double            lot;       // Tamanho do lote
   int               distance;  // Distância em pontos
  };
struct SBreakEvenEntry
  {
   double            stopGain;
   double            distance;
  };
struct SPartilOut
  {
   double            lot;
   double            distance;
   bool              done;
  };
//+------------------------------------------------------------------+


//-- Classe responvável por gerenciar as entradas e posições abertas
class ManagerExpert : public CObject
  {
private:
   SPartialEntry     m_partials[];
   SBreakEvenEntry   m_breakeven[];
   SPartilOut        m_partial_out[];
   int               m_count_partials;      // Contador de entradas
   int               m_count_breakeven;
   int               m_count_partial_out;

   ENUM_TIMEFRAMES   m_period;
   ulong             magic;
   CSymbolInfo       *m_symbol;         // pointer to the object-symbol
   CPositionInfo     m_position;                 // position info object
   COrderInfo        m_order;                    // order info object
   ManagerTrade      m_trade;
   ManagerSignal     *m_signal;
   ManagerTrailing   *m_trailing;
   ManagerRisk       *m_risk;
   //double            m_lot;
   datetime          m_time_expiration;               // time expiration order
   datetime          m_time_new_day;
   int               m_expiration;     // time of expiration of a pending order in bars
   double            m_adjusted_point; // "weight" 2/4 of a point
   int               m_pos_tot;
   bool              m_lookingfor_signal_allday;

   //-- variáveis para controle de algumas rotinas
   double            position_lot_initial;
   double            position_sl_initial;

   ulong             backtest_position_las_identifier;

   //-- variáveis para controle de horários
   string            m_hour_start;
   string            m_hour_end_daytrade;
   string            m_hour_close_positions;

public:
                     ManagerExpert();

   void              AddPartialEntry(double lot, int distance);
   void              AddBreakEven(double distance, double stopGain);
   void              AddPartialOut(double lot, double distance);

   ulong             position_las_identifier;
   ENUM_POSITION_TYPE              current_position;
   //ulong             m_identifier;
   CLog*             Log;                 // Logging
   void              Execute();
   void              OnManager();
   bool              BackTestIsNewTrade();
   bool              Init(ENUM_TIMEFRAMES period,ulong magic);

   //-- funções para injetar/definir tempo para experirar um ordem pendente e horários de operações
   void              SetExpiration(int value)            {  m_expiration = value;  };
   void              SetHoursLimits(string hour_start, string hour_end_daytrade, string hour_close_positions) {   m_hour_start = hour_start; m_hour_end_daytrade=hour_end_daytrade; m_hour_close_positions=hour_close_positions; };
   void              SetLookingSignalAllDay(bool value) {m_lookingfor_signal_allday  = value;}

   //-- horários de operação
   datetime          HourStart();
   datetime          HourCloseAll();
   datetime          HourEndDay();

   bool              StatePositionClose();
   bool              StatePositionOpen(double &profit, double &profitPoint, double &volume, ENUM_POSITION_TYPE &position_type);

   //-- Inicializadores
   void              InitSignal(ManagerSignal *signal);
   void              InitTrailing(ManagerTrailing *trailing);
   void              InitRisk(ManagerRisk *risk);

   bool              SelectPosition();
   bool              CheckHourDayTrade();

private:
   void              LogError(string function, string text);
   void              LogInf(string function, string text);
   string            Message(string text);
   bool              CheckLimits();
   bool              IsNewDay();
   void              ResetInNewDay();
   bool              CheckLimitsDayOperations();
   bool              LookingforSignalAllDay();
protected:

   bool              Refresh();
   bool              Processing();
   bool              OpenPosition();
   //bool              IsNewBar();
   datetime          GetExpiration();

   //-- funçõs abertura de trade
   bool              CheckOpenBuy();
   bool              CheckOpenSell();
   bool              OpenBuy(double price,double sl,double tp);
   bool              OpenSell(double price,double sl,double tp);
   bool              CheckCloseInputPartial();
   bool              CheckClose();

   //-- funções Trailing Stop
   bool              CheckTrailingStop(void);
   bool              CheckTrailingStopBuy(void);
   bool              TrailingStopBuy(double sl,double tp);
   bool              CheckTrailingStopSell(void);
   bool              TrailingStopSell(double sl,double tp);

   //-- funções para abertura e controle de Ordens Pendentes BuyStop/SellStop
   bool              CheckDeleteOrderBuy();
   bool              CheckDeleteOrderSell();
   bool              CheckRefreshOrderSell();
   bool              CheckRefreshOrderBuy();
   bool              ModifyOrderBuy(double price,double sl,double tp,datetime expiration);
   bool              ModifyOrderSell(double price,double sl,double tp,datetime expiration);

   //-- funções para reversão
   bool              CheckReverse();
   bool              CheckReverseBuy();
   bool              CheckReverseSell();
   bool              ReverseBuy(double price,double sl,double tp);
   bool              ReserveSell(double price,double sl,double tp);
   bool              CheckDeleteOrderReserve();
   bool              CheckRefreshReverseBuy();
   bool              CheckRefreshReverseSell();

   //-- funções úteis para delete de ordens
   bool              DeleteOrders();
   bool              DeleteOrdersLimit(ENUM_ORDER_TYPE order_type);
   bool              SellPending();
   bool              BuyPending();

   //-- funções para executar entradas parciais
   bool              OpenInputPartial();
   bool              CheckParamInputPartial();
   bool              CheckInputOrderLimit(ENUM_ORDER_TYPE order_limit_type);
   bool              OpenInputBuyLimit();
   bool              OpenInputSellLimit();
   bool              OpenSellLimit(double lot, double level);
   bool              OpenBuyLimit(double lot, double level);

   //-- funções para executar saídas parciais
   void              ExecuteOutputPartial();
   bool              OutputPartial(double lot, double level);

   //-- funções para executar break even
   void              ExecuteBreakEven();
   bool              BreakEven(double level, double stopgain);

   //-- outras funções necessárias
   bool              ModifyTakeProfit();
   bool              CheckNewPosition();
   void              ResetVariablePosition();
   void              CheckCloseAll();
   bool              CloseAll(double lot);
   bool              CheckPositionProtected();
   void              AccountProfit(double &profit, double &point);
  };
//-- Construtor com inicialização padrão das variáveis
ManagerExpert::ManagerExpert()
  {
   Log=CLog::GetLog();
   current_position = WRONG_VALUE;
   m_expiration=0;// 1 minuto padrão para cancelar ordem pendente, SellStop e BuyStop
//m_identifier = 0;

   m_adjusted_point    =10;
   m_time_new_day = 0;
   m_hour_start = "";
   m_hour_end_daytrade = "";
   m_hour_close_positions  = "";

//double            m_lot;
   m_time_expiration = 0;               // time expiration order
   m_time_new_day = 0;
   m_adjusted_point = 0; // "weight" 2/4 of a point
   m_pos_tot = 0;

//-- variáveis para controle de algumas rotinas
   position_lot_initial =0;
   position_sl_initial =0;
   position_las_identifier =0;
   backtest_position_las_identifier = 0;

//-- horários
   m_hour_start="";
   m_hour_end_daytrade="";
   m_hour_close_positions="";
  }
//-- Inicialziação de variáveis e outras classes/objetos
bool ManagerExpert::Init(ENUM_TIMEFRAMES period,ulong magic)
  {
   m_period = period;
   magic = magic;

   m_symbol=new CSymbolInfo;
   m_symbol.Name(Symbol());

   m_order=new COrderInfo;
   m_position=new CPositionInfo;

//-- init ctrade
   m_trade = new CTrade;
   m_trade.SetSymbol(GetPointer(m_symbol));
   m_trade.SetExpertMagicNumber(magic);
   m_trade.SetTypeFilling(ORDER_FILLING_IOC);

//m_trade.SetSymbol(GetPointer(m_symbol));
   m_trade.SetExpertMagicNumber(magic);
   m_trade.SetMarginMode();

//--- tuning for 3 or 5 digits
   int digits_adjust=(m_symbol.Digits()==3 || m_symbol.Digits()==5) ? 10 : 1;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

//--- set default deviation for trading in adjusted points
   m_trade.SetDeviationInPoints((ulong)(3*m_adjusted_point/m_symbol.Point()));

   m_trailing = new ManagerTrailing;

   return(true);
  }
//-- Inicializa Sinal/Técnica
void ManagerExpert::InitSignal(ManagerSignal *signal)
  {
   if(m_signal!=NULL)
      delete m_signal;
   m_signal = signal;
   m_signal.Init(m_period, GetPointer(m_symbol), &m_order);
  }
//-- Inicializa Trailing Stop
void ManagerExpert::InitTrailing(ManagerTrailing *trailing)
  {
   if(m_trailing!=NULL)
      delete m_trailing;

   m_trailing = trailing;
   m_trailing.Init(m_period, GetPointer(m_symbol));
  }
//-- Inicializa Gerencimento de Risco
void ManagerExpert::InitRisk(ManagerRisk *risk)
  {
   m_risk = risk;
//m_risk.BalanceDay();
  }
//-- Executa gerenciador de trades/entradas/saídas etc ...
void ManagerExpert::Execute()
  {
//-- atualiza as informações
   if(!Refresh())
      return;
   ResetInNewDay();

   Processing();

   if(m_lookingfor_signal_allday)
     {
      if(CheckLimitsDayOperations()==false)
         LookingforSignalAllDay();
     }
  }
//-- Processa/Gerencia tudo
bool ManagerExpert::Processing()
  {
//-- verifica encerramento do dia
   CheckCloseAll();
   current_position = WRONG_VALUE;

//m_identifier = m_position.Identifier();
   if(SelectPosition())
     {
      //-- verifica se a posição atual é diferente da anterior, pois pode acontecer de na virada de mão já
      //-- entrar numa nova operação, nesse caso as variáveis de controle deverão ser resetadas
      CheckNewPosition();

      //-- guarda o preço do stop loss original
      if(position_sl_initial == 0)
         position_sl_initial = m_position.StopLoss();

      ModifyTakeProfit();

      //-- guarda informação de qual tá sendo a posição, assim quando a posição for encerrada
      //-- mais abaixo podemos encerrar as ordens limit de entradas parciais caso não sejam executadas
      current_position = m_position.PositionType();

      //-- gerencia saídas parciais
      ExecuteOutputPartial();

      //-- gerencia break even
      ExecuteBreakEven();

      //-- gerencia entradas parciais
      OpenInputPartial();

      //-- gerencia cancelamento de ordens de reversão de posição
      CheckDeleteOrderReserve();

      if(CheckHourDayTrade())
        {
         //-- trata uma possível reversão de posição
         if(CheckReverse())
            return(true);
        }

      if(!CheckClose())
        {
         //-- verifica a possibilidade de fazer alteração na posição
         if(CheckTrailingStop())
            return(true);
         return(false);
        }
     }
   else
     {
      ResetVariablePosition();
     }

//-- se tinha uma posição aberta e tbm ordens posicionadas para entradas parciais, então cancela tudo
   CheckCloseInputPartial();

//--- check if plased pending orders
   int total=OrdersTotal();
   if(total!=0)
     {
      //-- procura pela última ordem posicionada
      for(int i=total-1; i>=0; i--)
        {
         m_order.SelectByIndex(i);
         if(m_order.Symbol()!=m_symbol.Name())
            continue;

         if(m_order.OrderType()==ORDER_TYPE_BUY_LIMIT || m_order.OrderType()==ORDER_TYPE_BUY_STOP)
           {
            if(CheckDeleteOrderBuy())
               return(true);

            //-- verifica a possibilidade de fazer mudanças na order stop
            if(CheckRefreshOrderBuy())
               return(true);
           }
         else
           {
            if(CheckDeleteOrderSell())
               return(true);

            //-- verifica a possibilidade de fazer mudanças na order stop
            if(CheckRefreshOrderSell())
               return(true);
           }
         //-- nada feito
         return(false);
        }
     }

   if(CheckLimitsDayOperations()==false)
      return false;

//-- check abertura de nova posição
   if(OpenPosition())
      return(true);

   return(false);
  }
//+------------------------------------------------------------------+
bool ManagerExpert::CheckLimitsDayOperations()
  {
//-- verifica horários para operar
   if(CheckHourDayTrade()==false)
      return false;

//-- check os limites do dia
   if(CheckLimits())
      return false;
   return true;
  }
//-- Verifica sinal para abertura de posições(buy/sell) ou posicionamento de ordens pendentes(sell stop/buy stop)
//-- ou (sell limit/buy limit)
bool ManagerExpert::OpenPosition()
  {
//int totPositions = PositionsTotal();
   if(CheckOpenBuy())
      return(true);
   if(CheckOpenSell())
      return(true);
//-- returna que nada foi feito
   return(false);
  }
//-- Verifica se é necessário executa fechamento de posições e/ou ordens pendentes
//-- caso seja necessário executa e retorna :true
bool ManagerExpert::CheckClose()
  {
   if(m_risk.CheckClose(GetPointer(m_position)))
      return(CloseAll(m_position.Volume()));
   return(false);
  }
//-- Verifica limites de horários de encerramento do dia e fecha tudo, posições e ordens pendentes
void ManagerExpert::CheckCloseAll()
  {
   datetime closeAll = HourCloseAll();
   datetime timeCurrent = TimeCurrent();

//if(closeAll == 0 || timeCurrent >= closeAll) //31/10/2019
   if(closeAll != 0 && timeCurrent >= closeAll) //31/10/2019
     {
      int total=OrdersTotal();
      if(total != 0 || m_position.Volume() > 0)
         CloseAll(m_position.Volume());
     }
  }
//-- Verifica se hora corrente está dentro dos limites de operação
//-- Se sim: Sim, opera
//-- Se não: Não, não pera
bool ManagerExpert::CheckHourDayTrade()
  {
   datetime start = HourStart();
   datetime enddaytrade  = HourEndDay();
   datetime timeCurrent = TimeCurrent();

//-- se o horário de início é maior/igual ao atual e a hora de encerramento é menor/igual do que a atual
//-- então tá dentro do horário de operar
   if(start == 0 && enddaytrade == 0)
      return(true);

   if(start != 0 && enddaytrade != 0)
     {
      if(timeCurrent>=start && timeCurrent<=enddaytrade)
         return(true);
      return(false);
     }

   if(start != 0 && timeCurrent>=start)
      return(true);
   if(enddaytrade != 0 && timeCurrent<=enddaytrade)
      return(true);
   return(false);
  }
//-- Fecha todas as posições e ordens pendentes
bool ManagerExpert::CloseAll(double lot)
  {
   bool result=false;
   if(m_position.PositionType() == POSITION_TYPE_BUY)
      result=m_trade.Sell(lot,0,0,0);
   else
      result=m_trade.Buy(lot,0,0,0);
   result|=DeleteOrders();
//---
   return(result);
  }
//-- Gerencia execução de Break Even
void ManagerExpert::ExecuteBreakEven()
  {
//-- verifica se tem algum break even definido
   if(m_count_breakeven > 0)
     {
      for(int i = 0; i < m_count_breakeven; i++)
        {
         if(BreakEven(m_breakeven[i].distance, m_breakeven[i].stopGain))
           {
            if(current_position == POSITION_TYPE_BUY)
               DeleteOrdersLimit(ORDER_TYPE_BUY_LIMIT);
            else
               DeleteOrdersLimit(ORDER_TYPE_SELL_LIMIT);
           }
        }
     }
  }
//-- Executa de fato o break even na posição aberta
bool ManagerExpert::BreakEven(double level, double stopgain)
  {
   if(level <= 0 || stopgain <= 0)
      return(false);

//-- verifica se a posição tá protegida, se protegida então alguma ação já levou stop pra dentro
   if(CheckPositionProtected())
     {
      double dist_stopgain = MathAbs(m_position.PriceOpen()-m_position.StopLoss());
      //-- verifica se a distância entre o stop e o preço de abertura é igual ou inferior ao break even
      //-- se for nem precisa fazer break even, pois já foi feito ou outra proteção superior foi feita,, exem: trailing
      if(stopgain <= dist_stopgain)
         return(false);
     }

   double pos_account_profit = 0;
   double pos_account_point = 0;
   AccountProfit(pos_account_profit, pos_account_point);

   if(pos_account_point >= level)
     {
      double sl = 0;
      if(m_position.PositionType() == POSITION_TYPE_BUY)
         sl = m_symbol.NormalizePrice(m_position.PriceOpen() + stopgain);
      else
         sl = m_symbol.NormalizePrice(m_position.PriceOpen() - stopgain);

      if(m_trade.PositionModify(m_position.Ticket(), sl, m_position.TakeProfit()))
         return(true);
     }
   return(false);
  }
//-- Obtem informações Profit em Pontos e R$ da posição aberta
void ManagerExpert::AccountProfit(double &profit, double &point)
  {
   profit=AccountInfoDouble(ACCOUNT_PROFIT);
   point=(profit/0.2)/m_position.Volume();
  }
//-- Gerencia execução de saídas parciais
void ManagerExpert::ExecuteOutputPartial()
  {
   for(int i = 0; i < m_count_partial_out; i++)
     {
      if(m_partial_out[i].done == false)
         m_partial_out[i].done = OutputPartial(m_partial_out[i].lot, m_partial_out[i].distance);
     }
  }
//-- Executa de fato a saída parcial da posição aberta
bool ManagerExpert::OutputPartial(double lot, double level)
  {
   double position_volume = m_position.Volume();
   if(lot <= 0 || level <= 0 || lot> position_volume)
      return(false);

   double pos_account_profit = 0;
   double pos_account_point = 0;
   AccountProfit(pos_account_profit, pos_account_point);

   if(pos_account_profit > 0)
     {
      if(pos_account_point >= level)
        {
         bool result = false;
         //-- executa a saída parcial
         if(m_position.PositionType() == POSITION_TYPE_BUY)
            result = m_trade.Sell(lot,_Symbol,m_symbol.Bid());
         else
            result = m_trade.Buy(lot,_Symbol,m_symbol.Ask());
         return(result);
        }
     }
   return(false);
  }
//-- Verifica se a posição aberta trata-se de uma nova;
//-- Só é possível obter essa informação 1 única vez
//-- pos após a primeira execução, a posição aberta deixa de ser uma nova e se torna atual
bool ManagerExpert::CheckNewPosition()
  {
   ulong position_identifier=PositionGetInteger(POSITION_IDENTIFIER);
   if(position_identifier>0 && position_las_identifier!=position_identifier)
     {
      position_las_identifier=position_identifier;
      ResetVariablePosition();
      return true;
     }
   return false;
  }
//-- Resetar as variáveis de controle de posição. A cada encerramento de posição é necessário resetar
//-- para iniciar um novo controle
void ManagerExpert::ResetVariablePosition()
  {
   for(int i = 0; i < m_count_partial_out; i++)
      m_partial_out[i].done = false;

   position_lot_initial = 0;
   position_sl_initial = 0;
  }
//-- Faz modificação do Take Profit, isso só vai acontecer em casos de entradas parciais. Pois, nesses casos
//-- o preço da posição muda, então é necessário atualizar o preço do take profit também
bool ManagerExpert::ModifyTakeProfit()
  {
   if(position_lot_initial == 0)
     {
      position_lot_initial = m_position.Volume();
      return(false);
     }

//-- verifica se o lot inicial é diferente do atual
//-- se diferente quer dizer que houve entra/saída parcial, então vamos verificar se é necessário
//-- ajustar o takeprofit... o ajuste do takeprofit é feito somente para entradas parciais
   if(position_lot_initial != m_position.Volume())
     {
      position_lot_initial = m_position.Volume();

      double signal_takeprofit=m_signal.TakeProfit();
      if(signal_takeprofit > 0)
        {
         //-- verifica se o TakeProfit tá no mesmo posicionamento definido pelo Signal
         //-- se tiver quer dizer que a mudança no volume foi devido saídas parciais, então não faz ajuste no take
         double dist_takeprofit = MathAbs(m_position.TakeProfit() - m_position.PriceOpen());
         if(dist_takeprofit==signal_takeprofit)
            return(false);

         double position_sl = m_position.StopLoss();
         double tp = 0;

         if(m_position.PositionType() == POSITION_TYPE_BUY)
            tp = m_symbol.NormalizePrice(m_position.PriceOpen()+m_signal.TakeProfit());
         else
            tp = m_symbol.NormalizePrice(m_position.PriceOpen()-m_signal.TakeProfit());

         if(m_trade.PositionModify(m_position.Ticket(), position_sl, tp))
            return(true);
        }
     }
   return(false);
  }
//-- Gerencia o posicionamento de ordens limit para entradas parciais
//-- caso o preço do stop loss seja do stop loss inicial, então alguma rotina de
//-- proteção foi executa, nesse caso não precisa fazer entradas parciais
bool ManagerExpert::OpenInputPartial()
  {
//-- se a posição tem um stop definido e o atual stop é diferente do stop inicial
//-- então o trailing stop foi executado
   if(position_sl_initial != m_position.StopLoss())
      return(false);

//-- verifica se a posição tá protegido com stop gain, se tiver não faz entradas parciais
   if(CheckPositionProtected())
      return(false);

//--
   if(!CheckParamInputPartial())
      return(false);

   if(m_position.PositionType() == POSITION_TYPE_BUY)
     {
      //-- organizar entradas parciais para compra
      if(!CheckInputOrderLimit(ORDER_TYPE_BUY_LIMIT))
         return OpenInputBuyLimit();
     }
   else
     {
      //-- organizar entradas parciais para venda
      if(!CheckInputOrderLimit(ORDER_TYPE_SELL_LIMIT))
         return OpenInputSellLimit();
     }
//-- nada feito
   return(false);
  }
//-- Verifica se existe alguma ordem limit posicionada para a operação corrente: ENUM_ORDER_TYPE
bool ManagerExpert::CheckInputOrderLimit(ENUM_ORDER_TYPE order_limit_type)
  {
   int total=OrdersTotal();
   int quantity=0;
   if(total!=0)
     {
      for(int i=total-1; i>=0; i--)
        {
         m_order.SelectByIndex(i);
         if(m_order.Symbol()!=m_symbol.Name())
            continue;
         if(m_order.OrderType()==order_limit_type)
            quantity++;
        }
     }
   return (quantity > 0);
  }
//-- Verifica se foi configurado para fazer entradas parciais
bool ManagerExpert::CheckParamInputPartial()
  {
   return (m_count_partials > 0);
  }
//-- Executa entradas parciais para posição aberta de venda
bool ManagerExpert::OpenInputSellLimit()
  {
   for(int i = 0; i < m_count_partials; i++)
      OpenSellLimit(m_partials[i].lot, m_partials[i].distance);
   return (false);
  }
//-- Executa entradas parciais para posição aberta de compra
bool ManagerExpert::OpenInputBuyLimit()
  {
   for(int i = 0; i < m_count_partials; i++)
      OpenBuyLimit(m_partials[i].lot, m_partials[i].distance);
   return (false);
  }
//-- Posiciona order limit para entrada em venda parcial
bool ManagerExpert::OpenSellLimit(double lot, double level)
  {
   if(lot <=0 && level<=0)
      return(false);

   double price_limit = m_symbol.NormalizePrice(m_position.PriceOpen()+level);
//-- para entradas parciais o StopLoss deve ser posicionado
   double position_sl = m_position.StopLoss();

//-- não precisa posiconar o TakeProfit para entradas parciais, ao sair no Take da entrada original
//-- o meta encerra tudo. O não posicionar TakeProfit para Order Limit já é um trabalho a menos na hora de
//-- ajustar o TakeProfit da posição, em teste foi concluído tudo isso
   double position_tp = 0;//m_position.TakeProfit();

//-- check se a entrada parcial tá sendo abaixo do stop loss
//-- a entrada deve ser na zona entre o preço de abertura e o stop loss
   if(price_limit >= position_sl)
      return(false);

   if(m_trade.SellLimit(lot, price_limit, _Symbol, position_sl,position_tp))
      return true;
   return(false);
  }
//-- Posiciona order limit para entrada em compra parcial
bool ManagerExpert::OpenBuyLimit(double lot, double level)
  {
   if(lot <=0 && level<=0)
      return(false);

   double price_limit = m_symbol.NormalizePrice(m_position.PriceOpen()-level);
//-- para entradas parciais o StopLoss deve ser posicionado
   double position_sl = m_position.StopLoss();

//-- não precisa posiconar o TakeProfit para entradas parciais, ao sair no Take da entrada original
//-- o meta encerra tudo. O não posicionar TakeProfit para Order Limit já é um trabalho a menos na hora de
//-- ajustar o TakeProfit da posição, em teste foi concluído tudo isso
   double position_tp = 0;//m_position.TakeProfit();

//-- check se a entrada parcial tá sendo acima do stop loss
//-- a entrada deve ser na zona entre o preço de abertura e o stop loss
   if(price_limit <= position_sl)
      return(false);

   if(m_trade.BuyLimit(lot, price_limit, _Symbol, position_sl, position_tp))
      return true;
   return(false);
  }
//-- Verifica se a posição tá protegida com stop loss dentro da posição
bool ManagerExpert::CheckPositionProtected()
  {
   if(m_position.StopLoss() <= 0)
      return(false);

   if(m_position.PositionType() == POSITION_TYPE_BUY)
     {
      //-- se o stop loss tá acima ou no mesmo pç da posição, então tá protegido
      if(m_position.StopLoss()>= m_position.PriceOpen())
         return(true);
     }
   else
     {
      //-- se o stop loss tá abaixo ou no mesmo pç da posição, então tá protegido
      if(m_position.StopLoss()<=m_position.PriceOpen())
         return(true);
     }
   return(false);
  }
//-- Executa atualização da ordem pendente de compra: Isso é necessário quando a ordem stop é posicionada e o preço não executa
//-- e dentro desse tempo é detectado um novo sinal com melhor preço, então o robô vai reposicionar a ordem nesse melhor preço
bool ManagerExpert::CheckRefreshOrderBuy()
  {
   double   price=EMPTY_VALUE;
   double   sl=0.0;
   double   tp=0.0;
   datetime expiration=GetExpiration();
//--- verifica a possiblidade de fazer modificações na order stop buy
   if(m_signal.CheckOpenBuy(price,sl,tp,expiration))
     {
      //-- verifica se o preço é o mesmo, se for nem precisa atualizar
      if(price == m_order.PriceOpen())
         return(false);

      m_time_expiration = expiration;
      return(ModifyOrderBuy(price, sl, tp,expiration));
     }
//--- nada feito
   return(false);
  }
//-- Executa atualização da ordem pendente de compra: Isso é necessário quando a ordem stop é posicionada e o preço não executa
//-- e dentro desse tempo é detectado um novo sinal com melhor preço, então o robô vai reposicionar a ordem nesse melhor preço
bool ManagerExpert::CheckRefreshOrderSell()
  {
   double   price=EMPTY_VALUE;
   double   sl=0.0;
   double   tp=0.0;
   datetime expiration=GetExpiration();
//--- verifica a possiblidade de fazer modificações na order stop buy
   if(m_signal.CheckOpenSell(price,sl,tp,expiration))
     {
      //-- verifica se o preço é o mesmo, se for nem precisa atualizar
      if(price == m_order.PriceOpen())
         return(false);

      m_time_expiration = expiration;
      return(ModifyOrderSell(price, sl, tp,expiration));

     }
//--- nada feito
   return(false);
  }
//-- Executa de fato a modificação da ordem pendente de venda
bool ManagerExpert::ModifyOrderSell(double price,double sl,double tp,datetime expiration)
  {
   if(price==EMPTY_VALUE)
      return(false);

   double m_lot= m_risk.Lots();
   if(m_lot==0.0)
      return(false);
   if(price == m_order.PriceOpen())
      return(false);
//---
   return (m_trade.OrderModify(m_order.Ticket(), price, sl, tp,m_order.TypeTime(), expiration));
  }
//-- Executa de fato a modificação da ordem pendente de compra
bool ManagerExpert::ModifyOrderBuy(double price,double sl,double tp, datetime expiration)
  {
   if(price==EMPTY_VALUE)
      return(false);

   double m_lot= m_risk.Lots();
   if(m_lot==0.0)
      return(false);
   if(price == m_order.PriceOpen())
      return(false);
//---
   return (m_trade.OrderModify(m_order.Ticket(), price, sl, tp,m_order.TypeTime(),expiration));
  }
//-- Gerencia o cancelamento de ordens pendentes de execução de reversão de posição
bool ManagerExpert::CheckDeleteOrderReserve()
  {
   int total=OrdersTotal();
   if(total!=0)
     {
      //-- procura pela última ordem posicionada
      for(int i=total-1; i>=0; i--)
        {
         m_order.SelectByIndex(i);
         if(m_order.Symbol()!=m_symbol.Name())
            continue;

         if(m_position.PositionType() == POSITION_TYPE_BUY)
           {
            //-- se tá comprado, então deve procurar por ordens de venda
            if(m_order.OrderType()==ORDER_TYPE_SELL_LIMIT || m_order.OrderType()==ORDER_TYPE_SELL_STOP)
              {
               if(CheckDeleteOrderSell())
                  return(true);

               if(CheckRefreshReverseSell())
                  return (true);
              }
           }
         else
           {
            //-- se tá vendido, então deve procurar por ordens de compra
            if(m_order.OrderType()==ORDER_TYPE_BUY_LIMIT || m_order.OrderType()==ORDER_TYPE_BUY_STOP)
              {
               if(CheckDeleteOrderBuy())
                  return(true);

               if(CheckRefreshReverseBuy())
                  return (true);
              }
            //--- return without operations
            return(false);
           }
        }
     }
   return (false);
  }
//-- Expiration: Executa cancelamento de ordens pendentes caso o campo limite seja expirado
bool ManagerExpert::CheckDeleteOrderBuy()
  {
//--- check the possibility of deleting the long order
   if(m_time_expiration!=0 && TimeCurrent()>m_time_expiration)
     {
      m_time_expiration=0;
      return(m_trade.OrderDelete(m_order.Ticket()));
     }
   if(m_signal.CheckDeleteOrderBuy())
      return(m_trade.OrderDelete(m_order.Ticket()));

   return(false);
  }
//-- Expiration: Executa cancelamento de ordens pendentes caso o campo limite seja expirado
bool ManagerExpert::CheckDeleteOrderSell()
  {
   datetime cutt = TimeCurrent();
//--- check the possibility of deleting the short order
   if(m_time_expiration!=0 && TimeCurrent()>m_time_expiration)
     {
      m_time_expiration=0;
      return(m_trade.OrderDelete(m_order.Ticket()));
     }
   if(m_signal.CheckDeleteOrderSell())
      return(m_trade.OrderDelete(m_order.Ticket()));
   return(false);
  }
//-- Verifica se é necessário fazer mudanças na ordem pendente de reversão de compra
bool ManagerExpert::CheckRefreshReverseBuy()
  {
   double   price=EMPTY_VALUE;
   double   sl=0.0;
   double   tp=0.0;
   datetime expiration=GetExpiration();

   if(m_signal.CheckReverseBuy(price,sl,tp,expiration))
     {
      m_time_expiration=expiration;
      return(ModifyOrderBuy(price,sl,tp,expiration));
     }
   return (false);
  }
//-- Verifica se é necessário fazer mudanças na ordem pendente de reversão de venda
bool ManagerExpert::CheckRefreshReverseSell()
  {
   double   price=EMPTY_VALUE;
   double   sl=0.0;
   double   tp=0.0;
   datetime expiration=GetExpiration();

   if(m_signal.CheckReverseSell(price,sl,tp,expiration))
     {
      m_time_expiration=expiration;
      return(ModifyOrderSell(price,sl,tp,expiration));
     }
   return (false);
  }
//-- Deleta ordens pendentes de entradas parciais
bool ManagerExpert::CheckCloseInputPartial()
  {
   if(current_position != WRONG_VALUE)
     {
      if(current_position == POSITION_TYPE_BUY)
         DeleteOrdersLimit(ORDER_TYPE_BUY_LIMIT);
      else
         DeleteOrdersLimit(ORDER_TYPE_SELL_LIMIT);

      current_position=WRONG_VALUE;
      return true;
     }
   return false;
  }
//-- Deleta uma determinada order limit
bool ManagerExpert::DeleteOrdersLimit(ENUM_ORDER_TYPE order_type)
  {
   int total=OrdersTotal();
   if(total!=0)
     {
      //-- remove todas as ordens limit
      for(int i=total-1; i>=0; i--)
        {
         m_order.SelectByIndex(i);
         if(m_order.Symbol()!=m_symbol.Name())
            continue;

         if(m_order.OrderType()==order_type)
            m_trade.OrderDelete(m_order.Ticket());
        }
      return(true);
     }
   return (false);
  }
//-- Deleta todas as ordens posicionadas
bool ManagerExpert::DeleteOrders(void)
  {
   bool result=true;
   int  total=OrdersTotal();
//---
   for(int i=total-1; i>=0; i--)
      if(m_order.Select(OrderGetTicket(i)))
        {
         if(m_order.Symbol()!=m_symbol.Name())
            continue;
         result&=m_trade.OrderDelete(m_order.Ticket());
        }
//---
   return(result);
  }
//-- Gerencia reversão de posição
bool ManagerExpert::CheckReverse()
  {
   if(CheckLimits())
      return(false);

   if(m_position.PositionType() == POSITION_TYPE_BUY)
     {
      //--- se tá comprado, a reversão seria uma possível venda
      return (CheckReverseBuy());
     }
   else
     {
      //--- se tá vendido, a reversão seria uma possível compra
      return (CheckReverseSell());
     }
   return(false);
  }
//-- Verifica se pode fazer reversão da posição de venda
bool ManagerExpert::CheckReverseSell()
  {
   double   price=EMPTY_VALUE;
   double   sl=0.0;
   double   tp=0.0;
   datetime expiration=GetExpiration();

   if(m_signal.CheckReverseSell(price,sl,tp,expiration))
     {
      if(BuyPending())
         return (false);

      m_time_expiration=expiration;
      return(ReserveSell(price,sl,tp));
     }
   return(false);
  }
//-- Verifica se pode fazer reversão da posição de compra
bool ManagerExpert::CheckReverseBuy()
  {
   double   price=EMPTY_VALUE;
   double   sl=0.0;
   double   tp=0.0;
   datetime expiration=GetExpiration();

   if(m_signal.CheckReverseBuy(price,sl,tp,expiration))
     {
      if(SellPending())
         return (false);

      m_time_expiration=expiration;
      return(ReverseBuy(price,sl,tp));
     }
   return(false);
  }
//-- Trata o time para limite para expirar a ordem pendente
datetime ManagerExpert::GetExpiration()
  {
   if(m_expiration <= 0)
      return 0;
   datetime timeCurrent = TimeCurrent();
   datetime expiration = timeCurrent;
   expiration += m_expiration*PeriodSeconds(m_period);
   return expiration;
  }
//-- Faz reversão da posição de venda para compra
bool ManagerExpert::ReserveSell(double price,double sl,double tp)
  {
   if(price==EMPTY_VALUE)
      return(false);

   double m_lot= m_risk.Lots();
   if(m_lot==0.0)
      return(false);
   double lot =  m_lot + m_position.Volume();
//--- se é virada de mão da venda, então temos que comprar
   return(m_trade.Buy(lot,price,sl,tp));
  }
//-- Faz reversão da posição de compra para venda
bool ManagerExpert::ReverseBuy(double price,double sl,double tp)
  {
   if(price==EMPTY_VALUE)
      return(false);
   double m_lot= m_risk.Lots();
   if(m_lot==0.0)
      return(false);
   double lot =  m_lot + m_position.Volume();
//---se é virada de mão de compra, então temos que vender
   return(m_trade.Sell(lot,price,sl,tp));
  }
//-- Verifica se há uma ordem pendente de venda
bool ManagerExpert::SellPending()
  {
   int total=OrdersTotal();
   if(total!=0)
     {
      //-- procura pela última ordem posicionada
      for(int i=total-1; i>=0; i--)
        {
         m_order.SelectByIndex(i);
         if(m_order.Symbol()!=m_symbol.Name())
            continue;
         //-- se tá comprado, então deve procurar por ordens de venda
         if(m_order.OrderType()==ORDER_TYPE_SELL_LIMIT || m_order.OrderType()==ORDER_TYPE_SELL_STOP)
            return(true);
         return false;
        }
     }
   return false;
  }
//-- Verifica se há uma ordem pendente de compra
bool ManagerExpert::BuyPending()
  {
   int total=OrdersTotal();
   if(total!=0)
     {
      //-- procura pela última ordem posicionada
      for(int i=total-1; i>=0; i--)
        {
         m_order.SelectByIndex(i);
         if(m_order.Symbol()!=m_symbol.Name())
            continue;
         //-- se tá comprado, então deve procurar por ordens de venda
         if(m_order.OrderType()==ORDER_TYPE_BUY_LIMIT || m_order.OrderType()==ORDER_TYPE_BUY_STOP)
            return(true);
         return false;
        }
     }
   return false;
  }
//-- Gerencia trailing stop
bool ManagerExpert::CheckTrailingStop(void)
  {
//-- check qual tipo de posição tá aberta, se é venda ou compra
   if(m_position.PositionType() == POSITION_TYPE_BUY)
     {
      //-- verificar a possiblidade de fazer modificação na posição de compra
      return (CheckTrailingStopBuy());
     }
   else
     {
      //-- verificar a possiblidade de fazer modificação na posição de venda
      return (CheckTrailingStopSell());
     }
//-- return que nada foi feito
   return(false);
  }
//-- Faz trailing stop de acordo com a programação das classes responsáveis
bool ManagerExpert::CheckTrailingStopBuy(void)
  {
   double sl=EMPTY_VALUE;
   double tp=EMPTY_VALUE;
//--- check for long trailing stop operations
   if(m_trailing.CheckTrailingStopBuy(GetPointer(m_position),sl,tp))
     {
      double position_sl=m_position.StopLoss();
      double position_tp=m_position.TakeProfit();
      if(sl==EMPTY_VALUE)
         sl=position_sl;
      else
         sl=m_symbol.NormalizePrice(sl);
      if(tp==EMPTY_VALUE)
         tp=position_tp;
      else
         tp=m_symbol.NormalizePrice(tp);
      if(sl==position_sl && tp==position_tp)
         return(false);

      //-- trailing stop acionado, então devemos cancelar todas as entradas parciais
      //-- e garantir q não sejam mais posicionadas
      DeleteOrdersLimit(ORDER_TYPE_BUY_LIMIT);

      //--- long trailing stop operations
      return(TrailingStopBuy(sl,tp));
     }
   return(false);
  }
//-- Faz trailing stop de acordo com a programação das classes responsáveis
bool ManagerExpert::CheckTrailingStopSell(void)
  {
   double sl=EMPTY_VALUE;
   double tp=EMPTY_VALUE;
//--- check for short trailing stop operations
   if(m_trailing.CheckTrailingStopSell(GetPointer(m_position),sl,tp))
     {
      double position_sl=m_position.StopLoss();
      double position_tp=m_position.TakeProfit();
      if(sl==EMPTY_VALUE)
         sl=position_sl;
      else
         sl=m_symbol.NormalizePrice(sl);
      if(tp==EMPTY_VALUE)
         tp=position_tp;
      else
         tp=m_symbol.NormalizePrice(tp);
      if(sl==position_sl && tp==position_tp)
         return(false);

      //-- trailing stop acionado, então devemos cancelar todas as entradas parciais
      //-- e garantir q não sejam mais posicionadas
      DeleteOrdersLimit(ORDER_TYPE_SELL_LIMIT);

      //--- short trailing stop operations
      return(TrailingStopSell(sl,tp));
     }
//--- return without operations
   return(false);
  }
//-- Faz trailing stop de acordo com a programação das classes responsáveis
bool ManagerExpert::TrailingStopSell(double sl,double tp)
  {
   bool result;
   result=m_trade.PositionModify(m_position.Ticket(),sl,tp);
   return(result);
  }
//-- Faz trailing stop de acordo com a programação das classes responsáveis
bool ManagerExpert::TrailingStopBuy(double sl,double tp)
  {
   bool result;
   result=m_trade.PositionModify(m_position.Ticket(),sl,tp);
   return(result);
  }
//+------------------------------------------------------------------+
bool ManagerExpert::LookingforSignalAllDay()
  {
   double   price=EMPTY_VALUE;
   double   sl=0.0;
   double   tp=0.0;
   datetime expiration=GetExpiration();

   if(m_signal.CheckSignalBuy(price,sl,tp,expiration))
      return true;
   if(m_signal.CheckSignalSell(price,sl,tp,expiration))
      return true;
   return(false);
  }
//-- Verifica se há um sinal de entrada em venda
bool ManagerExpert::CheckOpenSell(void)
  {
   double   price=EMPTY_VALUE;
   double   sl=0.0;
   double   tp=0.0;
   datetime expiration=GetExpiration();

//--- check signal for short enter operations
   if(m_signal.CheckSignalSell(price,sl,tp,expiration))
     {
      m_time_expiration=expiration;
      return(OpenSell(price,sl,tp));
     }
   return(false);
  }
//-- Verifica se há um sinal de entrada em compra
bool ManagerExpert::CheckOpenBuy(void)
  {
   double   price=EMPTY_VALUE;
   double   sl=0.0;
   double   tp=0.0;
   datetime expiration=GetExpiration();

   if(m_signal.CheckSignalBuy(price,sl,tp,expiration))
     {
      m_time_expiration=expiration;
      return(OpenBuy(price,sl,tp));
     }
   return(false);
  }
//-- Executa venda
bool ManagerExpert::OpenSell(double price,double sl,double tp)
  {
   if(price==EMPTY_VALUE)
      return(false);

   double m_lot= m_risk.Lots();
   if(m_lot==0.0)
      return(false);
//---
   return(m_trade.Sell(m_lot,price,sl,tp));
  }
//-- Executa compra
bool ManagerExpert::OpenBuy(double price,double sl,double tp)
  {
   if(price==EMPTY_VALUE)
      return(false);

   double m_lot= m_risk.Lots();
   if(m_lot==0.0)
      return(false);

   return(m_trade.Buy(m_lot,price,sl,tp));
  }
//-- Refresh
bool ManagerExpert::Refresh(void)
  {
   if(!m_symbol.RefreshRates())
      return(false);
//m_signal.Refresh();
   return(true);
  }
//-- Check se existe alguma posição aberta
bool ManagerExpert::SelectPosition(void)
  {
   bool res=false;
   res=m_position.Select(_Symbol);
   return(res);
  }
//-- Obtem horário de início
datetime ManagerExpert::HourStart()
  {
   if(m_hour_start!= "")
      return StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " "+m_hour_start);
   return 0;
  }
//-- Obtem horário de encerramento de tudo, ordens pendentes e posições abertas
datetime ManagerExpert::HourCloseAll()
  {
   if(m_hour_close_positions!= "")
      return StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " "+m_hour_close_positions);
   return 0;
  }
//-- Obtem horário de encerramento de entradas
datetime ManagerExpert::HourEndDay()
  {
   if(m_hour_end_daytrade!= "")
      return StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " "+m_hour_end_daytrade);
   return 0;
  }
//-- Grava log de erro
void ManagerExpert::LogError(string function, string text)
  {
   string format = Message(text);
   CMessage *msg = new CMessage(MESSAGE_INFO, function, format);
   Log.AddMessage(msg);
   Log.SaveToFile();
  }
//-- Grava log de informações
void ManagerExpert::LogInf(string function, string text)
  {
   string format = Message(text);
   CMessage *msg = new CMessage(MESSAGE_INFO, function, format);
   Log.AddMessage(msg);
   Log.SaveToFile();
  }
//-- Mensagem
string ManagerExpert::Message(string text)
  {
   string format = "";
   long identifier =m_position.Identifier();
   if(identifier > 0)
     {
      if(m_position.PositionType() == POSITION_TYPE_BUY)
         format += "BUY";
      else
         format += "SELL";
      format += "("+identifier+")";
     }
   format += " " + text;
   return format;
  }
//--
void OnManager()
  {

  }
//-- Status se houve algum trade aberto anteriormente
bool ManagerExpert::StatePositionClose()
  {
   int pos_tot     =PositionsTotal();
   if(pos_tot > 0)
     {
      m_pos_tot = pos_tot;
     }
   else
     {
      if(m_pos_tot > 0)
        {
         m_pos_tot = 0;
         return(true);
        }
     }
   return(false);
  }
//-- Para ambiente de teste, verifica se é um novo trade
bool ManagerExpert::BackTestIsNewTrade()
  {
   bool isBackTest = MQL5InfoInteger(MQL5_TESTER);
   if(!isBackTest)
      return(false);
   ulong position_identifier=m_position.Identifier();
   if(position_identifier>0 && backtest_position_las_identifier!=position_identifier)
     {
      backtest_position_las_identifier=position_identifier;
      return true;
     }
   return false;
  }
//-- Obtem informações da posição aberta: Profit, Profit em pontos e tipo de posição aberta
bool ManagerExpert::StatePositionOpen(double &profit, double &profitPoint, double &volume, ENUM_POSITION_TYPE &position_type)
  {
   profit = 0;
   volume = m_position.Volume();
   profitPoint = 0;
   position_type = WRONG_VALUE;

   if(volume > 0)
     {
      position_type = m_position.PositionType();
      AccountProfit(profit, profitPoint);
      return(true);
     }
   return(false);
  }
//-- Limites diário
bool ManagerExpert::CheckLimits()
  {
   bool max_profit = false;
   bool max_loss = false;
   bool max_inputs = false;

   if(m_risk.CheckLimits(max_profit, max_loss, max_inputs))
      return(true);
   return(false);
  }
//-- Resetar variáveis de m_risk quando identificar um novo dia
void ManagerExpert::ResetInNewDay()
  {
   if(IsNewDay())
      m_risk.ResetLimits();
  }
//-- Status se é um novo dia
bool ManagerExpert::IsNewDay()
  {
   if(m_time_new_day == 0)
     {
      m_time_new_day = TimeCurrent();
      return(true);
     }
   if(TimeToString(m_time_new_day, TIME_DATE) != TimeToString(TimeCurrent(), TIME_DATE))
     {
      m_time_new_day = TimeCurrent();
      return(true);
     }
   return(false);
  }
//--
void ManagerExpert::AddPartialEntry(double lot, int distance)
  {
// aumenta o tamanho do array
   m_count_partials++;
   ArrayResize(m_partials, m_count_partials);

   m_partials[m_count_partials - 1].lot = lot;
   m_partials[m_count_partials - 1].distance = distance;
  }
//--
void ManagerExpert::AddBreakEven(double distance, double stopGain)
  {
// aumenta o tamanho do array
   m_count_breakeven++;
   ArrayResize(m_breakeven, m_count_breakeven);

   m_breakeven[m_count_breakeven - 1].distance = distance;
   m_breakeven[m_count_breakeven - 1].stopGain = stopGain;
  }
//--
void ManagerExpert::AddPartialOut(double lot, double distance)
  {
// aumenta o tamanho do array
   m_count_partial_out++;
   ArrayResize(m_partial_out, m_count_partial_out);

   m_partial_out[m_count_partial_out - 1].distance = distance;
   m_partial_out[m_count_partial_out - 1].lot = lot;
  }
//+------------------------------------------------------------------+

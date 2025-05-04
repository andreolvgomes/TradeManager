//+------------------------------------------------------------------+
//|                                                 ParamsConfig.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ParamsConfig
  {
public:
   ENUM_TIMEFRAMES   m_period;
   int               m_number_barras;
   int               m_level_stoploss;
   int               m_amplitude_alvos;
   int               m_stop_loss;
   int               m_take_profit;
   int               m_amplitude_movimento;

   void              SetNumber_barras(int number_barras) {m_number_barras = number_barras;}
   void              SetLevel_stoploss(int level_stoploss) {m_level_stoploss = level_stoploss;}
   void              SetTakeProfit(int value) {m_take_profit = value;}
   void              SetAmplitudeAlvos(int amplitude_alvos) {m_amplitude_alvos = amplitude_alvos;}
   void              SetStopLoss(int stop_loss) {m_stop_loss = stop_loss;}
   void              SetAmplitude_movimento(int amplitude_movimento) {m_amplitude_movimento = amplitude_movimento;}
   void              SetPeriod(ENUM_TIMEFRAMES period) {m_period = period;}
  };
//+------------------------------------------------------------------+

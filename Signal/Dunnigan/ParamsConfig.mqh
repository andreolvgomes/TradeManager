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
   int               m_number_barras;
   int               m_level_stoploss;
   int               m_amplitude_alvos;
   int               m_number_barras_maior;
   int               m_stop_loss;
   bool              m_entryWithConfirmation;
   bool              m_analisar1;
   bool              m_analisar2;
   int               m_amplitude_movimento;
   ENUM_TIMEFRAMES   m_period1;
   ENUM_TIMEFRAMES   m_period2;
   ENUM_TIMEFRAMES   m_perdiodMaior;

   void              SetNumber_barras(int number_barras) {m_number_barras = number_barras;}
   void              SetNumber_barras_maior(int number_barras_maior) {m_number_barras_maior = number_barras_maior;}
   void              SetLevel_stoploss(int level_stoploss) {m_level_stoploss = level_stoploss;}
   void              SetAmplitudeAlvos(int amplitude_alvos) {m_amplitude_alvos = amplitude_alvos;}
   void              SetStopLoss(int stop_loss) {m_stop_loss = stop_loss;}
   void              SetEntryWithConfirmation(bool entryWithConfirmation) {m_entryWithConfirmation = entryWithConfirmation;}
   void              SetAnalisar1(bool analisar1) {m_analisar1 = analisar1;}
   void              SetAnalisar2(bool analisar2) {m_analisar2 = analisar2;}
   void              SetAmplitude_movimento(int amplitude_movimento) {m_amplitude_movimento = amplitude_movimento;}
   void              SetPeriod1(ENUM_TIMEFRAMES period1) {m_period1 = period1;}
   void              SetPeriod2(ENUM_TIMEFRAMES period2) {m_period2 = period2;}
   void              SetPerdiodMaior(ENUM_TIMEFRAMES perdiodMaior) {m_perdiodMaior = perdiodMaior;}
  };
//+------------------------------------------------------------------+

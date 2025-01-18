//+------------------------------------------------------------------+
//|                                                  calcLotSize.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

input double _riskPercent = 1; // %R
input int _stopLossTicks = 10000; // TICK STOP

int OnInit() {
   return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {

   calcLot(_stopLossTicks);
   return(rates_total);
}

double calcLot(double sl) {
   double risk = AccountInfoDouble(ACCOUNT_BALANCE) * _riskPercent / 100;
   double tickSize = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE);
   double lotstep = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
   double moneyPerLotstep = sl / tickSize * tickValue * lotstep;
   double lot = MathFloor(risk / moneyPerLotstep) * lotstep;
   double minVolumeAllowed = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
   double maxVolumeAllowed = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);

   if (maxVolumeAllowed != 0) lot = MathMin(lot, maxVolumeAllowed);
   if (minVolumeAllowed != 0) lot = MathMax(lot, minVolumeAllowed);

   double currentBidPrice = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   double currentAskPrice = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   double priceStopLong = currentBidPrice - sl * tickSize;
   double priceStopShort = currentAskPrice + sl * tickSize;

   if (!ObjectCreate(0, "short stop", OBJ_HLINE, 0, 0, priceStopShort))
      Print("Error creating short stop line: ", GetLastError());
   if (!ObjectCreate(0, "long stop", OBJ_HLINE, 0, 0, priceStopLong))
      Print("Error creating long stop line: ", GetLastError());

   Comment("LOTS = " + DoubleToString(lot, 2) + "\n"
           "PIP STOP = " + sl + "\n"
           "SHORT STOP = " + DoubleToString(priceStopShort, 5) + "\n"
           "LONG STOP = " + DoubleToString(priceStopLong, 5));

   return NormalizeDouble(lot, 2);
}

void OnDeinit(const int reason) {
   ObjectsDeleteAll(0);
}

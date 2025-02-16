//+------------------------------------------------------------------+
//|                                                  calcLotSize.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Stefano Macina Leone"
#property link      "https://www.stefanomacinaleone.it"
#property version   "1.01"
#property description "Calculate lot size based on risk percentage and stop loss in ticks"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_label1  "size"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_plots   1

input double _riskPercent = 1;    // Risk Percentage
input int _stopLossTicks = 250;   // Stop Loss in Ticks

double sizeBuffer[];

void getInit() {
   SetIndexBuffer(0, sizeBuffer, INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits + 1);
   IndicatorSetString(INDICATOR_SHORTNAME, "size");
}

int OnInit() {
   getInit();
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
   
   for(int i = 0; i < rates_total; i++) {
      double size = calcLot(_stopLossTicks);
      sizeBuffer[i] = size;
   }
   
   return(rates_total);
}

double calcLot(double slTicks) {
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double risk = accountBalance * _riskPercent / 100;
   
   // Get symbol properties
   double tickSize = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE);
   double lotStep = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
   
   // Calculate stop loss in price terms
   double stopLossInPrice = slTicks * tickSize;
   
   // Calculate money risked per lot
   double moneyPerLot = stopLossInPrice / tickSize * tickValue;
   
   // Calculate required lot size
   double lot = risk / moneyPerLot;
   
   // Round down to nearest lot step
   lot = MathFloor(lot / lotStep) * lotStep;
   
   // Apply min/max volume constraints
   double minVolume = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
   double maxVolume = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
   
   lot = MathMax(lot, minVolume);
   lot = MathMin(lot, maxVolume);
   
   // Calculate stop levels for display
   double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   double longStopPrice = bid - stopLossInPrice;
   double shortStopPrice = ask + stopLossInPrice;
   
   // Create stop level lines
   ObjectCreate(0, "long_stop", OBJ_HLINE, 0, 0, longStopPrice);
   ObjectCreate(0, "short_stop", OBJ_HLINE, 0, 0, shortStopPrice);
   
 
   Comment(
      "Account Balance: ", accountBalance, "\n",
      "Risk Amount: ", risk, "\n",
      "Stop Loss in Ticks: ", slTicks, "\n",
      "Stop Loss in Price: ", stopLossInPrice, "\n",
      "Tick Size: ", tickSize, "\n",
      "Tick Value: ", tickValue, "\n",
      "Money per Lot: ", moneyPerLot, "\n",
      "Long Stop Level: ", longStopPrice, "\n",
      "Short Stop Level: ", shortStopPrice, "\n",
      "Lot: ", lot
   );
   
   return NormalizeDouble(lot, 2);
}

void OnDeinit(const int reason) {
   Comment("");
   ObjectsDeleteAll(0);
}
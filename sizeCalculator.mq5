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
input int _stopLossPips = 100; // Pip Stop

int OnInit(){
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
                const int &spread[]){

   
   calcLot(_stopLossPips);

   return(rates_total);
}

double calcLot(double sl){
   double risk = AccountInfoDouble(ACCOUNT_BALANCE)*_riskPercent /100;
   double tickSize = SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE);
   double lotstep = SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   double moneyPerLotstep = sl/ tickSize * tickValue * lotstep;
   double lot = MathFloor(risk / moneyPerLotstep)*lotstep;
   double minVolumeAllowed = SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   double maxVolumeAllowed = SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   
   if(maxVolumeAllowed!=0) lot = MathMin(lot,maxVolumeAllowed);
   if(minVolumeAllowed!=0) lot = MathMax(lot,minVolumeAllowed);
   
   double currentbidPrice = SymbolInfoDouble(Symbol(),SYMBOL_BID);
   double currentAskPrice = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   double priceStopLong = currentbidPrice-sl;
   double priceStopShort = currentAskPrice+sl;
   
   ObjectCreate(0,"short stop",OBJ_HLINE,0,0,priceStopLong);
   ObjectCreate(0,"long stop",OBJ_HLINE,0,0,priceStopShort);
   
   Comment("LOTS = " + lot + "\n" 
          "PIP STOP = " + sl +"\n"
          "SHORT STOP = " + priceStopShort + "\n"
          "LONG STOP = " + priceStopLong
  );
   return NormalizeDouble(lot,2);
}


void OnDeinit(){
   ObjectsDeleteAll(0);
}
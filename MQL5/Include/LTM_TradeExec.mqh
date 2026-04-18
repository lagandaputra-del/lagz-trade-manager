//+------------------------------------------------------------------+
//|                                             LTM_TradeExec.mqh    |
//|         Lagz Trade Manager — Order execution functions            |
//|  Lot calculation, SL/TP conversion, market & pending orders.     |
//+------------------------------------------------------------------+
#ifndef LTM_TRADEEXEC_MQH
#define LTM_TRADEEXEC_MQH

//+------------------------------------------------------------------+
//| Lot calculation                                                    |
//+------------------------------------------------------------------+

//--- Return pip value for the current symbol in account currency.
//    One pip = 1 point for JPY pairs; 10 points for most others.
double LTM_PipValue()
{
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double point     = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

   // Points per pip (10 for 5-digit brokers, 1 for JPY / 3-digit)
   double pointsPerPip = 10.0;
   int    digits       = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   if(digits == 3 || digits == 1 || (digits == 5 && point == 0.001))
      pointsPerPip = 1.0;  // JPY-style

   double pipValueInBase = (tickValue / tickSize) * point * pointsPerPip;
   return pipValueInBase; // value of 1 pip per 1 lot
}

//--- Calculate lot size from current panel state.
//    Fixed mode  : returns g_panel.lotValue parsed as double.
//    Risk % mode : Lot = (Balance × Risk%) / (SL_pips × PipValue).
double LTM_CalculateLot()
{
   double minLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   if(!g_panel.lotModeRisk)
   {
      // Fixed lot — just parse the field value
      double lot = StringToDouble(g_panel.lotValue);
      lot = MathMax(minLot, MathMin(maxLot, lot));
      lot = MathRound(lot / lotStep) * lotStep;
      return lot;
   }

   // Risk % mode
   double balance  = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskPct  = StringToDouble(g_panel.lotValue); // lotValue holds risk%
   double slPips   = StringToDouble(g_panel.slValue);
   double pipValue = LTM_PipValue();

   if(slPips <= 0.0 || pipValue <= 0.0 || riskPct <= 0.0)
   {
      LTM_ShowStatus("Risk mode: need SL > 0 pips", true);
      return minLot;
   }

   double riskAmount = balance * (riskPct / 100.0);
   double lot        = riskAmount / (slPips * pipValue);

   // Normalise to broker lot step
   lot = MathRound(lot / lotStep) * lotStep;
   lot = MathMax(minLot, MathMin(maxLot, lot));
   return lot;
}

//+------------------------------------------------------------------+
//| SL / TP price helpers                                             |
//+------------------------------------------------------------------+

//--- Convert pips value to price distance (points)
double LTM_PipsToPrice(double pips)
{
   double point       = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int    digits      = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double pointsPerPip = (digits == 3 || digits == 1) ? 1.0 : 10.0;
   return pips * pointsPerPip * point;
}

//--- Resolve SL price for BUY (below Ask) or SELL (above Bid).
//    Returns 0.0 if no SL configured.
double LTM_ResolveSL(ENUM_ORDER_TYPE orderType)
{
   double slRaw = StringToDouble(g_panel.slValue);
   if(slRaw <= 0.0) return 0.0;

   if(g_panel.slTpModePips)
   {
      // Pips mode — convert relative to execution price
      double basePrice = (orderType == ORDER_TYPE_BUY)
                         ? SymbolInfoDouble(_Symbol, SYMBOL_ASK)
                         : SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double dist = LTM_PipsToPrice(slRaw);
      return (orderType == ORDER_TYPE_BUY)
             ? NormalizeDouble(basePrice - dist,
                               (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS))
             : NormalizeDouble(basePrice + dist,
                               (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
   }
   // Price mode — absolute value entered directly
   return NormalizeDouble(slRaw,
                          (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
}

//--- Resolve TP price for BUY or SELL.
//    Returns 0.0 if no TP configured.
double LTM_ResolveTP(ENUM_ORDER_TYPE orderType)
{
   double tpRaw = StringToDouble(g_panel.tpValue);
   if(tpRaw <= 0.0) return 0.0;

   if(g_panel.slTpModePips)
   {
      double basePrice = (orderType == ORDER_TYPE_BUY)
                         ? SymbolInfoDouble(_Symbol, SYMBOL_ASK)
                         : SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double dist = LTM_PipsToPrice(tpRaw);
      return (orderType == ORDER_TYPE_BUY)
             ? NormalizeDouble(basePrice + dist,
                               (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS))
             : NormalizeDouble(basePrice - dist,
                               (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
   }
   return NormalizeDouble(tpRaw,
                          (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
}

//+------------------------------------------------------------------+
//| Market orders                                                      |
//+------------------------------------------------------------------+
void LTM_OpenBuy()
{
   double lot = LTM_CalculateLot();
   double sl  = LTM_ResolveSL(ORDER_TYPE_BUY);
   double tp  = LTM_ResolveTP(ORDER_TYPE_BUY);

   if(g_trade.Buy(lot, _Symbol, 0, sl, tp, "LTM Buy"))
   {
      LTM_ShowStatus("Buy " + DoubleToString(lot, 2) + " lots opened", false);
   }
   else
   {
      LTM_ShowStatus("Buy err " + IntegerToString(g_trade.ResultRetcode())
                     + ": " + g_trade.ResultRetcodeDescription(), true);
   }
}

void LTM_OpenSell()
{
   double lot = LTM_CalculateLot();
   double sl  = LTM_ResolveSL(ORDER_TYPE_SELL);
   double tp  = LTM_ResolveTP(ORDER_TYPE_SELL);

   if(g_trade.Sell(lot, _Symbol, 0, sl, tp, "LTM Sell"))
   {
      LTM_ShowStatus("Sell " + DoubleToString(lot, 2) + " lots opened", false);
   }
   else
   {
      LTM_ShowStatus("Sell err " + IntegerToString(g_trade.ResultRetcode())
                     + ": " + g_trade.ResultRetcodeDescription(), true);
   }
}

//+------------------------------------------------------------------+
//| Pending orders                                                     |
//+------------------------------------------------------------------+

//--- Resolve pending order price from panel.
//    Uses pendingPrice field (absolute price entered by user).
//    If the field is zero, falls back to offset from current Ask/Bid.
double LTM_ResolvePendingPrice(ENUM_ORDER_TYPE pendingType)
{
   double price = StringToDouble(g_panel.pendingPrice);
   int    digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   if(price > 0.0)
      return NormalizeDouble(price, digits);

   // Fallback: current market price (no offset — user must fill in a price)
   if(pendingType == ORDER_TYPE_BUY_LIMIT)
      return NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), digits);
   return NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), digits);
}

void LTM_OpenBuyLimit()
{
   double lot   = LTM_CalculateLot();
   double price = LTM_ResolvePendingPrice(ORDER_TYPE_BUY_LIMIT);
   double sl    = 0.0, tp = 0.0;

   if(g_panel.slTpModePips)
   {
      double slRaw = StringToDouble(g_panel.slValue);
      double tpRaw = StringToDouble(g_panel.tpValue);
      int    digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      if(slRaw > 0.0) sl = NormalizeDouble(price - LTM_PipsToPrice(slRaw), digits);
      if(tpRaw > 0.0) tp = NormalizeDouble(price + LTM_PipsToPrice(tpRaw), digits);
   }
   else
   {
      sl = NormalizeDouble(StringToDouble(g_panel.slValue),
                           (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
      tp = NormalizeDouble(StringToDouble(g_panel.tpValue),
                           (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
      if(sl <= 0.0) sl = 0.0;
      if(tp <= 0.0) tp = 0.0;
   }

   if(g_trade.BuyLimit(lot, price, _Symbol, sl, tp,
                       ORDER_TIME_GTC, 0, "LTM BuyLimit"))
   {
      LTM_ShowStatus("BuyLimit @ " + DoubleToString(price, 5) + " placed", false);
   }
   else
   {
      LTM_ShowStatus("BuyLimit failed: " + IntegerToString(GetLastError()), true);
   }
}

void LTM_OpenSellLimit()
{
   double lot   = LTM_CalculateLot();
   double price = LTM_ResolvePendingPrice(ORDER_TYPE_SELL_LIMIT);
   double sl    = 0.0, tp = 0.0;

   if(g_panel.slTpModePips)
   {
      double slRaw = StringToDouble(g_panel.slValue);
      double tpRaw = StringToDouble(g_panel.tpValue);
      int    digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      if(slRaw > 0.0) sl = NormalizeDouble(price + LTM_PipsToPrice(slRaw), digits);
      if(tpRaw > 0.0) tp = NormalizeDouble(price - LTM_PipsToPrice(tpRaw), digits);
   }
   else
   {
      sl = NormalizeDouble(StringToDouble(g_panel.slValue),
                           (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
      tp = NormalizeDouble(StringToDouble(g_panel.tpValue),
                           (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
      if(sl <= 0.0) sl = 0.0;
      if(tp <= 0.0) tp = 0.0;
   }

   if(g_trade.SellLimit(lot, price, _Symbol, sl, tp,
                        ORDER_TIME_GTC, 0, "LTM SellLimit"))
   {
      LTM_ShowStatus("SellLimit @ " + DoubleToString(price, 5) + " placed", false);
   }
   else
   {
      LTM_ShowStatus("SellLimit failed: " + IntegerToString(GetLastError()), true);
   }
}

#endif // LTM_TRADEEXEC_MQH

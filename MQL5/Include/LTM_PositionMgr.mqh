//+------------------------------------------------------------------+
//|                                           LTM_PositionMgr.mqh    |
//|         Lagz Trade Manager — Position management functions        |
//|  CloseAll, CloseBuyOnly, CloseSellOnly, PartialClose,            |
//|  SetTPAll, SetBreakeven, AutoBreakeven.                          |
//+------------------------------------------------------------------+
#ifndef LTM_POSITIONMGR_MQH
#define LTM_POSITIONMGR_MQH

//+------------------------------------------------------------------+
//| Position snapshot struct                                          |
//+------------------------------------------------------------------+
struct PositionData
{
   ulong  ticket;
   string symbol;
   long   type;       // POSITION_TYPE_BUY or POSITION_TYPE_SELL
   double volume;
   double openPrice;
   double sl;
   double tp;
   double profit;     // floating P/L + swap
};

//+------------------------------------------------------------------+
//| Collect positions matching current filter                         |
//+------------------------------------------------------------------+

//--- Populate array with all managed positions on the given symbol.
//    Pass "" for symbol to collect across ALL symbols (BE scope).
int LTM_GetPositions(PositionData &arr[], const string sym)
{
   ArrayResize(arr, 0);
   int count = 0;

   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;

      // Symbol filter
      string posSym = PositionGetString(POSITION_SYMBOL);
      if(sym != "" && posSym != sym) continue;

      // Magic filter
      if(g_panel.manageOwnOnly &&
         PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;

      ArrayResize(arr, count + 1);
      arr[count].ticket    = ticket;
      arr[count].symbol    = posSym;
      arr[count].type      = PositionGetInteger(POSITION_TYPE);
      arr[count].volume    = PositionGetDouble(POSITION_VOLUME);
      arr[count].openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      arr[count].sl        = PositionGetDouble(POSITION_SL);
      arr[count].tp        = PositionGetDouble(POSITION_TP);
      arr[count].profit    = PositionGetDouble(POSITION_PROFIT)
                           + PositionGetDouble(POSITION_SWAP);
      count++;
   }
   return count;
}

//+------------------------------------------------------------------+
//| Sort positions ascending by profit (worst first)                  |
//| Used by PartialClose so remaining = highest-profit positions.     |
//+------------------------------------------------------------------+
void LTM_SortByProfitAsc(PositionData &arr[], int count)
{
   // Simple insertion sort — count is typically < 20
   for(int i = 1; i < count; i++)
   {
      PositionData key = arr[i];
      int j = i - 1;
      while(j >= 0 && arr[j].profit > key.profit)
      {
         arr[j + 1] = arr[j];
         j--;
      }
      arr[j + 1] = key;
   }
}

//+------------------------------------------------------------------+
//| Close All                                                          |
//+------------------------------------------------------------------+
void LTM_CloseAll()
{
   PositionData pos[];
   int cnt = LTM_GetPositions(pos, _Symbol);

   if(cnt == 0) { LTM_ShowStatus("No positions to close", false); return; }

   int closed = 0;
   for(int i = 0; i < cnt; i++)
   {
      if(g_trade.PositionClose(pos[i].ticket))
         closed++;
      else
         Print("LTM CloseAll: failed ticket=", pos[i].ticket,
               " err=", GetLastError());
   }

   if(closed == cnt)
      LTM_ShowStatus("Closed " + IntegerToString(closed) + " positions", false);
   else
      LTM_ShowStatus("Closed " + IntegerToString(closed) + "/" +
                     IntegerToString(cnt) + " positions", true);
}

//+------------------------------------------------------------------+
//| Close Buy Only                                                     |
//+------------------------------------------------------------------+
void LTM_CloseBuyOnly()
{
   PositionData pos[];
   int cnt = LTM_GetPositions(pos, _Symbol);

   int closed = 0, target = 0;
   for(int i = 0; i < cnt; i++)
   {
      if(pos[i].type != POSITION_TYPE_BUY) continue;
      target++;
      if(g_trade.PositionClose(pos[i].ticket))
         closed++;
      else
         Print("LTM CloseBuyOnly: failed ticket=", pos[i].ticket,
               " err=", GetLastError());
   }

   if(target == 0) { LTM_ShowStatus("No BUY positions to close", false); return; }
   LTM_ShowStatus("Closed " + IntegerToString(closed) + " BUY position(s)", closed < target);
}

//+------------------------------------------------------------------+
//| Close Sell Only                                                    |
//+------------------------------------------------------------------+
void LTM_CloseSellOnly()
{
   PositionData pos[];
   int cnt = LTM_GetPositions(pos, _Symbol);

   int closed = 0, target = 0;
   for(int i = 0; i < cnt; i++)
   {
      if(pos[i].type != POSITION_TYPE_SELL) continue;
      target++;
      if(g_trade.PositionClose(pos[i].ticket))
         closed++;
      else
         Print("LTM CloseSellOnly: failed ticket=", pos[i].ticket,
               " err=", GetLastError());
   }

   if(target == 0) { LTM_ShowStatus("No SELL positions to close", false); return; }
   LTM_ShowStatus("Closed " + IntegerToString(closed) + " SELL position(s)", closed < target);
}

//+------------------------------------------------------------------+
//| Partial Close                                                      |
//| pct  = fraction to close (0.25 / 0.50 / 0.75 / 0.80)            |
//| Sort order: worst profit first → remaining = best profit          |
//+------------------------------------------------------------------+
void LTM_PartialClose(double pct)
{
   PositionData pos[];
   int cnt = LTM_GetPositions(pos, _Symbol);

   if(cnt == 0) { LTM_ShowStatus("No positions to partial-close", false); return; }

   // Total volume across all managed positions
   double totalVol = 0.0;
   for(int i = 0; i < cnt; i++)
      totalVol += pos[i].volume;

   double toClose  = totalVol * pct;
   double minLot   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double lotStep  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   if(toClose < minLot) toClose = minLot;

   // Sort ascending profit — close worst first
   LTM_SortByProfitAsc(pos, cnt);

   double remaining = toClose;
   int    closed    = 0;

   for(int i = 0; i < cnt && remaining > 0.0; i++)
   {
      double closeVol = MathMin(remaining, pos[i].volume);

      // Normalise to lot step
      closeVol = MathRound(closeVol / lotStep) * lotStep;
      if(closeVol < minLot)
      {
         // Below minimum — close the whole position
         closeVol = pos[i].volume;
      }

      if(g_trade.PositionClosePartial(pos[i].ticket, closeVol))
      {
         remaining -= closeVol;
         closed++;
      }
      else
      {
         Print("LTM PartialClose: failed ticket=", pos[i].ticket,
               " vol=", closeVol, " err=", GetLastError());
      }
   }

   int pctInt = (int)MathRound(pct * 100);
   LTM_ShowStatus(IntegerToString(pctInt) + "% partial close done ("
                  + IntegerToString(closed) + " order(s))", false);
}

//+------------------------------------------------------------------+
//| Set TP on all positions                                            |
//+------------------------------------------------------------------+
void LTM_SetTPAll(double tpPrice)
{
   PositionData pos[];
   int cnt = LTM_GetPositions(pos, _Symbol);

   if(cnt == 0) { LTM_ShowStatus("No positions to modify", false); return; }

   int ok = 0;
   for(int i = 0; i < cnt; i++)
   {
      if(g_trade.PositionModify(pos[i].ticket, pos[i].sl, tpPrice))
         ok++;
      else
         Print("LTM SetTPAll: failed ticket=", pos[i].ticket,
               " err=", GetLastError());
   }

   LTM_ShowStatus("TP set for " + IntegerToString(ok) + " position(s)", ok < cnt);
}

//+------------------------------------------------------------------+
//| Manual Breakeven                                                   |
//| offsetPips — SL is placed offsetPips beyond entry price.         |
//| Only applies to positions already in profit >= offsetPips.        |
//+------------------------------------------------------------------+
void LTM_SetBreakeven(int offsetPips)
{
   double point       = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int    digits      = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double pointsPerPip = ((int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) == 3 ||
                          (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) == 1) ? 1.0 : 10.0;
   double offset      = offsetPips * pointsPerPip * point;

   PositionData pos[];
   int cnt = LTM_GetPositions(pos, _Symbol);

   if(cnt == 0) { LTM_ShowStatus("No positions for BE", false); return; }

   int modified = 0;
   for(int i = 0; i < cnt; i++)
   {
      double newSL;
      bool   inProfit;

      if(pos[i].type == POSITION_TYPE_BUY)
      {
         double currentAsk = SymbolInfoDouble(pos[i].symbol, SYMBOL_ASK);
         inProfit = (currentAsk >= pos[i].openPrice + offset);
         newSL    = NormalizeDouble(pos[i].openPrice + offset, digits);
      }
      else
      {
         double currentBid = SymbolInfoDouble(pos[i].symbol, SYMBOL_BID);
         inProfit = (currentBid <= pos[i].openPrice - offset);
         newSL    = NormalizeDouble(pos[i].openPrice - offset, digits);
      }

      if(!inProfit) continue;

      // Don't move SL in the wrong direction
      if(pos[i].type == POSITION_TYPE_BUY && pos[i].sl >= newSL) continue;
      if(pos[i].type == POSITION_TYPE_SELL && pos[i].sl > 0.0 && pos[i].sl <= newSL) continue;

      if(g_trade.PositionModify(pos[i].ticket, newSL, pos[i].tp))
         modified++;
      else
         Print("LTM SetBE: failed ticket=", pos[i].ticket,
               " err=", GetLastError());
   }

   if(modified > 0)
      LTM_ShowStatus("BE set for " + IntegerToString(modified) + " position(s)", false);
   else
      LTM_ShowStatus("No eligible positions for BE", false);
}

//+------------------------------------------------------------------+
//| Auto Breakeven — per-ticket flag prevents re-processing           |
//+------------------------------------------------------------------+

//--- Check if ticket is already in the done-array
bool LTM_AutoBEIsDone(ulong ticket)
{
   int sz = ArraySize(g_autoBEDone);
   for(int i = 0; i < sz; i++)
      if(g_autoBEDone[i] == ticket) return true;
   return false;
}

//--- Add ticket to done-array
void LTM_AutoBEMarkDone(ulong ticket)
{
   int sz = ArraySize(g_autoBEDone);
   ArrayResize(g_autoBEDone, sz + 1);
   g_autoBEDone[sz] = ticket;
}

//--- Called every OnTick when autoBEEnabled is true
void LTM_ProcessAutoBE()
{
   int    afterPips  = (int)StringToInteger(g_panel.autoBeAfter);
   int    offsetPips = (int)StringToInteger(g_panel.autoBeOfs);

   double point       = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int    digits      = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double pointsPerPip = (digits == 3 || digits == 1) ? 1.0 : 10.0;
   double activateDist = afterPips  * pointsPerPip * point;
   double offset       = offsetPips * pointsPerPip * point;

   // Scope: current symbol only, or all symbols
   string sym = InpBEScopeAllSymbols ? "" : _Symbol;

   PositionData pos[];
   int cnt = LTM_GetPositions(pos, sym);

   for(int i = 0; i < cnt; i++)
   {
      if(LTM_AutoBEIsDone(pos[i].ticket)) continue;

      double newSL;
      bool   triggered;

      if(pos[i].type == POSITION_TYPE_BUY)
      {
         double bid = SymbolInfoDouble(pos[i].symbol, SYMBOL_BID);
         triggered  = (bid >= pos[i].openPrice + activateDist);
         newSL      = NormalizeDouble(pos[i].openPrice + offset,
                                      (int)SymbolInfoInteger(pos[i].symbol, SYMBOL_DIGITS));
      }
      else
      {
         double ask = SymbolInfoDouble(pos[i].symbol, SYMBOL_ASK);
         triggered  = (ask <= pos[i].openPrice - activateDist);
         newSL      = NormalizeDouble(pos[i].openPrice - offset,
                                      (int)SymbolInfoInteger(pos[i].symbol, SYMBOL_DIGITS));
      }

      if(!triggered) continue;

      // Don't worsen the SL
      if(pos[i].type == POSITION_TYPE_BUY && pos[i].sl >= newSL) { LTM_AutoBEMarkDone(pos[i].ticket); continue; }
      if(pos[i].type == POSITION_TYPE_SELL && pos[i].sl > 0.0 && pos[i].sl <= newSL) { LTM_AutoBEMarkDone(pos[i].ticket); continue; }

      if(g_trade.PositionModify(pos[i].ticket, newSL, pos[i].tp))
      {
         LTM_AutoBEMarkDone(pos[i].ticket);
         LTM_ShowStatus("Auto BE: ticket #" + IntegerToString(pos[i].ticket), false);
      }
      else
      {
         Print("LTM AutoBE: failed ticket=", pos[i].ticket,
               " err=", GetLastError());
      }
   }
}

#endif // LTM_POSITIONMGR_MQH

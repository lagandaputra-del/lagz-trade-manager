//+------------------------------------------------------------------+
//|                                              LTM_Dashboard.mqh   |
//|         Lagz Trade Manager — Dashboard section rendering          |
//|  Draws real-time account stats (Balance, Equity, Margin, P/L).   |
//|  Also owns day-start balance persistence (LTM_DayStart.bin).     |
//+------------------------------------------------------------------+
#ifndef LTM_DASHBOARD_MQH
#define LTM_DASHBOARD_MQH

//+------------------------------------------------------------------+
//| Day-start balance — persisted across EA restarts                  |
//+------------------------------------------------------------------+
#define DAYSTART_FILE "LTM_DayStart.bin"

static double g_dayStartBalance = 0.0;
static int    g_dayStartDay     = -1;   // MqlDateTime.day of last save

//--- Write current day-start balance + day index to binary file
void LTM_DayStartSave()
{
   int fh = FileOpen(DAYSTART_FILE,
                     FILE_WRITE | FILE_BIN | FILE_COMMON);
   if(fh == INVALID_HANDLE)
   {
      Print("LTM_Dashboard: Cannot write ", DAYSTART_FILE,
            " error=", GetLastError());
      return;
   }
   FileWriteDouble(fh, g_dayStartBalance);          // 8 bytes
   FileWriteInteger(fh, g_dayStartDay, INT_VALUE);  // 4 bytes
   FileClose(fh);
}

//--- Load day-start balance from file.
//    If file absent, corrupt, or from a different day → init from
//    current balance and write a fresh file.
void LTM_DayStartInit()
{
   MqlDateTime dt;
   TimeToStruct(TimeTradeServer(), dt);

   bool loaded = false;

   if(FileIsExist(DAYSTART_FILE, FILE_COMMON))
   {
      int fh = FileOpen(DAYSTART_FILE,
                        FILE_READ | FILE_BIN | FILE_COMMON);
      if(fh != INVALID_HANDLE)
      {
         if(FileSize(fh) >= 12) // double(8) + int(4)
         {
            double savedBalance = FileReadDouble(fh);
            int    savedDay     = FileReadInteger(fh, INT_VALUE);
            loaded = (savedDay == dt.day && savedBalance > 0.0);
            if(loaded)
            {
               g_dayStartBalance = savedBalance;
               g_dayStartDay     = savedDay;
            }
         }
         FileClose(fh);
      }
   }

   if(!loaded)
   {
      // First run today — snapshot current balance
      g_dayStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      g_dayStartDay     = dt.day;
      LTM_DayStartSave();
   }
}

//--- Called every OnTick — detect day rollover and reset
void LTM_DayStartCheck()
{
   MqlDateTime dt;
   TimeToStruct(TimeTradeServer(), dt);

   if(dt.day != g_dayStartDay)
   {
      g_dayStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      g_dayStartDay     = dt.day;
      LTM_DayStartSave();
   }
}

//+------------------------------------------------------------------+
//| Account Overview — V2 2-row grid layout (Step 15)                 |
//| Called from LTM_DrawPanel() in LTM_GUI.mqh                        |
//+------------------------------------------------------------------+
void LTM_DrawAccountOverview(int yTop)
{
   int y  = yTop;
   int px = PANEL_PAD_X;

   g_canvas.FillRectangle(0, y, PANEL_W, y + PANEL_OVERVIEW_H, CLR_BG_PANEL);

   //--- Gather account values
   double balance    = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity     = AccountInfoDouble(ACCOUNT_EQUITY);
   double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);

   double runPL = 0.0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(g_panel.manageOwnOnly &&
         PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      runPL += PositionGetDouble(POSITION_PROFIT)
             + PositionGetDouble(POSITION_SWAP);
   }

   double profitToday    = balance + runPL - g_dayStartBalance;
   double profitTodayPct = (g_dayStartBalance > 0.0)
                           ? (profitToday / g_dayStartBalance * 100.0)
                           : 0.0;
   long spreadPts = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);

   //--- Row 1: 4-column grid — Balance | Equity | Free Mgn | PNL Hari
   int colW  = (PANEL_W - 2 * px) / 4;
   int row1Y = y + PANEL_PAD_Y;

   string todSign     = (profitToday >= 0) ? "+" : "";
   string colLabels[] = {"Balance", "Equity", "Free Mgn", "PNL Hari"};
   string colVals[]   = {
      DoubleToString(balance, 2),
      DoubleToString(equity, 2),
      DoubleToString(freeMargin, 2),
      todSign + DoubleToString(profitTodayPct, 1) + "%"
   };
   uint todClr    = (profitToday >= 0) ? CLR_PROFIT : CLR_LOSS;
   uint colClrs[] = {CLR_TEXT_PRIMARY, CLR_TEXT_PRIMARY, CLR_TEXT_PRIMARY, todClr};

   for(int c = 0; c < 4; c++)
   {
      int cx = px + c * colW;
      g_canvas.FontSet(FONT_LABEL, FSIZE_SECTION, FW_NORMAL, 0);
      g_canvas.TextOut(cx, row1Y,      colLabels[c], CLR_TEXT_DIM, TA_LEFT | TA_TOP);
      g_canvas.FontSet(FONT_LABEL_BOLD, FSIZE_VALUE, FW_BOLD, 0);
      g_canvas.TextOut(cx, row1Y + 13, colVals[c],   colClrs[c],   TA_LEFT | TA_TOP);
      g_canvas.FontSet(FONT_LABEL, FSIZE_SECTION, FW_NORMAL, 0);
      if(c < 3)
         g_canvas.TextOut(cx, row1Y + 27, "USD", CLR_TEXT_DIM, TA_LEFT | TA_TOP);
      else
      {
         string todUSD = todSign + DoubleToString(profitToday, 2);
         g_canvas.TextOut(cx, row1Y + 27, "(" + todUSD + ")", todClr, TA_LEFT | TA_TOP);
      }
   }

   //--- Row 2: Symbol | Spread | Server time (3 items — today% moved to col 4)
   int row2Y = y + 60;

   MqlDateTime dt;
   TimeToStruct(TimeTradeServer(), dt);
   string timeStr   = StringFormat("%02d:%02d:%02d", dt.hour, dt.min, dt.sec);
   string spreadStr = IntegerToString(spreadPts) + " pts";
   uint   spClr     = (spreadPts > 50) ? CLR_WARN : CLR_TEXT_DIM;

   g_canvas.FontSet(FONT_LABEL_BOLD, FSIZE_LABEL, FW_BOLD, 0);
   g_canvas.TextOut(px,           row2Y, _Symbol,   CLR_ACCENT,   TA_LEFT | TA_TOP);
   g_canvas.FontSet(FONT_LABEL,   FSIZE_SECTION, FW_NORMAL, 0);
   g_canvas.TextOut(px + 80,      row2Y, spreadStr, spClr,        TA_LEFT | TA_TOP);
   g_canvas.TextOut(PANEL_W - px, row2Y, timeStr,   CLR_TEXT_DIM, TA_RIGHT | TA_TOP);
}

#endif // LTM_DASHBOARD_MQH

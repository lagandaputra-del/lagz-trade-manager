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
//| Dashboard section rendering                                        |
//| yTop = top pixel of this section within the canvas               |
//+------------------------------------------------------------------+
void LTM_DrawDashboard(CCanvas &canvas, int yTop)
{
   int y   = yTop;
   int px  = PANEL_PAD_X;
   int valX = px + 90;   // value column: 480px panel — wider label room
   int rowH = 20;        // row height (fits 5 rows + header in PANEL_DASH_H=150)

   //--- Section background
   canvas.FillRectangle(0, y, PANEL_W, y + PANEL_DASH_H, CLR_BG_PANEL);

   //--- Gather account values
   double balance    = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity     = AccountInfoDouble(ACCOUNT_EQUITY);
   double margin     = AccountInfoDouble(ACCOUNT_MARGIN);
   double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double marginPct  = (equity > 0.0) ? (margin / equity * 100.0) : 0.0;
   string cur        = AccountInfoString(ACCOUNT_CURRENCY);

   //--- Running P/L on current symbol (filtered by magic if toggle on)
   double runPL     = 0.0;
   int    openCount = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(g_panel.manageOwnOnly &&
         PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      runPL += PositionGetDouble(POSITION_PROFIT)
             + PositionGetDouble(POSITION_SWAP);
      openCount++;
   }
   double runPLPct = (balance > 0.0) ? (runPL / balance * 100.0) : 0.0;

   //--- % Profit Today (vs day-start balance)
   double profitToday    = balance + runPL - g_dayStartBalance;
   double profitTodayPct = (g_dayStartBalance > 0.0)
                           ? (profitToday / g_dayStartBalance * 100.0)
                           : 0.0;

   //--- Spread in raw points
   long spreadPts = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);

   //--- Section header
   canvas.FillRectangle(0, y, PANEL_W, y + 1, CLR_BORDER_DIM);
   canvas.FontSet(FONT_LABEL, FSIZE_SECTION, FW_NORMAL, 0);
   canvas.TextOut(px, y + 3, "-- ACCOUNT --", CLR_TEXT_SECTION, TA_LEFT | TA_TOP);
   y += 16;

   //--- Row 1: Balance + % Profit Today
   {
      string balStr  = DoubleToString(balance, 2) + " " + cur;
      string todSign = (profitToday >= 0) ? "+" : "";
      string todStr  = todSign + DoubleToString(profitTodayPct, 2) + "% today";
      uint   todClr  = (profitToday >= 0) ? CLR_PROFIT : CLR_LOSS;

      canvas.FontSet(FONT_LABEL, FSIZE_LABEL, FW_NORMAL, 0);
      canvas.TextOut(px, y, "Balance", CLR_TEXT_DIM, TA_LEFT | TA_TOP);
      canvas.FontSet(FONT_MONO, FSIZE_VALUE, FW_NORMAL, 0);
      canvas.TextOut(valX, y, balStr, CLR_TEXT_PRIMARY, TA_LEFT | TA_TOP);
      canvas.FontSet(FONT_LABEL, FSIZE_SECTION, FW_NORMAL, 0);
      canvas.TextOut(PANEL_W - px, y, todStr, todClr, TA_RIGHT | TA_TOP);
   }
   y += rowH;

   //--- Row 2: Equity + Running P/L
   {
      string eqStr  = DoubleToString(equity, 2) + " " + cur;
      string plSign = (runPL >= 0) ? "+" : "";
      string plStr  = plSign + DoubleToString(runPL, 2)
                    + " (" + plSign + DoubleToString(runPLPct, 1) + "%)";
      uint   plClr  = (runPL >= 0) ? CLR_PROFIT : CLR_LOSS;

      canvas.FontSet(FONT_LABEL, FSIZE_LABEL, FW_NORMAL, 0);
      canvas.TextOut(px, y, "Equity", CLR_TEXT_DIM, TA_LEFT | TA_TOP);
      canvas.FontSet(FONT_MONO, FSIZE_VALUE, FW_NORMAL, 0);
      canvas.TextOut(valX, y, eqStr, CLR_TEXT_PRIMARY, TA_LEFT | TA_TOP);
      canvas.FontSet(FONT_MONO, FSIZE_SECTION, FW_NORMAL, 0);
      canvas.TextOut(PANEL_W - px, y, plStr, plClr, TA_RIGHT | TA_TOP);
   }
   y += rowH;

   //--- Row 3: Margin Used (+ %)
   {
      string mStr = DoubleToString(margin, 2) + " " + cur
                  + "  (" + DoubleToString(marginPct, 1) + "%)";

      canvas.FontSet(FONT_LABEL, FSIZE_LABEL, FW_NORMAL, 0);
      canvas.TextOut(px, y, "Margin", CLR_TEXT_DIM, TA_LEFT | TA_TOP);
      canvas.FontSet(FONT_MONO, FSIZE_VALUE, FW_NORMAL, 0);
      canvas.TextOut(valX, y, mStr, CLR_TEXT_PRIMARY, TA_LEFT | TA_TOP);
   }
   y += rowH;

   //--- Row 4: Free Margin + Spread
   {
      string fmStr = DoubleToString(freeMargin, 2) + " " + cur;
      string spStr = "Spread: " + IntegerToString(spreadPts) + " pts";
      uint   spClr = (spreadPts > 50) ? CLR_WARN : CLR_TEXT_DIM;

      canvas.FontSet(FONT_LABEL, FSIZE_LABEL, FW_NORMAL, 0);
      canvas.TextOut(px, y, "Free", CLR_TEXT_DIM, TA_LEFT | TA_TOP);
      canvas.FontSet(FONT_MONO, FSIZE_VALUE, FW_NORMAL, 0);
      canvas.TextOut(valX, y, fmStr, CLR_TEXT_PRIMARY, TA_LEFT | TA_TOP);
      canvas.FontSet(FONT_LABEL, FSIZE_SECTION, FW_NORMAL, 0);
      canvas.TextOut(PANEL_W - px, y, spStr, spClr, TA_RIGHT | TA_TOP);
   }
   y += rowH;

   //--- Row 5: Symbol + open position count
   {
      string posStr = IntegerToString(openCount)
                    + (openCount == 1 ? " position" : " positions");

      canvas.FontSet(FONT_LABEL, FSIZE_LABEL, FW_NORMAL, 0);
      canvas.TextOut(px, y, _Symbol, CLR_ACCENT, TA_LEFT | TA_TOP);
      canvas.FontSet(FONT_MONO, FSIZE_VALUE, FW_NORMAL, 0);
      canvas.TextOut(valX, y, posStr, CLR_TEXT_DIM, TA_LEFT | TA_TOP);
   }
}

#endif // LTM_DASHBOARD_MQH

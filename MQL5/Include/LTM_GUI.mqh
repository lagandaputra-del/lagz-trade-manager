//+------------------------------------------------------------------+
//|                                                    LTM_GUI.mqh   |
//|            Lagz Trade Manager — GUI constants, draw, events       |
//|  Included by LagzTradeManager.mq5 (single compilation unit).     |
//|  All globals (g_canvas, g_panel, g_hits, g_panelH, etc.) are     |
//|  defined in the main .mq5 — directly accessible here.            |
//+------------------------------------------------------------------+
#ifndef LTM_GUI_MQH
#define LTM_GUI_MQH

#include <Canvas\Canvas.mqh>

//+------------------------------------------------------------------+
//| Color constants  (V2 palette)                                      |
//+------------------------------------------------------------------+
// Backgrounds
#define CLR_BG_DEEP       XRGB(0x0F,0x11,0x1A)   // #0F111A main bg
#define CLR_BG_PANEL      XRGB(0x1F,0x23,0x2F)   // #1F232F card/section bg
#define CLR_BG_INPUT      XRGB(0x10,0x14,0x2A)   // #10142A input fields
// Borders
#define CLR_BORDER_DIM    XRGB(0x2A,0x2E,0x40)   // subtle separators
#define CLR_BORDER_GLOW   XRGB(0x6C,0x4A,0xF3)   // #6C4AF3 accent border
#define CLR_BORDER_FOCUS  XRGB(0x9C,0x7A,0xFF)   // active field border
// Text
#define CLR_TEXT_PRIMARY  XRGB(0xFF,0xFF,0xFF)   // #FFFFFF
#define CLR_TEXT_DIM      XRGB(0x8A,0x8F,0xA8)   // #8A8FA8 dimmed labels
#define CLR_TEXT_SECTION  XRGB(0x8A,0x8F,0xA8)   // section header text
// Accent
#define CLR_ACCENT        XRGB(0x6C,0x4A,0xF3)   // #6C4AF3 purple accent
#define CLR_ACCENT2       XRGB(0x00,0xD4,0xFF)   // cyan (secondary)
// Trading
#define CLR_PROFIT        XRGB(0x27,0xD0,0x8F)   // #27D08F BUY green
#define CLR_PROFIT_DIM    XRGB(0x0D,0x22,0x18)   // dark green card bg
#define CLR_LOSS          XRGB(0xFF,0x33,0x44)   // #FF3344 SELL red
#define CLR_LOSS_DIM      XRGB(0x28,0x0A,0x10)   // dark red card bg
#define CLR_WARN          XRGB(0xFF,0x98,0x44)   // #FF9844 orange (partial close)
// Buttons
#define CLR_NEUTRAL       XRGB(0x28,0x2C,0x40)   // neutral button bg
#define CLR_AUTO_OFF      XRGB(0x1A,0x1E,0x2C)   // disabled toggle bg
#define CLR_BTN_BE        XRGB(0x1E,0x40,0x7A)   // #1E407A SET BE blue
#define CLR_BTN_DANGER    XRGB(0xA7,0x44,0x44)   // #A74444 CLOSE ALL danger
#define CLR_BTN_TEXT_DK   XRGB(0x00,0x00,0x00)   // black text on bright buttons
#define CLR_WHITE         XRGB(0xFF,0xFF,0xFF)

//+------------------------------------------------------------------+
//| Layout constants  (400px wide — V2)                               |
//+------------------------------------------------------------------+
#define CANVAS_NAME       "LTM_Canvas"
#define PANEL_W           400
#define PANEL_TITLE_H     40
#define PANEL_COMPACT_H   145  // compact mode total height
#define PANEL_OVERVIEW_H  80   // 2-row account grid (3-line col + PAD_Y=10)
#define PANEL_TABS_H      36   // MARKET/PENDING tab bar
#define PANEL_INPUT_H     122  // 4 rows: lot + sl/tp + price + margin
#define PANEL_BUYSELL_H   56   // BUY/SELL buttons (always visible)
#define PANEL_QUICK_H     122  // sub-lbl + 28 partial row + sub-lbl + 28 SET BE + PAD_Y
#define PANEL_MANAGE_H    100  // PAD_Y + 34 CLOSE ALL + 10 + 34 CLOSE BUY/SELL
#define PANEL_BE_H        116  // PAD_Y + 26 toggle + 10 + 26 after + 10 + 26 ofs
#define PANEL_STATUS_H    26
#define PANEL_SEC_H       28   // collapsible section header height
#define PANEL_PAD_X       10
#define PANEL_PAD_Y       10
#define PANEL_XDIST       10
#define PANEL_YDIST       30

// Input field and button heights
#define FIELD_H           26    // input fields
#define BTN_H_LG          56    // BUY / SELL primary buttons
#define BTN_H_MD          34    // CLOSE ALL / CLOSE BUY / CLOSE SELL
#define BTN_H_SM          28    // partial close / SET BE / small actions
#define BTN_H_XS          22    // +/- increment buttons
#define BTN_PLUSMINUS_W   24    // width of +/- buttons

//+------------------------------------------------------------------+
//| Font constants  (V2 — all Tahoma)                                  |
//+------------------------------------------------------------------+
#define FONT_LABEL        "Tahoma"
#define FONT_LABEL_BOLD   "Tahoma Bold"
#define FONT_MONO         "Tahoma"
#define FSIZE_TITLE       -110
#define FSIZE_SECTION     -85
#define FSIZE_LABEL       -90
#define FSIZE_VALUE       -100
#define FSIZE_PL          -110
#define FSIZE_BTN         -95

//+------------------------------------------------------------------+
//| Active input field enum                                            |
//+------------------------------------------------------------------+
enum ENUM_ACTIVE_FIELD {
   FIELD_NONE        = 0,
   FIELD_LOT         = 1,
   FIELD_SL          = 2,
   FIELD_TP          = 3,
   FIELD_PENDING_PRICE = 4,
   FIELD_SET_TP      = 5,
   FIELD_BE_OFFSET   = 6,
   FIELD_AUTO_BE_AFTER = 7,
   FIELD_AUTO_BE_OFFSET = 8
};

//+------------------------------------------------------------------+
//| Panel state struct                                                 |
//+------------------------------------------------------------------+
struct PanelState {
   string  lotValue;
   string  slValue;
   string  tpValue;
   string  pendingPrice;
   string  setTPValue;
   string  beOffset;
   string  autoBeAfter;
   string  autoBeOfs;
   bool    lotModeRisk;
   bool    slTpModePips;
   bool    autoBEEnabled;
   bool    panelMinimized;
   bool    accordionOpen;
   bool    confirmCloseAll;
   bool    confirmPartial;
   bool    manageOwnOnly;
   ENUM_ACTIVE_FIELD activeField;
   // V2 fields
   bool    tabMarket;        // true=MARKET, false=PENDING
   bool    collapseOverview;
   bool    collapseInput;
   bool    collapseQuick;
   bool    collapseManage;
   bool    collapseBE;
};

//+------------------------------------------------------------------+
//| Hit region struct                                                  |
//+------------------------------------------------------------------+
struct HitRegion {
   int    x1, y1, x2, y2;
   string action;
};

//+------------------------------------------------------------------+
//| Forward declarations                                               |
//+------------------------------------------------------------------+
void LTM_DrawAccountOverview(int yTop);
void LTM_OpenBuy();
void LTM_OpenSell();
void LTM_OpenBuyLimit();
void LTM_OpenSellLimit();
void LTM_CloseAll();
void LTM_CloseBuyOnly();
void LTM_CloseSellOnly();
void LTM_PartialClose(double pct);
void LTM_SetTPAll(double price);
void LTM_SetBreakeven(int offsetPips);

//+------------------------------------------------------------------+
//| Canvas creation / resize                                          |
//+------------------------------------------------------------------+
void LTM_CreateCanvas()
{
   int totalH;
   if(g_panel.panelMinimized)
   {
      totalH = PANEL_COMPACT_H;
   }
   else
   {
      int inputH = PANEL_INPUT_H + (g_panel.tabMarket ? 0 : FIELD_H + 6);
      totalH = PANEL_TITLE_H
             + PANEL_SEC_H + (g_panel.collapseOverview ? 0 : PANEL_OVERVIEW_H)
             + PANEL_TABS_H
             + PANEL_SEC_H + (g_panel.collapseInput    ? 0 : inputH)
             + PANEL_BUYSELL_H
             + PANEL_SEC_H + (g_panel.collapseQuick    ? 0 : PANEL_QUICK_H)
             + PANEL_SEC_H + (g_panel.collapseManage   ? 0 : PANEL_MANAGE_H)
             + PANEL_SEC_H + (g_panel.collapseBE       ? 0 : PANEL_BE_H)
             + PANEL_STATUS_H;
   }

   if(totalH == g_panelH && ObjectFind(0, CANVAS_NAME) >= 0)
      return;

   g_panelH = totalH;

   if(ObjectFind(0, CANVAS_NAME) >= 0)
      g_canvas.Destroy();

   if(!g_canvas.CreateBitmapLabel(0, 0, CANVAS_NAME,
                                  PANEL_XDIST, PANEL_YDIST,
                                  PANEL_W, g_panelH,
                                  COLOR_FORMAT_XRGB_NOALPHA))
   {
      Print("LTM_GUI: CreateBitmapLabel failed");
      return;
   }

   ObjectSetInteger(0, CANVAS_NAME, OBJPROP_CORNER,    InpCorner);
   ObjectSetInteger(0, CANVAS_NAME, OBJPROP_XDISTANCE, PANEL_XDIST);
   ObjectSetInteger(0, CANVAS_NAME, OBJPROP_YDISTANCE, PANEL_YDIST);
   ObjectSetInteger(0, CANVAS_NAME, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, CANVAS_NAME, OBJPROP_HIDDEN,    true);
}

//+------------------------------------------------------------------+
//| Panel screen-space helpers                                         |
//+------------------------------------------------------------------+
int LTM_PanelScreenX()
{
   if(InpCorner == CORNER_RIGHT_UPPER || InpCorner == CORNER_RIGHT_LOWER)
      return (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS) - PANEL_XDIST - PANEL_W;
   return PANEL_XDIST;
}

int LTM_PanelScreenY()
{
   if(InpCorner == CORNER_LEFT_LOWER || InpCorner == CORNER_RIGHT_LOWER)
      return (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS) - PANEL_YDIST - g_panelH;
   return PANEL_YDIST;
}

//+------------------------------------------------------------------+
//| Hit region management                                              |
//+------------------------------------------------------------------+
void LTM_HitRegionAdd(int x1, int y1, int x2, int y2, const string action)
{
   if(g_hitCount >= ArraySize(g_hits))
      ArrayResize(g_hits, ArraySize(g_hits) + 32);

   g_hits[g_hitCount].x1     = x1;
   g_hits[g_hitCount].y1     = y1;
   g_hits[g_hitCount].x2     = x2;
   g_hits[g_hitCount].y2     = y2;
   g_hits[g_hitCount].action = action;
   g_hitCount++;
}

//+------------------------------------------------------------------+
//| Status bar message                                                 |
//+------------------------------------------------------------------+
void LTM_ShowStatus(const string msg, const bool isError)
{
   g_statusMsg   = msg;
   g_statusTime  = TimeCurrent();
   g_statusIsErr = isError;
}

//+------------------------------------------------------------------+
//| Panel state persistence — GlobalVariable-based                    |
//| Names are prefixed with magic number to avoid EA conflicts.       |
//+------------------------------------------------------------------+

string LTM_FormatRestored(double val)
{
   if(val == 0.0) return "0";
   double rounded = MathRound(val);
   if(MathAbs(val - rounded) < 0.0001)
      return IntegerToString((int)rounded);
   return DoubleToString(val, 2);
}

void LTM_PanelStateSave()
{
   string p = "LTM_" + IntegerToString(InpMagic) + "_";
   GlobalVariableSet(p + "Lot",     StringToDouble(g_panel.lotValue));
   GlobalVariableSet(p + "SL",      StringToDouble(g_panel.slValue));
   GlobalVariableSet(p + "TP",      StringToDouble(g_panel.tpValue));
   GlobalVariableSet(p + "Price",   StringToDouble(g_panel.pendingPrice));
   // Use -1.0 as sentinel for empty setTPValue
   GlobalVariableSet(p + "SetTP",   g_panel.setTPValue == "" ? -1.0 : StringToDouble(g_panel.setTPValue));
   GlobalVariableSet(p + "BEOfs",   StringToDouble(g_panel.beOffset));
   GlobalVariableSet(p + "ABEAft",  StringToDouble(g_panel.autoBeAfter));
   GlobalVariableSet(p + "ABEOfs",  StringToDouble(g_panel.autoBeOfs));
   GlobalVariableSet(p + "LotRisk", g_panel.lotModeRisk    ? 1.0 : 0.0);
   GlobalVariableSet(p + "Pips",    g_panel.slTpModePips   ? 1.0 : 0.0);
   GlobalVariableSet(p + "ABEon",   g_panel.autoBEEnabled  ? 1.0 : 0.0);
   GlobalVariableSet(p + "Mini",    g_panel.panelMinimized ? 1.0 : 0.0);
   GlobalVariableSet(p + "Accord",  g_panel.accordionOpen  ? 1.0 : 0.0);
   GlobalVariableSet(p + "TabMkt",  g_panel.tabMarket        ? 1.0 : 0.0);
   GlobalVariableSet(p + "ColOv",   g_panel.collapseOverview ? 1.0 : 0.0);
   GlobalVariableSet(p + "ColIn",   g_panel.collapseInput    ? 1.0 : 0.0);
   GlobalVariableSet(p + "ColQk",   g_panel.collapseQuick    ? 1.0 : 0.0);
   GlobalVariableSet(p + "ColMg",   g_panel.collapseManage   ? 1.0 : 0.0);
   GlobalVariableSet(p + "ColBE",   g_panel.collapseBE       ? 1.0 : 0.0);
}

bool LTM_PanelStateLoad()
{
   string p = "LTM_" + IntegerToString(InpMagic) + "_";
   if(!GlobalVariableCheck(p + "Lot")) return false;

   double v;
   GlobalVariableGet(p + "Lot",     v); g_panel.lotValue     = DoubleToString(v, 2);
   GlobalVariableGet(p + "SL",      v); g_panel.slValue      = LTM_FormatRestored(v);
   GlobalVariableGet(p + "TP",      v); g_panel.tpValue      = LTM_FormatRestored(v);
   GlobalVariableGet(p + "Price",   v); g_panel.pendingPrice = LTM_FormatRestored(v);
   GlobalVariableGet(p + "SetTP",   v); g_panel.setTPValue   = (v == -1.0) ? "" : DoubleToString(v, _Digits);
   GlobalVariableGet(p + "BEOfs",   v); g_panel.beOffset     = LTM_FormatRestored(v);
   GlobalVariableGet(p + "ABEAft",  v); g_panel.autoBeAfter  = LTM_FormatRestored(v);
   GlobalVariableGet(p + "ABEOfs",  v); g_panel.autoBeOfs    = LTM_FormatRestored(v);
   GlobalVariableGet(p + "LotRisk", v); g_panel.lotModeRisk    = (v >= 0.5);
   GlobalVariableGet(p + "Pips",    v); g_panel.slTpModePips   = (v >= 0.5);
   GlobalVariableGet(p + "ABEon",   v); g_panel.autoBEEnabled  = (v >= 0.5);
   GlobalVariableGet(p + "Mini",    v); g_panel.panelMinimized = (v >= 0.5);
   GlobalVariableGet(p + "Accord",  v); g_panel.accordionOpen  = (v >= 0.5);
   // V2 fields — default if key absent
   if(GlobalVariableCheck(p + "TabMkt")) { GlobalVariableGet(p + "TabMkt", v); g_panel.tabMarket        = (v >= 0.5); } else g_panel.tabMarket        = true;
   if(GlobalVariableCheck(p + "ColOv"))  { GlobalVariableGet(p + "ColOv",  v); g_panel.collapseOverview = (v >= 0.5); } else g_panel.collapseOverview = false;
   if(GlobalVariableCheck(p + "ColIn"))  { GlobalVariableGet(p + "ColIn",  v); g_panel.collapseInput    = (v >= 0.5); } else g_panel.collapseInput    = false;
   if(GlobalVariableCheck(p + "ColQk"))  { GlobalVariableGet(p + "ColQk",  v); g_panel.collapseQuick    = (v >= 0.5); } else g_panel.collapseQuick    = false;
   if(GlobalVariableCheck(p + "ColMg"))  { GlobalVariableGet(p + "ColMg",  v); g_panel.collapseManage   = (v >= 0.5); } else g_panel.collapseManage   = false;
   if(GlobalVariableCheck(p + "ColBE"))  { GlobalVariableGet(p + "ColBE",  v); g_panel.collapseBE       = (v >= 0.5); } else g_panel.collapseBE       = false;
   return true;
}

void LTM_PanelStateDelete()
{
   string p = "LTM_" + IntegerToString(InpMagic) + "_";
   GlobalVariableDel(p + "Lot");
   GlobalVariableDel(p + "SL");
   GlobalVariableDel(p + "TP");
   GlobalVariableDel(p + "Price");
   GlobalVariableDel(p + "SetTP");
   GlobalVariableDel(p + "BEOfs");
   GlobalVariableDel(p + "ABEAft");
   GlobalVariableDel(p + "ABEOfs");
   GlobalVariableDel(p + "LotRisk");
   GlobalVariableDel(p + "Pips");
   GlobalVariableDel(p + "ABEon");
   GlobalVariableDel(p + "Mini");
   GlobalVariableDel(p + "Accord");
   GlobalVariableDel(p + "TabMkt");
   GlobalVariableDel(p + "ColOv");
   GlobalVariableDel(p + "ColIn");
   GlobalVariableDel(p + "ColQk");
   GlobalVariableDel(p + "ColMg");
   GlobalVariableDel(p + "ColBE");
}

//+------------------------------------------------------------------+
//| Draw helpers                                                       |
//+------------------------------------------------------------------+

void LTM_DrawSectionHeader(int y, const string label, const string action, bool collapsed)
{
   g_canvas.FillRectangle(0, y, PANEL_W, y + PANEL_SEC_H, CLR_BG_PANEL);
   g_canvas.FillRectangle(0, y, PANEL_W, y + 1, CLR_BORDER_DIM);
   string arrow = collapsed ? ">" : "v";
   g_canvas.FontSet(FONT_LABEL_BOLD, FSIZE_LABEL, FW_BOLD, 0);
   g_canvas.TextOut(PANEL_PAD_X, y + PANEL_SEC_H/2, label, CLR_TEXT_DIM, TA_LEFT | TA_VCENTER);
   g_canvas.TextOut(PANEL_W - PANEL_PAD_X, y + PANEL_SEC_H/2, arrow, CLR_TEXT_DIM, TA_RIGHT | TA_VCENTER);
   LTM_HitRegionAdd(0, y, PANEL_W, y + PANEL_SEC_H, action);
}

void LTM_DrawButton(int x, int y, int w, int h,
                    const string label, uint bg, uint fg,
                    const string action)
{
   g_canvas.FillRectangle(x, y, x + w, y + h, bg);
   g_canvas.Rectangle(x, y, x + w, y + h, CLR_BORDER_DIM);
   g_canvas.FontSet(FONT_LABEL_BOLD, FSIZE_BTN, FW_BOLD, 0);
   g_canvas.TextOut(x + w / 2, y + h / 2, label, fg, TA_CENTER | TA_VCENTER);
   LTM_HitRegionAdd(x, y, x + w, y + h, action);
}

void LTM_DrawField(int x, int y, int w, int h,
                   const string val, ENUM_ACTIVE_FIELD fid)
{
   bool isActive = (g_panel.activeField == fid);
   uint border   = isActive ? CLR_BORDER_FOCUS : CLR_BORDER_DIM;

   g_canvas.FillRectangle(x, y, x + w, y + h, CLR_BG_INPUT);
   g_canvas.Rectangle(x, y, x + w, y + h, border);

   g_canvas.FontSet(FONT_MONO, FSIZE_VALUE, FW_NORMAL, 0);
   g_canvas.TextOut(x + 4, y + h / 2, val, CLR_TEXT_PRIMARY, TA_LEFT | TA_VCENTER);

   if(isActive)
   {
      int tw = 0, th = 0;
      g_canvas.TextSize(val, tw, th);
      int cx = x + 4 + tw;
      if(cx < x + w - 2)
         g_canvas.FillRectangle(cx, y + 3, cx + 1, y + h - 3, CLR_BORDER_FOCUS);
   }

   string actionStr = "FIELD_" + IntegerToString((int)fid);
   LTM_HitRegionAdd(x, y, x + w, y + h, actionStr);
}

//+------------------------------------------------------------------+
//| Title bar (V2)                                                     |
//+------------------------------------------------------------------+
void LTM_DrawTitleBar()
{
   int h = PANEL_TITLE_H;
   g_canvas.FillRectangle(0, 0, PANEL_W, h, CLR_BG_DEEP);
   g_canvas.FillRectangle(0, h - 2, PANEL_W, h, CLR_ACCENT);

   g_canvas.FontSet(FONT_LABEL_BOLD, FSIZE_TITLE, FW_BOLD, 0);
   g_canvas.TextOut(PANEL_PAD_X, h / 2, "LAGZ TRADE MANAGER", CLR_ACCENT, TA_LEFT | TA_VCENTER);

   int btnW = 26, btnH = h - 8, btnY = 4;
   int minBtnX = PANEL_W - btnW - 4;
   int gearX   = minBtnX - btnW - 6;

   // Settings icon (cosmetic)
   g_canvas.FillRectangle(gearX, btnY, gearX + btnW, btnY + btnH, CLR_BG_PANEL);
   g_canvas.Rectangle(gearX, btnY, gearX + btnW, btnY + btnH, CLR_BORDER_DIM);
   g_canvas.FontSet(FONT_LABEL, FSIZE_BTN, FW_NORMAL, 0);
   g_canvas.TextOut(gearX + btnW / 2, btnY + btnH / 2, "*", CLR_TEXT_DIM, TA_CENTER | TA_VCENTER);

   // Minimize button
   g_canvas.FillRectangle(minBtnX, btnY, minBtnX + btnW, btnY + btnH, CLR_BG_PANEL);
   g_canvas.Rectangle(minBtnX, btnY, minBtnX + btnW, btnY + btnH, CLR_BORDER_DIM);
   g_canvas.FontSet(FONT_LABEL_BOLD, FSIZE_BTN, FW_BOLD, 0);
   g_canvas.TextOut(minBtnX + btnW / 2, btnY + btnH / 2, "-", CLR_TEXT_PRIMARY, TA_CENTER | TA_VCENTER);
   LTM_HitRegionAdd(minBtnX, btnY, minBtnX + btnW, btnY + btnH, "MINIMIZE");
}

//+------------------------------------------------------------------+
//| Compact mode (replaces minimize title-bar-only behavior)           |
//+------------------------------------------------------------------+
void LTM_DrawCompactMode()
{
   int px = PANEL_PAD_X;
   int h  = PANEL_TITLE_H;

   // Title row
   g_canvas.FillRectangle(0, 0, PANEL_W, h, CLR_BG_DEEP);
   g_canvas.FillRectangle(0, h - 2, PANEL_W, h, CLR_ACCENT);
   g_canvas.FontSet(FONT_LABEL_BOLD, FSIZE_TITLE, FW_BOLD, 0);
   g_canvas.TextOut(px, h / 2, "LAGZ TRADE MANAGER", CLR_ACCENT, TA_LEFT | TA_VCENTER);

   int btnW = 26, btnH = h - 8, btnY = 4;
   int minBtnX = PANEL_W - btnW - 4;
   g_canvas.FillRectangle(minBtnX, btnY, minBtnX + btnW, btnY + btnH, CLR_BG_PANEL);
   g_canvas.Rectangle(minBtnX, btnY, minBtnX + btnW, btnY + btnH, CLR_BORDER_DIM);
   g_canvas.FontSet(FONT_LABEL_BOLD, FSIZE_BTN, FW_BOLD, 0);
   g_canvas.TextOut(minBtnX + btnW / 2, btnY + btnH / 2, "+", CLR_TEXT_PRIMARY, TA_CENTER | TA_VCENTER);
   LTM_HitRegionAdd(minBtnX, btnY, minBtnX + btnW, btnY + btnH, "MINIMIZE");

   // Account 4-col row
   int y = h + 4;
   g_canvas.FillRectangle(0, h, PANEL_W, h + 42, CLR_BG_PANEL);

   double balance    = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity     = AccountInfoDouble(ACCOUNT_EQUITY);
   double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double runPL      = 0.0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(g_panel.manageOwnOnly && PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      runPL += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
   }

   double profitToday    = balance + runPL - g_dayStartBalance;
   double profitTodayPct = (g_dayStartBalance > 0.0)
                           ? (profitToday / g_dayStartBalance * 100.0)
                           : 0.0;
   string todSign = (profitToday >= 0) ? "+" : "";

   string colLabels[] = {"Bal", "Eq", "Free", "PNL Hari"};
   string colVals[]   = {
      DoubleToString(balance, 2),
      DoubleToString(equity, 2),
      DoubleToString(freeMargin, 2),
      todSign + DoubleToString(profitTodayPct, 1) + "%"
   };
   uint todClr  = (profitToday >= 0) ? CLR_PROFIT : CLR_LOSS;
   uint colClrs[] = {CLR_TEXT_PRIMARY, CLR_TEXT_PRIMARY, CLR_TEXT_PRIMARY, todClr};

   int colW = (PANEL_W - 2 * px) / 4;
   for(int c = 0; c < 4; c++)
   {
      int cx = px + c * colW;
      g_canvas.FontSet(FONT_LABEL, FSIZE_SECTION, FW_NORMAL, 0);
      g_canvas.TextOut(cx, y, colLabels[c], CLR_TEXT_DIM, TA_LEFT | TA_TOP);
      g_canvas.FontSet(FONT_LABEL_BOLD, FSIZE_LABEL, FW_BOLD, 0);
      g_canvas.TextOut(cx, y + 14, colVals[c], colClrs[c], TA_LEFT | TA_TOP);
   }
   y += 42;

   // BUY / SELL buttons
   int gap = 4, bW = (PANEL_W - 2 * px - gap) / 2;
   LTM_DrawButton(px,            y, bW, BTN_H_LG, "↑ BUY",  CLR_PROFIT, CLR_BTN_TEXT_DK, "BUY");
   LTM_DrawButton(px + bW + gap, y, bW, BTN_H_LG, "↓ SELL", CLR_LOSS,   CLR_WHITE,       "SELL");
   y += BTN_H_LG;

   LTM_DrawStatusBar(y);
}

//+------------------------------------------------------------------+
//| Status bar                                                         |
//+------------------------------------------------------------------+
void LTM_DrawStatusBar(int y)
{
   g_canvas.FillRectangle(0, y, PANEL_W, y + PANEL_STATUS_H, CLR_BG_DEEP);
   g_canvas.FillRectangle(0, y, PANEL_W, y + 1, CLR_BORDER_DIM);

   if(g_statusMsg != "" && (TimeCurrent() - g_statusTime) >= 3)
      g_statusMsg = "";

   if(g_statusMsg != "")
   {
      uint msgClr = g_statusIsErr ? CLR_LOSS : CLR_PROFIT;
      g_canvas.FontSet(FONT_LABEL, FSIZE_LABEL, FW_NORMAL, 0);
      g_canvas.TextOut(PANEL_PAD_X, y + PANEL_STATUS_H / 2,
                       g_statusMsg, msgClr, TA_LEFT | TA_VCENTER);
   }
}

//+------------------------------------------------------------------+
//| Trade Mode Tabs (Step 7)                                           |
//+------------------------------------------------------------------+
void LTM_DrawTradeTabs(int yTop)
{
   int y  = yTop;
   int px = PANEL_PAD_X;
   int tabW = (PANEL_W - 2 * px) / 2;
   int h    = PANEL_TABS_H;

   g_canvas.FillRectangle(0, y, PANEL_W, y + h, CLR_BG_DEEP);
   g_canvas.FillRectangle(0, y, PANEL_W, y + 1, CLR_BORDER_DIM);

   // MARKET tab
   {
      bool   active = g_panel.tabMarket;
      uint   bg     = active ? CLR_BG_PANEL      : CLR_BG_DEEP;
      uint   fg     = active ? CLR_TEXT_PRIMARY   : CLR_TEXT_DIM;
      g_canvas.FillRectangle(px, y + 2, px + tabW, y + h - 2, bg);
      if(active) g_canvas.FillRectangle(px, y + h - 3, px + tabW, y + h - 1, CLR_ACCENT);
      g_canvas.FontSet(FONT_LABEL_BOLD, FSIZE_LABEL, FW_BOLD, 0);
      g_canvas.TextOut(px + tabW / 2, y + h / 2, "MARKET", fg, TA_CENTER | TA_VCENTER);
      LTM_HitRegionAdd(px, y, px + tabW, y + h, "TAB_MARKET");
   }

   // PENDING tab
   {
      bool   active = !g_panel.tabMarket;
      uint   bg     = active ? CLR_BG_PANEL      : CLR_BG_DEEP;
      uint   fg     = active ? CLR_TEXT_PRIMARY   : CLR_TEXT_DIM;
      g_canvas.FillRectangle(px + tabW, y + 2, px + 2 * tabW, y + h - 2, bg);
      if(active) g_canvas.FillRectangle(px + tabW, y + h - 3, px + 2 * tabW, y + h - 1, CLR_ACCENT);
      g_canvas.FontSet(FONT_LABEL_BOLD, FSIZE_LABEL, FW_BOLD, 0);
      g_canvas.TextOut(px + tabW + tabW / 2, y + h / 2, "PENDING", fg, TA_CENTER | TA_VCENTER);
      LTM_HitRegionAdd(px + tabW, y, px + 2 * tabW, y + h, "TAB_PENDING");
   }
}

//+------------------------------------------------------------------+
//| Trade Input section (Step 8)                                       |
//+------------------------------------------------------------------+
void LTM_DrawTradeInput(int yTop)
{
   int y    = yTop + 6;
   int px   = PANEL_PAD_X;
   int bPM  = BTN_PLUSMINUS_W;   // 24 — +/- button width
   int gap  = 4;
   int lblW = 30;                 // row label width
   int togW = 52;                 // toggle button width
   // field fills remaining space
   int fldW = PANEL_W - px - lblW - bPM - gap - bPM - gap - togW - gap - px;

   g_canvas.FillRectangle(0, yTop, PANEL_W, yTop + PANEL_INPUT_H + (g_panel.tabMarket ? 0 : FIELD_H + 6), CLR_BG_DEEP);

   // Row 1: Lot / Risk% with +/- and mode toggle
   {
      string lotLbl = g_panel.lotModeRisk ? "Risk%" : "Lot";
      g_canvas.FontSet(FONT_LABEL, FSIZE_LABEL, FW_NORMAL, 0);
      g_canvas.TextOut(px, y + FIELD_H / 2, lotLbl, CLR_TEXT_DIM, TA_LEFT | TA_VCENTER);

      int minX  = px + lblW;
      int fldX  = minX + bPM + gap;
      int plusX = fldX + fldW + gap;
      int togX  = plusX + bPM + gap;

      LTM_DrawButton(minX, y, bPM,  FIELD_H, "-",   CLR_NEUTRAL,  CLR_WHITE,    "LOT_MINUS");
      LTM_DrawField (fldX, y, fldW, FIELD_H, g_panel.lotValue, FIELD_LOT);
      LTM_DrawButton(plusX, y, bPM, FIELD_H, "+",   CLR_NEUTRAL,  CLR_WHITE,    "LOT_PLUS");
      string tLbl = g_panel.lotModeRisk ? "RISK%" : "FIXED";
      LTM_DrawButton(togX,  y, togW, FIELD_H, tLbl, CLR_AUTO_OFF, CLR_TEXT_DIM, "TOGGLE_LOT_MODE");
   }
   y += FIELD_H + 6;

   // Row 2: SL with +/- and pips/price toggle
   {
      g_canvas.FontSet(FONT_LABEL, FSIZE_LABEL, FW_NORMAL, 0);
      g_canvas.TextOut(px, y + FIELD_H / 2, "SL", CLR_TEXT_DIM, TA_LEFT | TA_VCENTER);

      int minX  = px + lblW;
      int fldX  = minX + bPM + gap;
      int plusX = fldX + fldW + gap;
      int togX  = plusX + bPM + gap;

      LTM_DrawButton(minX, y, bPM,  FIELD_H, "-",   CLR_NEUTRAL,  CLR_WHITE,    "SL_MINUS");
      LTM_DrawField (fldX, y, fldW, FIELD_H, g_panel.slValue, FIELD_SL);
      LTM_DrawButton(plusX, y, bPM, FIELD_H, "+",   CLR_NEUTRAL,  CLR_WHITE,    "SL_PLUS");
      string modeLbl = g_panel.slTpModePips ? "pips" : "price";
      LTM_DrawButton(togX,  y, togW, FIELD_H, modeLbl, CLR_AUTO_OFF, CLR_TEXT_DIM, "TOGGLE_SLTP_MODE");
   }
   y += FIELD_H + 6;

   // Row 3: TP with +/- (same field width, no toggle on right)
   {
      g_canvas.FontSet(FONT_LABEL, FSIZE_LABEL, FW_NORMAL, 0);
      g_canvas.TextOut(px, y + FIELD_H / 2, "TP", CLR_TEXT_DIM, TA_LEFT | TA_VCENTER);

      int minX  = px + lblW;
      int fldX  = minX + bPM + gap;
      int plusX = fldX + fldW + gap;

      LTM_DrawButton(minX, y, bPM,  FIELD_H, "-", CLR_NEUTRAL, CLR_WHITE, "TP_MINUS");
      LTM_DrawField (fldX, y, fldW, FIELD_H, g_panel.tpValue, FIELD_TP);
      LTM_DrawButton(plusX, y, bPM, FIELD_H, "+", CLR_NEUTRAL, CLR_WHITE, "TP_PLUS");
   }
   y += FIELD_H + 6;

   // Row 4: Price (PENDING mode only)
   if(!g_panel.tabMarket)
   {
      g_canvas.FontSet(FONT_LABEL, FSIZE_LABEL, FW_NORMAL, 0);
      g_canvas.TextOut(px, y + FIELD_H / 2, "Price", CLR_TEXT_DIM, TA_LEFT | TA_VCENTER);
      int priceFieldW = PANEL_W - px - lblW - px;
      LTM_DrawField(px + lblW, y, priceFieldW, FIELD_H, g_panel.pendingPrice, FIELD_PENDING_PRICE);
   }
}

//+------------------------------------------------------------------+
//| BUY / SELL buttons — always visible (Step 9)                      |
//+------------------------------------------------------------------+
void LTM_DrawBuySellButtons(int yTop)
{
   int px  = PANEL_PAD_X;
   int gap = 4;
   int bW  = (PANEL_W - 2 * px - gap) / 2;

   g_canvas.FillRectangle(0, yTop, PANEL_W, yTop + BTN_H_LG, CLR_BG_DEEP);

   if(g_panel.tabMarket)
   {
      LTM_DrawButton(px,             yTop, bW, BTN_H_LG, "↑ BUY",        CLR_PROFIT, CLR_BTN_TEXT_DK, "BUY");
      LTM_DrawButton(px + bW + gap,  yTop, bW, BTN_H_LG, "↓ SELL",       CLR_LOSS,   CLR_WHITE,       "SELL");
   }
   else
   {
      LTM_DrawButton(px,             yTop, bW, BTN_H_LG, "↑ BUY LIMIT",  CLR_PROFIT, CLR_BTN_TEXT_DK, "BUY_LIMIT");
      LTM_DrawButton(px + bW + gap,  yTop, bW, BTN_H_LG, "↓ SELL LIMIT", CLR_LOSS,   CLR_WHITE,       "SELL_LIMIT");
   }
}

//+------------------------------------------------------------------+
//| Quick Actions (Step 10)                                            |
//+------------------------------------------------------------------+
void LTM_DrawQuickActions(int yTop)
{
   int y  = yTop + PANEL_PAD_Y;
   int px = PANEL_PAD_X;

   g_canvas.FillRectangle(0, yTop, PANEL_W, yTop + PANEL_QUICK_H, CLR_BG_DEEP);

   // Sub-label
   g_canvas.FontSet(FONT_LABEL, FSIZE_SECTION, FW_NORMAL, 0);
   g_canvas.TextOut(px, y, "PARTIAL CLOSE - QUICK %", CLR_TEXT_DIM, TA_LEFT | TA_TOP);
   y += 14;

   // Row 1: 25% | 50% | 75% | 80%
   {
      int gap = 4;
      int bW  = (PANEL_W - 2 * px - 3 * gap) / 4;
      LTM_DrawButton(px,                y, bW, BTN_H_SM, "25%", CLR_WARN, CLR_BTN_TEXT_DK, "PARTIAL_25");
      LTM_DrawButton(px + (bW+gap),     y, bW, BTN_H_SM, "50%", CLR_WARN, CLR_BTN_TEXT_DK, "PARTIAL_50");
      LTM_DrawButton(px + 2*(bW+gap),   y, bW, BTN_H_SM, "75%", CLR_WARN, CLR_BTN_TEXT_DK, "PARTIAL_75");
      LTM_DrawButton(px + 3*(bW+gap),   y, bW, BTN_H_SM, "80%", CLR_WARN, CLR_BTN_TEXT_DK, "PARTIAL_80");
   }
   y += BTN_H_SM + 10;

   // Sub-label
   g_canvas.FontSet(FONT_LABEL, FSIZE_SECTION, FW_NORMAL, 0);
   g_canvas.TextOut(px, y, "SET BREAKEVEN", CLR_TEXT_DIM, TA_LEFT | TA_TOP);
   y += 14;

   // Row 2: SET BREAKEVEN — full width
   LTM_DrawButton(px, y, PANEL_W - 2 * px, BTN_H_SM, "SET BREAKEVEN", CLR_BTN_BE, CLR_WHITE, "SET_BE");
}

//+------------------------------------------------------------------+
//| Manage Positions section (Step 11)                                 |
//+------------------------------------------------------------------+
void LTM_DrawManageSection(int yTop)
{
   int y  = yTop + PANEL_PAD_Y;
   int px = PANEL_PAD_X;

   g_canvas.FillRectangle(0, yTop, PANEL_W, yTop + PANEL_MANAGE_H, CLR_BG_DEEP);

   // Row 1: CLOSE ALL — full width, danger color
   LTM_DrawButton(px, y, PANEL_W - 2 * px, BTN_H_MD, "CLOSE ALL", CLR_BTN_DANGER, CLR_WHITE, "CLOSE_ALL");
   y += BTN_H_MD + 10;

   // Row 2: CLOSE BUY | CLOSE SELL
   {
      int gap = 4;
      int bW  = (PANEL_W - 2 * px - gap) / 2;
      LTM_DrawButton(px,            y, bW, BTN_H_MD, "CLOSE BUY",  CLR_PROFIT_DIM, CLR_PROFIT, "CLOSE_BUY");
      LTM_DrawButton(px + bW + gap, y, bW, BTN_H_MD, "CLOSE SELL", CLR_LOSS_DIM,   CLR_LOSS,   "CLOSE_SELL");
   }
}

//+------------------------------------------------------------------+
//| Auto Breakeven section (Step 12)                                   |
//+------------------------------------------------------------------+
void LTM_DrawBESection(int yTop)
{
   int y   = yTop + PANEL_PAD_Y;
   int px  = PANEL_PAD_X;
   int bPM = BTN_PLUSMINUS_W;
   int gap = 4;
   int lblW = 76;   // "After (pips)" / "+ Ofs (pips)"
   int fldW = PANEL_W - px - lblW - bPM - gap - bPM - gap - px;

   g_canvas.FillRectangle(0, yTop, PANEL_W, yTop + PANEL_BE_H, CLR_BG_DEEP);

   // Row 1: AUTO BE toggle + label
   {
      bool   abeOn  = g_panel.autoBEEnabled;
      uint   abeBg  = abeOn ? CLR_ACCENT   : CLR_AUTO_OFF;
      uint   abeFg  = abeOn ? CLR_WHITE    : CLR_TEXT_DIM;
      int    togW   = 44;

      LTM_DrawButton(px, y, togW, FIELD_H, abeOn ? "ON" : "OFF", abeBg, abeFg, "TOGGLE_AUTO_BE");
      g_canvas.FontSet(FONT_LABEL, FSIZE_LABEL, FW_NORMAL, 0);
      g_canvas.TextOut(px + togW + 8, y + FIELD_H / 2, "AUTO BREAKEVEN", CLR_TEXT_DIM, TA_LEFT | TA_VCENTER);
   }
   y += FIELD_H + 10;

   // Row 2: After (pips) +/-
   {
      g_canvas.FontSet(FONT_LABEL, FSIZE_LABEL, FW_NORMAL, 0);
      g_canvas.TextOut(px, y + FIELD_H / 2, "After (pips)", CLR_TEXT_DIM, TA_LEFT | TA_VCENTER);

      int minX  = px + lblW;
      int fldX  = minX + bPM + gap;
      int plusX = fldX + fldW + gap;

      LTM_DrawButton(minX,  y, bPM, FIELD_H, "-", CLR_NEUTRAL, CLR_WHITE, "ABE_AFTER_MINUS");
      LTM_DrawField (fldX,  y, fldW, FIELD_H, g_panel.autoBeAfter, FIELD_AUTO_BE_AFTER);
      LTM_DrawButton(plusX, y, bPM, FIELD_H, "+", CLR_NEUTRAL, CLR_WHITE, "ABE_AFTER_PLUS");
   }
   y += FIELD_H + 10;

   // Row 3: Offset (pips) +/-
   {
      g_canvas.FontSet(FONT_LABEL, FSIZE_LABEL, FW_NORMAL, 0);
      g_canvas.TextOut(px, y + FIELD_H / 2, "+ Ofs (pips)", CLR_TEXT_DIM, TA_LEFT | TA_VCENTER);

      int minX  = px + lblW;
      int fldX  = minX + bPM + gap;
      int plusX = fldX + fldW + gap;

      LTM_DrawButton(minX,  y, bPM, FIELD_H, "-", CLR_NEUTRAL, CLR_WHITE, "ABE_OFS_MINUS");
      LTM_DrawField (fldX,  y, fldW, FIELD_H, g_panel.autoBeOfs, FIELD_AUTO_BE_OFFSET);
      LTM_DrawButton(plusX, y, bPM, FIELD_H, "+", CLR_NEUTRAL, CLR_WHITE, "ABE_OFS_PLUS");
   }
}

//+------------------------------------------------------------------+
//| Main draw orchestrator (Step 3)                                    |
//+------------------------------------------------------------------+
void LTM_DrawPanel()
{
   LTM_CreateCanvas();

   g_hitCount = 0;
   g_canvas.Erase(CLR_BG_DEEP);

   g_canvas.Rectangle(0, 0, PANEL_W - 1, g_panelH - 1, CLR_BORDER_GLOW);
   g_canvas.Rectangle(1, 1, PANEL_W - 2, g_panelH - 2, CLR_BORDER_DIM);

   if(g_panel.panelMinimized)
   {
      LTM_DrawCompactMode();
      g_canvas.Update();
      return;
   }

   int y = 0;

   LTM_DrawTitleBar();
   y += PANEL_TITLE_H;

   // Account Overview (collapsible)
   LTM_DrawSectionHeader(y, "ACCOUNT OVERVIEW", "COLLAPSE_OVERVIEW", g_panel.collapseOverview);
   y += PANEL_SEC_H;
   if(!g_panel.collapseOverview)
   {
      LTM_DrawAccountOverview(y);
      y += PANEL_OVERVIEW_H;
   }

   // Trade Mode Tabs (always visible)
   LTM_DrawTradeTabs(y);
   y += PANEL_TABS_H;

   // Trade Input (collapsible)
   LTM_DrawSectionHeader(y, "TRADE INPUT", "COLLAPSE_INPUT", g_panel.collapseInput);
   y += PANEL_SEC_H;
   if(!g_panel.collapseInput)
   {
      LTM_DrawTradeInput(y);
      y += PANEL_INPUT_H + (g_panel.tabMarket ? 0 : FIELD_H + 6);
   }

   // BUY / SELL always visible
   LTM_DrawBuySellButtons(y);
   y += PANEL_BUYSELL_H;

   // Quick Actions (collapsible)
   LTM_DrawSectionHeader(y, "QUICK ACTIONS", "COLLAPSE_QUICK", g_panel.collapseQuick);
   y += PANEL_SEC_H;
   if(!g_panel.collapseQuick)
   {
      LTM_DrawQuickActions(y);
      y += PANEL_QUICK_H;
   }

   // Manage Positions (collapsible)
   LTM_DrawSectionHeader(y, "MANAGE POSITIONS", "COLLAPSE_MANAGE", g_panel.collapseManage);
   y += PANEL_SEC_H;
   if(!g_panel.collapseManage)
   {
      LTM_DrawManageSection(y);
      y += PANEL_MANAGE_H;
   }

   // Auto Breakeven (collapsible)
   LTM_DrawSectionHeader(y, "AUTO BREAKEVEN", "COLLAPSE_BE", g_panel.collapseBE);
   y += PANEL_SEC_H;
   if(!g_panel.collapseBE)
   {
      LTM_DrawBESection(y);
      y += PANEL_BE_H;
   }

   LTM_DrawStatusBar(y);
   g_canvas.Update();
}

//+------------------------------------------------------------------+
//| Active field get/set helpers                                       |
//+------------------------------------------------------------------+
string LTM_GetActiveFieldValue()
{
   switch(g_panel.activeField)
   {
      case FIELD_LOT:            return g_panel.lotValue;
      case FIELD_SL:             return g_panel.slValue;
      case FIELD_TP:             return g_panel.tpValue;
      case FIELD_PENDING_PRICE:  return g_panel.pendingPrice;
      case FIELD_SET_TP:         return g_panel.setTPValue;
      case FIELD_BE_OFFSET:      return g_panel.beOffset;
      case FIELD_AUTO_BE_AFTER:  return g_panel.autoBeAfter;
      case FIELD_AUTO_BE_OFFSET: return g_panel.autoBeOfs;
      default:                   return "";
   }
}

void LTM_SetActiveFieldValue(const string val)
{
   switch(g_panel.activeField)
   {
      case FIELD_LOT:            g_panel.lotValue     = val; break;
      case FIELD_SL:             g_panel.slValue      = val; break;
      case FIELD_TP:             g_panel.tpValue      = val; break;
      case FIELD_PENDING_PRICE:  g_panel.pendingPrice = val; break;
      case FIELD_SET_TP:         g_panel.setTPValue   = val; break;
      case FIELD_BE_OFFSET:      g_panel.beOffset     = val; break;
      case FIELD_AUTO_BE_AFTER:  g_panel.autoBeAfter  = val; break;
      case FIELD_AUTO_BE_OFFSET: g_panel.autoBeOfs    = val; break;
      default: break;
   }
}

//+------------------------------------------------------------------+
//| Action dispatcher                                                  |
//+------------------------------------------------------------------+
void LTM_DispatchAction(const string action)
{
   if(StringFind(action, "FIELD_") == 0)
   {
      int fid = (int)StringToInteger(StringSubstr(action, 6));
      g_panel.activeField = (ENUM_ACTIVE_FIELD)fid;
      LTM_DrawPanel();
      return;
   }

   g_panel.activeField = FIELD_NONE;

   if(action == "BUY")
   {
      LTM_OpenBuy();
   }
   else if(action == "SELL")
   {
      LTM_OpenSell();
   }
   else if(action == "BUY_LIMIT")
   {
      LTM_OpenBuyLimit();
   }
   else if(action == "SELL_LIMIT")
   {
      LTM_OpenSellLimit();
   }
   else if(action == "CLOSE_ALL")
   {
      if(g_panel.confirmCloseAll)
      {
         int res = MessageBox("Close ALL positions on " + _Symbol + "?",
                              "Confirm Close All", MB_YESNO | MB_ICONQUESTION);
         if(res != IDYES)
         {
            LTM_DrawPanel();
            return;
         }
      }
      LTM_CloseAll();
   }
   else if(action == "CLOSE_BUY")
   {
      LTM_CloseBuyOnly();
   }
   else if(action == "CLOSE_SELL")
   {
      LTM_CloseSellOnly();
   }
   else if(action == "PARTIAL_25")
   {
      if(g_panel.confirmPartial)
      {
         int res = MessageBox("Partial close 25% of " + _Symbol + " positions?",
                              "Confirm Partial Close", MB_YESNO | MB_ICONQUESTION);
         if(res != IDYES) { LTM_DrawPanel(); return; }
      }
      LTM_PartialClose(0.25);
   }
   else if(action == "PARTIAL_50")
   {
      if(g_panel.confirmPartial)
      {
         int res = MessageBox("Partial close 50% of " + _Symbol + " positions?",
                              "Confirm Partial Close", MB_YESNO | MB_ICONQUESTION);
         if(res != IDYES) { LTM_DrawPanel(); return; }
      }
      LTM_PartialClose(0.50);
   }
   else if(action == "PARTIAL_75")
   {
      if(g_panel.confirmPartial)
      {
         int res = MessageBox("Partial close 75% of " + _Symbol + " positions?",
                              "Confirm Partial Close", MB_YESNO | MB_ICONQUESTION);
         if(res != IDYES) { LTM_DrawPanel(); return; }
      }
      LTM_PartialClose(0.75);
   }
   else if(action == "PARTIAL_80")
   {
      if(g_panel.confirmPartial)
      {
         int res = MessageBox("Partial close 80% of " + _Symbol + " positions?",
                              "Confirm Partial Close", MB_YESNO | MB_ICONQUESTION);
         if(res != IDYES) { LTM_DrawPanel(); return; }
      }
      LTM_PartialClose(0.80);
   }
   else if(action == "SET_TP")
   {
      double tp = StringToDouble(g_panel.setTPValue);
      if(tp > 0.0)
         LTM_SetTPAll(tp);
      else
         LTM_ShowStatus("Enter a valid TP price", true);
   }
   else if(action == "SET_BE")
   {
      LTM_SetBreakeven((int)StringToInteger(g_panel.autoBeOfs));
   }
   else if(action == "MINIMIZE")
   {
      g_panel.panelMinimized = !g_panel.panelMinimized;
   }
   else if(action == "TOGGLE_LOT_MODE")
   {
      g_panel.lotModeRisk = !g_panel.lotModeRisk;
   }
   else if(action == "TOGGLE_SLTP_MODE")
   {
      g_panel.slTpModePips = !g_panel.slTpModePips;
   }
   else if(action == "TOGGLE_AUTO_BE")
   {
      g_panel.autoBEEnabled = !g_panel.autoBEEnabled;
      ArrayResize(g_autoBEDone, 0);
   }
   // V2: Tab switching
   else if(action == "TAB_MARKET")  { g_panel.tabMarket = true; }
   else if(action == "TAB_PENDING") { g_panel.tabMarket = false; }
   // V2: Section collapse toggles
   else if(action == "COLLAPSE_OVERVIEW") { g_panel.collapseOverview = !g_panel.collapseOverview; }
   else if(action == "COLLAPSE_INPUT")    { g_panel.collapseInput    = !g_panel.collapseInput;    }
   else if(action == "COLLAPSE_QUICK")    { g_panel.collapseQuick    = !g_panel.collapseQuick;    }
   else if(action == "COLLAPSE_MANAGE")   { g_panel.collapseManage   = !g_panel.collapseManage;   }
   else if(action == "COLLAPSE_BE")       { g_panel.collapseBE       = !g_panel.collapseBE;       }
   // V2: +/- buttons for Lot
   else if(action == "LOT_PLUS")
   {
      double v = StringToDouble(g_panel.lotValue) + 0.01;
      g_panel.lotValue = DoubleToString(MathMax(0.01, v), 2);
   }
   else if(action == "LOT_MINUS")
   {
      double v = StringToDouble(g_panel.lotValue) - 0.01;
      g_panel.lotValue = DoubleToString(MathMax(0.01, v), 2);
   }
   // V2: +/- buttons for SL
   else if(action == "SL_PLUS" || action == "SL_MINUS")
   {
      double step = g_panel.slTpModePips
                    ? 1.0
                    : SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE) * 10.0;
      double v = StringToDouble(g_panel.slValue);
      v += (action == "SL_PLUS") ? step : -step;
      if(v < 0.0) v = 0.0;
      g_panel.slValue = g_panel.slTpModePips
                        ? DoubleToString(v, 0)
                        : DoubleToString(v, _Digits);
   }
   // V2: +/- buttons for TP
   else if(action == "TP_PLUS" || action == "TP_MINUS")
   {
      double step = g_panel.slTpModePips
                    ? 1.0
                    : SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE) * 10.0;
      double v = StringToDouble(g_panel.tpValue);
      v += (action == "TP_PLUS") ? step : -step;
      if(v < 0.0) v = 0.0;
      g_panel.tpValue = g_panel.slTpModePips
                        ? DoubleToString(v, 0)
                        : DoubleToString(v, _Digits);
   }
   // V2: +/- buttons for Auto BE After
   else if(action == "ABE_AFTER_PLUS" || action == "ABE_AFTER_MINUS")
   {
      double v = StringToDouble(g_panel.autoBeAfter);
      v += (action == "ABE_AFTER_PLUS") ? 1.0 : -1.0;
      if(v < 0.0) v = 0.0;
      g_panel.autoBeAfter = DoubleToString(v, 0);
   }
   // V2: +/- buttons for Auto BE Offset
   else if(action == "ABE_OFS_PLUS" || action == "ABE_OFS_MINUS")
   {
      double v = StringToDouble(g_panel.autoBeOfs);
      v += (action == "ABE_OFS_PLUS") ? 1.0 : -1.0;
      if(v < 0.0) v = 0.0;
      g_panel.autoBeOfs = DoubleToString(v, 0);
   }

   LTM_DrawPanel();
}

//+------------------------------------------------------------------+
//| Click event handler                                                |
//+------------------------------------------------------------------+
void LTM_HandleClick(int chartX, int chartY)
{
   int px = chartX - LTM_PanelScreenX();
   int py = chartY - LTM_PanelScreenY();

   if(px < 0 || py < 0 || px >= PANEL_W || py >= g_panelH)
   {
      if(g_panel.activeField != FIELD_NONE)
      {
         g_panel.activeField = FIELD_NONE;
         LTM_DrawPanel();
      }
      return;
   }

   for(int i = g_hitCount - 1; i >= 0; i--)
   {
      if(px >= g_hits[i].x1 && px < g_hits[i].x2 &&
         py >= g_hits[i].y1 && py < g_hits[i].y2)
      {
         LTM_DispatchAction(g_hits[i].action);
         return;
      }
   }

   if(g_panel.activeField != FIELD_NONE)
   {
      g_panel.activeField = FIELD_NONE;
      LTM_DrawPanel();
   }
}

//+------------------------------------------------------------------+
//| Keyboard event handler                                             |
//+------------------------------------------------------------------+
void LTM_HandleKey(int keyCode, const string sparam)
{
   if(InpKeyShortcuts)
   {
      if(keyCode == 90 && g_panel.activeField == FIELD_NONE) // Z → BUY
      {
         LTM_OpenBuy();
         LTM_DrawPanel();
         return;
      }
      if(keyCode == 67 && g_panel.activeField == FIELD_NONE) // C → SELL
      {
         LTM_OpenSell();
         LTM_DrawPanel();
         return;
      }
      if(keyCode == 70 && g_panel.activeField == FIELD_NONE) // F → SET BREAKEVEN
      {
         LTM_SetBreakeven((int)StringToInteger(g_panel.autoBeOfs));
         LTM_DrawPanel();
         return;
      }
      if(keyCode == 116) // F5 → CLOSE ALL
      {
         g_panel.activeField = FIELD_NONE;
         if(g_panel.confirmCloseAll)
         {
            int res = MessageBox("Close ALL positions on " + _Symbol + "?",
                                 "Confirm Close All", MB_YESNO | MB_ICONQUESTION);
            if(res != IDYES)
            {
               LTM_DrawPanel();
               return;
            }
         }
         LTM_CloseAll();
         LTM_DrawPanel();
         return;
      }
   }

   if(g_panel.activeField == FIELD_NONE)
      return;

   string cur = LTM_GetActiveFieldValue();

   if(keyCode == 8) // Backspace
   {
      if(StringLen(cur) > 0)
         cur = StringSubstr(cur, 0, StringLen(cur) - 1);
   }
   else if(keyCode == 13) // Enter — deselect
   {
      g_panel.activeField = FIELD_NONE;
      LTM_DrawPanel();
      return;
   }
   else
   {
      string ch = "";

      if(keyCode >= 48 && keyCode <= 57)
         ch = CharToString((uchar)(keyCode));
      else if(keyCode >= 96 && keyCode <= 105)
         ch = CharToString((uchar)(keyCode - 96 + 48));
      else if(keyCode == 110 || keyCode == 190)
      {
         if(StringFind(cur, ".") < 0)
            ch = ".";
      }
      else if(keyCode == 189 || keyCode == 109)
      {
         if(StringLen(cur) == 0)
            ch = "-";
      }

      if(ch != "")
         cur += ch;
   }

   LTM_SetActiveFieldValue(cur);
   LTM_DrawPanel();
}

#endif // LTM_GUI_MQH

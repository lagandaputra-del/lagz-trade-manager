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
//| Color constants                                                    |
//+------------------------------------------------------------------+
// Backgrounds
#define CLR_BG_DEEP       XRGB(0x07,0x07,0x12)   // near-black navy
#define CLR_BG_PANEL      XRGB(0x0D,0x0D,0x1E)   // section backgrounds
#define CLR_BG_INPUT      XRGB(0x16,0x16,0x2E)   // input fields
// Borders
#define CLR_BORDER_DIM    XRGB(0x1E,0x1E,0x3C)   // subtle separators
#define CLR_BORDER_GLOW   XRGB(0x7C,0x3A,0xED)   // purple glow (outer border)
#define CLR_BORDER_FOCUS  XRGB(0xA7,0x8B,0xFA)   // active field border
// Text
#define CLR_TEXT_PRIMARY  XRGB(0xEE,0xF2,0xFF)   // near-white
#define CLR_TEXT_DIM      XRGB(0x55,0x65,0x96)   // dimmed labels
#define CLR_TEXT_SECTION  XRGB(0x8B,0x7E,0xBF)   // section header text
// Accent
#define CLR_ACCENT        XRGB(0x7C,0x3A,0xED)   // purple (primary accent)
#define CLR_ACCENT2       XRGB(0x00,0xD4,0xFF)   // cyan (secondary)
// Trading
#define CLR_PROFIT        XRGB(0x10,0xD9,0x8A)   // vivid green
#define CLR_PROFIT_DIM    XRGB(0x0A,0x28,0x1A)   // dark green card bg
#define CLR_LOSS          XRGB(0xF2,0x36,0x45)   // vivid red
#define CLR_LOSS_DIM      XRGB(0x28,0x09,0x10)   // dark red card bg
#define CLR_WARN          XRGB(0xF5,0xA6,0x23)   // amber (partial close)
// Buttons
#define CLR_NEUTRAL       XRGB(0x22,0x22,0x48)   // neutral button bg
#define CLR_AUTO_OFF      XRGB(0x18,0x18,0x30)   // disabled toggle bg
#define CLR_BTN_BE        XRGB(0x1E,0x40,0x7A)   // SET BE button (blue-navy)
#define CLR_BTN_TEXT_DK   XRGB(0x00,0x00,0x00)   // black text on bright buttons
#define CLR_WHITE         XRGB(0xFF,0xFF,0xFF)

//+------------------------------------------------------------------+
//| Layout constants  (480px wide — designed for 1440p+)             |
//+------------------------------------------------------------------+
#define CANVAS_NAME       "LTM_Canvas"
#define PANEL_W           480
#define PANEL_TITLE_H     44
#define PANEL_DASH_H      150
#define PANEL_ORDER_H     226   // 16hdr + 36+36+36 fields + 62 BUY/SELL + 40 LIMIT
#define PANEL_MANAGE_H    156   // 16hdr + 44 CLOSE_ALL + 34 SET_TP + 36 partial + 26 accord
#define PANEL_BE_H        132   // 16hdr + 32 offset-field + 56 SET-BE + 28 auto-BE
#define PANEL_ACCORD_H    62
#define PANEL_STATUS_H    28
#define PANEL_PAD_X       14
#define PANEL_PAD_Y       6
#define PANEL_XDIST       10
#define PANEL_YDIST       30

// Input field and button heights
#define FIELD_H           28    // input fields
#define BTN_H_LG          52    // BUY / SELL (and SET BE — same prominence)
#define BTN_H_MD          38    // BUY LIMIT / SELL LIMIT / CLOSE ALL
#define BTN_H_SM          30    // Partial close buttons
#define BTN_H_XS          26    // Accordion toggle

//+------------------------------------------------------------------+
//| Font constants                                                     |
//+------------------------------------------------------------------+
#define FONT_LABEL        "Arial"
#define FONT_LABEL_BOLD   "Arial Bold"
#define FONT_MONO         "Courier New"
#define FSIZE_TITLE       -120
#define FSIZE_SECTION     -90
#define FSIZE_LABEL       -100
#define FSIZE_VALUE       -110
#define FSIZE_PL          -120
#define FSIZE_BTN         -100

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
void LTM_DrawDashboard(CCanvas &canvas, int yTop);
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
      totalH = PANEL_TITLE_H + PANEL_STATUS_H;
   }
   else
   {
      totalH = PANEL_TITLE_H
             + PANEL_DASH_H
             + PANEL_ORDER_H
             + PANEL_MANAGE_H
             + PANEL_BE_H
             + PANEL_STATUS_H;
      if(g_panel.accordionOpen)
         totalH += PANEL_ACCORD_H;
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
}

//+------------------------------------------------------------------+
//| Draw helpers                                                       |
//+------------------------------------------------------------------+

void LTM_DrawSectionLabel(int y, const string label)
{
   g_canvas.FillRectangle(0, y, PANEL_W, y + 16, CLR_BG_PANEL);
   g_canvas.FillRectangle(0, y, PANEL_W, y + 1,  CLR_BORDER_DIM);
   g_canvas.FontSet(FONT_LABEL, FSIZE_SECTION, FW_NORMAL, 0);
   g_canvas.TextOut(PANEL_PAD_X, y + 8, label, CLR_TEXT_SECTION, TA_LEFT | TA_VCENTER);
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
//| Title bar                                                          |
//+------------------------------------------------------------------+
void LTM_DrawTitleBar()
{
   int h = PANEL_TITLE_H;

   g_canvas.FillRectangle(0, 0, PANEL_W, h, CLR_BG_DEEP);
   // Purple accent bottom border (2px)
   g_canvas.FillRectangle(0, h - 2, PANEL_W, h, CLR_ACCENT);

   g_canvas.FontSet(FONT_LABEL_BOLD, FSIZE_TITLE, FW_BOLD, 0);
   g_canvas.TextOut(PANEL_PAD_X, h / 2, "LAGZ TRADE MANAGER",
                    CLR_ACCENT, TA_LEFT | TA_VCENTER);

   int btnW = 28;
   int btnX = PANEL_W - btnW - 4;
   int btnY = 4;
   int btnH = h - 8;
   string minLbl = g_panel.panelMinimized ? "+" : "-";

   g_canvas.FillRectangle(btnX, btnY, btnX + btnW, btnY + btnH, CLR_BG_PANEL);
   g_canvas.Rectangle(btnX, btnY, btnX + btnW, btnY + btnH, CLR_BORDER_DIM);
   g_canvas.FontSet(FONT_LABEL_BOLD, FSIZE_BTN, FW_BOLD, 0);
   g_canvas.TextOut(btnX + btnW / 2, btnY + btnH / 2,
                    minLbl, CLR_TEXT_PRIMARY, TA_CENTER | TA_VCENTER);
   LTM_HitRegionAdd(btnX, btnY, btnX + btnW, btnY + btnH, "MINIMIZE");

   if(g_panel.panelMinimized)
   {
      double runPL = 0.0;
      for(int i = 0; i < PositionsTotal(); i++)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
         if(g_panel.manageOwnOnly && PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
         runPL += PositionGetDouble(POSITION_PROFIT)
                + PositionGetDouble(POSITION_SWAP);
      }

      string plStr = _Symbol + "  " + (runPL >= 0 ? "+" : "") + DoubleToString(runPL, 2);
      uint   plClr = (runPL >= 0) ? CLR_PROFIT : CLR_LOSS;

      g_canvas.FontSet(FONT_MONO, FSIZE_LABEL, FW_NORMAL, 0);
      g_canvas.TextOut(btnX - 4, h / 2, plStr, plClr, TA_RIGHT | TA_VCENTER);
   }
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
//| Order section                                                      |
//+------------------------------------------------------------------+
void LTM_DrawOrderSection(int yTop)
{
   int y  = yTop;
   int px = PANEL_PAD_X;

   LTM_DrawSectionLabel(y, "-- ORDER --");
   y += 16;

   // --- Row 1: Lot / Risk% field + mode toggle ---
   {
      string lotLbl = g_panel.lotModeRisk ? "Risk%" : "Lot";
      g_canvas.FontSet(FONT_LABEL, FSIZE_LABEL, FW_NORMAL, 0);
      g_canvas.TextOut(px, y + FIELD_H / 2, lotLbl, CLR_TEXT_DIM, TA_LEFT | TA_VCENTER);

      int labelW    = 50;
      int fieldX    = px + labelW;
      int toggleW   = 72;
      int fieldW    = PANEL_W - px - fieldX - toggleW - 4;

      LTM_DrawField(fieldX, y, fieldW, FIELD_H, g_panel.lotValue, FIELD_LOT);

      string toggleLbl = g_panel.lotModeRisk ? "RISK %" : "FIXED";
      uint   toggleBg  = g_panel.lotModeRisk ? CLR_NEUTRAL : CLR_AUTO_OFF;
      LTM_DrawButton(fieldX + fieldW + 4, y, toggleW, FIELD_H,
                     toggleLbl, toggleBg, CLR_WHITE, "TOGGLE_LOT_MODE");
   }
   y += FIELD_H + 8;

   // --- Row 2: SL / TP fields + pips/price toggle ---
   {
      // Layout: [SL lbl][SL field][gap][TP lbl][TP field][gap][toggle]
      int lblW     = 28;   // "SL" or "TP" label width
      int toggleW  = 58;
      int gap      = 6;
      int eachW    = (PANEL_W - 2*px - 2*lblW - toggleW - 2*gap) / 2;

      int slLblX   = px;
      int slFieldX = slLblX + lblW;
      int tpLblX   = slFieldX + eachW + gap;
      int tpFieldX = tpLblX + lblW;
      int toggleX  = PANEL_W - px - toggleW;

      g_canvas.FontSet(FONT_LABEL, FSIZE_LABEL, FW_NORMAL, 0);
      g_canvas.TextOut(slLblX, y + FIELD_H / 2, "SL", CLR_TEXT_DIM, TA_LEFT | TA_VCENTER);
      LTM_DrawField(slFieldX, y, eachW, FIELD_H, g_panel.slValue, FIELD_SL);

      g_canvas.TextOut(tpLblX, y + FIELD_H / 2, "TP", CLR_TEXT_DIM, TA_LEFT | TA_VCENTER);
      LTM_DrawField(tpFieldX, y, eachW, FIELD_H, g_panel.tpValue, FIELD_TP);

      string modeLbl = g_panel.slTpModePips ? "pips" : "price";
      LTM_DrawButton(toggleX, y, toggleW, FIELD_H,
                     modeLbl, CLR_AUTO_OFF, CLR_TEXT_DIM, "TOGGLE_SLTP_MODE");
   }
   y += FIELD_H + 8;

   // --- Row 3: Pending price field ---
   {
      int lblW   = 52;
      int fieldX = px + lblW;
      int fieldW = PANEL_W - fieldX - px;

      g_canvas.FontSet(FONT_LABEL, FSIZE_LABEL, FW_NORMAL, 0);
      g_canvas.TextOut(px, y + FIELD_H / 2, "Price", CLR_TEXT_DIM, TA_LEFT | TA_VCENTER);
      LTM_DrawField(fieldX, y, fieldW, FIELD_H, g_panel.pendingPrice, FIELD_PENDING_PRICE);
   }
   y += FIELD_H + 8;

   // --- Row 4: BUY / SELL ---
   {
      int gap  = 6;
      int btnW = (PANEL_W - 2*px - gap) / 2;

      LTM_DrawButton(px,           y, btnW, BTN_H_LG, "BUY",
                     CLR_PROFIT, CLR_BTN_TEXT_DK, "BUY");
      LTM_DrawButton(px + btnW + gap, y, btnW, BTN_H_LG, "SELL",
                     CLR_LOSS,   CLR_WHITE,       "SELL");
   }
   y += BTN_H_LG + 10;

   // --- Row 5: BUY LIMIT / SELL LIMIT ---
   {
      int gap  = 6;
      int btnW = (PANEL_W - 2*px - gap) / 2;

      LTM_DrawButton(px,           y, btnW, BTN_H_MD, "BUY LIMIT",
                     CLR_PROFIT_DIM, CLR_PROFIT, "BUY_LIMIT");
      LTM_DrawButton(px + btnW + gap, y, btnW, BTN_H_MD, "SELL LIMIT",
                     CLR_LOSS_DIM,   CLR_LOSS,   "SELL_LIMIT");
   }
}

//+------------------------------------------------------------------+
//| Manage section                                                     |
//+------------------------------------------------------------------+
void LTM_DrawManageSection(int yTop)
{
   int y  = yTop;
   int px = PANEL_PAD_X;

   LTM_DrawSectionLabel(y, "-- MANAGE --");
   y += 16;

   // --- Row 1: CLOSE ALL full-width ---
   LTM_DrawButton(px, y, PANEL_W - 2*px, BTN_H_MD,
                  "CLOSE ALL", CLR_LOSS, CLR_WHITE, "CLOSE_ALL");
   y += BTN_H_MD + 6;

   // --- Row 2: SET TP label + field + submit button ---
   {
      int lblW   = 62;   // "SET TP" label
      int arrowW = 44;   // "|>" submit button
      int fieldW = PANEL_W - 2*px - lblW - arrowW - 4;

      g_canvas.FontSet(FONT_LABEL, FSIZE_LABEL, FW_NORMAL, 0);
      g_canvas.TextOut(px, y + FIELD_H / 2, "SET TP", CLR_TEXT_DIM, TA_LEFT | TA_VCENTER);

      int fieldX = px + lblW;
      LTM_DrawField(fieldX, y, fieldW, FIELD_H, g_panel.setTPValue, FIELD_SET_TP);
      LTM_DrawButton(fieldX + fieldW + 4, y, arrowW, FIELD_H,
                     "|>", CLR_NEUTRAL, CLR_WHITE, "SET_TP");
   }
   y += FIELD_H + 6;

   // --- Row 3: Partial close 25 / 50 / 75 / 80 ---
   {
      int gap  = 4;
      int btnW = (PANEL_W - 2*px - 3*gap) / 4;

      LTM_DrawButton(px,                 y, btnW, BTN_H_SM,
                     "25%", CLR_WARN, CLR_BTN_TEXT_DK, "PARTIAL_25");
      LTM_DrawButton(px + (btnW+gap),    y, btnW, BTN_H_SM,
                     "50%", CLR_WARN, CLR_BTN_TEXT_DK, "PARTIAL_50");
      LTM_DrawButton(px + 2*(btnW+gap),  y, btnW, BTN_H_SM,
                     "75%", CLR_WARN, CLR_BTN_TEXT_DK, "PARTIAL_75");
      LTM_DrawButton(px + 3*(btnW+gap),  y, btnW, BTN_H_SM,
                     "80%", CLR_WARN, CLR_BTN_TEXT_DK, "PARTIAL_80");
   }
   y += BTN_H_SM + 6;

   // --- Row 4: Accordion toggle ---
   {
      string accordLbl = g_panel.accordionOpen ? "^ Less" : "v More";
      LTM_DrawButton(px, y, PANEL_W - 2*px, BTN_H_XS,
                     accordLbl, CLR_AUTO_OFF, CLR_TEXT_DIM, "TOGGLE_ACCORD");
   }
}

//+------------------------------------------------------------------+
//| Breakeven section                                                  |
//+------------------------------------------------------------------+
void LTM_DrawBESection(int yTop)
{
   int y  = yTop;
   int px = PANEL_PAD_X;

   LTM_DrawSectionLabel(y, "-- BREAKEVEN --");
   y += 16;

   // --- Row 1: BE offset field ---
   {
      int lblW   = 100;   // "Offset(pips)" label
      int fieldW = PANEL_W - 2*px - lblW;

      g_canvas.FontSet(FONT_LABEL, FSIZE_LABEL, FW_NORMAL, 0);
      g_canvas.TextOut(px, y + FIELD_H / 2, "Offset(pips)", CLR_TEXT_DIM, TA_LEFT | TA_VCENTER);

      LTM_DrawField(px + lblW, y, fieldW, FIELD_H, g_panel.beOffset, FIELD_BE_OFFSET);
   }
   y += FIELD_H + 4;

   // --- Row 2: SET BREAKEVEN — full-width, same prominence as BUY/SELL ---
   LTM_DrawButton(px, y, PANEL_W - 2*px, BTN_H_LG,
                  "SET BREAKEVEN", CLR_BTN_BE, CLR_WHITE, "SET_BE");
   y += BTN_H_LG + 4;

   // --- Row 3: Auto BE toggle + After + Offset fields ---
   {
      bool   abeOn  = g_panel.autoBEEnabled;
      string abeLbl = abeOn ? "ON" : "OFF";
      uint   abeBg  = abeOn ? CLR_NEUTRAL : CLR_AUTO_OFF;
      uint   abeFg  = abeOn ? CLR_PROFIT  : CLR_TEXT_DIM;

      int toggleW     = 50;
      int afterLblW   = 44;
      int afterFieldW = 58;
      int ofsLblW     = 44;
      int ofsFieldW   = PANEL_W - px - toggleW - 6 - afterLblW - 4 - afterFieldW - 6 - ofsLblW - 4 - 6 - px;

      LTM_DrawButton(px, y, toggleW, FIELD_H, abeLbl, abeBg, abeFg, "TOGGLE_AUTO_BE");

      int cur = px + toggleW + 6;
      g_canvas.FontSet(FONT_LABEL, FSIZE_LABEL, FW_NORMAL, 0);
      g_canvas.TextOut(cur, y + FIELD_H / 2, "After", CLR_TEXT_DIM, TA_LEFT | TA_VCENTER);
      cur += afterLblW + 4;

      LTM_DrawField(cur, y, afterFieldW, FIELD_H, g_panel.autoBeAfter, FIELD_AUTO_BE_AFTER);
      cur += afterFieldW + 6;

      g_canvas.TextOut(cur, y + FIELD_H / 2, "+Ofs:", CLR_TEXT_DIM, TA_LEFT | TA_VCENTER);
      cur += ofsLblW + 4;

      if(ofsFieldW < 24) ofsFieldW = 24;
      LTM_DrawField(cur, y, ofsFieldW, FIELD_H, g_panel.autoBeOfs, FIELD_AUTO_BE_OFFSET);
   }
}

//+------------------------------------------------------------------+
//| Accordion — Close Buy / Close Sell                                 |
//+------------------------------------------------------------------+
void LTM_DrawAccordion(int yTop)
{
   int y  = yTop + 6;
   int px = PANEL_PAD_X;
   int gap  = 4;
   int btnW = (PANEL_W - 2*px - gap) / 2;

   LTM_DrawButton(px,           y, btnW, BTN_H_MD,
                  "CLOSE BUYS", CLR_PROFIT_DIM, CLR_PROFIT, "CLOSE_BUY");
   LTM_DrawButton(px + btnW + gap, y, btnW, BTN_H_MD,
                  "CLOSE SELLS", CLR_LOSS_DIM, CLR_LOSS, "CLOSE_SELL");
}

//+------------------------------------------------------------------+
//| Main draw orchestrator                                             |
//+------------------------------------------------------------------+
void LTM_DrawPanel()
{
   LTM_CreateCanvas();

   g_hitCount = 0;
   g_canvas.Erase(CLR_BG_DEEP);

   g_canvas.Rectangle(0, 0, PANEL_W - 1, g_panelH - 1, CLR_BORDER_GLOW);
   g_canvas.Rectangle(1, 1, PANEL_W - 2, g_panelH - 2, CLR_BORDER_DIM);

   LTM_DrawTitleBar();

   if(g_panel.panelMinimized)
   {
      LTM_DrawStatusBar(PANEL_TITLE_H);
   }
   else
   {
      int y = PANEL_TITLE_H;

      LTM_DrawDashboard(g_canvas, y);
      y += PANEL_DASH_H;

      LTM_DrawOrderSection(y);
      y += PANEL_ORDER_H;

      LTM_DrawManageSection(y);
      y += PANEL_MANAGE_H;

      LTM_DrawBESection(y);
      y += PANEL_BE_H;

      if(g_panel.accordionOpen)
      {
         LTM_DrawAccordion(y);
         y += PANEL_ACCORD_H;
      }

      LTM_DrawStatusBar(y);
   }

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
      LTM_SetBreakeven((int)StringToInteger(g_panel.beOffset));
   }
   else if(action == "MINIMIZE")
   {
      g_panel.panelMinimized = !g_panel.panelMinimized;
   }
   else if(action == "TOGGLE_ACCORD")
   {
      g_panel.accordionOpen = !g_panel.accordionOpen;
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
         LTM_SetBreakeven((int)StringToInteger(g_panel.beOffset));
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

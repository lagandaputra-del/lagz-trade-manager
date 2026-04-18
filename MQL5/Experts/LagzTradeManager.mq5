//+------------------------------------------------------------------+
//|                                         LagzTradeManager.mq5    |
//|                          Lagz Trade Manager — Main EA File       |
//|  Manual trading panel for XAUUSD, NAS100, SP500, BTCUSD.        |
//|  Uses CCanvas bitmap rendering — NOT CChartObject labels.        |
//+------------------------------------------------------------------+
#property copyright   "Lagz"
#property version     "1.00"
#property strict
#property description "Lagz Trade Manager — Manual Trading Panel v1"

#include <Canvas\Canvas.mqh>
#include <Trade\Trade.mqh>

//--- Include order matters: GUI must come first (defines structs used by all)
//--- Files are in MQL5\Include\ so angle-bracket form resolves correctly
#include <LTM_GUI.mqh>
#include <LTM_Dashboard.mqh>
#include <LTM_TradeExec.mqh>
#include <LTM_PositionMgr.mqh>

//+------------------------------------------------------------------+
//| Input parameters                                                   |
//+------------------------------------------------------------------+
input ulong  InpMagic              = 20250101; // Magic Number
input bool   InpManageOwnOnly      = true;     // Manage Own Trades Only (filter by magic)
input double InpDefaultLot         = 0.01;     // Default Lot Size
input double InpDefaultRisk        = 1.0;      // Default Risk % (for Risk% mode)
input int    InpSlippage           = 3;        // Max Slippage (points)
input bool   InpSLTPModePips       = true;     // SL/TP input in Pips (false = Price)
input bool   InpConfirmCloseAll    = true;     // Confirm before Close All
input bool   InpConfirmPartial     = true;     // Confirm before Partial Close
input bool   InpAutoBE             = false;    // Auto Breakeven ON/OFF
input int    InpAutoBEAfter        = 20;       // Auto BE Activate After (pips)
input int    InpAutoBEOffset       = 0;        // Auto BE SL Offset (pips)
input bool   InpBEScopeAllSymbols  = false;    // BE Scope: All Symbols (false = current only)
input ENUM_BASE_CORNER InpCorner   = CORNER_LEFT_UPPER; // Panel Corner Position
input bool   InpKeyShortcuts       = true;     // Enable Keyboard Shortcuts (F1/F2/F5)

//+------------------------------------------------------------------+
//| Global objects                                                     |
//+------------------------------------------------------------------+
CCanvas    g_canvas;           // CCanvas bitmap handle
CTrade     g_trade;            // CTrade order execution wrapper

//+------------------------------------------------------------------+
//| Global panel state                                                 |
//+------------------------------------------------------------------+
PanelState g_panel;            // All interactive panel state

//+------------------------------------------------------------------+
//| Hit region system                                                  |
//+------------------------------------------------------------------+
HitRegion  g_hits[];           // Dynamic array of clickable regions
int        g_hitCount = 0;     // Number of registered hit regions

//+------------------------------------------------------------------+
//| Auto Breakeven tracking                                            |
//+------------------------------------------------------------------+
ulong      g_autoBEDone[];     // Tickets that have already been auto-BE'd

//+------------------------------------------------------------------+
//| Status bar                                                         |
//+------------------------------------------------------------------+
string     g_statusMsg    = ""; // Current status message
datetime   g_statusTime   = 0;  // When the message was set
bool       g_statusIsErr  = false; // true = error (red), false = success (green)

//+------------------------------------------------------------------+
//| Panel geometry                                                     |
//+------------------------------------------------------------------+
int        g_panelH = 0;       // Current canvas pixel height (tracks resize)

//+------------------------------------------------------------------+
//| OnInit                                                             |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Configure CTrade
   g_trade.SetExpertMagicNumber(InpMagic);
   g_trade.SetDeviationInPoints(InpSlippage);
   // ORDER_FILLING_FOK is standard for Forex/CFD market execution (XAUUSD, NAS, etc.)
   g_trade.SetTypeFilling(ORDER_FILLING_FOK);

   //--- Initialise panel state from inputs
   g_panel.lotValue        = DoubleToString(InpDefaultLot, 2);
   g_panel.slValue         = "0";
   g_panel.tpValue         = "0";
   g_panel.pendingPrice    = "0";
   g_panel.setTPValue      = "";
   g_panel.beOffset        = "0";
   g_panel.autoBeAfter     = IntegerToString(InpAutoBEAfter);
   g_panel.autoBeOfs       = IntegerToString(InpAutoBEOffset);
   g_panel.lotModeRisk     = false;
   g_panel.slTpModePips    = InpSLTPModePips;
   g_panel.autoBEEnabled   = InpAutoBE;
   g_panel.panelMinimized  = false;
   g_panel.accordionOpen   = false;
   g_panel.confirmCloseAll = InpConfirmCloseAll;
   g_panel.confirmPartial  = InpConfirmPartial;
   g_panel.manageOwnOnly   = InpManageOwnOnly;
   g_panel.activeField     = FIELD_NONE;

   //--- Restore user's last panel values if available (survives timeframe changes)
   LTM_PanelStateLoad();

   //--- Auto BE tracking array starts empty
   ArrayResize(g_autoBEDone, 0);
   ArrayResize(g_hits, 64);

   //--- Load or initialise day-start balance (for % Profit Today)
   LTM_DayStartInit();

   //--- Draw initial panel
   LTM_DrawPanel();

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| OnDeinit                                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Clean up GlobalVariables when EA is manually removed (not on TF change/recompile)
   if(reason == REASON_REMOVE)
      LTM_PanelStateDelete();

   //--- Destroy canvas bitmap and remove object from chart
   if(ObjectFind(0, CANVAS_NAME) >= 0)
      g_canvas.Destroy();

   //--- Release arrays
   ArrayFree(g_hits);
   ArrayFree(g_autoBEDone);

   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| OnTick                                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Check for new day and reset day-start balance if needed
   LTM_DayStartCheck();

   //--- Auto Breakeven — runs every tick when enabled
   if(g_panel.autoBEEnabled)
      LTM_ProcessAutoBE();

   //--- Redraw panel with fresh market data
   LTM_DrawPanel();
}

//+------------------------------------------------------------------+
//| OnChartEvent                                                       |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long   &lparam,
                  const double &dparam,
                  const string &sparam)
{
   switch(id)
   {
      case CHARTEVENT_CLICK:
         //--- Mouse click on chart — test panel hit regions
         LTM_HandleClick((int)lparam, (int)dparam);
         LTM_PanelStateSave();
         break;

      case CHARTEVENT_KEYDOWN:
         //--- Keyboard input — shortcuts + field text entry
         LTM_HandleKey((int)lparam, sparam);
         LTM_PanelStateSave();
         break;

      case CHARTEVENT_CHART_CHANGE:
         //--- Chart resized or scrolled — force canvas recreate and redraw
         g_panelH = 0; // Invalidate cached height so LTM_CreateCanvas recreates
         LTM_DrawPanel();
         break;

      default:
         break;
   }
}

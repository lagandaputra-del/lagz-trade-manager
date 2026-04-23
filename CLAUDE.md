# CLAUDE.md — Lagz Trade Manager (MT5 Expert Advisor)

## Project Overview
EA panel overlay MT5 (MQL5). Eksekusi order manual, monitoring akun realtime, manajemen posisi massal. Bukan bot otomatis — tidak ada logika entry sinyal.

## Instrumen & Akun
- Target: **XAUUSD, NAS100, SP500, BTCUSD** — spread & volatilitas tinggi
- Tipe akun: **Hedging** — buy + sell bisa terbuka bersamaan di simbol yang sama
- Scope: **satu chart/simbol aktif** saja
- Ada EA lain di akun → **magic number filter wajib** (toggle setting)

## Arsitektur & File Structure
Rendering GUI: **CCanvas (bitmap)** — full kontrol warna, custom font, alpha blending. Bukan CChartObject standar.
```
MQL5/Experts/LagzTradeManager.mq5  ← main (OnInit, OnTick, OnChartEvent, OnDeinit)
MQL5/Include/LTM_Dashboard.mqh     ← Account Overview rendering + DayStart balance
MQL5/Include/LTM_TradeExec.mqh     ← OpenBuy, OpenSell, OpenBuyLimit, OpenSellLimit
MQL5/Include/LTM_PositionMgr.mqh   ← CloseAll, PartialClose, SetTPAll, SetBreakeven, AutoBE
MQL5/Include/LTM_GUI.mqh           ← layout constants, draw helpers, input handling, state persistence
MQL5/Files/LTM_DayStart.bin        ← balance awal hari (persist antar restart)
```
Include `.mqh` pakai **angle bracket** `<LTM_GUI.mqh>` — file ada di `MQL5\Include\` standar.

## Account Overview (V2)
Refresh setiap **OnTick()**, tanpa throttle. Layout 2-row grid:
- **Row 1 — 4 kolom**: Balance | Equity | Free Mgn | PNL Hari
  - Tiap kolom: label kecil (dim) → nilai bold → sub-text
  - Col 1-3 sub-text: `"USD"` (dim)
  - Col 4 (PNL Hari): main value = **% gain hari ini** (e.g. `+0.0%`), sub-text = **USD gain** (e.g. `(+0.00)`)
  - Warna PNL col: `#27D08F` profit / `#FF3344` loss
- **Row 2**: Symbol (accent) | Spread (raw pts) | Server time
- % Profit Today baseline: balance 00:00 server time → `LTM_DayStart.bin`, reset tiap hari baru
- Spread: **raw points** — tidak auto-reject order

## Lot Sizing
- **Fixed Lot** — input manual, default `0.01`
- **Risk %** — `Lot = (Balance × Risk%) / (SL_pips × PipValue)`
- Toggle di panel

## Order Execution
- **Instant**: BUY @ Ask, SELL @ Bid. SL/TP toggle **pips** atau **price** mode
- **Pending**: BUY LIMIT / SELL LIMIT — input harga absolut atau offset pips dari current price
- Konfirmasi popup: hanya Close All dan Partial Close (toggle ON/OFF per aksi)

## Position Management
- **Partial Close 25/50/75/80%**: sort posisi by profit ascending → close profit terkecil dulu. Jika lot < min broker → full close. Formula: `lot_to_close = total_lots × persen`
- **Close All**: semua posisi di simbol aktif (dipengaruhi magic number filter)
- **Close Buy / Close Sell**: di section Manage Positions
- **Set TP**: hidden di V2 (fitur ada di code, UI disembunyikan)
- **Manual BE**: tombol SET BREAKEVEN di Quick Actions, offset pakai field `autoBeOfs`
  - Buy: `SL = entry + offset`; Sell: `SL = entry − offset`
- **Auto BE**: toggle + `Activate After (pips)` + `BE Offset` — jalan di OnTick, per-ticket flag

## Settings
| Parameter | Default | Catatan |
|---|---|---|
| Magic Number | `20250101` | Magic number order EA ini |
| Manage Own Trades Only | `true` | Filter magic number ON/OFF |
| Default Lot Size | `0.01` | Lot saat mode Fixed |
| Default Risk % | `1.0` | Risk per trade |
| Slippage | `3` | Max slippage (points) |
| SL/TP Input Mode | `Pips` | Toggle pips / price |
| Confirmation: Close All | `true` | Popup sebelum Close All |
| Confirmation: Partial Close | `true` | Popup sebelum Partial Close |
| Auto BE | `false` | Toggle auto breakeven |
| Auto BE Activate (pips) | `20` | Trigger |
| Auto BE Offset (pips) | `0` | SL offset dari entry |
| Panel Position | `Top-Left` | Top-Left/Right, Bottom-Left/Right |
| Keyboard Shortcuts | `true` | Z=BUY C=SELL F=SET_BE F5=CLOSE ALL |

## UI / UX (V2)
- Theme: `#0F111A` bg, `#1F232F` card, `#6C4AF3` accent
- Font: **Tahoma** semua elemen
- Panel: **400px** lebar. Minimize → **Compact Mode** (title bar + Bal/Eq/Free/PNL + BUY/SELL, ~145px)
- Layout (atas→bawah): Title Bar → Account Overview → Trade Tabs → Trade Input → BUY/SELL → Quick Actions → Manage Positions → Auto Breakeven → Status Bar
- **Trade Mode**: Tab MARKET (default) / PENDING
- **+/- buttons**: Lot (0.01) | SL/TP pips (1) | SL/TP price (tick × 10)
- **BUY/SELL**: teks dengan arrow symbol — `↑ BUY` / `↓ SELL`
- **Quick Actions**: sub-label "PARTIAL CLOSE - QUICK %" → 25/50/75/80% → sub-label "SET BREAKEVEN" → tombol
- **Status bar**: fade ~3 detik, tidak pakai MT5 Alert popup
- **Shortcuts**: `Z`=BUY `C`=SELL `F`=SET BE `F5`=CLOSE ALL (aktif hanya saat tidak ada field aktif)

### Button Styles
- **Solid fill**: BUY, SELL, CLOSE ALL, SET BREAKEVEN, +/- buttons
- **Outlined** (dark body + colored border + colored text): 25%/50%/75%/80% (orange), CLOSE BUY (green), CLOSE SELL (red)
- `LTM_DrawButton` punya parameter opsional `border` — default `CLR_BORDER_DIM`, override untuk outlined style
- **Auto BE toggle ON**: hijau (`CLR_PROFIT`), bukan accent/ungu. Shape rectangular (CCanvas tidak support rounded smooth)

### V2 Color Palette
| Token | Hex | Penggunaan |
|---|---|---|
| BG | `#0F111A` | Background utama |
| Card | `#1F232F` | Section backgrounds |
| Input | `#10142A` | Input fields |
| Accent | `#6C4AF3` | Border glow, tab aktif, title |
| BUY | `#27D08F` | Tombol BUY, profit |
| SELL | `#FF3344` | Tombol SELL, loss |
| Danger | `#A74444` | CLOSE ALL |
| Orange | `#FF9844` | Partial close %, warning |
| BE Blue | `#1E407A` | SET BREAKEVEN |

## Compile
```bash
cp MQL5/Experts/LagzTradeManager.mq5 "C:/Users/Laganda/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Experts/"
cp MQL5/Include/LTM_*.mqh "C:/Users/Laganda/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Include/"
"C:/Program Files/MetaTrader 5/MetaEditor64.exe" /compile:"C:/Users/Laganda/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Experts/LagzTradeManager.mq5" /log:"C:/Users/Laganda/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Logs/LagzTM_compile.log"
```
Baca log (UTF-16):
```powershell
$c = [System.IO.File]::ReadAllText('...LagzTM_compile.log', [System.Text.Encoding]::Unicode); ($c -split "`n") | Where-Object { $_ -match 'error|warning|Result' }
```

## Status Implementasi

### V1 — ✅ Complete
### V2 — 🔄 In Progress (per 2026-04-23)
Files yang diubah: **`LTM_GUI.mqh`** + **`LTM_Dashboard.mqh`** saja.
Files zero-changes: `LTM_TradeExec.mqh`, `LTM_PositionMgr.mqh`, `LagzTradeManager.mq5`

**Sudah selesai:** Panel 400px, Tahoma, color palette, collapsible sections, tabs MARKET/PENDING, +/- buttons, compact mode, CLOSE BUY/SELL, Auto BE section, status bar, shortcuts.

**Sisa (plan: `~/.claude/plans/apakah-dengan-plan-ini-quizzical-seal.md`):**
1. Account Overview PNL col → today % + USD sub-text, row 2 jadi 3 item
2. BUY/SELL arrow icons (`↑ BUY` / `↓ SELL`)
3. Quick Actions sub-labels
4. Trade Input: SL/TP side-by-side, "Lot Size" label
5. Outlined button style (partial close + CLOSE BUY/SELL) + BE toggle color fix

### Backlog (belum dimulai)
- Trailing Stop
- Close Profit / Close Loss

## Hal yang TIDAK boleh dilakukan
- Jangan buat trailing stop — backlog
- Jangan auto-reject order karena spread tinggi
- Jangan gunakan CChartObjectButton/Label untuk komponen utama — pakai CCanvas
- Jangan close posisi simbol lain kecuali toggle "All Symbols" aktif
- Partial close tidak boleh FIFO — urutkan dari profit terkecil dulu
- **V2**: Jangan ubah `LTM_TradeExec.mqh`, `LTM_PositionMgr.mqh`, `LagzTradeManager.mq5`
- **V2**: SET TP field di-hidden, bukan dihapus — field struct tetap ada
- **V2**: `g_panel.beOffset` unused/hidden — jangan hapus dari struct, SET_BE dispatch pakai `g_panel.autoBeOfs`

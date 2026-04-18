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
MQL5/Include/LTM_Dashboard.mqh     ← render dashboard section
MQL5/Include/LTM_TradeExec.mqh     ← OpenBuy, OpenSell, OpenBuyLimit, OpenSellLimit
MQL5/Include/LTM_PositionMgr.mqh   ← CloseAll, PartialClose, SetTPAll, SetBreakeven, AutoBE
MQL5/Include/LTM_GUI.mqh           ← layout constants, draw helpers, input handling, state persistence
MQL5/Files/LTM_DayStart.bin        ← balance awal hari (persist antar restart)
```
Include `.mqh` pakai **angle bracket** `<LTM_GUI.mqh>` — file ada di `MQL5\Include\` standar.

## Dashboard
- Refresh setiap **OnTick()**, tanpa throttle
- Fields: Balance, Equity, Margin (+ %), Free Margin, Running P/L (+ %), % Profit Today
- Spread: **raw points** — tidak auto-reject order
- % Profit Today baseline: balance 00:00 server time → `LTM_DayStart.bin`, reset tiap hari baru
- Warna P/L: `#00FF9D` profit / `#FF3B5C` loss

## Lot Sizing
- **Fixed Lot** — input manual, default `0.01`
- **Risk %** — `Lot = (Balance × Risk%) / (SL_pips × PipValue)`
- Toggle di panel

## Order Execution
- **Instant**: BUY @ Ask, SELL @ Bid. SL/TP toggle **pips** atau **price** mode
- **Pending**: BUY LIMIT / SELL LIMIT — input harga absolut atau offset pips dari current price
- Konfirmasi popup: hanya Close All dan Partial Close (toggle ON/OFF per aksi)

## Position Management
- **Partial Close 25/50/75/80%**: sort posisi by profit ascending → close yang profit terkecil dulu. Jika lot < min broker → full close posisi tersebut. Formula: `lot_to_close = total_lots × persen`
- **Close All**: semua posisi di simbol aktif (dipengaruhi magic number filter)
- **Close Buy / Close Sell**: di accordion area (panel expandable)
- **Set TP**: harga absolut, apply ke semua posisi di simbol aktif
- **Manual BE**: input offset pips → SET BE → apply ke posisi floating profit ≥ offset pips
  - Buy: `SL = entry + offset`; Sell: `SL = entry − offset`
- **Auto BE**: toggle + `Activate After (pips)` + `BE Offset` — jalan di OnTick, per-ticket flag
- Scope BE: toggle `Current Symbol` / `All Symbols`

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
| BE Scope | `Current Symbol` | Current Symbol / All Symbols |
| Panel Position | `Top-Left` | Top-Left/Right, Bottom-Left/Right |
| Keyboard Shortcuts | `true` | Z=BUY C=SELL F=SET_BE F5=CLOSE ALL |

## UI / UX
- Theme: `#080C14` bg, `#0D1421` card, `#7C3AED` accent/border glow
- Font: `Arial Bold` labels/tombol, `Courier New` angka. Monitor target 1440p+
- Panel: 480px lebar, expandable accordion. Minimize → collapse ke title bar
- Status bar: pesan error/sukses fade ~3 detik (tidak pakai MT5 Alert popup)
- **Shortcuts**: `Z`=BUY `C`=SELL `F`=SET BE `F5`=CLOSE ALL _(aktif hanya saat tidak ada field aktif)_
- F1/F2 tidak bisa dipakai — di-intercept MT5 (Help & Price Data Center)

## Compile
```bash
cp MQL5/Experts/LagzTradeManager.mq5 "C:/Users/Laganda/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Experts/"
cp MQL5/Include/LTM_*.mqh "C:/Users/Laganda/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Include/"
"C:/Program Files/MetaTrader 5/MetaEditor64.exe" /compile:"C:/Users/Laganda/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Experts/LagzTradeManager.mq5" /log:"C:/Users/Laganda/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Logs/LagzTM_compile.log"
```
Baca log (UTF-16): `powershell -File -` lalu:
`$c = [System.IO.File]::ReadAllText('...LagzTM_compile.log', [System.Text.Encoding]::Unicode); ($c -split "``n") | Where-Object { $_ -match 'error|warning|Result' }`

## Status Implementasi (per 2026-04-18)
Semua file ✅ compile **0 errors, 0 warnings** — `.ex5` siap di-attach.

| File | Catatan |
|---|---|
| `LTM_GUI.mqh` | Layout, draw, events, hit-region, GlobalVariable state persistence |
| `LTM_Dashboard.mqh` | DayStart binary + DrawDashboard |
| `LTM_TradeExec.mqh` | LotCalc, SL/TP resolver, OpenBuy/Sell/BuyLimit/SellLimit |
| `LTM_PositionMgr.mqh` | CloseAll, CloseBuy/Sell, PartialClose, SetTPAll, SetBreakeven, AutoBE |
| `LagzTradeManager.mq5` | 14 inputs, globals, OnInit/OnTick/OnChartEvent/OnDeinit |

### Visual QA (MT5 live) — semua ✅ confirmed
- Panel dark theme, dashboard fields (Balance/Equity/Margin/Spread/P/L)
- Auto BE row layout rapi (label tidak tertimpa field)
- Ganti timeframe → panel state tersimpan (GlobalVariable, prefix `LTM_{magic}_*`)
- Partial close 25/50/75/80% berfungsi
- Minimize/expand title bar
- Status bar fade ~3 detik
- % Profit Today reset tiap hari baru
- Shortcuts Z/C/F/F5 semua berfungsi

### Backlog v2
- Trailing Stop

## Hal yang TIDAK boleh dilakukan
- Jangan buat trailing stop di v1 — masuk backlog v2
- Jangan auto-reject order karena spread tinggi — hanya tampilkan spread
- Jangan gunakan CChartObjectButton/Label untuk komponen utama — pakai CCanvas
- Jangan close posisi dari simbol lain kecuali toggle "All Symbols" aktif
- Partial close tidak boleh FIFO — urutkan dari profit terkecil dulu

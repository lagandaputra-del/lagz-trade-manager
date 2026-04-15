# CLAUDE.md — Lagz Trade Manager (MT5 Expert Advisor)

## Project Overview
EA panel overlay untuk MetaTrader 5 (MQL5). Fungsi: eksekusi order manual, monitoring akun realtime,
dan manajemen posisi massal. Bukan bot otomatis — tidak ada logika entry sinyal.

---

## Instrumen & Akun

- Target instrumen: **XAUUSD (Gold), NAS100, SP500, BTCUSD** — spread & volatilitas tinggi
- Tipe akun: **Hedging** (bisa ada buy + sell terbuka bersamaan di simbol yang sama)
- Scope panel: **satu chart/simbol aktif** saja — semua aksi apply ke simbol chart tempat EA dipasang
- Ada EA lain di akun yang sama → **magic number filter wajib ada** (toggle setting)

---

## Arsitektur & Rendering

- Rendering GUI: **CCanvas (bitmap)** — bukan CChartObject standar
  - Alasan: full kontrol warna, custom font, alpha blending untuk futuristic dark theme
  - CCanvas di-attach ke chart sebagai bitmap object, di-redraw setiap kali state berubah
- File structure:
  ```
  MQL5/Experts/LagzTradeManager.mq5     ← main (OnInit, OnTick, OnChartEvent, OnDeinit)
  MQL5/Include/LTM_Dashboard.mqh        ← render dashboard section
  MQL5/Include/LTM_TradeExec.mqh        ← OpenBuy, OpenSell, OpenBuyLimit, OpenSellLimit
  MQL5/Include/LTM_PositionMgr.mqh      ← CloseAll, PartialClose, SetTPAll, SetBreakeven, AutoBE
  MQL5/Include/LTM_GUI.mqh              ← layout constants, draw helpers, input handling
  MQL5/Files/LTM_DayStart.bin           ← simpan balance awal hari (persist antar restart)
  ```

---

## Dashboard

- Refresh: **setiap OnTick(), tanpa throttle** — user sadar risiko flicker saat news
- Fields: Balance, Equity, Margin Used (+ %), Free Margin, Running P/L (+ %), % Profit Today
- Spread ditampilkan: **raw points** (contoh: `Spread: 25 pts`) — tidak auto-reject order
- % Profit Today baseline: **balance pada 00:00 server time** hari tersebut
  - Disimpan ke `LTM_DayStart.bin` agar persist jika EA di-restart
  - Reset otomatis tiap hari baru (deteksi via TimeToStruct perbandingan hari)
- Warna P/L: `#00FF9D` (profit) / `#FF3B5C` (loss)

---

## Lot Sizing

- Dua mode, ada **toggle di panel**:
  1. **Fixed Lot** — user input manual, default `0.01`
  2. **Risk %** — input SL (pips) + risk % dari balance → EA kalkulasi lot otomatis
- Formula Risk % mode: `Lot = (Balance × Risk%) / (SL_pips × PipValue)`

---

## Order Execution

### Instant Order
- BUY di harga Ask, SELL di harga Bid
- SL/TP: toggle **pips mode** atau **price mode** di panel
  - Pips mode: konversi ke harga berdasarkan Ask/Bid saat eksekusi
  - Price mode: input harga absolut langsung

### Pending Order (BUY LIMIT / SELL LIMIT)
- Input harga: dua cara sekaligus di panel:
  1. Field harga absolut (ketik langsung)
  2. Offset pips dari current price (shortcut `+/− pips`)

### Konfirmasi
- Default: popup konfirmasi **hanya untuk Close All dan Partial Close**
- BUY/SELL/limit order: langsung eksekusi tanpa popup
- Toggle di Settings: bisa ON/OFF per jenis aksi

---

## Position Management

### Partial Close (25% / 50% / 75% / 80%)
- Scope: total volume gabungan semua posisi di simbol aktif
- **Urutan close: dari posisi dengan floating profit TERKECIL terlebih dahulu**
  - Tujuan: yang tersisa adalah posisi dengan profit terbesar
  - Bukan FIFO, bukan random — sort by profit ascending sebelum close
- Jika hasil kalkulasi lot < minimum lot broker: **close posisi tersebut penuh (full close)**
- Formula: `lot_to_close = total_lots × persen`

### Close All
- Tutup semua posisi terbuka di simbol aktif
- Dipengaruhi toggle magic number filter (lihat bagian Settings)

### Close Buy Only / Close Sell Only
- Ada, tapi di **secondary/accordion area** (panel expandable) — tidak di area utama
- Menjaga panel utama tetap clean

### Set TP (All Trades)
- Input: harga absolut (price)
- Apply ke semua posisi terbuka di simbol aktif

### Breakeven
- **Manual BE**: input offset pips → klik SET BE → apply ke semua posisi yang sudah profit
  - Buy: `SL = entry + (offset × point)`; Sell: `SL = entry − (offset × point)`
  - Hanya posisi yang floating profit ≥ offset pips yang dimodifikasi
- **Auto BE**: toggle ON/OFF + input `Activate After (pips)` + `BE Offset (pips)`
  - Jalan di OnTick — cek semua posisi, set flag per ticket agar tidak diproses ulang
- Scope BE: **toggle setting** — `Current Symbol Only` vs `All Symbols`

### Trailing Stop
- **TIDAK ada di v1** — masuk v2

---

## Settings (Input EA + Sub-panel)

| Parameter | Default | Catatan |
|---|---|---|
| Magic Number | `20250101` | Magic number order EA ini |
| Manage Own Trades Only | `true` | Filter magic number ON/OFF |
| Default Lot Size | `0.01` | Lot saat mode Fixed |
| Default Risk % | `1.0` | Risk per trade saat mode Risk% |
| Slippage | `3` | Max slippage (points) |
| SL/TP Input Mode | `Pips` | Toggle pips / price |
| Confirmation: Close All | `true` | Popup sebelum Close All |
| Confirmation: Partial Close | `true` | Popup sebelum Partial Close |
| Auto BE | `false` | Toggle auto breakeven |
| Auto BE Activate (pips) | `20` | Trigger |
| Auto BE Offset (pips) | `0` | SL offset dari entry |
| BE Scope | `Current Symbol` | Current Symbol / All Symbols |
| Panel Position | `Top-Left` | Top-Left/Right, Bottom-Left/Right |
| Keyboard Shortcuts | `true` | F1=BUY F2=SELL F5=CLOSE ALL |

---

## UI / UX

### Dark Futuristic Theme (CCanvas)
- Background utama: `#080C14`, section card: `#0D1421`
- Accent / border glow: `#00D4FF` (cyan)
- Profit: `#00FF9D`, Loss: `#FF3B5C`, Warning: `#FF8C42`
- Font: `Arial Bold` untuk label/tombol, `Courier New` untuk angka harga/nilai
- Monitor target: **1440p+** — panel boleh lebih besar dari panel MT5 standar

### Ukuran Panel
- Lebar: ~240px, tinggi total: ~420px (expandable dengan accordion)
- Tombol BUY/SELL: 28px tinggi, warna solid kontras tinggi
- Tombol partial close: 22px, warna oranye `#FF8C42`

### Minimize
- Klik tombol `[−]` di title bar → **collapse ke title bar saja**
- Klik lagi untuk expand penuh
- Saat collapsed, title bar tetap tampilkan simbol + P/L singkat

### Error & Status Bar
- Area kecil di bawah panel: tampilkan pesan error/sukses sementara (fade out ~3 detik)
- Contoh: `✗ Order failed: not enough margin`, `✓ BE set for 3 positions`
- Tidak ada MT5 Alert popup untuk error order — semua ke status bar

### Keyboard Shortcuts (v1)
- `F1` → BUY (market, lot sesuai panel)
- `F2` → SELL (market, lot sesuai panel)
- `F5` → CLOSE ALL (tetap ada konfirmasi jika toggle ON)
- Implementasi via `OnChartEvent(CHARTEVENT_KEYDOWN)`

---

## Compile via Terminal

```bash
# Copy files ke MT5 data folder dulu, lalu compile:
cp MQL5/Experts/LagzTradeManager.mq5 "C:/Users/Laganda/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Experts/"
cp MQL5/Include/LTM_*.mqh "C:/Users/Laganda/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Include/"

# Compile
"C:/Program Files/MetaTrader 5/MetaEditor64.exe" /compile:"C:/Users/Laganda/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Experts/LagzTradeManager.mq5" /log:"C:/Users/Laganda/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Logs/LagzTM_compile.log"

# Cek hasil log
cat "C:/Users/Laganda/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Logs/LagzTM_compile.log"
```

Output `.ex5` akan ada di folder Experts — langsung bisa di-attach ke chart MT5.

---

## Hal yang TIDAK boleh dilakukan
- Jangan buat trailing stop di v1 — masuk backlog v2
- Jangan auto-reject order karena spread tinggi — hanya tampilkan spread
- Jangan gunakan CChartObjectButton/Label untuk komponen utama — pakai CCanvas
- Jangan close posisi dari simbol lain kecuali toggle "All Symbols" aktif
- Partial close tidak boleh FIFO — urutkan dari profit terkecil dulu

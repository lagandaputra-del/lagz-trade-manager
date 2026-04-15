# Lagz Trade Manager — Product Requirements Document

## 1. Overview

Lagz Trade Manager adalah Expert Advisor (EA) untuk MetaTrader 5 yang berfungsi sebagai panel manajemen trading interaktif. EA ini tampil sebagai overlay GUI di atas chart dan memungkinkan trader melakukan eksekusi order, monitoring akun, serta manajemen posisi secara cepat tanpa perlu membuka dialog MT5 bawaan.

**Target pengguna:** Trader manual & semi-otomatis yang aktif di forex/gold/indices  
**Platform:** MetaTrader 5 (MQL5)  
**Mode tampilan:** Overlay panel (ChartObject / Canvas) menempel di sudut chart

---

## 2. Goals & Non-Goals

### Goals
- Mempercepat eksekusi order (buy/sell instant & pending)
- Monitoring equity, margin, dan profit/loss secara realtime
- Manajemen posisi massal (close partial, breakeven, set TP)

### Non-Goals
- Automated/algorithmic trading (tidak ada logika entry otomatis)
- Grid/martingale strategy engine
- Backtest support

---

## 3. Functional Requirements

### 3.1 Dashboard

Bagian atas panel menampilkan data akun secara realtime.

| Field | Deskripsi |
|---|---|
| Balance | Saldo akun (USD), update realtime |
| Equity | Equity akun (USD), update realtime |
| Margin Used | Margin yang digunakan (USD) + persentase dari equity |
| Free Margin | Margin bebas (USD) |
| Running P/L | Floating profit/loss semua posisi terbuka (USD) |
| % Profit Today | (Equity sekarang − Balance awal hari) / Balance awal hari × 100 |

**Aturan tampilan:**
- Semua nilai di-refresh setiap tick (`OnTick`)
- Warna teks Running P/L: hijau jika profit, merah jika loss
- Balance awal hari disimpan saat EA pertama kali jalan di hari tersebut, dan di-reset otomatis setiap hari baru

---

### 3.2 Trade Execution

#### 3.2.1 Instant Order
- **BUY** — buka market order Buy di harga ask
- **SELL** — buka market order Sell di harga bid
- Input **Lot Size**: field angka, default `0.01`, step `0.01`

#### 3.2.2 Pending Order
- **BUY LIMIT** — buka pending Buy Limit di harga yang diinput
- **SELL LIMIT** — buka pending Sell Limit di harga yang diinput
- Input **Price**: field angka untuk harga pending order

#### 3.2.3 SL / TP saat Open Order
- Field **SL** dalam pips (0 = tidak pakai SL)
- Field **TP** dalam pips (0 = tidak pakai TP)
- Dikonversi ke harga otomatis berdasarkan ask/bid saat eksekusi

---

### 3.3 Position Management

#### 3.3.1 Close All Trades
- Tombol **CLOSE ALL** — tutup semua posisi terbuka (buy + sell)
- Popup konfirmasi sebelum eksekusi (bisa di-toggle di settings)

#### 3.3.2 Partial Close

Tombol persentase menutup sebagian dari **total volume semua posisi terbuka**:

| Tombol | Aksi |
|---|---|
| CLOSE 25% | Tutup 25% dari total lot semua posisi |
| CLOSE 50% | Tutup 50% dari total lot semua posisi |
| CLOSE 75% | Tutup 75% dari total lot semua posisi |
| CLOSE 80% | Tutup 80% dari total lot semua posisi |

**Logika eksekusi:**
1. Hitung total lot dari semua posisi terbuka
2. Kalkulasi lot yang harus ditutup = total lot × persentase
3. Close posisi dari yang paling lama dibuka (FIFO) sampai lot target terpenuhi
4. Jika sisa lot dalam satu posisi lebih besar dari yang perlu ditutup, lakukan partial close pada posisi tersebut

#### 3.3.3 Set Take Profit (All Trades)
- Input field: harga TP (dalam price, bukan pips)
- Tombol **SET TP** — terapkan TP yang sama ke semua posisi terbuka
- Berlaku untuk posisi buy maupun sell

#### 3.3.4 Breakeven

**Manual Breakeven:**
- Input field **BE Offset (pips)** — jumlah pips offset dari entry (default `0` = tepat di entry)
- Tombol **SET BE** — pindahkan SL semua posisi ke harga entry ± offset
  - Buy: `SL = entry price + (BE offset × point)`
  - Sell: `SL = entry price − (BE offset × point)`
- Hanya posisi yang floating profit-nya sudah mencapai atau melebihi BE offset pips yang akan dimodifikasi

**Auto Breakeven:**
- Toggle ON/OFF: **Auto BE**
- Input **Activate After (pips)** — trigger: posisi dipindah ke BE setelah profit mencapai X pips
- Input **BE Offset (pips)** — offset SL dari entry (0 = tepat entry)
- Logika berjalan di `OnTick`:
  - Iterasi semua posisi terbuka
  - Jika floating profit ≥ Activate After pips **dan** SL belum di-set ke breakeven level → set SL ke entry ± offset
  - Flag posisi yang sudah di-BE agar tidak diproses ulang

---

### 3.4 Settings

Parameter yang bisa dikonfigurasi via input EA (sebelum attach) atau sub-panel settings:

| Parameter | Default | Deskripsi |
|---|---|---|
| Default Lot Size | `0.01` | Lot default saat buka order |
| Slippage | `3` | Max slippage (points) |
| Magic Number | `20250101` | Magic number untuk order EA ini |
| Show Confirmation | `true` | Popup konfirmasi sebelum Close All |
| Auto BE | `false` | Toggle auto breakeven on/off |
| Auto BE Activate (pips) | `20` | Jumlah pips profit untuk trigger auto BE |
| Auto BE Offset (pips) | `0` | Offset SL dari entry saat BE |
| Panel Position | `Top-Left` | Posisi panel di chart (Top-Left / Top-Right / Bottom-Left / Bottom-Right) |

---

## 4. UI Design — Futuristic Dark Theme

### 4.1 Design Language

Visual style: **Cyberpunk / HUD (Heads-Up Display)** — terinspirasi dari trading terminal sci-fi.  
Kesan: gelap, bersih, presisi. Accent warna neon cyan & electric blue kontras di atas background hitam pekat.

Implementasi di MQL5 menggunakan **CCanvas** (bitmap rendering) untuk kontrol penuh atas warna, border, dan efek — bukan CChartObject standar yang tampilannya terbatas.

---

### 4.2 Color Palette

| Token | Hex | Penggunaan |
|---|---|---|
| `BG_DEEP` | `#080C14` | Background utama panel |
| `BG_PANEL` | `#0D1421` | Background section/card |
| `BG_INPUT` | `#111927` | Background input field |
| `BORDER_DIM` | `#1A2A3A` | Border section separator |
| `BORDER_GLOW` | `#00D4FF` | Border accent / glow line tipis |
| `TEXT_PRIMARY` | `#E0F0FF` | Teks utama (label, value) |
| `TEXT_DIM` | `#4A6A8A` | Teks sekunder / label field |
| `TEXT_SECTION` | `#00A8CC` | Judul section (DASHBOARD, BREAKEVEN, dll) |
| `ACCENT_CYAN` | `#00D4FF` | Highlight, border aktif, logo accent |
| `PROFIT_GREEN` | `#00FF9D` | P/L positif, tombol BUY |
| `PROFIT_DIM` | `#007A4D` | BUY LIMIT (tone lebih redup) |
| `LOSS_RED` | `#FF3B5C` | P/L negatif, tombol SELL, CLOSE ALL |
| `LOSS_DIM` | `#8A1A2E` | SELL LIMIT (tone lebih redup) |
| `WARN_ORANGE` | `#FF8C42` | Tombol partial close (25/50/75/80%) |
| `NEUTRAL_BLUE` | `#1E6FA8` | Tombol SET TP, SET BE |
| `AUTO_ON` | `#00FF9D` | Toggle Auto BE aktif |
| `AUTO_OFF` | `#2A3A4A` | Toggle Auto BE nonaktif |

---

### 4.3 Typography

| Elemen | Font | Size | Weight | Warna |
|---|---|---|---|---|
| Title bar "LAGZ TRADE MANAGER" | `Arial Bold` | 9pt | Bold | `ACCENT_CYAN` |
| Label field (Balance, Equity…) | `Arial` | 8pt | Normal | `TEXT_DIM` |
| Nilai angka (harga, lot, USD) | `Courier New` | 9pt | Bold | `TEXT_PRIMARY` |
| Judul section | `Arial Bold` | 7pt | Bold | `TEXT_SECTION` + uppercase |
| Teks tombol | `Arial Bold` | 8pt | Bold | `#FFFFFF` |
| P/L positif | `Courier New` | 10pt | Bold | `PROFIT_GREEN` |
| P/L negatif | `Courier New` | 10pt | Bold | `LOSS_RED` |

---

### 4.4 Layout Wireframe

```
╔══════════════════════════════════════════╗  ← border ACCENT_CYAN (1px glow)
║  ◈ LAGZ TRADE MANAGER        [ ─ ] [ ✕ ]║  ← title bar BG_DEEP
╠══════════════════════════════════════════╣
║  ── DASHBOARD ───────────────────────── ║  ← section label TEXT_SECTION
║  Balance   $10,000.00   Equity $10,050  ║
║  Margin    $200.00 (2%) Free   $9,800   ║
║  ┌─────────────────────────────────────┐ ║
║  │  P/L  ▲  +$50.00   (+0.50%)        │ ║  ← card BG_PANEL, teks PROFIT_GREEN
║  │  Today    +0.50%                   │ ║
║  └─────────────────────────────────────┘ ║
╠══════════════════════════════════════════╣
║  ── ORDER ───────────────────────────── ║
║  Lot [ 0.01 ]   Price [ 0.00000      ]  ║  ← input BG_INPUT, border BORDER_DIM
║  SL  [ 0 pips]  TP    [ 0 pips       ]  ║
║                                          ║
║  ╔══════════════╗  ╔═══════════════════╗ ║
║  ║     BUY      ║  ║       SELL        ║ ║  ← BG PROFIT_GREEN / LOSS_RED
║  ╚══════════════╝  ╚═══════════════════╝ ║
║  ╔══════════════╗  ╔═══════════════════╗ ║
║  ║  BUY LIMIT   ║  ║    SELL LIMIT     ║ ║  ← BG PROFIT_DIM / LOSS_DIM
║  ╚══════════════╝  ╚═══════════════════╝ ║
╠══════════════════════════════════════════╣
║  ── MANAGE ──────────────────────────── ║
║  ╔═══════════════╗  SET TP [ 0.00000 ] ║
║  ║  CLOSE ALL    ║  [ SET TP ▶ ]       ║  ← CLOSE ALL: LOSS_RED
║  ╚═══════════════╝                      ║
║  ┌──────────┬──────────┬──────┬────────┐ ║
║  │ CLOSE 25%│ CLOSE 50%│ 75%  │  80%  │ ║  ← WARN_ORANGE
║  └──────────┴──────────┴──────┴────────┘ ║
╠══════════════════════════════════════════╣
║  ── BREAKEVEN ───────────────────────── ║
║  Offset [ 0 pips ]        [ SET BE ▶ ] ║  ← SET BE: NEUTRAL_BLUE
║  Auto BE [ ● OFF ]  After [20]  +[0]   ║  ← toggle pill shape
╚══════════════════════════════════════════╝
```

---

### 4.5 Komponen Visual Detail

#### Title Bar
- Background: `BG_DEEP`
- Border bawah: garis 1px `ACCENT_CYAN` dengan opacity 80%
- Icon `◈` di kiri sebagai logo mark warna `ACCENT_CYAN`
- Tombol `[─]` minimize dan `[✕]` close: warna `TEXT_DIM`, hover jadi `TEXT_PRIMARY`

#### Dashboard Card (P/L)
- Background: `BG_PANEL` dengan border kiri 2px `PROFIT_GREEN` (profit) atau `LOSS_RED` (loss)
- Nilai P/L: font monospace lebih besar, bold
- Panah `▲` (profit) / `▼` (loss) sebelum nilai

#### Input Fields
- Background: `BG_INPUT`
- Border: `BORDER_DIM` normal → `ACCENT_CYAN` saat fokus/active
- Teks: `TEXT_PRIMARY`, placeholder: `TEXT_DIM`

#### Tombol BUY / SELL
- BUY: background solid `PROFIT_GREEN`, teks `#000000` (hitam) — kontras tinggi
- SELL: background solid `LOSS_RED`, teks `#FFFFFF`
- BUY LIMIT: background `PROFIT_DIM`, border 1px `PROFIT_GREEN`, teks `PROFIT_GREEN`
- SELL LIMIT: background `LOSS_DIM`, border 1px `LOSS_RED`, teks `LOSS_RED`
- Hover effect: brightness +15% (simulasi dengan warna lebih terang)

#### Tombol Partial Close
- Background: `WARN_ORANGE` dengan opacity 85%
- Border: 1px `WARN_ORANGE`
- Teks: `#000000`

#### Tombol CLOSE ALL
- Background: `LOSS_RED`
- Border: 1px highlight `#FF6B80`
- Teks: `#FFFFFF`, font bold

#### Toggle Auto BE
- Shape: pill/rounded rectangle
- OFF state: background `AUTO_OFF`, dot abu-abu, label "OFF" warna `TEXT_DIM`
- ON state: background `#003D1F`, border `AUTO_ON`, dot `AUTO_ON`, label "ON"

#### Section Separator
- Garis horizontal 1px `BORDER_DIM`
- Label section: uppercase, `TEXT_SECTION`, font size 7pt, tracking lebar

#### Panel Border
- Border luar panel: 1px solid `ACCENT_CYAN`
- Corner radius: 2px (kotak, bukan terlalu rounded — kesan industrial/tech)

---

### 4.6 Ukuran Panel

| Property | Value |
|---|---|
| Lebar panel | 220 px |
| Tinggi total | ~380 px (expandable) |
| Padding internal | 8px horizontal, 5px vertikal per section |
| Tinggi tombol besar (BUY/SELL) | 28px |
| Tinggi tombol kecil (partial close) | 22px |
| Tinggi input field | 20px |

---

## 5. Technical Architecture (MQL5)

### File Structure

```
MQL5/
├── Experts/
│   └── LagzTradeManager.mq5       ← main EA file (OnInit, OnTick, OnChartEvent, OnDeinit)
├── Include/
│   ├── LTM_Dashboard.mqh          ← render label dashboard (balance, equity, P/L, dll)
│   ├── LTM_TradeExec.mqh          ← fungsi OpenBuy, OpenSell, OpenBuyLimit, OpenSellLimit
│   ├── LTM_PositionMgr.mqh        ← CloseAll, PartialClose, SetTPAll, SetBreakeven, AutoBE
│   └── LTM_GUI.mqh                ← create/destroy GUI objects, layout constants
└── Files/
    └── LTM_DayStart.bin           ← simpan balance awal hari (persist antar restart EA)
```

### MQL5 APIs yang Digunakan

| Kebutuhan | API / Class |
|---|---|
| GUI labels & buttons | `CChartObjectLabel`, `CChartObjectButton`, `CChartObjectEdit` |
| Handle klik & input | `OnChartEvent(CHARTEVENT_OBJECT_CLICK, CHARTEVENT_OBJECT_ENDEDIT)` |
| Refresh data per tick | `OnTick()` |
| Eksekusi order | `CTrade::Buy()`, `CTrade::Sell()`, `CTrade::BuyLimit()`, `CTrade::SellLimit()` |
| Baca posisi | `PositionSelect()`, `PositionGetDouble()`, `PositionGetInteger()` |
| Modifikasi SL/TP | `CTrade::PositionModify()` |
| Data akun | `AccountInfoDouble(ACCOUNT_BALANCE/EQUITY/MARGIN/FREEMARGIN)` |
| Partial close | `CTrade::PositionClosePartial()` |
| Waktu server | `TimeCurrent()`, `TimeToStruct()` |

---

## 6. Acceptance Criteria

| # | Skenario | Expected Result |
|---|---|---|
| 1 | Klik BUY dengan lot 0.01 | Market buy order terbuka di harga ask |
| 2 | Klik SELL dengan lot 0.05 | Market sell order terbuka di harga bid |
| 3 | Isi price, klik SELL LIMIT | Pending sell limit order terbuka di harga yang diinput |
| 4 | Ada 4 posisi, klik CLOSE 50% | ~50% total volume tertutup (FIFO) |
| 5 | Klik SET BE dengan offset 2 pips | SL semua posisi yang sudah profit pindah ke entry ± 2 pips |
| 6 | Auto BE aktif (after 20 pips), posisi profit 21 pips | SL otomatis pindah ke entry + offset |
| 7 | Isi harga TP, klik SET TP | Semua posisi terbuka mendapat TP yang sama |
| 8 | Klik CLOSE ALL | Semua posisi tertutup (setelah konfirmasi) |
| 9 | Dashboard refresh setiap tick | Balance, equity, P/L, margin update realtime |
| 10 | % Profit Today | Kalkulasi vs balance awal hari akurat, reset di hari baru |

---

## 7. Out of Scope (v1)

- Trailing stop otomatis
- Hedge mode
- Partial close per-posisi individual
- Grid/sequence pending orders
- Mobile/email notifications
- Multi-symbol dashboard

---

## 8. Future Considerations (v2)

- Trailing stop dengan custom step & activation
- Close by profit target (close all when floating profit ≥ $X atau pips X)
- Per-posisi management table (individual SL/TP/close per baris)
- Laporan harian (profit per hari disimpan di log file)
- One-click BE dari tabel posisi

<h1 align="center">Crypto → Wall Street</h1>

<p align="center">
  <strong>A macOS menu-bar widget for tokenized stocks.</strong><br/>
  Live xStock prices in your menu bar · a two-way coin ⇄ stock converter · one click to the swapper.
</p>

<p align="center">
  <img alt="Powered by SODAX" src="https://img.shields.io/badge/Powered%20by-SODAX-FF9048?style=for-the-badge&labelColor=1A1312" />
  <img alt="macOS 13+" src="https://img.shields.io/badge/macOS-13%2B-FF9048?style=for-the-badge&labelColor=1A1312" />
  <img alt="Swift" src="https://img.shields.io/badge/Swift-5.9-FF9048?style=for-the-badge&labelColor=1A1312" />
</p>

---

## What it does

A tiny always-available widget that lives in your menu bar:

- **Live prices** for the 8 xStocks — TSLA, NVDA, SPY, QQQ, MSTR, COIN, GOOGL, CRCL — plus major coins (ETH, SOL, BTC, BNB, AVAX, USDC, USDT, bnUSD).
- **Two-way converter** — type an amount of any coin to see how many shares it buys, or hit **⇄** to flip to shares → coin. Shows both unit rates and each leg's USD price.
- **Open swapper ↗** — launches the full [Crypto → Wall Street](#the-full-swapper) web app to actually execute the swap.

Prices come straight from the public **SODAX** solver oracle (`api.sodax.com/v1/intent/oracle`) — the same feed that drives the swap engine. No API key, refreshed every 60 seconds.

## Install

**Option A — download a build** (recommended)

1. Grab `Crypto → Wall Street.app` from the [latest release](../../releases/latest).
2. Drag it into `/Applications`.
3. First launch: right-click → **Open** (it's ad-hoc signed, so Gatekeeper asks once).
4. Look up at your menu bar — you'll see the live price. Click it for the panel.

**Option B — build from source**

```bash
git clone https://github.com/hazy2go/crypto-to-wallstreet-mac.git
cd crypto-to-wallstreet-mac
./bundle.sh
open "dist/Crypto → Wall Street.app"
```

Requires the Swift toolchain (`xcode-select --install` is enough — **full Xcode not needed**).
During development you can also just `swift run`.

### Launch at login

System Settings → General → **Login Items** → add `Crypto → Wall Street.app`.
It runs as a menu-bar-only app (no Dock icon). Quit via the ⏻ button in the panel.

## Configure

Edit `Sources/CryptoWallStreet/Catalog.swift`:

- `SWAPPER_URL` — point **Open swapper** at your deployed web app (defaults to `http://localhost:3210`).
- `COINS` / `STOCKS` — add or reorder assets (the `symbol` must match the oracle's symbol).
- `REFRESH_SECONDS` — price refresh cadence.

## The full swapper

This widget is the desktop companion to the **Crypto → Wall Street** web app — a one-tap
swap UI that turns any token you hold into a tokenized stock, settled on Solana, routed by
the SODAX solver. ("Turn your ETH into Tesla.")

## Project layout

| File | Purpose |
| --- | --- |
| `Catalog.swift` | asset lists, brand palette, URLs, refresh cadence |
| `PriceStore.swift` | oracle fetch + 60 s timer + symbol→price map |
| `ContentView.swift` | the panel: pickers, converter, price glance |
| `App.swift` | `MenuBarExtra` scene + dynamic price label |
| `Format.swift` | number / relative-time formatting |
| `bundle.sh` | build + `.app` packaging + ad-hoc sign |

## Notes

- xStocks are tokenized equities that settle on Solana; this widget is **read-only** (prices
  and conversions). All actual swapping happens in the web app with your connected wallet.
- Prices reflect the SODAX solver oracle and may differ slightly from the exact quote you'll
  get at swap time (fees + slippage).

---

<p align="center">
  <sub>Powered by <a href="https://sodax.com"><b>SODAX</b></a> — Swaps Without Borders.</sub>
</p>

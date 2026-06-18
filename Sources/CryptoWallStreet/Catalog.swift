import SwiftUI

/// SODAX brand palette (official). "Orange Sonic" is the accent.
extension Color {
  static let sodaxOrange = Color(red: 1.0, green: 0.565, blue: 0.282)   // #FF9048 Orange Sonic
  static let sodaxBg     = Color(red: 0.10, green: 0.075, blue: 0.072)  // espresso-tinted near-black
  static let sodaxInk    = Color(red: 0.92, green: 0.89, blue: 0.87)    // cream-white
}

/// The full swapper this widget complements. Change to your deployed URL.
let SWAPPER_URL = URL(string: "http://localhost:3210")!

/// Public SODAX solver oracle — same prices that drive the swap engine. No key.
let ORACLE_URL = URL(string: "https://api.sodax.com/v1/intent/oracle")!

/// Refresh cadence for the price feed.
let REFRESH_SECONDS: TimeInterval = 60

struct Asset: Identifiable, Hashable {
  let symbol: String   // oracle lookup symbol, e.g. "TSLAx" / "ETH"
  let ticker: String   // display, e.g. "TSLA" / "ETH"
  let name: String
  var id: String { symbol }
}

/// The 8 xStocks (oracle symbol → display).
let STOCKS: [Asset] = [
  Asset(symbol: "TSLAx",  ticker: "TSLA",  name: "Tesla"),
  Asset(symbol: "NVDAx",  ticker: "NVDA",  name: "NVIDIA"),
  Asset(symbol: "SPYx",   ticker: "SPY",   name: "S&P 500"),
  Asset(symbol: "QQQx",   ticker: "QQQ",   name: "Nasdaq 100"),
  Asset(symbol: "MSTRx",  ticker: "MSTR",  name: "MicroStrategy"),
  Asset(symbol: "COINx",  ticker: "COIN",  name: "Coinbase"),
  Asset(symbol: "GOOGLx", ticker: "GOOGL", name: "Alphabet"),
  Asset(symbol: "CRCLx",  ticker: "CRCL",  name: "Circle"),
]

/// Major coins you'd swap from (oracle symbol → display).
let COINS: [Asset] = [
  Asset(symbol: "ETH",   ticker: "ETH",   name: "Ethereum"),
  Asset(symbol: "SOL",   ticker: "SOL",   name: "Solana"),
  Asset(symbol: "BTC",   ticker: "BTC",   name: "Bitcoin"),
  Asset(symbol: "BNB",   ticker: "BNB",   name: "BNB"),
  Asset(symbol: "AVAX",  ticker: "AVAX",  name: "Avalanche"),
  Asset(symbol: "USDC",  ticker: "USDC",  name: "USD Coin"),
  Asset(symbol: "USDT",  ticker: "USDT",  name: "Tether"),
  Asset(symbol: "bnUSD", ticker: "bnUSD", name: "Balanced $"),
]

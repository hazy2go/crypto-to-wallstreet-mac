import SwiftUI

/// NieR:Automata terminal palette + SODAX "Orange Sonic" accent.
extension Color {
  static let nierBone  = Color(red: 0.784, green: 0.761, blue: 0.659)  // #c8c2a8 field
  static let nierPanel = Color(red: 0.741, green: 0.718, blue: 0.612)  // #bdb79c recessed
  static let nierInk   = Color(red: 0.271, green: 0.255, blue: 0.220)  // #454138 ink
  static let nierFaint = Color(red: 0.514, green: 0.486, blue: 0.392)  // #837c64
  static let nierLine  = Color(red: 0.271, green: 0.255, blue: 0.220).opacity(0.38)
  static let sodaxOrange = Color(red: 1.0, green: 0.565, blue: 0.282)  // #FF9048 Orange Sonic
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

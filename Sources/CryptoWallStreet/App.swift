import SwiftUI
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    // Menu-bar-only: no Dock icon, no app-switcher entry.
    NSApp.setActivationPolicy(.accessory)
  }
}

@main
struct CryptoWallStreetApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
  @StateObject private var store = PriceStore()
  @AppStorage("stock") private var stockSym = "TSLAx"

  private var labelText: String {
    let stock = STOCKS.first { $0.symbol == stockSym } ?? STOCKS[0]
    if let p = store.price(stock.symbol) { return "\(stock.ticker) \(Fmt.usd(p))" }
    return "◢◤ xStocks"
  }

  var body: some Scene {
    MenuBarExtra {
      ContentView(store: store)
        .onAppear { store.start() }
    } label: {
      Text(labelText)
    }
    .menuBarExtraStyle(.window)
  }
}

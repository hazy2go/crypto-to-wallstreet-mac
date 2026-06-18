import SwiftUI
import AppKit

/// Hairline rectangular frame — the NieR menu-box look (no rounded corners).
private struct NierBox: ViewModifier {
  var fill: Color = .nierPanel
  func body(content: Content) -> some View {
    content
      .background(fill)
      .overlay(Rectangle().stroke(Color.nierLine, lineWidth: 1))
  }
}
private extension View {
  func nierBox(_ fill: Color = .nierPanel) -> some View { modifier(NierBox(fill: fill)) }
  func mono(_ size: CGFloat, _ weight: Font.Weight = .regular) -> some View {
    font(.system(size: size, weight: weight, design: .monospaced))
  }
}

struct ContentView: View {
  @ObservedObject var store: PriceStore

  @AppStorage("coin") private var coinSym = "ETH"
  @AppStorage("stock") private var stockSym = "TSLAx"
  @AppStorage("amount") private var amount = "1"
  @AppStorage("coinToStock") private var coinToStock = true

  /// Every coin the oracle prices, majors first (with proper names), then the
  /// long tail alphabetically. xStocks excluded. Falls back to the curated list
  /// before the first price load.
  private var coinOptions: [Asset] {
    let priced = store.prices
    if priced.isEmpty { return COINS }
    let stockSyms = Set(STOCKS.map(\.symbol))
    var out = COINS.filter { priced[$0.symbol] != nil }
    let have = Set(out.map(\.symbol))
    let tail = priced.keys
      .filter { !stockSyms.contains($0) && !have.contains($0) }
      .sorted()
      .map { Asset(symbol: $0, ticker: $0, name: $0) }
    out.append(contentsOf: tail)
    return out
  }

  private var coin: Asset {
    coinOptions.first { $0.symbol == coinSym } ?? COINS.first { $0.symbol == coinSym } ?? COINS[0]
  }
  private var stock: Asset { STOCKS.first { $0.symbol == stockSym } ?? STOCKS[0] }
  private var coinPrice: Double? { store.price(coin.symbol) }
  private var stockPrice: Double? { store.price(stock.symbol) }

  private var converted: Double? {
    guard let cp = coinPrice, let sp = stockPrice, sp > 0, cp > 0 else { return nil }
    let a = amount.asAmount
    return coinToStock ? a * cp / sp : a * sp / cp
  }
  private var fromAsset: Asset { coinToStock ? coin : stock }
  private var toAsset: Asset { coinToStock ? stock : coin }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      header
      Rectangle().fill(Color.nierLine).frame(height: 1)

      VStack(alignment: .leading, spacing: 13) {
        converter
        Rectangle().fill(Color.nierLine).frame(height: 1)
        glance
        footer
        poweredBy
      }
      .padding(14)
    }
    .frame(width: 326)
    .background(Color.nierBone)
    .foregroundStyle(Color.nierInk)
    .environment(\.colorScheme, .light) // NieR theme is light; keep system controls dark-on-bone
  }

  // MARK: header

  private var header: some View {
    HStack(spacing: 7) {
      Text("◢◤").foregroundStyle(Color.sodaxOrange)
      Text("CRYPTO → WALL STREET").mono(11, .bold).tracking(1.5)
      Spacer()
      if store.loading {
        ProgressView().scaleEffect(0.45).frame(width: 12, height: 12)
      }
    }
    .padding(.horizontal, 14).padding(.vertical, 11)
    .background(Color.nierPanel)
  }

  // MARK: converter

  private var converter: some View {
    VStack(alignment: .leading, spacing: 9) {
      label("CONVERT")

      HStack(spacing: 8) {
        picker(selection: $coinSym, options: coinOptions)
        Button { coinToStock.toggle() } label: {
          Text("⇄").mono(13, .bold).foregroundStyle(Color.sodaxOrange)
            .frame(width: 28, height: 26).nierBox(.nierBone)
        }
        .buttonStyle(.plain).help("Flip direction")
        picker(selection: $stockSym, options: STOCKS)
      }

      label(coinToStock ? "YOU SPEND \(coin.ticker)" : "YOU SPEND \(stock.ticker)")
      HStack(spacing: 8) {
        TextField("0", text: $amount)
          .textFieldStyle(.plain)
          .mono(22, .medium)
          .padding(.horizontal, 9).padding(.vertical, 6)
          .nierBox(.nierBone)
          .onChange(of: amount) { v in amount = v.filter { $0.isNumber || $0 == "." } }
        Text(fromAsset.ticker).mono(15, .bold)
        Spacer()
      }

      result
    }
  }

  private var result: some View {
    VStack(alignment: .leading, spacing: 4) {
      label("YOU RECEIVE")
      if let out = converted {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
          Text("≈ \(Fmt.qty(out))").mono(21, .semibold)
          Text(toAsset.ticker).mono(14, .bold).foregroundStyle(Color.sodaxOrange)
        }
        if let cp = coinPrice, let sp = stockPrice {
          let per = cp / sp
          Text("1 \(coin.ticker) = \(Fmt.qty(per)) \(stock.ticker)   1 \(stock.ticker) = \(Fmt.qty(1/per)) \(coin.ticker)")
            .mono(9.5).foregroundStyle(Color.nierFaint)
          Text("\(coin.ticker) \(Fmt.usd(cp))   \(stock.ticker) \(Fmt.usd(sp))")
            .mono(9.5).foregroundStyle(Color.nierFaint)
        }
      } else {
        Text(store.errorText ?? "LOADING FEED…").mono(11).foregroundStyle(Color.nierFaint)
      }
    }
  }

  // MARK: glance

  private var glance: some View {
    VStack(alignment: .leading, spacing: 6) {
      label("XSTOCKS")
      LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 5) {
        ForEach(STOCKS.prefix(4)) { s in
          HStack(spacing: 6) {
            Text("■").font(.system(size: 7)).foregroundStyle(Color.sodaxOrange)
            Text(s.ticker).mono(11, .bold)
            Spacer()
            Text(store.price(s.symbol).map(Fmt.usd) ?? "··").mono(11).foregroundStyle(Color.nierFaint)
          }
          .padding(.horizontal, 8).padding(.vertical, 5)
          .nierBox(.nierBone)
        }
      }
    }
  }

  // MARK: footer

  private var footer: some View {
    HStack(spacing: 0) {
      Text("UPDATED \(Fmt.relative(store.lastUpdated).uppercased())")
        .mono(9).foregroundStyle(Color.nierFaint)
      Spacer()
      footBtn("REFRESH") { Task { await store.refresh() } }
      footBtn("SWAPPER ↗") { NSWorkspace.shared.open(SWAPPER_URL) }
      Button { NSApp.terminate(nil) } label: {
        Image(systemName: "power").font(.system(size: 11))
      }.buttonStyle(.plain).help("Quit")
    }
  }

  private var poweredBy: some View {
    HStack(spacing: 4) {
      Spacer()
      Text("POWERED BY").mono(8).foregroundStyle(Color.nierFaint).tracking(1)
      Text("SODAX").mono(8, .heavy).foregroundStyle(Color.sodaxOrange).tracking(1)
      Spacer()
    }
  }

  // MARK: bits

  private func label(_ t: String) -> some View {
    HStack(spacing: 6) {
      Text("■").font(.system(size: 7)).foregroundStyle(Color.sodaxOrange)
      Text(t).mono(9.5, .semibold).tracking(1.2).foregroundStyle(Color.nierFaint)
    }
  }

  /// Custom Menu instead of native Picker: the native picker renders its
  /// selected-value label in the system label colour (white under the dark
  /// system appearance), which is unreadable on bone. A Menu label is fully
  /// styleable, so we force ink.
  private func picker(selection: Binding<String>, options: [Asset]) -> some View {
    let current = options.first { $0.symbol == selection.wrappedValue }?.ticker
      ?? selection.wrappedValue
    return Menu {
      ForEach(options) { a in
        Button(a.ticker) { selection.wrappedValue = a.symbol }
      }
    } label: {
      HStack(spacing: 6) {
        Text(current).mono(13, .bold).foregroundStyle(Color.nierInk)
        Spacer(minLength: 4)
        Text("▾").mono(9).foregroundStyle(Color.nierFaint)
      }
      .padding(.horizontal, 10).padding(.vertical, 7)
      .frame(maxWidth: .infinity)
      .nierBox(.nierBone)
      .contentShape(Rectangle())
    }
    .menuStyle(.borderlessButton)
    .menuIndicator(.hidden)
    .fixedSize(horizontal: false, vertical: true)
  }

  private func footBtn(_ t: String, _ action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Text(t).mono(10, .semibold).foregroundStyle(Color.sodaxOrange)
    }
    .buttonStyle(.plain)
    .padding(.leading, 12)
  }
}

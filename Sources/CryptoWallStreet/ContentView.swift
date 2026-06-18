import SwiftUI
import AppKit

struct ContentView: View {
  @ObservedObject var store: PriceStore

  @AppStorage("coin") private var coinSym = "ETH"
  @AppStorage("stock") private var stockSym = "TSLAx"
  @AppStorage("amount") private var amount = "1"
  @AppStorage("coinToStock") private var coinToStock = true

  private var coin: Asset { COINS.first { $0.symbol == coinSym } ?? COINS[0] }
  private var stock: Asset { STOCKS.first { $0.symbol == stockSym } ?? STOCKS[0] }
  private var coinPrice: Double? { store.price(coin.symbol) }
  private var stockPrice: Double? { store.price(stock.symbol) }

  // How many of `to` you get for `amount` of `from`.
  private var converted: Double? {
    guard let cp = coinPrice, let sp = stockPrice, sp > 0, cp > 0 else { return nil }
    let a = amount.asAmount
    return coinToStock ? a * cp / sp : a * sp / cp
  }

  private var fromAsset: Asset { coinToStock ? coin : stock }
  private var toAsset: Asset { coinToStock ? stock : coin }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      header

      Divider().overlay(Color.white.opacity(0.08))

      // ---- Converter ----
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          assetPicker(title: "Coin", selection: $coinSym, options: COINS)
          Spacer(minLength: 8)
          Button {
            coinToStock.toggle()
          } label: {
            Image(systemName: "arrow.left.arrow.right")
              .font(.system(size: 12, weight: .bold))
          }
          .buttonStyle(.borderless)
          .help("Flip direction")
          Spacer(minLength: 8)
          assetPicker(title: "Stock", selection: $stockSym, options: STOCKS)
        }

        Text(coinToStock ? "You spend" : "You spend")
          .font(.system(size: 10, weight: .semibold))
          .foregroundStyle(.secondary)

        HStack(spacing: 8) {
          TextField("0", text: $amount)
            .textFieldStyle(.roundedBorder)
            .font(.system(.title3, design: .monospaced))
            .frame(maxWidth: 130)
            .onChange(of: amount) { newVal in
              amount = newVal.filter { $0.isNumber || $0 == "." }
            }
          Text(fromAsset.ticker)
            .font(.system(.title3, design: .monospaced).weight(.bold))
          Spacer()
        }

        resultRow
      }

      Divider().overlay(Color.white.opacity(0.08))

      glance
      footer

      HStack(spacing: 4) {
        Spacer()
        Text("Powered by").font(.system(size: 9)).foregroundStyle(.tertiary)
        Text("SODAX").font(.system(size: 9, weight: .heavy)).foregroundStyle(Color.sodaxOrange)
        Spacer()
      }
    }
    .padding(14)
    .frame(width: 320)
    .background(Color.sodaxBg)
    .foregroundStyle(Color.sodaxInk)
  }

  // MARK: - pieces

  private var header: some View {
    HStack(spacing: 6) {
      Text("◢◤").foregroundStyle(Color.sodaxOrange)
      Text("Crypto → Wall Street").font(.system(size: 13, weight: .bold))
      Spacer()
      if store.loading { ProgressView().scaleEffect(0.5).frame(width: 14, height: 14) }
    }
  }

  private func assetPicker(title: String, selection: Binding<String>, options: [Asset]) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title.uppercased())
        .font(.system(size: 9, weight: .semibold)).foregroundStyle(.tertiary)
      Picker("", selection: selection) {
        ForEach(options) { a in Text(a.ticker).tag(a.symbol) }
      }
      .labelsHidden()
      .frame(width: 110)
    }
  }

  private var resultRow: some View {
    VStack(alignment: .leading, spacing: 3) {
      Text("You receive")
        .font(.system(size: 10, weight: .semibold)).foregroundStyle(.secondary)
      if let out = converted {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
          Text("≈ \(Fmt.qty(out))")
            .font(.system(.title2, design: .monospaced).weight(.semibold))
          Text(toAsset.ticker)
            .font(.system(.body, design: .monospaced).weight(.bold))
            .foregroundStyle(Color.sodaxOrange)
        }
        if let cp = coinPrice, let sp = stockPrice {
          let perCoin = cp / sp
          Text("1 \(coin.ticker) ≈ \(Fmt.qty(perCoin)) \(stock.ticker)   ·   1 \(stock.ticker) ≈ \(Fmt.qty(1/perCoin)) \(coin.ticker)")
            .font(.system(size: 10, design: .monospaced)).foregroundStyle(.tertiary)
          Text("\(coin.ticker) \(Fmt.usd(cp))   ·   \(stock.ticker) \(Fmt.usd(sp))")
            .font(.system(size: 10, design: .monospaced)).foregroundStyle(.tertiary)
        }
      } else {
        Text(store.errorText ?? "Loading prices…")
          .font(.system(size: 12)).foregroundStyle(.secondary)
      }
    }
  }

  private var glance: some View {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
      ForEach(STOCKS.prefix(4)) { s in
        HStack {
          Text(s.ticker).font(.system(size: 11, design: .monospaced).weight(.bold))
          Spacer()
          Text(store.price(s.symbol).map(Fmt.usd) ?? "—")
            .font(.system(size: 11, design: .monospaced))
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8).padding(.vertical, 5)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 7))
      }
    }
  }

  private var footer: some View {
    HStack {
      Text("Updated \(Fmt.relative(store.lastUpdated))")
        .font(.system(size: 10)).foregroundStyle(.tertiary)
      Spacer()
      Button("Refresh") { Task { await store.refresh() } }
        .buttonStyle(.borderless).font(.system(size: 11))
      Button("Open swapper ↗") { NSWorkspace.shared.open(SWAPPER_URL) }
        .buttonStyle(.borderless).font(.system(size: 11, weight: .semibold))
        .foregroundStyle(Color.sodaxOrange)
      Button { NSApp.terminate(nil) } label: { Image(systemName: "power") }
        .buttonStyle(.borderless).help("Quit")
    }
  }
}

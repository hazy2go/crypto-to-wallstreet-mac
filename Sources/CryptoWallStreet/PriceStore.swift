import SwiftUI

private struct OraclePrice: Decodable {
  let symbol: String
  let priceUsd: Double
}

/// Fetches and caches the SODAX oracle's USD prices, keyed by symbol.
@MainActor
final class PriceStore: ObservableObject {
  @Published var prices: [String: Double] = [:]
  @Published var lastUpdated: Date?
  @Published var loading = false
  @Published var errorText: String?

  private var timer: Timer?

  func start() {
    Task { await refresh() }
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: REFRESH_SECONDS, repeats: true) { [weak self] _ in
      Task { await self?.refresh() }
    }
  }

  func price(_ symbol: String) -> Double? { prices[symbol] }

  func refresh() async {
    loading = true
    defer { loading = false }
    do {
      var req = URLRequest(url: ORACLE_URL)
      req.timeoutInterval = 12
      let (data, resp) = try await URLSession.shared.data(for: req)
      guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
        errorText = "Feed unavailable"
        return
      }
      let rows = try JSONDecoder().decode([OraclePrice].self, from: data)
      // First occurrence per symbol wins (prices are consistent across chains).
      var map: [String: Double] = [:]
      for r in rows where map[r.symbol] == nil && r.priceUsd > 0 {
        map[r.symbol] = r.priceUsd
      }
      prices = map
      lastUpdated = Date()
      errorText = nil
    } catch {
      errorText = "Couldn’t reach the price feed"
    }
  }
}

import Foundation

enum Fmt {
  static func usd(_ v: Double) -> String {
    if v >= 1000 { return "$" + group(v, frac: 0) }
    if v >= 1 { return "$" + group(v, frac: 2) }
    if v > 0 { return "$" + trim(v, frac: 4) }
    return "—"
  }

  /// Token amount: trims trailing zeros, scales precision to magnitude.
  static func qty(_ v: Double) -> String {
    if v == 0 { return "0" }
    if v >= 1000 { return group(v, frac: 2) }
    if v >= 1 { return trim(v, frac: 4) }
    if v >= 0.0001 { return trim(v, frac: 6) }
    return String(format: "%.2e", v)
  }

  private static func group(_ v: Double, frac: Int) -> String {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    f.minimumFractionDigits = frac
    f.maximumFractionDigits = frac
    return f.string(from: v as NSNumber) ?? String(v)
  }

  private static func trim(_ v: Double, frac: Int) -> String {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    f.minimumFractionDigits = 0
    f.maximumFractionDigits = frac
    f.usesGroupingSeparator = false
    return f.string(from: v as NSNumber) ?? String(v)
  }

  static func relative(_ date: Date?) -> String {
    guard let date else { return "—" }
    let s = Int(Date().timeIntervalSince(date))
    if s < 5 { return "just now" }
    if s < 60 { return "\(s)s ago" }
    return "\(s / 60)m ago"
  }
}

extension String {
  /// Parse a user-typed decimal, tolerant of grouping separators.
  var asAmount: Double {
    Double(replacingOccurrences(of: ",", with: "")) ?? 0
  }
}

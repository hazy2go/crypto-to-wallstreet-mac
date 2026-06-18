// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "CryptoWallStreet",
  platforms: [.macOS(.v13)],
  targets: [
    .executableTarget(name: "CryptoWallStreet")
  ]
)

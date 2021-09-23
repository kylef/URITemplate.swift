// swift-tools-version:4.2

import PackageDescription

let package = Package(
  name: "URITemplate",
  products: [
    .library(name: "URITemplate", targets: ["URITemplate"])
  ],
  dependencies: [
    .package(url: "https://github.com/kylef/PathKit.git", .upToNextMinor(from: "1.0.0")),
    .package(url: "https://github.com/kylef/Spectre.git", .upToNextMinor(from: "0.10.1"))
  ],
  targets: [
    .target(name: "URITemplate", dependencies: [], path: "Sources"),
    .testTarget(name: "URITemplateTests", dependencies: ["URITemplate", "PathKit", "Spectre"], path: "Tests/URITemplateTests")
  ]
)

import PackageDescription


let package = Package(
  name: "URITemplate",
  testDependencies: [
    .Package(url: "https://github.com/kylef/Spectre", majorVersion: 0, minor: 7),
    .Package(url: "https://github.com/kylef/PathKit", majorVersion: 0, minor: 6),
  ]
)

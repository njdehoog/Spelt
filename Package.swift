import PackageDescription

let package = Package(
    name: "SpeltPackage",
    targets: [
        Target(
            name: "Spelt",
            dependencies: []),
        Target(
            name: "CLI",
            dependencies: ["Spelt"])
        ],
    dependencies: [
        .Package(url: "https://github.com/njdehoog/Witness.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/njdehoog/swift-yaml.git", majorVersion: 0, minor: 1)
    ]
)

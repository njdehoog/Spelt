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
        ]
)

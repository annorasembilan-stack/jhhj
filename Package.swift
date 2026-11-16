// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "OlorisPictures",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "OlorisPictures",
            path: "Sources/OlorisPictures"
        )
    ]
)

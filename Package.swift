// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "swift-nio-irc-eliza",
    products: [
        .library   (name: "IRCElizaBot", targets: [ "IRCElizaBot" ]),
        .executable(name: "elizabot",    targets: [ "elizabot" ])
    ],
    dependencies: [
        .package(url: "https://github.com/AlwaysRightInstitute/SwiftEliza.git",
                 from: "1.0.0"),
        .package(url: "https://github.com/NozeIO/swift-nio-irc-client.git",
                 from: "0.6.0")
    ],
    targets: [
        .target(name: "IRCElizaBot", dependencies: [ "IRC", "Eliza" ]),
        .target(name: "elizabot",    dependencies: [ "IRCElizaBot"  ])
    ]
)

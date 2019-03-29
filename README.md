# swift-nio-irc-eliza

![Swift4](https://img.shields.io/badge/swift-4-blue.svg)
![Swift5](https://img.shields.io/badge/swift-5-blue.svg)
![iOS](https://img.shields.io/badge/os-iOS-green.svg?style=flat)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![tuxOS](https://img.shields.io/badge/os-tuxOS-green.svg?style=flat)
![Travis](https://travis-ci.org/NozeIO/swift-nio-irc-eliza.svg?branch=master)

[SwiftNIO IRC](https://github.com/NozeIO/swift-nio-irc)
is a Internet Relay Chat protocol implementation for
[SwiftNIO](https://github.com/apple/swift-nio),
including a client.

SwiftNIO IRC Eliza, is a scalable Rogerian psychotherapist based on
the
[SwiftEliza](https://github.com/kennysong/SwiftEliza)
module. Eliza is always there for you!

This bot can be used standalone, or you can embed it as a Swift module.

## Talking to Eliza

In your IRC just talk to nickname `Eliza`, she'll respond!

<img src="http://zeezide.de/img/irc-eliza-720x781.png" />

## Importing the module using Swift Package Manager

An example `Package.swift `importing the necessary module:

```swift
// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "MyElizaBotTool",
    dependencies: [
        .package(url: "https://github.com/NozeIO/swift-nio-irc-eliza.git",
                 from: "0.7.0")
    ],
    targets: [
        .target(name: "MyElizaBotTool",
                dependencies: [ "IRCElizaBot" ])
    ]
)
```


### Who

Brought to you by
[ZeeZide](http://zeezide.de).
We like
[feedback](https://twitter.com/ar_institute),
GitHub stars,
cool [contract work](http://zeezide.com/en/services/services.html),
presumably any form of praise you can think of.

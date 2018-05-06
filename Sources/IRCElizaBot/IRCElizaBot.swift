//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-nio-irc open source project
//
// Copyright (c) 2018 ZeeZide GmbH. and the swift-nio-irc project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIOIRC project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import struct Foundation.TimeInterval
import struct Foundation.Date
import NIO
import IRC
import Eliza

public let defaultNickName = IRCNickName("Eliza")!

open class IRCElizaBot : IRCClientDelegate {
  
  open class Options : IRCClientOptions {
    
    open var thinkingTime   : TimeInterval = 2.0
    open var sessionTimeout : TimeInterval = 2 * 60.0
    
    override public init(port           : Int             = DefaultIRCPort,
                         host           : String          = "localhost",
                         password       : String?         = nil,
                         nickname       : IRCNickName     = defaultNickName,
                         userInfo       : IRCUserInfo?    = nil,
                         eventLoopGroup : EventLoopGroup? = nil)
    {
      super.init(port: port, host: host, password: password,
                 nickname: nickname, userInfo: userInfo,
                 eventLoopGroup: eventLoopGroup)
    }
  }
  
  open class Session {
    
    weak var bot     : IRCElizaBot?
    let patient      : IRCNickName
    var isThinking   = false
    let delay        : TimeAmount
    let timeout      : TimeAmount
    var timeoutTimer : Scheduled<Void>?
    
    init(patient: IRCNickName, bot: IRCElizaBot) {
      self.patient = patient
      self.bot     = bot
      self.delay   = .milliseconds(TimeAmount.Value(bot.options.thinkingTime * 1000.0))
      self.timeout = .seconds(TimeAmount.Value(bot.options.sessionTimeout))
      
      restartTimeout()
    }
    
    func restartTimeout() {
      timeoutTimer?.cancel()
      timeoutTimer = bot?.ircClient.eventLoop.scheduleTask(in: timeout) {
        [weak self] in
        self?.onTimeout()
      }
    }
    open func onTimeout() {
      guard let bot = bot else { return }
      bot.ircClient.sendMessage(bot.eliza.elizaBye(), to: .nickname(patient))
      bot.sessions.removeValue(forKey: patient)
    }
    
    open func sayHello() {
      guard let bot = bot else { return }
      bot.ircClient.sendMessage(bot.eliza.elizaHi(), to: .nickname(patient))
    }
    
    open func replyTo(_ statement: String) {
      guard !isThinking   else { return }
      guard let bot = bot else { return }
      
      timeoutTimer?.cancel()
      isThinking = true
      _ = bot.ircClient.eventLoop.scheduleTask(in: delay) {
        self.isThinking = false
        bot.ircClient.sendMessage(bot.eliza.replyTo(statement),
                                  to: .nickname(self.patient))
        self.restartTimeout()
      }
    }
    
  }
  
  public let options   : Options
  public let ircClient : IRCClient
  public let eliza     = Eliza()

  public private(set) var nick : IRCNickName
  var sessions = [ IRCNickName : Session ]()
  
  public init(options: Options = Options()) {
    self.options   = options
    self.nick      = options.nickname
    self.ircClient = IRCClient(options: options)
    self.ircClient.delegate = self
  }
  
  open func connect() {
    ircClient.connect()
  }
  
  
  // MARK: - IRC message handling

  open func client(_ client: IRCClient,
                   message: String, from user: IRCUserID,
                   for recipients: [ IRCMessageRecipient ])
  {
    guard recipients.contains(where: { $0 == .nickname(nick) }) else {
      print("Eliza(\(nick.stringValue): received message for different nick:",
            recipients.map { $0.stringValue })
      return
    }
    
    if let session = sessions[user.nick] {
      session.replyTo(message)
    }
    else {
      let session = Session(patient: user.nick, bot: self)
      sessions[user.nick] = session
      session.sayHello()
      session.replyTo(message)
    }
  }
  
  // MARK: - Nick tracking

  open func client(_ client        : IRCClient,
                   registered nick : IRCNickName,
                   with   userInfo : IRCUserInfo)
  {
    self.nick = nick
    print("Eliza is ready and listening!")
  }
  open func client(_ client: IRCClient, changedNickTo nick: IRCNickName) {
    self.nick = nick
  }

  open func clientFailedToRegister(_ client: IRCClient) {
    print("Eliza failed to register!")
  }
}

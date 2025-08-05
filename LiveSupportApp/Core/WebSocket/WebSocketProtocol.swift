//
//  WebSocketProtocol.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import Foundation

protocol WebSocketManagerProtocol: ObservableObject {
    var isConnected: Bool { get }
    var receivedMessage: String? { get }
    
    func connect()
    func disconnect()
    func send(message: String)
}

protocol WebSocketDelegate: AnyObject {
    func webSocketDidConnect()
    func webSocketDidDisconnect()
    func webSocketDidReceiveMessage(_ message: String)
    func webSocketDidReceiveError(_ error: Error)
}

//
//  WebSocketManager.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import Foundation
import Network

class WebSocketManager: NSObject, WebSocketManagerProtocol, ObservableObject {
    @Published var isConnected = false
    @Published var receivedMessage: String?
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let urlSession = URLSession(configuration: .default)
    weak var delegate: WebSocketDelegate?
    
    private let socketURL = "wss://echo.websocket.org"
    private var reconnectTimer: Timer?
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    private let reconnectDelay: TimeInterval = 2.0
    
    // MARK: - Connection Management
    
    func connect() {
        guard let url = URL(string: socketURL) else { 
            handleConnectionError(WebSocketError.invalidURL)
            return 
        }
        
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        
        DispatchQueue.main.async {
            self.isConnected = true
            self.reconnectAttempts = 0
        }
        
        delegate?.webSocketDidConnect()
        receiveMessage()
    }
    
    func disconnect() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        
        DispatchQueue.main.async {
            self.isConnected = false
        }
        
        delegate?.webSocketDidDisconnect()
    }
    
    // MARK: - Message Handling
    
    func send(message: String) {
        guard isConnected else {
            handleConnectionError(WebSocketError.notConnected)
            return
        }
        
        print("WebSocket sending: \(message)")
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { [weak self] error in
            if let error = error {
                print("WebSocket send error: \(error)")
                self?.handleConnectionError(WebSocketError.sendFailed(error))
            } else {
                print("WebSocket message sent successfully")
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                self.handleReceivedMessage(message)
                self.receiveMessage() 
                
            case .failure(let error):
                print("WebSocket receive error: \(error)")
                self.handleConnectionError(WebSocketError.receiveFailed(error))
            }
        }
    }
    
    private func handleReceivedMessage(_ message: URLSessionWebSocketTask.Message) {
        let text: String
        
        switch message {
        case .string(let stringValue):
            text = stringValue
        case .data(let data):
            guard let stringValue = String(data: data, encoding: .utf8) else {
                print("Failed to decode data message")
                return
            }
            text = stringValue
        @unknown default:
            print("Unknown message type received")
            return
        }
        
        print("WebSocket received: \(text)")
        DispatchQueue.main.async {
            self.receivedMessage = text
        }
        delegate?.webSocketDidReceiveMessage(text)
    }
    
    // MARK: - Error Handling & Reconnection
    
    private func handleConnectionError(_ error: WebSocketError) {
        print("WebSocket error: \(error)")
        delegate?.webSocketDidReceiveError(error)
        
        DispatchQueue.main.async {
            self.isConnected = false
        }
        
        scheduleReconnection()
    }
    
    private func scheduleReconnection() {
        guard reconnectAttempts < maxReconnectAttempts else {
            print("Max reconnection attempts reached")
            return
        }
        
        reconnectTimer?.invalidate()
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: reconnectDelay, repeats: false) { [weak self] _ in
            self?.attemptReconnection()
        }
    }
    
    private func attemptReconnection() {
        reconnectAttempts += 1
        print("Attempting reconnection \(reconnectAttempts)/\(maxReconnectAttempts)")
        connect()
    }
}

// MARK: - WebSocket Error Types

enum WebSocketError: Error, LocalizedError {
    case invalidURL
    case notConnected
    case sendFailed(Error)
    case receiveFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid WebSocket URL"
        case .notConnected:
            return "WebSocket is not connected"
        case .sendFailed(let error):
            return "Failed to send message: \(error.localizedDescription)"
        case .receiveFailed(let error):
            return "Failed to receive message: \(error.localizedDescription)"
        }
    }
}

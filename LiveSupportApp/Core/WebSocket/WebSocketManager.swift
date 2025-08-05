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
    
    func connect() {
        guard let url = URL(string: socketURL) else { return }
        
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        
        DispatchQueue.main.async {
            self.isConnected = true
        }
        
        delegate?.webSocketDidConnect()
        receiveMessage()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        
        DispatchQueue.main.async {
            self.isConnected = false
        }
        
        delegate?.webSocketDidDisconnect()
    }
    
    func send(message: String) {
        print("WebSocket sending: \(message)")
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { [weak self] error in
            if let error = error {
                print("WebSocket send error: \(error)")
                self?.delegate?.webSocketDidReceiveError(error)
            } else {
                print("WebSocket message sent successfully")
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("WebSocket received: \(text)")
                    DispatchQueue.main.async {
                        self?.receivedMessage = text
                    }
                    self?.delegate?.webSocketDidReceiveMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        print("WebSocket received (data): \(text)")
                        DispatchQueue.main.async {
                            self?.receivedMessage = text
                        }
                        self?.delegate?.webSocketDidReceiveMessage(text)
                    }
                @unknown default:
                    break
                }
                self?.receiveMessage()
                
            case .failure(let error):
                print("WebSocket receive error: \(error)")
                self?.delegate?.webSocketDidReceiveError(error)
            }
        }
    }
}

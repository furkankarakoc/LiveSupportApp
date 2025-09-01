//
//  LiveSupportInteractor.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import Foundation

class LiveSupportInteractor: LiveSupportInteractorInputProtocol, WebSocketDelegate {
    weak var presenter: LiveSupportInteractorOutputProtocol?
    
    private let webSocketManager = WebSocketManager()
    private var chatFlow: [String: ChatStep] = [:]
    private var currentStepId = "step_1"
    private var isWaitingForResponse = false
    
    init() {
        webSocketManager.delegate = self
        loadChatFlow()
    }
    
    func loadInitialStep() {
        let initialStepId = "step_1"
        guard let step = chatFlow[initialStepId] else {
            print("Initial step '\(initialStepId)' not found")
            print("Available steps: \(Array(chatFlow.keys))")
            presenter?.didEncounterError(NSError(domain: "ChatError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Initial step not found"]))
            return
        }
        
        currentStepId = initialStepId
        print("Loading initial step: \(initialStepId)")
        presenter?.didLoadStep(step)
    }
    
    func sendAction(_ action: ChatAction) {
        print("User action: \(action.text)")
        print("Action type: \(action.type)")
        print("Action nextStep: \(action.nextStep ?? "nil")")
        
        if action.type == "end_conversation" {
            print("Handling as end conversation action")
            handleEndConversation()
            return
        }
        
        print("Handling as normal navigation action")
        sendActionToWebSocket(action)
        isWaitingForResponse = true
    }
    
    private func sendActionToWebSocket(_ action: ChatAction) {
        guard let currentStep = chatFlow[currentStepId] else {
            print("Current step not found: \(currentStepId)")
            return
        }
        
        let message = WebSocketMessage(
            currentStep: currentStep,
            userAction: action
        )
        
        do {
            let jsonData = try JSONEncoder().encode(message)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            
            print("Sending to WebSocket: \(action.text)")
            webSocketManager.send(message: jsonString)
        } catch {
            print("Failed to encode WebSocket message: \(error)")
            fallbackToLocalNavigation(action)
        }
    }
    
    private func handleEndConversation() {
        print("Handling end conversation - showing rating directly")
        
        DispatchQueue.main.async {
            self.presenter?.didReceiveMessage("Konuşma sonlandırıldı. Teşekkürler!")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.disconnectWebSocket()
        }
    }
    
    func connectWebSocket() {
        print("Connecting to WebSocket...")
        webSocketManager.connect()
    }
    
    func disconnectWebSocket() {
        print("Disconnecting from WebSocket...")
        webSocketManager.disconnect()
    }
    
    func endConversation() {
        handleEndConversation()
    }
    
    // MARK: - Media Message Handling
    
    func sendTextMessage(_ message: TextWebSocketMessage) {
        print("Sending text message via WebSocket: \(message.content)")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message.data, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            webSocketManager.send(message: jsonString)
        } catch {
            print("Failed to encode text message: \(error)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.presenter?.didReceiveMessage("Bot yanıtı: \(message.content)")
            }
        }
    }
    
    func sendMediaMessage(_ message: MediaWebSocketMessage) {
        print("Sending media message via WebSocket: \(message.mediaContent.fileName)")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message.data, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            webSocketManager.send(message: jsonString)
        } catch {
            print("Failed to encode media message: \(error)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let responseMessage = "Dosya alındı: \(message.mediaContent.fileName) (\(message.mediaContent.formattedFileSize))"
                self.presenter?.didReceiveMessage(responseMessage)
            }
        }
    }
    
    private func loadChatFlow() {
        if let loadedFlow = JSONLoader.loadChatFlow() {
            chatFlow = loadedFlow
            print("Loaded chat flow from JSON with \(chatFlow.count) steps")
        } else {
            print("Failed to load JSON, using sample flow")
            createSampleFlow()
        }
    }
    
    private func createSampleFlow() {
        chatFlow = [
            "step_1": ChatStep(
                id: "step_1",
                type: "button",
                content: .object(ChatContent(
                    text: "Merhaba! Size nasıl yardımcı olabilirim?",
                    buttons: [
                        ChatButton(label: "Teknik Destek", action: "step_technical"),
                        ChatButton(label: "Satış Bilgisi", action: "step_sales"),
                        ChatButton(label: "Sohbeti bitir", action: "end_conversation")
                    ]
                )),
                action: "await_user_choice"
            )
        ]
        print("Sample flow created with \(chatFlow.count) steps")
    }
    
    // MARK: - WebSocketDelegate -
    func webSocketDidConnect() {
        print("WebSocket Connected Successfully!")
        presenter?.didConnectWebSocket()
    }
    
    func webSocketDidDisconnect() {
        print("WebSocket Disconnected")
        presenter?.didDisconnectWebSocket()
    }
    
    func webSocketDidReceiveMessage(_ message: String) {
        print("Received from WebSocket: \(String(message.prefix(100)))...")
                
        guard isWaitingForResponse else {
            print("Not waiting for response, ignoring message")
            return
        }
        
        isWaitingForResponse = false
        handleWebSocketResponse(message)
    }
    

    
    private func handleWebSocketResponse(_ message: String) {
        print("Handling WebSocket response...")
        
        do {
            guard let data = message.data(using: .utf8),
                  let webSocketMessage = try? JSONDecoder().decode(WebSocketMessage.self, from: data) else {
                print("Failed to parse WebSocket response, using fallback")
                return
            }
            
            print("WebSocket response parsed successfully")
            
            let userAction = webSocketMessage.userAction
            navigateBasedOnWebSocketResponse(userAction)
            
        } catch {
            print("WebSocket response parsing error: \(error)")
        }
    }
    
    private func navigateBasedOnWebSocketResponse(_ action: ChatAction) {
        print("Navigating based on WebSocket response")
        
        guard let nextStepId = action.nextStep,
              let nextStep = chatFlow[nextStepId] else {
            print("Next step not found from WebSocket response: \(action.nextStep ?? "nil")")
            return
        }
        
        currentStepId = nextStepId
        print("Moving to step: \(nextStepId) (from WebSocket response)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.presenter?.didLoadStep(nextStep)
        }
    }
    
    private func fallbackToLocalNavigation(_ action: ChatAction) {
        print("Falling back to local JSON navigation")
        
        guard let nextStepId = action.nextStep,
              let nextStep = chatFlow[nextStepId] else {
            print("Next step not found in fallback: \(action.nextStep ?? "nil")")
            return
        }
        
        currentStepId = nextStepId
        print("Moving to step: \(nextStepId) (fallback)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.presenter?.didLoadStep(nextStep)
        }
    }
    
    func webSocketDidReceiveError(_ error: Error) {
        print("WebSocket error: \(error.localizedDescription)")
        
        if error.localizedDescription.contains("Socket is not connected") {
            print("Socket disconnection is normal during end conversation")
            return
        }
        
        presenter?.didEncounterError(error)
    }
}

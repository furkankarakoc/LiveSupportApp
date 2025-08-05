//
//  WebSocketMessage.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 6.08.2025.
//

import Foundation

struct WebSocketMessage: Codable {
    let currentStep: ChatStep
    let userAction: ChatAction
    let timestamp: Date
    let messageType: String
    
    init(currentStep: ChatStep, userAction: ChatAction) {
        self.currentStep = currentStep
        self.userAction = userAction
        self.timestamp = Date()
        self.messageType = "user_action"
    }
}

struct EndConversationMessage: Codable {
    let action: String
    let timestamp: Date
    let messageType: String
    
    init() {
        self.action = "end_conversation"
        self.timestamp = Date()
        self.messageType = "end_conversation"
    }
}

struct WebSocketResponse: Codable {
    let nextStep: String?
    let message: String?
    let actions: [ChatAction]?
    let shouldEndConversation: Bool?
    let responseType: String?
}

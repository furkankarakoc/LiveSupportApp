//
//  WebSocketMessage.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 6.08.2025.
//

import Foundation

// MARK: - WebSocket Message Protocol

protocol WebSocketMessageProtocol {
    var type: String { get }
    var data: [String: Any] { get }
}

// MARK: - Message Types

struct TextWebSocketMessage: WebSocketMessageProtocol, Codable {
    let type: String = "text"
    let content: String
    let timestamp: Date
    let isFromUser: Bool
    
    var data: [String: Any] {
        return [
            "type": type,
            "content": content,
            "timestamp": ISO8601DateFormatter().string(from: timestamp),
            "isFromUser": isFromUser
        ]
    }
    
    init(content: String, isFromUser: Bool) {
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = Date()
    }
}

struct MediaWebSocketMessage: WebSocketMessageProtocol, Codable {
    let type: String = "media"
    let content: String
    let mediaContent: MediaContent
    let timestamp: Date
    let isFromUser: Bool
    
    var data: [String: Any] {
        var mediaData: [String: Any] = [
            "fileName": mediaContent.fileName,
            "fileSize": mediaContent.fileSize,
            "mimeType": mediaContent.mimeType,
            "mediaType": mediaContent.mediaType.rawValue
        ]
        
        if let localPath = mediaContent.localPath {
            mediaData["localPath"] = localPath
        }
        
        if let thumbnailPath = mediaContent.thumbnailPath {
            mediaData["thumbnailPath"] = thumbnailPath
        }
        
        return [
            "type": type,
            "content": content,
            "mediaContent": mediaData,
            "timestamp": ISO8601DateFormatter().string(from: timestamp),
            "isFromUser": isFromUser
        ]
    }
    
    init(content: String, mediaContent: MediaContent, isFromUser: Bool) {
        self.content = content
        self.mediaContent = mediaContent
        self.isFromUser = isFromUser
        self.timestamp = Date()
    }
}

struct ActionWebSocketMessage: WebSocketMessageProtocol, Codable {
    let type: String = "action"
    let actionId: String
    let actionText: String
    let nextStep: String?
    let timestamp: Date
    
    var data: [String: Any] {
        var actionData: [String: Any] = [
            "type": type,
            "actionId": actionId,
            "actionText": actionText,
            "timestamp": ISO8601DateFormatter().string(from: timestamp)
        ]
        
        if let nextStep = nextStep {
            actionData["nextStep"] = nextStep
        }
        
        return actionData
    }
    
    init(actionId: String, actionText: String, nextStep: String? = nil) {
        self.actionId = actionId
        self.actionText = actionText
        self.nextStep = nextStep
        self.timestamp = Date()
    }
}

// MARK: - Legacy Message Types

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

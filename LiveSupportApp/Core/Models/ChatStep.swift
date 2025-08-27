//
//  ChatStep.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import Foundation

struct ChatStep: Codable, Identifiable {
    let id: String
    let type: String
    let content: ChatContentWrapper?
    let action: String?
    
    var message: String? {
        switch content {
        case .object(let chatContent):
            return chatContent.text
        case .string(let text):
            return text
        case .none:
            return nil
        }
    }
    
    var actions: [ChatAction]? {
        switch content {
        case .object(let chatContent):
            let uniqueButtons = chatContent.buttons?.reduce(into: [ChatButton]()) { result, button in
                if !result.contains(where: { $0.action == button.action }) {
                    result.append(button)
                }
            }
            return uniqueButtons?.compactMap { createAction(from: $0) }
        case .string(_), .none:
            return createEndConversationActionIfNeeded()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "step"
        case type
        case content
        case action
    }
        
    private func createAction(from button: ChatButton) -> ChatAction {
        let isEndConversation = button.action == "end_conversation"
        
        if isEndConversation {
            return ChatAction.endConversation(id: button.label, text: button.label)
        } else {
            return ChatAction.navigate(id: button.label, text: button.label, nextStep: button.action)
        }
    }
    
    private func createEndConversationActionIfNeeded() -> [ChatAction]? {
        guard action == "end_conversation" else { return nil }
        return [ChatAction.endConversation()]
    }
}

enum ChatContentWrapper: Codable {
    case string(String)
    case object(ChatContent)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let objectValue = try? container.decode(ChatContent.self) {
            self = .object(objectValue)
        } else {
            throw DecodingError.typeMismatch(
                ChatContentWrapper.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected String or ChatContent object"
                )
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let stringValue):
            try container.encode(stringValue)
        case .object(let objectValue):
            try container.encode(objectValue)
        }
    }
}

struct ChatContent: Codable {
    let text: String?
    let buttons: [ChatButton]?
}

struct ChatButton: Codable {
    let label: String
    let action: String
}

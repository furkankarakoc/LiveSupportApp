//
//  ChatAction.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import Foundation

struct ChatAction: Codable, Identifiable {
    let id: String
    let text: String
    let type: String
    let nextStep: String?
    let payload: [String: String]?
    
    // MARK: - Convenience Initializers
    
    init(id: String, text: String, type: String, nextStep: String? = nil, payload: [String: String]? = nil) {
        self.id = id
        self.text = text
        self.type = type
        self.nextStep = nextStep
        self.payload = payload
    }
    
    // MARK: - Factory Methods
    
    static func endConversation(id: String = "end", text: String = "Konuşmayı sonlandır") -> ChatAction {
        ChatAction(
            id: id,
            text: text,
            type: "end_conversation",
            nextStep: nil,
            payload: nil
        )
    }
    
    static func navigate(id: String, text: String, nextStep: String) -> ChatAction {
        ChatAction(
            id: id,
            text: text,
            type: "navigate",
            nextStep: nextStep,
            payload: nil
        )
    }
    
    // MARK: - Computed Properties
    
    var isEndConversation: Bool {
        type == "end_conversation"
    }
    
    var isNavigate: Bool {
        type == "navigate"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, text, type, payload
        case nextStep = "next_step"
    }
}

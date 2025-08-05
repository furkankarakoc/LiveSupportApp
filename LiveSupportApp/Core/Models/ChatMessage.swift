//
//  ChatMessage.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import Foundation

struct ChatMessage: Codable, Identifiable {
    let id = UUID()
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    let step: ChatStep?
    
    init(content: String, isFromUser: Bool, step: ChatStep? = nil) {
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = Date()
        self.step = step
    }
}

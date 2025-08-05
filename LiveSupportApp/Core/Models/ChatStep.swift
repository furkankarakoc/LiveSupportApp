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
    let message: String?
    let actions: [ChatAction]?
    let nextStep: String?
    
    enum CodingKeys: String, CodingKey {
        case id, type, message, actions
        case nextStep = "next_step"
    }
}

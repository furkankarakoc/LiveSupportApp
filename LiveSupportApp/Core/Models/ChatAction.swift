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
    
    enum CodingKeys: String, CodingKey {
        case id, text, type, payload
        case nextStep = "next_step"
    }
}

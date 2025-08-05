//
//  LiveSupportEntity.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import Foundation

struct LiveSupportEntity {
    let chatFlow: [String: ChatStep]
    let currentStepId: String
    
    init(chatFlow: [String: ChatStep], currentStepId: String = "start") {
        self.chatFlow = chatFlow
        self.currentStepId = currentStepId
    }
}

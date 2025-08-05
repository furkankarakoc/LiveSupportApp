//
//  JSONLoader.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import Foundation

class JSONLoader {
    static func loadChatFlow() -> [String: ChatStep]? {
        guard let url = Bundle.main.url(forResource: "live_support_flow", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        do {
            let steps = try JSONDecoder().decode([String: ChatStep].self, from: data)
            return steps
        } catch {
            print("JSON decode error: \(error)")
            return nil
        }
    }
}

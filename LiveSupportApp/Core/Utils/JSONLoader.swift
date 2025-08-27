//
//  JSONLoader.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import Foundation

class JSONLoader {
    
    // MARK: - Static Methods
    
    static func loadChatFlow() -> [String: ChatStep]? {
        if let cached = shared.cachedChatFlow {
            return cached
        }
        
        shared.cachedChatFlow = loadChatFlowFromBundle()
        return shared.cachedChatFlow
    }
    
    static func reloadChatFlow() -> [String: ChatStep]? {
        shared.cachedChatFlow = nil
        return loadChatFlow()
    }
    
    // MARK: - Private Singleton & Methods
    
    private static let shared = JSONLoader()
    private var cachedChatFlow: [String: ChatStep]?
    
    private init() {}
    
    private static func loadChatFlowFromBundle() -> [String: ChatStep]? {
        guard let url = Bundle.main.url(forResource: "live_support_flow", withExtension: "json") else {
            print("JSON file not found: live_support_flow.json")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let stepsArray = try JSONDecoder().decode([ChatStep].self, from: data)
            
            let stepsDict = Dictionary(uniqueKeysWithValues: stepsArray.map { ($0.id, $0) })
            
            print("Chat flow loaded successfully with \(stepsDict.count) steps")
            return stepsDict
            
        } catch {
            print("Failed to load chat flow: \(error.localizedDescription)")
            return nil
        }
    }
}

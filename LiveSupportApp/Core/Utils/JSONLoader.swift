//
//  JSONLoader.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import Foundation

class JSONLoader {
    static func loadChatFlow() -> [String: ChatStep]? {
        if let bundlePath = Bundle.main.resourcePath {
            print("Bundle path: \(bundlePath)")
            let fileManager = FileManager.default
            do {
                let files = try fileManager.contentsOfDirectory(atPath: bundlePath)
                let jsonFiles = files.filter { $0.hasSuffix(".json") }
                print("JSON files in bundle: \(jsonFiles)")
            } catch {
                print("Error listing bundle contents: \(error)")
            }
        }
        
        guard let url = Bundle.main.url(forResource: "live_support_flow", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("JSON file not found")
            return nil
        }
        
        print("JSON data size: \(data.count) bytes")
        
        do {
            let stepsArray = try JSONDecoder().decode([ChatStep].self, from: data)
            print("JSON decoded successfully")
            print("Steps in JSON: \(stepsArray.map { $0.id })")
            
            var stepsDict: [String: ChatStep] = [:]
            for step in stepsArray {
                stepsDict[step.id] = step
            }
            
            print("JSON loaded successfully: \(Array(stepsDict.keys))")
            return stepsDict
        } catch {
            print("JSON decode error: \(error)")
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON (first 200 chars): \(String(jsonString.prefix(200)))")
            }
            
            return nil
        }
    }
}

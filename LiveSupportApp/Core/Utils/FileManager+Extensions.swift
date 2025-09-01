//
//  FileManager+Extensions.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import Foundation
import UIKit

extension FileManager {
    
    // MARK: - Media Storage
    
    static var mediaCacheDirectory: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let mediaPath = documentsPath.appendingPathComponent("Media", isDirectory: true)
        
        try? FileManager.default.createDirectory(at: mediaPath, withIntermediateDirectories: true)
        
        return mediaPath
    }
    
    static var thumbnailCacheDirectory: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let thumbnailPath = documentsPath.appendingPathComponent("Thumbnails", isDirectory: true)
        
        try? FileManager.default.createDirectory(at: thumbnailPath, withIntermediateDirectories: true)
        
        return thumbnailPath
    }
    
    // MARK: - File Operations
    
    static func saveMedia(_ data: Data, fileName: String) -> String? {
        let fileURL = mediaCacheDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Error saving media file: \(error)")
            return nil
        }
    }
    
    static func saveThumbnail(_ image: UIImage, fileName: String) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
        
        let fileURL = thumbnailCacheDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Error saving thumbnail: \(error)")
            return nil
        }
    }
    
    static func deleteMediaFile(at path: String) {
        let url = URL(fileURLWithPath: path)
        try? FileManager.default.removeItem(at: url)
    }
    
    static func mediaCacheSize() -> Int64 {
        let mediaURL = mediaCacheDirectory
        let thumbnailURL = thumbnailCacheDirectory
        
        var totalSize: Int64 = 0
        
        if let mediaEnumerator = FileManager.default.enumerator(at: mediaURL, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in mediaEnumerator {
                if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += Int64(fileSize)
                }
            }
        }
        
        if let thumbnailEnumerator = FileManager.default.enumerator(at: thumbnailURL, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in thumbnailEnumerator {
                if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += Int64(fileSize)
                }
            }
        }
        
        return totalSize
    }
    
    static func clearMediaCache() {
        let mediaURL = mediaCacheDirectory
        try? FileManager.default.removeItem(at: mediaURL)
        try? FileManager.default.createDirectory(at: mediaURL, withIntermediateDirectories: true)
        
        let thumbnailURL = thumbnailCacheDirectory
        try? FileManager.default.removeItem(at: thumbnailURL)
        try? FileManager.default.createDirectory(at: thumbnailURL, withIntermediateDirectories: true)
    }
}

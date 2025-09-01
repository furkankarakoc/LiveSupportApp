//
//  ChatMessage.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import Foundation
import UIKit


enum MediaType: String, Codable, CaseIterable {
    case text = "text"
    case image = "image"
    case document = "document"
    
    var displayName: String {
        switch self {
        case .text: return "Metin"
        case .image: return "Görsel"
        case .document: return "Belge"
        }
    }
    
    var systemIcon: String {
        switch self {
        case .text: return "text.bubble"
        case .image: return "photo"
        case .document: return "doc"
        }
    }
}

struct MediaContent: Codable, Equatable {
    let fileName: String
    let fileSize: Int64
    let mimeType: String
    let mediaType: MediaType
    let localPath: String?
    let thumbnailPath: String?
    
    init(fileName: String, fileSize: Int64, mimeType: String, mediaType: MediaType, localPath: String? = nil, thumbnailPath: String? = nil) {
        self.fileName = fileName
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.mediaType = mediaType
        self.localPath = localPath
        self.thumbnailPath = thumbnailPath
    }
    
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
    
    var displayContent: String {
        switch mediaType {
        case .image:
            return "Görsel paylaşıldı"
        case .document:
            return "\(fileName)"
        case .text:
            return fileName
        }
    }
}

struct ChatMessage: Codable, Identifiable {
    let id = UUID()
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    let step: ChatStep?
    let mediaContent: MediaContent?
    let messageType: MediaType
    
    init(content: String, isFromUser: Bool, step: ChatStep? = nil, mediaContent: MediaContent? = nil) {
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = Date()
        self.step = step
        self.mediaContent = mediaContent
        self.messageType = mediaContent?.mediaType ?? .text
    }
    
    var isMediaMessage: Bool {
        return mediaContent != nil && messageType != .text
    }
    
    var displayContent: String {
        if isMediaMessage {
            switch messageType {
            case .image:
                return "Görsel paylaşıldı"
            case .document:
                return "\(mediaContent?.fileName ?? "Belge paylaşıldı")"
            case .text:
                return content
            }
        }
        return content
    }
}

// MARK: - Rating Models

struct ConversationRating: Codable {
    let rating: Int
    let feedback: String?
    let timestamp: Date
    
    init(rating: Int, feedback: String? = nil) {
        self.rating = max(1, min(5, rating))
        self.feedback = feedback
        self.timestamp = Date()
    }
}

enum RatingAction {
    case submit(ConversationRating)
    case reconnect
}

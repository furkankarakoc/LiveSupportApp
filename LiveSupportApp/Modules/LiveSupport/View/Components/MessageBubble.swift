//
//  MessageBubble.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                userMessageView
            } else {
                botMessageView
                Spacer()
            }
        }
    }
    
    // MARK: - View Components
    
    private var userMessageView: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(message.content)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Text(formatTime(message.timestamp))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var botMessageView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(message.content)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.1))
                .foregroundColor(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Text(formatTime(message.timestamp))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Private Methods
    
    private func formatTime(_ date: Date) -> String {
        Self.timeFormatter.string(from: date)
    }
}

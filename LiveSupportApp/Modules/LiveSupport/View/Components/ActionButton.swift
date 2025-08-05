//
//  ActionButton.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import SwiftUI

struct ActionButton: View {
    let action: ChatAction
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(action.text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(buttonColor)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var buttonColor: Color {
        switch action.type {
        case "end_conversation":
            return .red
        case "navigate":
            return .blue
        default:
            return .green
        }
    }
}

struct ActionButtonsView: View {
    let actions: [ChatAction]
    let onActionTap: (ChatAction) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(actions) { action in
                ActionButton(action: action) {
                    onActionTap(action)
                }
            }
        }
    }
}

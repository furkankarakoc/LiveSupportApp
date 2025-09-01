//
//  ChatInputView.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import SwiftUI
import PhotosUI

struct ChatInputView: View {
    @Binding var messageText: String
    @State private var showImagePicker = false
    @State private var showDocumentPicker = false
    @State private var showMediaOptions = false
    @State private var selectedMedia: [MediaContent] = []
    
    let onSendMessage: (String) -> Void
    let onSendMedia: (MediaContent) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if !selectedMedia.isEmpty {
                selectedMediaPreview
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
            }
            
            // Ana input alanı
            HStack(spacing: 12) {
                // Medya butonu
                Button(action: {
                    showMediaOptions = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .confirmationDialog("Dosya Seç", isPresented: $showMediaOptions, titleVisibility: .visible) {
                    Button("Fotoğraf Seç") {
                        showImagePicker = true
                    }
                    
                    Button("Belge Seç") {
                        showDocumentPicker = true
                    }
                    
                    Button("İptal", role: .cancel) {}
                }
                
                HStack {
                    TextField("Mesajınızı yazın...", text: $messageText, axis: .vertical)
                        .textFieldStyle(PlainTextFieldStyle())
                        .lineLimit(1...4)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    
                    if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !selectedMedia.isEmpty {
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .padding(.trailing, 8)
                    }
                }
                .background(Color(UIColor.systemGray6))
                .cornerRadius(20)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color(UIColor.systemBackground))
        .onChange(of: selectedMedia) { media in
            if let latestMedia = media.last {
                sendMediaMessage(latestMedia)
                // Medyayı listeden çıkar
                selectedMedia.removeAll()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            if #available(iOS 14.0, *) {
                ModernPhotoPicker(selectedMedia: $selectedMedia)
            } else {
                ImagePicker(selectedMedia: $selectedMedia)
            }
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(selectedMedia: $selectedMedia)
        }
    }
    
    @ViewBuilder
    private var selectedMediaPreview: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(selectedMedia.enumerated()), id: \.offset) { index, media in
                    MediaPreviewCard(media: media) {
                        selectedMedia.remove(at: index)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 80)
        .background(Color(UIColor.systemGray6).opacity(0.5))
    }
    
    private func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmedText.isEmpty {
            onSendMessage(trimmedText)
            messageText = ""
        }
        
        for media in selectedMedia {
            sendMediaMessage(media)
        }
        selectedMedia.removeAll()
    }
    
    private func sendMediaMessage(_ media: MediaContent) {
        onSendMedia(media)
    }
}

// MARK: - Media Preview Card

struct MediaPreviewCard: View {
    let media: MediaContent
    let onRemove: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if media.mediaType == .image {
                    AsyncImage(url: URL(fileURLWithPath: media.thumbnailPath ?? media.localPath ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    }
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                        .overlay(
                            VStack(spacing: 4) {
                                Image(systemName: media.mediaType.systemIcon)
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                
                                Text(String(media.fileName.prefix(8)) + "...")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                                    .lineLimit(1)
                            }
                        )
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.white)
                    .background(Color.red, in: Circle())
            }
            .offset(x: 8, y: -8)
        }
    }
}

// MARK: - Preview

struct ChatInputView_Previews: PreviewProvider {
    @State static var messageText = ""
    
    static var previews: some View {
        VStack {
            Spacer()
            ChatInputView(
                messageText: $messageText,
                onSendMessage: { message in
                    print("Send message: \(message)")
                },
                onSendMedia: { media in
                    print("Send media: \(media.fileName)")
                }
            )
        }
        .previewLayout(.sizeThatFits)
    }
}

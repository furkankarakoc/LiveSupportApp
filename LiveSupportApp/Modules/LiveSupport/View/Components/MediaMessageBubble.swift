//
//  MediaMessageBubble.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import SwiftUI

struct MediaMessageBubble: View {
    let message: ChatMessage
    @State private var showFullImage = false
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                mediaContent
                    .frame(maxWidth: 250)
            } else {
                mediaContent
                    .frame(maxWidth: 250)
                Spacer()
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showFullImage) {
            if let mediaContent = message.mediaContent,
               mediaContent.mediaType == .image {
                FullImageView(mediaContent: mediaContent)
            }
        }
    }
    
    @ViewBuilder
    private var mediaContent: some View {
        if let media = message.mediaContent {
            VStack(alignment: .leading, spacing: 8) {
                switch media.mediaType {
                case .image:
                    imageContent(media)
                case .document:
                    documentContent(media)
                case .text:
                    textContent
                }
                
                HStack {
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if message.isFromUser {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 4)
            }
            .padding(12)
            .background(message.isFromUser ? Color.blue : Color(UIColor.systemGray5))
            .foregroundColor(message.isFromUser ? .white : .primary)
            .cornerRadius(16)
        } else {
            textContent
        }
    }
    
    @ViewBuilder
    private func imageContent(_ media: MediaContent) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Görsel önizleme
            AsyncImage(url: URL(fileURLWithPath: media.thumbnailPath ?? media.localPath ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 200, maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onTapGesture {
                        showFullImage = true
                    }
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 200, height: 150)
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("Yükleniyor...")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
            }
            
            HStack {
                Image(systemName: "photo")
                    .foregroundColor(message.isFromUser ? .white.opacity(0.8) : .blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(media.fileName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Text(media.formattedFileSize)
                        .font(.caption2)
                        .opacity(0.8)
                }
                
                Spacer()
            }
            .padding(.top, 4)
        }
    }
    
    @ViewBuilder
    private func documentContent(_ media: MediaContent) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(message.isFromUser ? .white.opacity(0.2) : .blue.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: media.mediaType.systemIcon)
                        .font(.title3)
                        .foregroundColor(message.isFromUser ? .white : .blue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(media.fileName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                HStack {
                    Text(media.formattedFileSize)
                        .font(.caption)
                        .opacity(0.8)
                    
                    Spacer()
                    
                    Button(action: {
                        openDocument(media)
                    }) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.caption)
                            .foregroundColor(message.isFromUser ? .white : .blue)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private var textContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(message.content)
                .font(.body)
                .multilineTextAlignment(.leading)
            
            HStack {
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if message.isFromUser {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(12)
        .background(message.isFromUser ? Color.blue : Color(UIColor.systemGray5))
        .foregroundColor(message.isFromUser ? .white : .primary)
        .cornerRadius(16)
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func openDocument(_ media: MediaContent) {
        guard let path = media.localPath,
              let url = URL(string: "file://\(path)") else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Full Image View

struct FullImageView: View {
    let mediaContent: MediaContent
    @Environment(\.presentationMode) var presentationMode
    @State private var scale: CGFloat = 1.0
    @State private var offset = CGSize.zero
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                AsyncImage(url: URL(fileURLWithPath: mediaContent.localPath ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            SimultaneousGesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        scale = value
                                    }
                                    .onEnded { _ in
                                        withAnimation(.spring()) {
                                            if scale < 1 {
                                                scale = 1
                                                offset = .zero
                                            } else if scale > 3 {
                                                scale = 3
                                            }
                                        }
                                    },
                                
                                DragGesture()
                                    .onChanged { value in
                                        offset = value.translation
                                    }
                                    .onEnded { _ in
                                        withAnimation(.spring()) {
                                            if scale <= 1 {
                                                offset = .zero
                                            }
                                        }
                                    }
                            )
                        )
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
            .navigationTitle(mediaContent.fileName)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Kapat") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white),
                
                trailing: Button(action: {
                    shareImage()
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.white)
                }
            )
        }
    }
    
    private func shareImage() {
        guard let path = mediaContent.localPath,
              let image = UIImage(contentsOfFile: path) else { return }
        
        let activityViewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityViewController, animated: true)
        }
    }
}

// MARK: - Preview

struct MediaMessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            MediaMessageBubble(message: ChatMessage(
                content: "Merhaba! Nasıl yardımcı olabilirim?",
                isFromUser: false
            ))
            
            MediaMessageBubble(message: ChatMessage(
                content: "Bir sorunum var",
                isFromUser: true
            ))
            
            MediaMessageBubble(message: ChatMessage(
                content: "",
                isFromUser: true,
                mediaContent: MediaContent(
                    fileName: "screenshot.jpg",
                    fileSize: 2048576,
                    mimeType: "image/jpeg",
                    mediaType: .image,
                    localPath: "/tmp/screenshot.jpg"
                )
            ))
            
            MediaMessageBubble(message: ChatMessage(
                content: "",
                isFromUser: false,
                mediaContent: MediaContent(
                    fileName: "manual.pdf",
                    fileSize: 1024000,
                    mimeType: "application/pdf",
                    mediaType: .document,
                    localPath: "/tmp/manual.pdf"
                )
            ))
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

//
//  LiveSupportView.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import SwiftUI

struct LiveSupportView: View {
    @ObservedObject var presenter: LiveSupportPresenter
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var lastMessageId: UUID?
    @State private var messageText = ""
    
    init(presenter: LiveSupportPresenter) {
        self.presenter = presenter
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "message.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text("Canlı Destek")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Circle()
                            .fill(presenter.isConnected ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        Text(presenter.isConnected ? "Bağlı" : "Bağlantı Kesildi")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(presenter.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if !presenter.isConversationEnded,
                               let step = presenter.currentStep,
                               let actions = step.actions {
                                ActionButtonsView(actions: actions) { action in
                                    presenter.didTapAction(action)
                                }
                                .padding(.top, 8)
                            }
                            
                            if presenter.isConversationEnded {
                                Button(action: {
                                    presenter.handleRatingAction(.reconnect)
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                        Text("Tekrar Bağlan")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: presenter.messages.count) { _ in
                        scrollToLatestMessage(proxy: proxy, newCount: presenter.messages.count)
                    }
                }
                
                Spacer()
                
                if !presenter.isConversationEnded {
                    ChatInputView(
                        messageText: $messageText,
                        onSendMessage: { message in
                            presenter.didSendTextMessage(message)
                        },
                        onSendMedia: { media in
                            presenter.didSendMediaMessage(media)
                        }
                    )
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                print("LiveSupportView appeared")
                presenter.viewDidLoad()
            }
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tamam") { }
        } message: {
            Text(errorMessage)
        }
        .onReceive(presenter.errorPublisher) { error in
            errorMessage = error
            showError = true
        }
        .overlay(
            ZStack {
                if presenter.showRatingView {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                        }
                    
                    RatingView(
                        isPresented: Binding(
                            get: { presenter.showRatingView },
                            set: { presenter.showRatingView = $0 }
                        ),
                        onAction: { action in
                            presenter.handleRatingAction(action)
                        }
                    )
                    .transition(AnyTransition.scale.combined(with: AnyTransition.opacity))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: presenter.showRatingView)
        )
    }
    
    // MARK: - Private Methods
    
    private func scrollToLatestMessage(proxy: ScrollViewProxy, newCount: Int) {
        guard newCount > 0,
              let lastMessage = presenter.messages.last,
              lastMessage.id != lastMessageId else { return }
        
        lastMessageId = lastMessage.id
        
        withAnimation(.easeInOut(duration: 0.3)) {
            proxy.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }

}

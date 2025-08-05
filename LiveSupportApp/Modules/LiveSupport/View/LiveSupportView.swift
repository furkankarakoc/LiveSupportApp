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
    
    init(presenter: LiveSupportPresenter) {
        self.presenter = presenter
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Canlı Destek")
                        .font(.title2)
                        .fontWeight(.bold)
                    
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
                            
                            if let step = presenter.currentStep,
                               let actions = step.actions {
                                ActionButtonsView(actions: actions) { action in
                                    presenter.didTapAction(action)
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: presenter.messages.count) { _ in
                        if let lastMessage = presenter.messages.last {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                Spacer()
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
    }
}

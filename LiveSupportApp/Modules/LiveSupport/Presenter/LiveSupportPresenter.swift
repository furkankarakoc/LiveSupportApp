//
//  LiveSupportPresenter.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import Foundation
import Combine

class LiveSupportPresenter: LiveSupportPresenterProtocol, LiveSupportInteractorOutputProtocol, ObservableObject {
    var view: LiveSupportViewProtocol?
    var interactor: LiveSupportInteractorInputProtocol?
    var router: LiveSupportRouterProtocol?
    
    @Published var messages: [ChatMessage] = []
    @Published var currentStep: ChatStep?
    @Published var isConnected: Bool = false
    @Published var isConversationEnded: Bool = false
    @Published var showRatingView: Bool = false
    @Published var isRatingSubmitted: Bool = false
    
    private let errorSubject = PassthroughSubject<String, Never>()
    var errorPublisher: AnyPublisher<String, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        print("LiveSupportPresenter: View did load")
        interactor?.connectWebSocket()
        interactor?.loadInitialStep()
    }
    
    func didTapAction(_ action: ChatAction) {
        print("User tapped action: \(action.text)")
        
        guard !isConversationEnded else { return }
        
        let userMessage = ChatMessage(content: action.text, isFromUser: true)
        messages.append(userMessage)
        
        interactor?.sendAction(action)
    }
    
    func didTapEndConversation() {
        print("User requested end conversation")
        isConversationEnded = true
        showRatingView = true
        interactor?.endConversation()
    }
    
    // MARK: - Message Handling
    
    func didSendTextMessage(_ text: String) {
        print("User sent text message: \(text)")
        
        guard !isConversationEnded else { return }
        
        let userMessage = ChatMessage(content: text, isFromUser: true)
        messages.append(userMessage)
        
        // WebSocket'e gönder
        let wsMessage = TextWebSocketMessage(content: text, isFromUser: true)
        interactor?.sendTextMessage(wsMessage)
    }
    
    func didSendMediaMessage(_ media: MediaContent) {
        print("User sent media message: \(media.fileName)")
        
        guard !isConversationEnded else { return }
        
        let mediaMessage = ChatMessage(
            content: media.displayContent,
            isFromUser: true,
            mediaContent: media
        )
        messages.append(mediaMessage)
        
        // WebSocket'e gönder
        let wsMessage = MediaWebSocketMessage(
            content: media.displayContent,
            mediaContent: media,
            isFromUser: true
        )
        interactor?.sendMediaMessage(wsMessage)
    }
    
    // MARK: - Rating Actions
    
    func handleRatingAction(_ action: RatingAction) {
        switch action {
        case .submit(let rating):
            print("User submitted rating: \(rating.rating) stars")
            submitRating(rating)
            
        case .reconnect:
            print("User requested reconnection")
            reconnectConversation()
        }
    }
    
    private func submitRating(_ rating: ConversationRating) {
        print("Rating submitted: \(rating.rating) stars, Feedback: \(rating.feedback ?? "None")")
        
        isRatingSubmitted = true
        
        let thankYouMessage = ChatMessage(
            content: "Puanınız için teşekkürler! Deneyiminizi sürekli iyileştirmeye çalışıyoruz.",
            isFromUser: false
        )
        messages.append(thankYouMessage)
        
    }
    
    private func reconnectConversation() {
        print("Reconnecting conversation")
        
        isConversationEnded = false
        showRatingView = false
        isRatingSubmitted = false
        messages.removeAll()
        currentStep = nil
        
        interactor?.connectWebSocket()
        interactor?.loadInitialStep()
    }
    
    // MARK: - LiveSupportInteractorOutputProtocol
    func didLoadStep(_ step: ChatStep) {
        print("Presenter: Received new step - \(step.id)")
        
        guard !isConversationEnded else { return }
        
        DispatchQueue.main.async {
            self.currentStep = step
            
            if let message = step.message {
                let botMessage = ChatMessage(content: message, isFromUser: false, step: step)
                self.messages.append(botMessage)
                print("Added bot message: \(String(message.prefix(50)))...")
            }
        }
        
        view?.showStep(step)
    }
    
    func didReceiveMessage(_ message: String) {
        print("Presenter: Received message - \(message)")
        
        if message.contains("Konuşma sonlandırıldı") {
            print("End conversation message received, showing rating view")
            isConversationEnded = true
            showRatingView = true
            return
        }
        
        guard !isConversationEnded else { return }
        
        DispatchQueue.main.async {
            let botMessage = ChatMessage(content: message, isFromUser: false)
            self.messages.append(botMessage)
        }
    }
    
    func didConnectWebSocket() {
        print("Presenter: WebSocket connected")
        DispatchQueue.main.async {
            self.isConnected = true
        }
        view?.showConnectionStatus(true)
    }
    
    func didDisconnectWebSocket() {
        print("Presenter: WebSocket disconnected")
        DispatchQueue.main.async {
            self.isConnected = false
        }
        view?.showConnectionStatus(false)
    }
    
    func didEncounterError(_ error: Error) {
        print("Presenter: Error - \(error.localizedDescription)")
        let errorMessage = error.localizedDescription
        
        DispatchQueue.main.async {
            self.errorSubject.send(errorMessage)
        }
        
        view?.showError(errorMessage)
    }
}

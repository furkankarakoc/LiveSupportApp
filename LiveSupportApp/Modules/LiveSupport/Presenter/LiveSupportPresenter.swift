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
        
        let userMessage = ChatMessage(content: action.text, isFromUser: true)
        messages.append(userMessage)
        
        interactor?.sendAction(action)
    }
    
    func didTapEndConversation() {
        print("User requested end conversation")
        interactor?.endConversation()
        router?.dismissChat()
    }
    
    // MARK: - LiveSupportInteractorOutputProtocol
    func didLoadStep(_ step: ChatStep) {
        print("Presenter: Received new step - \(step.id)")
        
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

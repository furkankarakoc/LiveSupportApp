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
        interactor?.connectWebSocket()
        interactor?.loadInitialStep()
    }
    
    func didTapAction(_ action: ChatAction) {
        let userMessage = ChatMessage(content: action.text, isFromUser: true)
        messages.append(userMessage)
        
        interactor?.sendAction(action)
    }
    
    func didTapEndConversation() {
        interactor?.endConversation()
        router?.dismissChat()
    }
    
    // MARK: - LiveSupportInteractorOutputProtocol
    func didLoadStep(_ step: ChatStep) {
        currentStep = step
        
        if let message = step.message {
            let botMessage = ChatMessage(content: message, isFromUser: false, step: step)
            messages.append(botMessage)
        }
        
        view?.showStep(step)
    }
    
    func didReceiveMessage(_ message: String) {
        let botMessage = ChatMessage(content: message, isFromUser: false)
        messages.append(botMessage)
    }
    
    func didConnectWebSocket() {
        isConnected = true
        view?.showConnectionStatus(true)
    }
    
    func didDisconnectWebSocket() {
        isConnected = false
        view?.showConnectionStatus(false)
    }
    
    func didEncounterError(_ error: Error) {
        errorSubject.send(error.localizedDescription)
        view?.showError(error.localizedDescription)
    }
}

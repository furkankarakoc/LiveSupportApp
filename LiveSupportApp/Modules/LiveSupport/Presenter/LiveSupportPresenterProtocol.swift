//
//  LiveSupportPresenterProtocol.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import Foundation

protocol LiveSupportPresenterProtocol: ObservableObject {
    var view: LiveSupportViewProtocol? { get set }
    var interactor: LiveSupportInteractorInputProtocol? { get set }
    var router: LiveSupportRouterProtocol? { get set }
    
    var messages: [ChatMessage] { get }
    var currentStep: ChatStep? { get }
    var isConnected: Bool { get }
    
    func viewDidLoad()
    func didTapAction(_ action: ChatAction)
    func didTapEndConversation()
}

protocol LiveSupportViewProtocol {
    func showStep(_ step: ChatStep)
    func showMessage(_ message: ChatMessage)
    func showConnectionStatus(_ isConnected: Bool)
    func showError(_ message: String)
}

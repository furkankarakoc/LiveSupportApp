//
//  LiveSupportInteractorProtocol.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import Foundation

protocol LiveSupportInteractorInputProtocol: AnyObject {
    var presenter: LiveSupportInteractorOutputProtocol? { get set }
    
    func loadInitialStep()
    func sendAction(_ action: ChatAction)
    func endConversation()
    func connectWebSocket()
    func disconnectWebSocket()
}

protocol LiveSupportInteractorOutputProtocol: AnyObject {
    func didLoadStep(_ step: ChatStep)
    func didReceiveMessage(_ message: String)
    func didConnectWebSocket()
    func didDisconnectWebSocket()
    func didEncounterError(_ error: Error)
}

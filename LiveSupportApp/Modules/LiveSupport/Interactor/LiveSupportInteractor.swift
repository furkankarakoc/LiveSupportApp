//
//  LiveSupportInteractor.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import Foundation

class LiveSupportInteractor: LiveSupportInteractorInputProtocol, WebSocketDelegate {
    weak var presenter: LiveSupportInteractorOutputProtocol?
    
    private let webSocketManager = WebSocketManager()
    private var chatFlow: [String: ChatStep] = [:]
    private var currentStepId = "start"
    
    init() {
        webSocketManager.delegate = self
        loadChatFlow()
    }
    
    func loadInitialStep() {
        guard let step = chatFlow[currentStepId] else {
            presenter?.didEncounterError(NSError(domain: "ChatError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Initial step not found"]))
            return
        }
        presenter?.didLoadStep(step)
    }
    
    func sendAction(_ action: ChatAction) {
        let actionData = try? JSONEncoder().encode(action)
        let actionString = actionData != nil ? String(data: actionData!, encoding: .utf8) ?? "" : ""
        
        webSocketManager.send(message: actionString)
        
        if let nextStepId = action.nextStep,
           let nextStep = chatFlow[nextStepId] {
            currentStepId = nextStepId
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.presenter?.didLoadStep(nextStep)
            }
        } else if action.type == "end_conversation" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.endConversation()
            }
        }
    }
    
    func endConversation() {
        disconnectWebSocket()
        presenter?.didReceiveMessage("Konuşma sonlandırıldı. Teşekkürler!")
    }
    
    func connectWebSocket() {
        webSocketManager.connect()
    }
    
    func disconnectWebSocket() {
        webSocketManager.disconnect()
    }
    
    private func loadChatFlow() {
        chatFlow = JSONLoader.loadChatFlow() ?? [:]
        
        if chatFlow.isEmpty {
            createSampleFlow()
        }
    }
    
    private func createSampleFlow() {
        chatFlow = [
            "start": ChatStep(
                id: "start",
                type: "welcome",
                message: "Merhaba! Size nasıl yardımcı olabilirim?",
                actions: [
                    ChatAction(id: "1", text: "Teknik Destek", type: "navigate", nextStep: "technical", payload: nil),
                    ChatAction(id: "2", text: "Satış Bilgisi", type: "navigate", nextStep: "sales", payload: nil),
                    ChatAction(id: "3", text: "Genel Sorular", type: "navigate", nextStep: "general", payload: nil)
                ],
                nextStep: nil
            ),
            "technical": ChatStep(
                id: "technical",
                type: "support",
                message: "Teknik destek için hangi konuda yardıma ihtiyacınız var?",
                actions: [
                    ChatAction(id: "4", text: "Uygulama Sorunu", type: "navigate", nextStep: "app_issue", payload: nil),
                    ChatAction(id: "5", text: "Hesap Sorunu", type: "navigate", nextStep: "account_issue", payload: nil),
                    ChatAction(id: "6", text: "Ana Menüye Dön", type: "navigate", nextStep: "start", payload: nil)
                ],
                nextStep: nil
            ),
            "sales": ChatStep(
                id: "sales",
                type: "info",
                message: "Satış ekibimizle görüşmek ister misiniz?",
                actions: [
                    ChatAction(id: "7", text: "Evet, görüşmek istiyorum", type: "navigate", nextStep: "contact_sales", payload: nil),
                    ChatAction(id: "8", text: "Hayır, teşekkürler", type: "navigate", nextStep: "start", payload: nil)
                ],
                nextStep: nil
            ),
            "general": ChatStep(
                id: "general",
                type: "info",
                message: "Genel sorularınız için size yardımcı olmaya hazırım.",
                actions: [
                    ChatAction(id: "9", text: "SSS'yi görüntüle", type: "navigate", nextStep: "faq", payload: nil),
                    ChatAction(id: "10", text: "Konuşmayı sonlandır", type: "end_conversation", nextStep: nil, payload: nil)
                ],
                nextStep: nil
            ),
            "contact_sales": ChatStep(
                id: "contact_sales",
                type: "final",
                message: "Satış ekibimiz en kısa sürede sizinle iletişime geçecek. Teşekkürler!",
                actions: [
                    ChatAction(id: "11", text: "Konuşmayı sonlandır", type: "end_conversation", nextStep: nil, payload: nil)
                ],
                nextStep: nil
            ),
            "faq": ChatStep(
                id: "faq",
                type: "info",
                message: "Sık sorulan sorular bölümüne yönlendiriliyorsunuz...",
                actions: [
                    ChatAction(id: "12", text: "Ana Menüye Dön", type: "navigate", nextStep: "start", payload: nil),
                    ChatAction(id: "13", text: "Konuşmayı sonlandır", type: "end_conversation", nextStep: nil, payload: nil)
                ],
                nextStep: nil
            ),
            "app_issue": ChatStep(
                id: "app_issue",
                type: "support",
                message: "Uygulama sorununu çözmek için lütfen uygulamayı kapatıp tekrar açmayı deneyin. Sorun devam ederse teknik ekibimiz size yardımcı olacak.",
                actions: [
                    ChatAction(id: "14", text: "Sorunu çözdü", type: "navigate", nextStep: "resolved", payload: nil),
                    ChatAction(id: "15", text: "Hala sorun var", type: "navigate", nextStep: "escalate", payload: nil),
                    ChatAction(id: "16", text: "Ana Menüye Dön", type: "navigate", nextStep: "start", payload: nil)
                ],
                nextStep: nil
            ),
            "account_issue": ChatStep(
                id: "account_issue",
                type: "support",
                message: "Hesap sorunlarınız için e-posta adresinizi doğrulayın ve şifrenizi sıfırlamayı deneyin.",
                actions: [
                    ChatAction(id: "17", text: "Sorunu çözdü", type: "navigate", nextStep: "resolved", payload: nil),
                    ChatAction(id: "18", text: "Hala sorun var", type: "navigate", nextStep: "escalate", payload: nil),
                    ChatAction(id: "19", text: "Ana Menüye Dön", type: "navigate", nextStep: "start", payload: nil)
                ],
                nextStep: nil
            ),
            "resolved": ChatStep(
                id: "resolved",
                type: "success",
                message: "Harika! Sorununuzu çözdüğümüze sevindik. Başka bir konuda yardıma ihtiyacınız var mı?",
                actions: [
                    ChatAction(id: "20", text: "Evet, başka sorum var", type: "navigate", nextStep: "start", payload: nil),
                    ChatAction(id: "21", text: "Hayır, teşekkürler", type: "end_conversation", nextStep: nil, payload: nil)
                ],
                nextStep: nil
            ),
            "escalate": ChatStep(
                id: "escalate",
                type: "escalation",
                message: "Anlıyorum. Sorununuzu üst seviye destek ekibimize yönlendiriyorum. Bir temsilcimiz 24 saat içinde sizinle iletişime geçecek.",
                actions: [
                    ChatAction(id: "22", text: "Teşekkürler", type: "end_conversation", nextStep: nil, payload: nil)
                ],
                nextStep: nil
            )
        ]
    }
    
    // MARK: - WebSocketDelegate
    func webSocketDidConnect() {
        presenter?.didConnectWebSocket()
    }
    
    func webSocketDidDisconnect() {
        presenter?.didDisconnectWebSocket()
    }
    
    func webSocketDidReceiveMessage(_ message: String) {
        
        if message.contains("Request served by") {
            return
        }
        
        if message.hasPrefix("{") && message.hasSuffix("}") {
            return
        }
        
        presenter?.didReceiveMessage(message)
    }
    
    func webSocketDidReceiveError(_ error: Error) {
        presenter?.didEncounterError(error)
    }
}

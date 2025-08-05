//
//  LiveSupportRouter.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import SwiftUI

class LiveSupportRouter: LiveSupportRouterProtocol {
    static func createModule() -> AnyView {
        let interactor = LiveSupportInteractor()
        let presenter = LiveSupportPresenter()
        let router = LiveSupportRouter()
        
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        
        return AnyView(LiveSupportView(presenter: presenter))
    }
    
    func dismissChat() {
    //Close chat
    }
}

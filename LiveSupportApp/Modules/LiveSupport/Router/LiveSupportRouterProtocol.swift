//
//  LiveSupportRouterProtocol.swift
//  LiveSupportApp
//
//  Created by furkankarakoc on 5.08.2025.
//

import SwiftUI

protocol LiveSupportRouterProtocol: AnyObject {
    static func createModule() -> AnyView
    func dismissChat()
}

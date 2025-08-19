//
//  AuthenticationService.swift
//  code-tr
//
//  Created by Faruk Kuz on 19.08.2025.
//

import Foundation
import SwiftUI

class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()
    
    @Published var isAuthenticated: Bool = false
    @Published var currentToken: String?
    
    private init() {}
    
    func login(with token: String) {
        self.currentToken = token
        self.isAuthenticated = true
    }
    
    func logout() {
        self.currentToken = nil
        self.isAuthenticated = false
    }
}

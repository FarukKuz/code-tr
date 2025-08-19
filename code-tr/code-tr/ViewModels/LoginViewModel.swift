//
//  LoginViewModel.swift
//  code-tr
//
//  Created by Faruk Kuz on 19.08.2025.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    private let authService = AuthenticationService.shared
    
    // AuthenticationService'den isAuthenticated'i okuyoruz
    var isAuthenticated: Bool {
        authService.isAuthenticated
    }
    
    func login() {
        guard !username.isEmpty && !password.isEmpty else {
            errorMessage = "Kullanıcı adı ve şifre boş olamaz."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let request = LoginRequest(username: username, password: password)
        
        Task {
            do {
                let response = try await apiService.login(request: request)
                
                await MainActor.run {
                    self.isLoading = false
                    if response.status == "success" {
                        // AuthenticationService'e login durumunu bildir
                        self.authService.login(with: response.token)
                    } else {
                        self.errorMessage = "Giriş başarısız."
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func logout() {
        authService.logout()
        username = ""
        password = ""
    }
}

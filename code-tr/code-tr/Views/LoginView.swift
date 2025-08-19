//
//  LoginView.swift
//  code-tr
//
//  Created by Faruk Kuz on 18.08.2025.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @StateObject private var authService = AuthenticationService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                // Logo
                Image(systemName: "key.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.primary)
                
                Text("Admin Girişi")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
                
                // Giriş formu
                VStack(spacing: 16) {
                    TextField("Kullanıcı Adı", text: $viewModel.username)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    SecureField("Şifre", text: $viewModel.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Button("Giriş Yap") {
                            viewModel.login()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                    }
                    
                    // Hata mesajı
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                .padding()
                
                Spacer()
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationTitle("Giriş")
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    LoginView()
}

//
//  MainView.swift
//  code-tr
//
//  Created by Faruk Kuz on 19.08.2025.
//

import SwiftUI

struct MainView: View {
    @StateObject private var authService = AuthenticationService.shared
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                FleetView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut, value: authService.isAuthenticated)
    }
}

#Preview {
    MainView()
}

//
//  FleetView.swift
//  code-tr
//
//  Created by Faruk Kuz on 18.08.2025.
//

import SwiftUI

struct FleetView: View {
    @StateObject private var viewModel = FleetViewModel()
    @ObservedObject private var userContext = UserContextService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with user info, time, stats, search and filters
                FleetHeaderView(viewModel: viewModel)
                
                // Main content
                if viewModel.isLoading && viewModel.simCards.isEmpty {
                    LoadingView()
                } else if viewModel.filteredSimCards.isEmpty {
                    EmptyStateView(
                        title: "SIM Kart Bulunamadı",
                        message: viewModel.simCards.isEmpty ?
                            "Henüz hiç SIM kart yok" :
                            "Arama kriterlerinize uygun SIM kart bulunamadı",
                        actionTitle: viewModel.simCards.isEmpty ? "Yenile" : "Filtreleri Temizle",
                        action: viewModel.simCards.isEmpty ?
                            viewModel.loadFleet :
                            clearFilters
                    )
                } else {
                    SIMCardList(viewModel: viewModel)
                }
            }
            .navigationTitle("IoT Yönetimi")
            .navigationBarTitleDisplayMode(.inline) // inline'a çevirdim header'ın görünmesi için
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Yenile") {
                        viewModel.loadFleet()
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .alert("Hata", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("Tamam") {
                    viewModel.clearMessages()
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .alert("Başarılı", isPresented: .constant(viewModel.successMessage != nil)) {
                Button("Tamam") {
                    viewModel.clearMessages()
                }
            } message: {
                Text(viewModel.successMessage ?? "")
            }
            .refreshable {
                viewModel.loadFleet()
            }
        }
    }
    
    private func clearFilters() {
        viewModel.searchText = ""
        viewModel.selectedStatus = nil
        viewModel.selectedCity = nil
        viewModel.selectedRiskLevel = nil
    }
}

#Preview {
    FleetView()
}

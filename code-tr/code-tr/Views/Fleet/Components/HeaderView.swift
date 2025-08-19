//
//  HeaderView.swift
//  code-tr
//
//  Created by Faruk Kuz on 19.08.2025.
//

import SwiftUI

struct HeaderView: View {
    @ObservedObject var viewModel: FleetViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("SIM ID, Cihaz Tipi veya Şehir ara...", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !viewModel.searchText.isEmpty {
                    Button("Temizle") {
                        viewModel.searchText = ""
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Status Filter
                    Menu {
                        Button("Tümü") {
                            viewModel.selectedStatus = nil
                        }
                        
                        ForEach(SIMStatus.allCases, id: \.self) { status in
                            Button(status.displayName) {
                                viewModel.selectedStatus = status
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.selectedStatus?.displayName ?? "Durum")
                            Image(systemName: "chevron.down")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // City Filter
                    Menu {
                        Button("Tüm Şehirler") {
                            viewModel.selectedCity = nil
                        }
                        
                        ForEach(viewModel.availableCities, id: \.self) { city in
                            Button(city) {
                                viewModel.selectedCity = city
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.selectedCity ?? "Şehir")
                            Image(systemName: "chevron.down")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}

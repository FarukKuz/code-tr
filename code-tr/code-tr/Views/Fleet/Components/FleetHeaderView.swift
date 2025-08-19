//
//  FleetHeaderView.swift
//  code-tr
//
//  Created by Faruk Kuz on 18.08.2025.
//

import SwiftUI

struct FleetHeaderView: View {
    @ObservedObject var viewModel: FleetViewModel
    @ObservedObject var userContext = UserContextService.shared
    
    var body: some View {
        VStack(spacing: 12) {
            // User and Time Info Bar
            HStack {
                // User Info
                HStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.blue)
                    Text(userContext.currentUser)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Current Time (UTC)
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.gray)
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(userContext.currentDateTime)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .monospacedDigit()
                        Text("UTC")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Fleet Statistics Overview
            FleetStatsRow(viewModel: viewModel)
            
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
                    
                    // Risk Filter
                    Menu {
                        Button("Tüm Risk Seviyesi") {
                            viewModel.selectedRiskLevel = nil
                        }
                        
                        ForEach(RiskLevel.allCases, id: \.self) { risk in
                            Button(risk.displayName) {
                                viewModel.selectedRiskLevel = risk
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.selectedRiskLevel?.displayName ?? "Risk")
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
        .shadow(color: .gray.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}

struct FleetStatsRow: View {
    @ObservedObject var viewModel: FleetViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            StatCard(
                title: "Toplam SIM",
                value: "\(viewModel.simCards.count)",
                icon: "sim",
                color: .blue
            )
            
            StatCard(
                title: "Aktif",
                value: "\(viewModel.activeCount)",
                icon: "checkmark.circle.fill",
                color: .green
            )
            
            StatCard(
                title: "Yüksek Risk",
                value: "\(viewModel.highRiskCount)",
                icon: "exclamationmark.triangle.fill",
                color: .red
            )
            
            StatCard(
                title: "Anomali",
                value: "\(viewModel.anomalyCount)",
                icon: "waveform.path.ecg",
                color: .orange
            )
        }
        .padding(.horizontal)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

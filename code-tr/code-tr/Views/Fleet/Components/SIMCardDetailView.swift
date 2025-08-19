//
//  SIMCardDetailView.swift
//  code-tr
//
//  Created by Faruk Kuz on 18.08.2025.
//

import SwiftUI

struct SIMCardDetailView: View {
    let simCard: SIMCard
    let isLoading: Bool
    let onActionSelected: (BulkAction) -> Void
    let onViewTimeSeriesRequested: () -> Void
    @State private var showingActionConfirmation = false
    @State private var selectedAction: BulkAction?
    @State private var actionState: SIMActionState?
    @State private var timeRemaining: String = ""
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 16) {
            Divider()
            
            // Active Action Status (if any)
            if let activeAction = actionState?.currentAction, activeAction.isActive {
                ActiveActionBanner(activeAction: activeAction, timeRemaining: timeRemaining)
            }
            
            // Detay Bilgileri - 3 Sütun
            VStack(alignment: .leading, spacing: 12) {
                Text("SIM Detayları")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    DetailInfoCard(title: "SIM ID", value: String(simCard.simId))
                    DetailInfoCard(title: "Müşteri ID", value: String(simCard.customerId))
                    DetailInfoCard(title: "Cihaz Tipi", value: simCard.deviceType)
                    DetailInfoCard(title: "APN", value: simCard.apn)
                    DetailInfoCard(title: "Durum", value: simCard.status.displayName)
                    DetailInfoCard(title: "Şehir", value: simCard.city)
                }
            }
            
            // Plan Bilgileri - 3 Sütun
            if let plan = simCard.plan {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Plan Detayları")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        DetailInfoCard(title: "Plan Adı", value: plan.planName)
                        DetailInfoCard(title: "Aylık Kota", value: "\(plan.monthlyQuotaMb) MB")
                        DetailInfoCard(title: "Aylık Fiyat", value: String(format: "%.2f ₺", plan.monthlyPrice))
                        DetailInfoCard(title: "Plan APN", value: plan.apn)
                        DetailInfoCard(title: "Aşım Ücreti", value: String(format: "%.3f ₺/MB", plan.overagePerMb))
                        DetailInfoCard(title: "Plan ID", value: String(plan.planId))
                    }
                }
            }
            
            // Device Profile Bilgileri - 3 Sütun
            if let profile = simCard.deviceProfile {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Cihaz Profili")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        DetailInfoCard(title: "Cihaz Tipi", value: profile.deviceType)
                        DetailInfoCard(title: "Günlük Min", value: "\(profile.expectedDailyMbMin) MB")
                        DetailInfoCard(title: "Günlük Max", value: "\(profile.expectedDailyMbMax) MB")
                        DetailInfoCard(title: "Roaming Beklentisi", value: profile.roamingExpected ? "Evet" : "Hayır")
                        DetailInfoCard(title: "Ortalama Kullanım", value: "\((profile.expectedDailyMbMin + profile.expectedDailyMbMax) / 2) MB")
                        DetailInfoCard(title: "Varyasyon", value: "\(profile.expectedDailyMbMax - profile.expectedDailyMbMin) MB")
                    }
                }
            }
            
            // Eylem Butonları
            VStack(alignment: .leading, spacing: 8) {
                Text("Yapılabilecek İşlemler")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if isLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("İşlem yapılıyor...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        // Zaman Serisi Butonu
                        ActionButton(
                            title: "Son 30 Gün Verisi",
                            subtitle: "Saatlik/Günlük MB",
                            icon: "chart.line.uptrend.xyaxis",
                            color: .blue
                        ) {
                            onViewTimeSeriesRequested()
                        }
                        
                        // Anomali Analizi
                        ActionButton(
                            title: "Anomali Analizi",
                            subtitle: "Risk & Detay",
                            icon: "waveform.path.ecg",
                            color: .orange
                        ) {
                            // TODO: Anomali analizi
                        }
                        
                        // What-If Analizi
                        ActionButton(
                            title: "Maliyet Analizi",
                            subtitle: "What-If",
                            icon: "dollarsign.circle",
                            color: .green
                        ) {
                            // TODO: What-if analizi
                        }
                        
                        // Eylem Önerileri
                        ActionButton(
                            title: "Eylem Önerileri",
                            subtitle: "AI Tavsiye",
                            icon: "brain.head.profile",
                            color: .purple
                        ) {
                            // TODO: Action recommendations
                        }
                    }
                    
                    // Action Buttons - Check if blocked by active action
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(BulkAction.allCases, id: \.self) { action in
                            let isDisabled = isActionDisabled(action)
                            
                            SingleActionButton(
                                action: action,
                                isDisabled: isDisabled
                            ) {
                                if !isDisabled {
                                    selectedAction = action
                                    showingActionConfirmation = true
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
        .onAppear {
            loadActionState()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .confirmationDialog(
            "İşlem Onayı",
            isPresented: $showingActionConfirmation,
            titleVisibility: .visible
        ) {
            if let action = selectedAction {
                Button(action.displayName) {
                    onActionSelected(action)
                }
                
                Button("İptal", role: .cancel) {}
            }
        } message: {
            if let action = selectedAction {
                Text("SIM #\(simCard.simId) için \(action.description)")
            }
        }
    }
    
    private func isActionDisabled(_ action: BulkAction) -> Bool {
        guard let activeAction = actionState?.currentAction, activeAction.isActive else {
            return false
        }
        
        // If SIM is frozen, only allow unfreeze-like actions
        if activeAction.action == .freeze {
            return action != .notify // Only allow notifications when frozen
        }
        
        return false
    }
    
    private func loadActionState() {
        // Mock action state - replace with API call
        if simCard.simId == 2001 { // Example: SIM 2001 is frozen
            let startTime = ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3600)) // 1 hour ago
            let endTime = ISO8601DateFormatter().string(from: Date().addingTimeInterval(23 * 3600)) // 23 hours from now
            
            actionState = SIMActionState(
                simId: simCard.simId,
                currentAction: ActiveAction(
                    actionType: BulkAction.freeze.rawValue,
                    startTime: startTime,
                    endTime: endTime,
                    reason: "Anormal kullanım tespit edildi",
                    actor: "FarukKuz"
                ),
                history: []
            )
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTimeRemaining()
        }
        updateTimeRemaining()
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTimeRemaining() {
        guard let activeAction = actionState?.currentAction, activeAction.isActive else {
            timeRemaining = ""
            return
        }
        
        let remaining = activeAction.timeRemaining
        if remaining > 0 {
            let hours = Int(remaining) / 3600
            let minutes = Int(remaining) % 3600 / 60
            let seconds = Int(remaining) % 60
            timeRemaining = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            timeRemaining = "00:00:00"
            // Action expired, reload state
            loadActionState()
        }
    }
}

struct ActiveActionBanner: View {
    let activeAction: ActiveAction
    let timeRemaining: String
    
    var body: some View {
        HStack {
            Image(systemName: activeAction.action?.icon ?? "clock.fill")
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activeAction.action?.displayName ?? "Aktif İşlem")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Kalan süre: \(timeRemaining)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("Uygulayan:")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(activeAction.actor)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.orange)
        .cornerRadius(8)
    }
}

struct ActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct SingleActionButton: View {
    let action: BulkAction
    let isDisabled: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Image(systemName: action.icon)
                    .font(.title3)
                    .foregroundColor(isDisabled ? .gray : .white)
                
                Text(action.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isDisabled ? .gray : .white)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isDisabled ? Color.gray.opacity(0.3) : actionColor)
            .cornerRadius(6)
        }
        .disabled(isDisabled)
    }
    
    private var actionColor: Color {
        switch action {
        case .freeze: return .orange
        case .throttle: return .yellow
        case .block: return .red
        case .notify: return .blue
        case .activate: return .green
        }
    }
}

// BulkAction'a icon property'si ekleyelim
extension BulkAction {
    var icon: String {
        switch self {
        case .freeze: return "snowflake"
        case .throttle: return "speedometer"
        case .block: return "xmark.shield"
        case .notify: return "bell"
        case .activate: return "checkmark"
        }
    }
}

struct DetailInfoCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(2)
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(6)
        .frame(minHeight: 50)
    }
}

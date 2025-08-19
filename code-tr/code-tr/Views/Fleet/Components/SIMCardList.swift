//
//  SIMCardList.swift
//  code-tr
//
//  Created by Faruk Kuz on 19.08.2025.
//

import SwiftUI

struct SIMCardList: View {
    @ObservedObject var viewModel: FleetViewModel
    @State private var showingTimeSeriesView = false
    @State private var selectedSimForTimeSeries: SIMCard?
    
    var body: some View {
        List {
            ForEach(viewModel.filteredSimCards) { simCard in
                VStack(spacing: 0) {
                    // Ana SIM Card Row
                    SIMCardRowView(
                        simCard: simCard,
                        isSelected: viewModel.selectedSimId == simCard.simId,
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.toggleSimCardSelection(simCard.simId)
                            }
                        }
                    )
                    
                    // Genişletilmiş Detail Area
                    if viewModel.expandedSimId == simCard.simId {
                        EnhancedSIMDetailView(
                            simCard: simCard,
                            isLoading: viewModel.isLoading,
                            onActionSelected: { action in
                                viewModel.performSingleAction(
                                    action,
                                    for: simCard.simId,
                                    reason: "user_action_\(action.rawValue)_by_FarukKuz_at_2025-08-19_01:20:40"
                                )
                            },
                            onViewTimeSeriesRequested: {
                                selectedSimForTimeSeries = simCard
                                showingTimeSeriesView = true
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        ))
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
        .background(TurkcellColors.light)
        .sheet(isPresented: $showingTimeSeriesView) {
            if let simCard = selectedSimForTimeSeries {
                TimeSeriesView(simCard: simCard)
            }
        }
    }
}

// MARK: - SIM Card Row (unchanged)
struct SIMCardRowView: View {
    let simCard: SIMCard
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                // SIM ID and Device Type
                HStack {
                    Text("SIM #\(simCard.simId)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(TurkcellColors.dark)
                    
                    Spacer()
                    
                    Text(simCard.deviceType)
                        .font(.caption)
                        .foregroundColor(TurkcellColors.secondary)
                        .fontWeight(.medium)
                }
                
                // Status and City
                HStack {
                    SIMStatusBadge(status: simCard.status)
                    
                    Text("•")
                        .foregroundColor(TurkcellColors.dark.opacity(0.3))
                    
                    Text(simCard.city)
                        .font(.caption)
                        .foregroundColor(TurkcellColors.dark.opacity(0.7))
                    
                    Spacer()
                    
                    SIMCustomerIndicator(customerId: simCard.customerId)
                }
                
                // Plan and APN
                HStack {
                    Text(simCard.plan?.planName ?? "Plan bilgisi yok")
                        .font(.caption)
                        .foregroundColor(TurkcellColors.dark.opacity(0.6))
                    
                    Spacer()
                    
                    Text(simCard.apn)
                        .font(.caption)
                        .foregroundColor(TurkcellColors.secondary.opacity(0.8))
                        .fontWeight(.medium)
                }
            }
            
            // Expand/Collapse Icon
            Image(systemName: isSelected ? "chevron.up" : "chevron.down")
                .foregroundColor(TurkcellColors.primary)
                .font(.caption)
                .fontWeight(.bold)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? TurkcellColors.primary.opacity(0.1) : Color.white)
                .shadow(color: TurkcellColors.dark.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}

// MARK: - Enhanced SIM Detail View with Dynamic Actions
struct EnhancedSIMDetailView: View {
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
        VStack(spacing: 20) {
            // Active Action Status Banner
            if let activeAction = actionState?.currentAction, activeAction.isActive {
                ActiveSIMActionBanner(activeAction: activeAction, timeRemaining: timeRemaining)
            }
            
            // SIM Details - 3 Column Grid
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "SIM Detayları", icon: "sim")
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    SIMDetailCard(title: "SIM ID", value: String(simCard.simId))
                    SIMDetailCard(title: "Müşteri ID", value: String(simCard.customerId))
                    SIMDetailCard(title: "Cihaz Tipi", value: simCard.deviceType)
                    SIMDetailCard(title: "APN", value: simCard.apn)
                    SIMDetailCard(title: "Durum", value: simCard.status.displayName)
                    SIMDetailCard(title: "Şehir", value: simCard.city)
                }
            }
            
            // Plan Details - 3 Column Grid
            if let plan = simCard.plan {
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Plan Detayları", icon: "doc.text")
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                        SIMDetailCard(title: "Plan Adı", value: plan.planName)
                        SIMDetailCard(title: "Aylık Kota", value: "\(plan.monthlyQuotaMb) MB")
                        SIMDetailCard(title: "Aylık Fiyat", value: String(format: "%.2f ₺", plan.monthlyPrice))
                        SIMDetailCard(title: "Plan APN", value: plan.apn)
                        SIMDetailCard(title: "Aşım Ücreti", value: String(format: "%.3f ₺/MB", plan.overagePerMb))
                        SIMDetailCard(title: "Plan ID", value: String(plan.planId))
                    }
                }
            }
            
            // Device Profile - 3 Column Grid
            if let profile = simCard.deviceProfile {
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Cihaz Profili", icon: "cpu")
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                        SIMDetailCard(title: "Cihaz Tipi", value: profile.deviceType)
                        SIMDetailCard(title: "Günlük Min", value: "\(profile.expectedDailyMbMin) MB")
                        SIMDetailCard(title: "Günlük Max", value: "\(profile.expectedDailyMbMax) MB")
                        SIMDetailCard(title: "Roaming", value: profile.roamingExpected ? "Evet" : "Hayır")
                        SIMDetailCard(title: "Ortalama", value: "\((profile.expectedDailyMbMin + profile.expectedDailyMbMax) / 2) MB")
                        SIMDetailCard(title: "Varyasyon", value: "\(profile.expectedDailyMbMax - profile.expectedDailyMbMin) MB")
                    }
                }
            }
            
            // Analysis Buttons
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Analiz ve Veriler", icon: "chart.bar")
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    SIMAnalysisButton(
                        title: "Son 30 Gün Verisi",
                        subtitle: "Saatlik/Günlük MB",
                        iconName: "chart.line.uptrend.xyaxis",
                        buttonColor: TurkcellColors.info,
                        action: onViewTimeSeriesRequested
                    )
                    
                    SIMAnalysisButton(
                        title: "Anomali Analizi",
                        subtitle: "Risk & Detay",
                        iconName: "waveform.path.ecg",
                        buttonColor: TurkcellColors.warning,
                        action: {
                            // TODO: Anomali analizi
                        }
                    )
                    
                    SIMAnalysisButton(
                        title: "Maliyet Analizi",
                        subtitle: "What-If",
                        iconName: "dollarsign.circle",
                        buttonColor: TurkcellColors.success,
                        action: {
                            // TODO: What-if analizi
                        }
                    )
                    
                    SIMAnalysisButton(
                        title: "Eylem Önerileri",
                        subtitle: "AI Tavsiye",
                        iconName: "brain.head.profile",
                        buttonColor: TurkcellColors.secondary,
                        action: {
                            // TODO: Action recommendations
                        }
                    )
                }
            }
            
            // Dynamic Action Buttons
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Yapılabilecek İşlemler", icon: "gearshape")
                
                if isLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(TurkcellColors.primary)
                        Text("İşlem yapılıyor...")
                            .font(.caption)
                            .foregroundColor(TurkcellColors.dark.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    // DİNAMİK BUTONLAR - SIM durumuna göre değişir
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                        ForEach(getAvailableActions(for: simCard), id: \.self) { action in
                            let isDisabled = isActionDisabled(action)
                            
                            SIMActionButton(
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
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: TurkcellColors.dark.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 8)
        .onAppear {
            loadActionState()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .confirmationDialog(
            selectedAction?.displayName ?? "İşlem Onayı",
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
                Text("SIM #\(simCard.simId) için \"\(action.displayName)\" işlemi gerçekleştirilecek.\n\nAçıklama: \(action.description)")
            }
        }
    }
    
    // DİNAMİK BUTON MANTAĞI - SIM durumuna göre farklı butonlar
    private func getAvailableActions(for simCard: SIMCard) -> [BulkAction] {
        var actions: [BulkAction] = []
        
        // Aktif action varsa sadece notify'a izin ver
        if let activeAction = actionState?.currentAction, activeAction.isActive {
            return [.notify]
        }
        
        // SIM durumuna göre mevcut butonları belirle
        switch simCard.status {
        case .active:
            // Aktif SIM için: Dondur, Hızı Sınırla, Engelle, Bildirim
            actions = [.freeze, .throttle, .block, .notify]
            
        case .blocked:
            // Engelli SIM için: Aktifleştir, Bildirim
            actions = [.activate, .notify]
            
        default:
            // Diğer durumlar (frozen vs) için: Aktifleştir, Bildirim
            actions = [.activate, .notify]
        }
        
        return actions
    }
    
    private func isActionDisabled(_ action: BulkAction) -> Bool {
        // Aktif action varsa sadece notify aktif
        if let activeAction = actionState?.currentAction, activeAction.isActive {
            return action != .notify
        }
        
        return false
    }
    
    private func loadActionState() {
        // Current UTC time: 2025-08-19 01:20:40
        // Current User: FarukKuz
        // Mock: SIM 2001 is frozen - 1 hour ago başladı, 22 saat 39 dakika kaldı
        if simCard.simId == 2001 {
            let startTime = "2025-08-19 00:20:40" // 1 saat önce başladı
            let endTime = "2025-08-20 00:20:40"   // 22 saat 39 dakika kaldı
            
            actionState = SIMActionState(
                simId: simCard.simId,
                currentAction: ActiveAction(
                    actionType: BulkAction.freeze.rawValue,
                    startTime: startTime,
                    endTime: endTime,
                    reason: "Anormal kullanım tespit edildi - User: FarukKuz, Time: 2025-08-19 01:20:40 UTC",
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
        guard let activeAction = actionState?.currentAction else {
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
            actionState = nil
        }
    }
}

// MARK: - Supporting Views (unchanged)
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(TurkcellColors.primary)
                .font(.system(size: 16, weight: .semibold))
            
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(TurkcellColors.dark)
            
            Spacer()
        }
    }
}

struct ActiveSIMActionBanner: View {
    let activeAction: ActiveAction
    let timeRemaining: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: activeAction.action?.actionIcon ?? "clock.fill")
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .semibold))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activeAction.action?.displayName ?? "Aktif İşlem")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Kalan süre: \(timeRemaining)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Uygulayan:")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(activeAction.actor)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(TurkcellColors.warning)
        )
    }
}

struct SIMAnalysisButton: View {
    let title: String
    let subtitle: String
    let iconName: String
    let buttonColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(buttonColor)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(TurkcellColors.dark)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(TurkcellColors.dark.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(buttonColor.opacity(0.3), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SIMActionButton: View {
    let action: BulkAction
    let isDisabled: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Image(systemName: action.actionIcon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isDisabled ? TurkcellColors.dark.opacity(0.3) : .white)
                
                Text(action.displayName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isDisabled ? TurkcellColors.dark.opacity(0.3) : .white)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isDisabled ? TurkcellColors.light : action.buttonColor)
            )
        }
        .disabled(isDisabled)
        .buttonStyle(PlainButtonStyle())
    }
}

struct SIMCustomerIndicator: View {
    let customerId: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "person.fill")
                .foregroundColor(TurkcellColors.secondary)
                .font(.caption)
            
            Text("Müşteri #\(customerId)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(TurkcellColors.secondary)
        }
    }
}

struct SIMDetailCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(TurkcellColors.dark.opacity(0.6))
            
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(TurkcellColors.dark)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 50)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(TurkcellColors.light)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(TurkcellColors.primary.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct SIMStatusBadge: View {
    let status: SIMStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(status.badgeColor)
            )
            .foregroundColor(.white)
    }
}

//
//  FleetViewModel.swift
//  code-tr
//
//  Created by Faruk Kuz on 18.08.2025.
//

import Foundation
import Combine

class FleetViewModel: ObservableObject {
    @Published var simCards: [SIMCard] = []
    @Published var filteredSimCards: [SIMCard] = []
    @Published var selectedSimId: Int?
    @Published var searchText: String = ""
    @Published var selectedStatus: SIMStatus?
    @Published var selectedCity: String?
    @Published var selectedRiskLevel: RiskLevel? // Yeni filter
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var expandedSimId: Int?
    @Published var successMessage: String?
    
    // Risk assessments cache
    @Published var riskAssessments: [Int: RiskAssessment] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService = APIService.shared
    private let userContext = UserContextService.shared
    
    var availableCities: [String] {
        Array(Set(simCards.map(\.city))).sorted()
    }
    
    var selectedSimCard: SIMCard? {
        guard let selectedSimId = selectedSimId else { return nil }
        return simCards.first { $0.simId == selectedSimId }
    }
    
    // Fleet Statistics
    var activeCount: Int {
        simCards.filter { $0.status == .active }.count
    }
    
    var highRiskCount: Int {
        riskAssessments.values.filter { $0.riskLevel == .high }.count
    }
    
    var anomalyCount: Int {
        riskAssessments.values.reduce(0) { $0 + $1.anomalyCount }
    }
    
    init() {
        setupSearchAndFilter()
        loadFleet()
        loadRiskAssessments()
    }
    
    private func setupSearchAndFilter() {
        Publishers.CombineLatest4($searchText, $selectedStatus, $selectedCity, $selectedRiskLevel)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchText, status, city, risk in
                self?.filterSimCards(searchText: searchText, status: status, city: city, riskLevel: risk)
            }
            .store(in: &cancellables)
    }
    
    func loadFleet() {
        isLoading = true
        errorMessage = nil
        
        apiService.getFleetPublisher()
            .sink(
                receiveCompletion: { [weak self] completion in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        if case .failure(let error) = completion {
                            self?.errorMessage = "Filo verileri yüklenirken hata oluştu: \(error.localizedDescription)"
                        }
                    }
                },
                receiveValue: { [weak self] simCards in
                    DispatchQueue.main.async {
                        self?.simCards = simCards
                        self?.filterSimCards(
                            searchText: self?.searchText ?? "",
                            status: self?.selectedStatus,
                            city: self?.selectedCity,
                            riskLevel: self?.selectedRiskLevel
                        )
                        self?.loadRiskAssessments()
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func loadRiskAssessments() {
        for simCard in simCards {
            Task {
                do {
                    let response = try await apiService.getRiskAssessment(simId: simCard.simId)
                    if let riskAssessment = response.data {
                        DispatchQueue.main.async {
                            self.riskAssessments[simCard.simId] = riskAssessment
                        }
                    }
                } catch {
                    print("Risk assessment failed for SIM \(simCard.simId): \(error)")
                }
            }
        }
    }
    
    private func filterSimCards(searchText: String, status: SIMStatus?, city: String?, riskLevel: RiskLevel?) {
        var filtered = simCards
        
        if !searchText.isEmpty {
            filtered = filtered.filter { simCard in
                String(simCard.simId).localizedCaseInsensitiveContains(searchText) ||
                simCard.deviceType.localizedCaseInsensitiveContains(searchText) ||
                simCard.city.localizedCaseInsensitiveContains(searchText) ||
                (simCard.plan?.planName ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let status = status {
            filtered = filtered.filter { $0.status == status }
        }
        
        if let city = city {
            filtered = filtered.filter { $0.city == city }
        }
        
        if let riskLevel = riskLevel {
            filtered = filtered.filter { simCard in
                riskAssessments[simCard.simId]?.riskLevel == riskLevel
            }
        }
        
        filteredSimCards = filtered
        
        if let selectedId = selectedSimId,
           !filtered.contains(where: { $0.simId == selectedId }) {
            selectedSimId = nil
            expandedSimId = nil
        }
    }
    
    func toggleSimCardSelection(_ simId: Int) {
        if selectedSimId == simId {
            selectedSimId = nil
            expandedSimId = nil
        } else {
            selectedSimId = simId
            expandedSimId = simId
        }
    }
    
    func performSingleAction(_ action: BulkAction, for simId: Int, reason: String) {
        let request = BulkActionRequest(
            simIds: [simId],
            action: action.rawValue,
            reason: reason,
            actor: userContext.currentUser // Current user'ı kullan
        )
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        apiService.performBulkActionPublisher(request)
            .sink(
                receiveCompletion: { [weak self] completion in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        if case .failure(let error) = completion {
                            self?.errorMessage = "İşlem başarısız: \(error.localizedDescription)"
                        }
                    }
                },
                receiveValue: { [weak self] response in
                    DispatchQueue.main.async {
                        if response.status {
                            self?.successMessage = response.messages.first ?? "İşlem başarıyla tamamlandı"
                            self?.selectedSimId = nil
                            self?.expandedSimId = nil
                            self?.loadFleet()
                        } else {
                            self?.errorMessage = response.messages.first ?? "Bilinmeyen bir hata oluştu"
                        }
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func getRiskAssessment(for simId: Int) -> RiskAssessment? {
        return riskAssessments[simId]
    }
    
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}

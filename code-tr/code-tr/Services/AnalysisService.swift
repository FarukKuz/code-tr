//
//  AnalysisService.swift
//  code-tr
//
//  Created by Faruk Kuz on 18.08.2025.
//

import Foundation
import Combine

extension APIService {
    
    // MARK: - Risk Assessment
    func getRiskAssessment(simId: Int) async throws -> APIResponse<RiskAssessment> {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        let riskFactors = [
            RiskFactor(
                type: "usage_spike",
                impact: 0.8,
                description: "Son 24 saatte %400 artış"
            ),
            RiskFactor(
                type: "unexpected_roaming",
                impact: 0.6,
                description: "Beklenmeyen roaming aktivitesi"
            )
        ]
        
        let riskAssessment = RiskAssessment(
            simId: simId,
            riskLevel: .high,
            riskScore: 0.75,
            anomalyCount: 3,
            lastCalculated: ISO8601DateFormatter().string(from: Date()),
            factors: riskFactors
        )
        
        return APIResponse(
            status: true,
            messages: ["Risk analizi başarıyla tamamlandı"],
            code: 200,
            data: riskAssessment
        )
    }
    
    // MARK: - Anomaly Detection
    func getAnomalyDetection(simId: Int) async throws -> APIResponse<AnomalyDetection> {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        let evidence = AnomalyEvidence(
            baselineValue: 150.0,
            currentValue: 600.0,
            deviationPercentage: 300.0,
            comparisonPeriod: "Son 7 gün ortalaması",
            dataPoints: [
                EvidenceDataPoint(timestamp: "2025-08-18T20:00:00Z", value: 580.0, isAnomalous: true),
                EvidenceDataPoint(timestamp: "2025-08-18T21:00:00Z", value: 620.0, isAnomalous: true),
                EvidenceDataPoint(timestamp: "2025-08-18T22:00:00Z", value: 600.0, isAnomalous: true)
            ]
        )
        
        let anomalies = [
            DetailedAnomaly(
                type: .suddenSpike,
                severity: .critical,
                timestamp: "2025-08-18T20:00:00Z",
                endTimestamp: "2025-08-18T23:00:00Z",
                description: "Son 3 saatte veri kullanımında %300 artış tespit edildi",
                evidence: evidence,
                recommendation: "SIM kartını geçici olarak dondurun ve müşteriyle iletişime geçin",
                affectedMetrics: ["mb_used", "hourly_usage"]
            ),
            DetailedAnomaly(
                type: .unexpectedRoaming,
                severity: .high,
                timestamp: "2025-08-18T15:00:00Z",
                endTimestamp: nil,
                description: "Cihaz profili roaming beklemiyor ancak 50MB roaming kullanımı tespit edildi",
                evidence: AnomalyEvidence(
                    baselineValue: 0.0,
                    currentValue: 50.0,
                    deviationPercentage: 100.0,
                    comparisonPeriod: "Cihaz profili beklentisi",
                    dataPoints: []
                ),
                recommendation: "Roaming ayarlarını kontrol edin",
                affectedMetrics: ["roaming_mb"]
            )
        ]
        
        let detection = AnomalyDetection(
            simId: simId,
            anomalies: anomalies,
            totalAnomalies: anomalies.count,
            criticalCount: anomalies.filter { $0.severity == .critical }.count,
            analysisTimestamp: ISO8601DateFormatter().string(from: Date())
        )
        
        return APIResponse(
            status: true,
            messages: ["Anomali analizi tamamlandı"],
            code: 200,
            data: detection
        )
    }
    
    // MARK: - Time Series Data
    func getTimeSeriesData(simId: Int, period: TimePeriod, days: Int = 30) async throws -> APIResponse<TimeSeriesData> {
        try await Task.sleep(nanoseconds: 600_000_000)
        
        var dataPoints: [TimeSeriesPoint] = []
        let calendar = Calendar.current
        let now = Date()
        
        for i in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                let timestamp = ISO8601DateFormatter().string(from: date)
                
                // Simulate anomaly on recent days
                let isAnomaly = i < 3 && Int.random(in: 1...10) > 7
                let baseUsage = Double.random(in: 100...200)
                let anomalyMultiplier = isAnomaly ? Double.random(in: 3...5) : 1.0
                
                dataPoints.append(TimeSeriesPoint(
                    timestamp: timestamp,
                    mbUsed: baseUsage * anomalyMultiplier,
                    roamingMb: Double.random(in: 0...20),
                    smsCount: Int.random(in: 0...5),
                    isAnomaly: isAnomaly,
                    anomalyTypes: isAnomaly ? [.suddenSpike] : []
                ))
            }
        }
        
        let summary = TimeSeriesSummary(
            totalMB: dataPoints.reduce(0) { $0 + $1.mbUsed },
            averageDailyMB: dataPoints.map(\.mbUsed).reduce(0, +) / Double(dataPoints.count),
            peakDayMB: dataPoints.map(\.mbUsed).max() ?? 0,
            anomalyDays: dataPoints.filter(\.isAnomaly).count,
            roamingDays: dataPoints.filter { $0.roamingMb > 0 }.count,
            inactiveDays: dataPoints.filter { $0.mbUsed < 5 }.count
        )
        
        let timeSeriesData = TimeSeriesData(
            simId: simId,
            period: period,
            dataPoints: dataPoints.reversed(),
            summary: summary
        )
        
        return APIResponse(
            status: true,
            messages: ["Zaman serisi verisi alındı"],
            code: 200,
            data: timeSeriesData
        )
    }
    
    // MARK: - Action Recommendations kısmını güncelleyin
    func getActionRecommendations(simId: Int) async throws -> APIResponse<ActionRecommendation> {
        try await Task.sleep(nanoseconds: 700_000_000)
        
        let recommendedActions = [
            RecommendedAction(
                actionType: BulkAction.freeze.rawValue, // String olarak sakla
                confidence: 0.9,
                expectedImpact: "Kullanım %100 azalacak",
                risks: ["Servis kesintisi", "Müşteri memnuniyetsizliği"],
                benefits: ["Anormal kullanım durur", "Maliyet kontrolü"]
            ),
            RecommendedAction(
                actionType: BulkAction.throttle.rawValue, // String olarak sakla
                confidence: 0.7,
                expectedImpact: "Kullanım %65 azalacak",
                risks: ["Performans düşüşü"],
                benefits: ["Servis devam eder", "Kullanım kontrol altına alınır"]
            )
        ]
        
        let impactAnalysis = ImpactAnalysis(
            expectedUsageReduction: 65.0,
            expectedCostImpact: -45.0,
            affectedServices: ["Veri", "IoT"],
            duration: "24 saat",
            reversible: true
        )
        
        let recommendation = ActionRecommendation(
            simId: simId,
            recommendedActions: recommendedActions,
            impactAnalysis: impactAnalysis,
            priority: .high,
            reasoning: "Anormal kullanım paterni tespit edildi. Acil müdahale gerekli."
        )
        
        return APIResponse(
            status: true,
            messages: ["Eylem önerileri hazırlandı"],
            code: 200,
            data: recommendation
        )
    }

    // MARK: - What-If Analysis
    func getWhatIfScenarios(simId: Int) async throws -> APIResponse<WhatIfScenario> {
        try await Task.sleep(nanoseconds: 900_000_000)
        
        let scenarios = [
            CostScenario(
                scenarioType: .current,
                planId: 1,
                addons: [],
                monthlyCost: 25.0,
                estimatedOverage: 45.0,
                totalEstimatedCost: 70.0,
                savings: 0.0,
                costBreakdown: ScenarioCostBreakdown(
                    basePlanCost: 25.0,
                    addonCosts: [],
                    estimatedOverageCost: 45.0,
                    taxes: 5.6,
                    discounts: 0.0
                ),
                pros: ["Değişiklik yok", "Bilinen plan"],
                cons: ["Yüksek aşım ücreti", "Maliyet verimsiz"]
            ),
            CostScenario(
                scenarioType: .upgradePlan,
                planId: 2,
                addons: [],
                monthlyCost: 45.0,
                estimatedOverage: 8.0,
                totalEstimatedCost: 53.0,
                savings: 17.0,
                costBreakdown: ScenarioCostBreakdown(
                    basePlanCost: 45.0,
                    addonCosts: [],
                    estimatedOverageCost: 8.0,
                    taxes: 4.24,
                    discounts: 0.0
                ),
                pros: ["%24 tasarruf", "Daha fazla kota", "Daha düşük aşım"],
                cons: ["Daha yüksek temel ücret"]
            ),
            CostScenario(
                scenarioType: .addDataPack,
                planId: 1,
                addons: [701],
                monthlyCost: 25.0,
                estimatedOverage: 15.0,
                totalEstimatedCost: 55.0,
                savings: 15.0,
                costBreakdown: ScenarioCostBreakdown(
                    basePlanCost: 25.0,
                    addonCosts: [
                        AddonCostDetail(addonId: 701, name: "200MB Ek Paket", cost: 15.0, extraMB: 200)
                    ],
                    estimatedOverageCost: 15.0,
                    taxes: 4.4,
                    discounts: 0.0
                ),
                pros: ["Orta düzey tasarruf", "Esnek çözüm"],
                cons: ["Hala aşım riski var"]
            )
        ]
        
        let recommendations = [
            ScenarioRecommendation(
                scenarioId: scenarios[1].id.uuidString,
                rank: 1,
                reasoning: "En yüksek tasarruf ve güvenlik sağlar",
                confidenceScore: 0.92,
                expectedSavings: 17.0,
                riskLevel: "Düşük"
            )
        ]
        
        let usagePattern = UsagePattern(
            averageMonthlyMB: 1800.0,
            peakDayMB: 150.0,
            roamingPercentage: 5.0,
            usageVariability: 0.3,
            predictedNextMonthMB: 1950.0,
            seasonalTrends: []
        )
        
        let whatIfScenario = WhatIfScenario(
            simId: simId,
            scenarios: scenarios,
            recommendations: recommendations,
            currentUsagePattern: usagePattern
        )
        
        return APIResponse(
            status: true,
            messages: ["Maliyet senaryoları hesaplandı"],
            code: 200,
            data: whatIfScenario
        )
    }
}

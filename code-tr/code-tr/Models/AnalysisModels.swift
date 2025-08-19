//
//  AnalysisModels.swift
//  code-tr
//
//  Created by Faruk Kuz on 18.08.2025.
//

import Foundation

// MARK: - Risk Assessment Models
struct RiskAssessment: Identifiable, Codable {
    let simId: Int
    let riskLevel: RiskLevel
    let riskScore: Double // 0.0 - 1.0
    let anomalyCount: Int
    let lastCalculated: String
    let factors: [RiskFactor]
    
    // Computed property for Identifiable
    var id: String { "\(simId)_\(lastCalculated)" }
    
    enum CodingKeys: String, CodingKey {
        case simId = "sim_id"
        case riskLevel = "risk_level"
        case riskScore = "risk_score"
        case anomalyCount = "anomaly_count"
        case lastCalculated = "last_calculated"
        case factors
    }
}

enum RiskLevel: String, Codable, CaseIterable {
    case low = "low"       // 0.0 - 0.3 (Yeşil)
    case medium = "medium" // 0.3 - 0.7 (Turuncu)
    case high = "high"     // 0.7 - 1.0 (Kırmızı)
    
    var displayName: String {
        switch self {
        case .low: return "Düşük Risk"
        case .medium: return "Orta Risk"
        case .high: return "Yüksek Risk"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "orange"
        case .high: return "red"
        }
    }
}

struct RiskFactor: Identifiable, Codable {
    let type: String
    let impact: Double // 0.0 - 1.0
    let description: String
    
    // Computed property for Identifiable
    var id: String { "\(type)_\(impact)" }
    
    enum CodingKeys: String, CodingKey {
        case type, impact, description
    }
}

// MARK: - Anomaly Detection Models
struct AnomalyDetection: Identifiable, Codable {
    let simId: Int
    let anomalies: [DetailedAnomaly]
    let totalAnomalies: Int
    let criticalCount: Int
    let analysisTimestamp: String
    
    // Computed property for Identifiable
    var id: String { "\(simId)_\(analysisTimestamp)" }
    
    enum CodingKeys: String, CodingKey {
        case simId = "sim_id"
        case anomalies
        case totalAnomalies = "total_anomalies"
        case criticalCount = "critical_count"
        case analysisTimestamp = "analysis_timestamp"
    }
}

struct DetailedAnomaly: Identifiable, Codable {
    let type: AnomalyType
    let severity: AnomalySeverity
    let timestamp: String
    let endTimestamp: String?
    let description: String
    let evidence: AnomalyEvidence
    let recommendation: String
    let affectedMetrics: [String]
    
    // Computed property for Identifiable
    var id: String { "\(type.rawValue)_\(timestamp)" }
    
    enum CodingKeys: String, CodingKey {
        case type, severity, timestamp
        case endTimestamp = "end_timestamp"
        case description, evidence, recommendation
        case affectedMetrics = "affected_metrics"
    }
}

enum AnomalyType: String, Codable, CaseIterable {
    case suddenSpike = "sudden_spike"
    case sustainedDrain = "sustained_drain"
    case inactivity = "inactivity"
    case unexpectedRoaming = "unexpected_roaming"
    case locationAnomaly = "location_anomaly"
    case timePatternAnomaly = "time_pattern_anomaly"
    
    var displayName: String {
        switch self {
        case .suddenSpike: return "Ani Artış"
        case .sustainedDrain: return "Sürekli Tüketim"
        case .inactivity: return "İnaktivite"
        case .unexpectedRoaming: return "Beklenmeyen Roaming"
        case .locationAnomaly: return "Lokasyon Anomalisi"
        case .timePatternAnomaly: return "Zaman Deseni Anomalisi"
        }
    }
    
    var icon: String {
        switch self {
        case .suddenSpike: return "arrow.up.circle.fill"
        case .sustainedDrain: return "minus.circle.fill"
        case .inactivity: return "pause.circle.fill"
        case .unexpectedRoaming: return "location.circle.fill"
        case .locationAnomaly: return "map.circle.fill"
        case .timePatternAnomaly: return "clock.circle.fill"
        }
    }
}

enum AnomalySeverity: String, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
    var displayName: String {
        switch self {
        case .low: return "Düşük"
        case .medium: return "Orta"
        case .high: return "Yüksek"
        case .critical: return "Kritik"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "yellow"
        case .high: return "orange"
        case .critical: return "red"
        }
    }
}

struct AnomalyEvidence: Codable {
    let baselineValue: Double
    let currentValue: Double
    let deviationPercentage: Double
    let comparisonPeriod: String
    let dataPoints: [EvidenceDataPoint]
    
    enum CodingKeys: String, CodingKey {
        case baselineValue = "baseline_value"
        case currentValue = "current_value"
        case deviationPercentage = "deviation_percentage"
        case comparisonPeriod = "comparison_period"
        case dataPoints = "data_points"
    }
}

struct EvidenceDataPoint: Identifiable, Codable {
    let timestamp: String
    let value: Double
    let isAnomalous: Bool
    
    // Computed property for Identifiable
    var id: String { timestamp }
    
    enum CodingKeys: String, CodingKey {
        case timestamp, value
        case isAnomalous = "is_anomalous"
    }
}

// MARK: - Action Recommendation Models
struct ActionRecommendation: Identifiable, Codable {
    let simId: Int
    let recommendedActions: [RecommendedAction]
    let impactAnalysis: ImpactAnalysis
    let priority: ActionPriority
    let reasoning: String
    
    // Computed property for Identifiable
    var id: String { String(simId) }
    
    enum CodingKeys: String, CodingKey {
        case simId = "sim_id"
        case recommendedActions = "recommended_actions"
        case impactAnalysis = "impact_analysis"
        case priority, reasoning
    }
}

struct RecommendedAction: Identifiable, Codable {
    let actionType: String // BulkAction'ın raw value'sunu string olarak saklayacağız
    let confidence: Double // 0.0 - 1.0
    let expectedImpact: String
    let risks: [String]
    let benefits: [String]
    
    // Computed property for Identifiable
    var id: String { actionType }
    
    // BulkAction enum'una convert etmek için computed property
    var action: BulkAction? {
        BulkAction(rawValue: actionType)
    }
    
    enum CodingKeys: String, CodingKey {
        case actionType = "action_type"
        case confidence
        case expectedImpact = "expected_impact"
        case risks, benefits
    }
}

struct ImpactAnalysis: Codable {
    let expectedUsageReduction: Double // percentage
    let expectedCostImpact: Double // TL
    let affectedServices: [String]
    let duration: String
    let reversible: Bool
    
    enum CodingKeys: String, CodingKey {
        case expectedUsageReduction = "expected_usage_reduction"
        case expectedCostImpact = "expected_cost_impact"
        case affectedServices = "affected_services"
        case duration, reversible
    }
}

enum ActionPriority: String, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case urgent = "urgent"
    
    var displayName: String {
        switch self {
        case .low: return "Düşük"
        case .medium: return "Orta"
        case .high: return "Yüksek"
        case .urgent: return "Acil"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "yellow"
        case .high: return "orange"
        case .urgent: return "red"
        }
    }
}

// MARK: - Time Series Models
struct TimeSeriesData: Identifiable, Codable {
    let simId: Int
    let period: TimePeriod
    let dataPoints: [TimeSeriesPoint]
    let summary: TimeSeriesSummary
    
    // Computed property for Identifiable
    var id: String { "\(simId)_\(period.rawValue)" }
    
    enum CodingKeys: String, CodingKey {
        case simId = "sim_id"
        case period
        case dataPoints = "data_points"
        case summary
    }
}

enum TimePeriod: String, Codable, CaseIterable {
    case hourly = "hourly"
    case daily = "daily"
    case weekly = "weekly"
    
    var displayName: String {
        switch self {
        case .hourly: return "Saatlik"
        case .daily: return "Günlük"
        case .weekly: return "Haftalık"
        }
    }
}

struct TimeSeriesPoint: Identifiable, Codable {
    let timestamp: String
    let mbUsed: Double
    let roamingMb: Double
    let smsCount: Int?
    let isAnomaly: Bool
    let anomalyTypes: [AnomalyType]
    
    // Computed property for Identifiable
    var id: String { timestamp }
    
    enum CodingKeys: String, CodingKey {
        case timestamp
        case mbUsed = "mb_used"
        case roamingMb = "roaming_mb"
        case smsCount = "sms_count"
        case isAnomaly = "is_anomaly"
        case anomalyTypes = "anomaly_types"
    }
}

struct TimeSeriesSummary: Codable {
    let totalMB: Double
    let averageDailyMB: Double
    let peakDayMB: Double
    let anomalyDays: Int
    let roamingDays: Int
    let inactiveDays: Int
    
    enum CodingKeys: String, CodingKey {
        case totalMB = "total_mb"
        case averageDailyMB = "average_daily_mb"
        case peakDayMB = "peak_day_mb"
        case anomalyDays = "anomaly_days"
        case roamingDays = "roaming_days"
        case inactiveDays = "inactive_days"
    }
}

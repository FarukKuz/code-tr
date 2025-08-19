//
//  WhatIfModels.swift
//  code-tr
//
//  Created by Faruk Kuz on 18.08.2025.
//

import Foundation

// MARK: - What-If Analysis Models
struct WhatIfScenario: Identifiable, Codable {
    let id = UUID()
    let simId: Int
    let scenarios: [CostScenario]
    let recommendations: [ScenarioRecommendation]
    let currentUsagePattern: UsagePattern
}

struct CostScenario: Identifiable, Codable {
    let id = UUID()
    let scenarioType: ScenarioType
    let planId: Int?
    let addons: [Int]
    let monthlyCost: Double
    let estimatedOverage: Double
    let totalEstimatedCost: Double
    let savings: Double // vs current
    let costBreakdown: ScenarioCostBreakdown
    let pros: [String]
    let cons: [String]
}

enum ScenarioType: String, Codable, CaseIterable {
    case current = "current"
    case upgradePlan = "upgrade_plan"
    case downgradePlan = "downgrade_plan"
    case addDataPack = "add_data_pack"
    case optimized = "optimized"
    
    var displayName: String {
        switch self {
        case .current: return "Mevcut Plan"
        case .upgradePlan: return "Plan Yükseltme"
        case .downgradePlan: return "Plan İndirme"
        case .addDataPack: return "Ek Paket"
        case .optimized: return "Optimize Edilmiş"
        }
    }
    
    var icon: String {
        switch self {
        case .current: return "checkmark.circle"
        case .upgradePlan: return "arrow.up.circle"
        case .downgradePlan: return "arrow.down.circle"
        case .addDataPack: return "plus.circle"
        case .optimized: return "star.circle"
        }
    }
}

struct ScenarioCostBreakdown: Codable {
    let basePlanCost: Double
    let addonCosts: [AddonCostDetail]
    let estimatedOverageCost: Double
    let taxes: Double
    let discounts: Double
}

struct AddonCostDetail: Identifiable, Codable {
    let id = UUID()
    let addonId: Int
    let name: String
    let cost: Double
    let extraMB: Int
}

struct ScenarioRecommendation: Identifiable, Codable {
    let id = UUID()
    let scenarioId: String
    let rank: Int
    let reasoning: String
    let confidenceScore: Double
    let expectedSavings: Double
    let riskLevel: String
}

struct UsagePattern: Codable {
    let averageMonthlyMB: Double
    let peakDayMB: Double
    let roamingPercentage: Double
    let usageVariability: Double // Standard deviation
    let predictedNextMonthMB: Double
    let seasonalTrends: [SeasonalTrend]
}

struct SeasonalTrend: Identifiable, Codable {
    let id = UUID()
    let month: String
    let expectedMultiplier: Double
    let confidence: Double
}

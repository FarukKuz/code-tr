//
//  FleetModels.swift
//  code-tr
//
//  Created by Faruk Kuz on 18.08.2025.
//

import Foundation

// MARK: - API Response Wrapper
struct APIResponse<T: Codable>: Codable {
    let status: Bool
    let messages: [String]
    let code: Int
    let data: T?
}

// MARK: - Fleet Models
struct SIMCard: Identifiable, Codable {
    let simId: Int // Int olarak değişti
    let customerId: Int
    let deviceType: String
    let apn: String
    let planId: Int
    var status: SIMStatus
    let city: String
    
    // İlişkili veriler (JOIN'den gelecek)
    let plan: IotPlan?
    let deviceProfile: DeviceProfile?
    
    // Computed properties
    var id: String { String(simId) } // Identifiable için
    
    enum CodingKeys: String, CodingKey {
        case simId = "sim_id"
        case customerId = "customer_id"
        case deviceType = "device_type"
        case apn
        case planId = "plan_id"
        case status, city, plan
        case deviceProfile = "device_profile"
    }
}

enum SIMStatus: String, Codable, CaseIterable {
    case active = "active"
    case blocked = "blocked"
    case frozen = "frozen"
    
    var displayName: String {
        switch self {
        case .active: return "Aktif"
        case .blocked: return "Engelli"
        case .frozen: return "Dondurulmuş"
        }
    }
    
    var color: String {
        switch self {
        case .active: return "green"
        case .blocked: return "red"
        case .frozen: return "yellow"
        }
    }
}

// MARK: - IoT Plan Model
struct IotPlan: Codable {
    let planId: Int
    let planName: String
    let monthlyQuotaMb: Int
    let monthlyPrice: Double
    let overagePerMb: Double
    let apn: String
    
    enum CodingKeys: String, CodingKey {
        case planId = "plan_id"
        case planName = "plan_name"
        case monthlyQuotaMb = "monthly_quota_mb"
        case monthlyPrice = "monthly_price"
        case overagePerMb = "overage_per_mb"
        case apn
    }
}

// MARK: - Device Profile Model
struct DeviceProfile: Codable {
    let deviceType: String
    let expectedDailyMbMin: Int
    let expectedDailyMbMax: Int
    let roamingExpected: Bool
    
    enum CodingKeys: String, CodingKey {
        case deviceType = "device_type"
        case expectedDailyMbMin = "expected_daily_mb_min"
        case expectedDailyMbMax = "expected_daily_mb_max"
        case roamingExpected = "roaming_expected"
    }
}

// MARK: - Usage Models
struct UsageData: Identifiable, Codable {
    let id: Int
    let simId: Int
    let timestampMb: String // ISO String olarak
    let mbUsed: Int
    let roamingMb: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case simId = "sim_id"
        case timestampMb = "timestamp_mb"
        case mbUsed = "mb_used"
        case roamingMb = "roaming_mb"
    }
}

// MARK: - Add-on Pack Model
struct AddOnPack: Identifiable, Codable {
    let addonId: Int
    let name: String
    let extraMb: Int
    let price: Double
    let apn: String
    
    var id: String { String(addonId) }
    
    enum CodingKeys: String, CodingKey {
        case addonId = "addon_id"
        case name
        case extraMb = "extra_mb"
        case price, apn
    }
}

// MARK: - Action Models
enum BulkAction: String, CaseIterable {
    case freeze = "freeze_24h"
    case throttle = "throttle"
    case block = "block_sim"
    case notify = "notify_user"
    case activate = "activate"
    
    var displayName: String {
        switch self {
        case .freeze: return "24 Saat Dondur"
        case .throttle: return "Hızı Kısıtla"
        case .block: return "SIM'i Engelle"
        case .notify: return "Bildirim Gönder"
        case .activate: return "Aktifleştir"
        }
    }
    
    var description: String {
        switch self {
        case .freeze: return "SIM kartını 24 saat boyunca donduracak"
        case .throttle: return "SIM kartının hızını kısıtlayacak"
        case .block: return "SIM kartını tamamen engelleyecek"
        case .notify: return "Kullanıcıya bildirim gönderecek"
        case .activate: return "SIM kartını aktifleştirecek"
        }
    }
}

enum ActionStatus: String, Codable {
    case done = "done"
    case pending = "pending"
    case failed = "failed"
    
    var displayName: String {
        switch self {
        case .done: return "Tamamlandı"
        case .pending: return "Bekliyor"
        case .failed: return "Başarısız"
        }
    }
}

struct BulkActionRequest: Codable {
    let simIds: [Int] // String'den Int'e değişti
    let action: String
    let reason: String
    let actor: String // Kullanıcı bilgisi eklendi
    
    enum CodingKeys: String, CodingKey {
        case simIds = "sim_ids"
        case action, reason, actor
    }
}

struct ActionLog: Identifiable, Codable {
    let actionId: String
    let simId: Int
    let action: String
    let reason: String
    let createdAt: String
    let actor: String
    let status: ActionStatus
    
    var id: String { actionId }
    
    enum CodingKeys: String, CodingKey {
        case actionId = "action_id"
        case simId = "sim_id"
        case action, reason
        case createdAt = "created_at"
        case actor, status
    }
}

// MARK: - What-If Analysis Models
struct WhatIfRequest: Codable {
    let planId: Int?
    let addons: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case planId = "plan_id"
        case addons
    }
}

struct WhatIfResponse: Codable {
    let currentTotal: Double
    let candidateTotal: Double
    let saving: Double
    let breakdown: CostBreakdown
    
    enum CodingKeys: String, CodingKey {
        case currentTotal = "current_total"
        case candidateTotal = "candidate_total"
        case saving, breakdown
    }
}

struct CostBreakdown: Codable {
    let planCost: Double
    let addonCosts: [AddonCost]
    let overageCost: Double
    
    enum CodingKeys: String, CodingKey {
        case planCost = "plan_cost"
        case addonCosts = "addon_costs"
        case overageCost = "overage_cost"
    }
}

struct AddonCost: Identifiable, Codable {
    let addonId: Int
    let name: String
    let cost: Double
    
    var id: String { String(addonId) }
    
    enum CodingKeys: String, CodingKey {
        case addonId = "addon_id"
        case name, cost
    }
}

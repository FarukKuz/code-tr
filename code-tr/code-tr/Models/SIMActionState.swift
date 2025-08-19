//
//  SIMActionState.swift
//  code-tr
//
//  Created by Faruk Kuz on 18.08.2025.
//

import Foundation

struct SIMActionState: Identifiable, Codable {
    let simId: Int
    let currentAction: ActiveAction?
    let history: [ActionHistory]
    
    var id: String { String(simId) }
    
    enum CodingKeys: String, CodingKey {
        case simId = "sim_id"
        case currentAction = "current_action"
        case history
    }
}

struct ActiveAction: Codable {
    let actionType: String
    let startTime: String
    let endTime: String
    let reason: String
    let actor: String
    
    var timeRemaining: TimeInterval {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        guard let endDate = formatter.date(from: endTime) else { return 0 }
        return endDate.timeIntervalSinceNow
    }
    
    var isActive: Bool {
        timeRemaining > 0
    }
    
    var action: BulkAction? {
        BulkAction(rawValue: actionType)
    }
    
    enum CodingKeys: String, CodingKey {
        case actionType = "action_type"
        case startTime = "start_time"
        case endTime = "end_time"
        case reason, actor
    }
}

struct ActionHistory: Identifiable, Codable {
    let id: String
    let actionType: String
    let startTime: String
    let endTime: String?
    let reason: String
    let actor: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, actionType = "action_type"
        case startTime = "start_time"
        case endTime = "end_time"
        case reason, actor, status
    }
}

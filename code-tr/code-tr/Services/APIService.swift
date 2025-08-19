//
//  APIService.swift
//  code-tr
//
//  Created by Faruk Kuz on 18.08.2025.
//

import Foundation
import Combine

class APIService {
    static let shared = APIService()
    private let baseURL = "http://localhost:8000/api"
    private let session = URLSession.shared
    
    init() {}
    
    // MARK: - Authentication
    func login(request: LoginRequest) async throws -> LoginResponse {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        if request.username == "admin" && request.password == "admin123" {
            return LoginResponse(token: "mock-jwt-token-12345", status: "success")
        } else {
            throw NSError(domain: "LoginError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı adı veya şifre yanlış."])
        }
    }
    
    // MARK: - Fleet Management
    func getFleet() async throws -> [SIMCard] {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        return [
            SIMCard(
                simId: 2001,
                customerId: 1,
                deviceType: "IoT Sensor",
                apn: "iot.turkcell.com",
                planId: 1,
                status: .active,
                city: "İstanbul",
                plan: IotPlan(
                    planId: 1,
                    planName: "IoT Basic 1GB",
                    monthlyQuotaMb: 1024,
                    monthlyPrice: 25.00,
                    overagePerMb: 0.05,
                    apn: "iot.turkcell.com"
                ),
                deviceProfile: DeviceProfile(
                    deviceType: "IoT Sensor",
                    expectedDailyMbMin: 10,
                    expectedDailyMbMax: 50,
                    roamingExpected: false
                )
            ),
            SIMCard(
                simId: 2002,
                customerId: 1,
                deviceType: "GPS Tracker",
                apn: "iot.turkcell.com",
                planId: 2,
                status: .active,
                city: "Ankara",
                plan: IotPlan(
                    planId: 2,
                    planName: "IoT Plus 2GB",
                    monthlyQuotaMb: 2048,
                    monthlyPrice: 45.00,
                    overagePerMb: 0.04,
                    apn: "iot.turkcell.com"
                ),
                deviceProfile: DeviceProfile(
                    deviceType: "GPS Tracker",
                    expectedDailyMbMin: 20,
                    expectedDailyMbMax: 100,
                    roamingExpected: true
                )
            ),
            SIMCard(
                simId: 2003,
                customerId: 2,
                deviceType: "Smart Meter",
                apn: "iot.turkcell.com",
                planId: 1,
                status: .blocked,
                city: "İzmir",
                plan: IotPlan(
                    planId: 1,
                    planName: "IoT Basic 1GB",
                    monthlyQuotaMb: 1024,
                    monthlyPrice: 25.00,
                    overagePerMb: 0.05,
                    apn: "iot.turkcell.com"
                ),
                deviceProfile: DeviceProfile(
                    deviceType: "Smart Meter",
                    expectedDailyMbMin: 5,
                    expectedDailyMbMax: 25,
                    roamingExpected: false
                )
            )
        ]
    }
    
    func getUsage(simId: Int, days: Int = 30) async throws -> [UsageData] {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        var usageData: [UsageData] = []
        let calendar = Calendar.current
        let today = Date()
        
        for i in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let formatter = ISO8601DateFormatter()
                let timestamp = formatter.string(from: date)
                
                let baseUsage = Int.random(in: 50...500)
                let roamingUsage = Int.random(in: 0...50)
                
                usageData.append(UsageData(
                    id: i + 1,
                    simId: simId,
                    timestampMb: timestamp,
                    mbUsed: baseUsage,
                    roamingMb: roamingUsage
                ))
            }
        }
        
        return usageData.reversed()
    }
    
    func performBulkAction(_ actionRequest: BulkActionRequest) async throws -> APIResponse<[ActionLog]> {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        let actionLogs = actionRequest.simIds.map { simId in
            ActionLog(
                actionId: "action_\(UUID().uuidString.prefix(8))",
                simId: simId,
                action: actionRequest.action,
                reason: actionRequest.reason,
                createdAt: ISO8601DateFormatter().string(from: Date()),
                actor: actionRequest.actor,
                status: .done
            )
        }
        
        return APIResponse(
            status: true,
            messages: ["İşlem başarıyla tamamlandı"],
            code: 200,
            data: actionLogs
        )
    }
    
    func getWhatIfAnalysis(simId: Int, request: WhatIfRequest) async throws -> WhatIfResponse {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        return WhatIfResponse(
            currentTotal: 25.00,
            candidateTotal: 45.00,
            saving: -20.00,
            breakdown: CostBreakdown(
                planCost: 45.00,
                addonCosts: [],
                overageCost: 0.00
            )
        )
    }
    
    // MARK: - Combine Wrappers
    func getFleetPublisher() -> AnyPublisher<[SIMCard], Error> {
        Future { promise in
            Task {
                do {
                    let result = try await self.getFleet()
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func performBulkActionPublisher(_ actionRequest: BulkActionRequest) -> AnyPublisher<APIResponse<[ActionLog]>, Error> {
        Future { promise in
            Task {
                do {
                    let result = try await self.performBulkAction(actionRequest)
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

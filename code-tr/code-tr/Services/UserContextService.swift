//
//  UserContextService.swift
//  code-tr
//
//  Created by Faruk Kuz on 18.08.2025.
//

import Foundation
import SwiftUI

class UserContextService: ObservableObject {
    static let shared = UserContextService()
    
    @Published var currentUser: String = "FarukKuz"
    @Published var currentDateTime: String = ""
    @Published var timeZone: TimeZone = TimeZone(identifier: "UTC") ?? TimeZone.current
    
    private var timer: Timer?
    
    private init() {
        startDateTimeUpdates()
    }
    
    private func startDateTimeUpdates() {
        updateDateTime()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateDateTime()
        }
    }
    
    private func updateDateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = timeZone
        currentDateTime = formatter.string(from: Date())
    }
    
    func setUser(_ username: String) {
        currentUser = username
    }
    
    func getCurrentISOTimestamp() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: Date())
    }
    
    deinit {
        timer?.invalidate()
    }
}

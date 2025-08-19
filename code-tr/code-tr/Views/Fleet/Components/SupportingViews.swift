//
//  SupportingViews.swift
//  code-tr
//
//  Created by Faruk Kuz on 18.08.2025.
//

import SwiftUI

// MARK: - Analysis Button
struct AnalysisButton: View {
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

// MARK: - BulkAction Extension (Ana extension)
extension BulkAction {
    var actionIcon: String {
        switch self {
        case .freeze: return "snowflake"
        case .throttle: return "speedometer"
        case .block: return "xmark.shield"
        case .notify: return "bell"
        }
    }
    
    var buttonColor: Color {
        switch self {
        case .freeze: return .orange
        case .throttle: return .yellow
        case .block: return .red
        case .notify: return .blue
        }
    }
}

// MARK: - SIMStatus Extension
extension SIMStatus {
    var badgeColor: Color {
        switch self {
        case .active: return .green
        case .blocked: return .red
        }
    }
}

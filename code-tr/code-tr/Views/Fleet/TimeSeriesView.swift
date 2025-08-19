//
//  TimeSeriesView.swift
//  code-tr
//
//  Created by Faruk Kuz on 18.08.2025.
//

import SwiftUI

struct TimeSeriesView: View {
    let simCard: SIMCard
    @State private var timeSeriesData: TimeSeriesData?
    @State private var selectedPeriod: TimePeriod = .daily
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Period Selector
                Picker("Dönem", selection: $selectedPeriod) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Text(period.displayName).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if isLoading {
                    ProgressView("Veriler yükleniyor...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let timeSeriesData = timeSeriesData {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Summary Cards
                            TimeSeriesSummaryView(summary: timeSeriesData.summary)
                            
                            // Simple Chart Placeholder
                            TimeSeriesChartPlaceholder(data: timeSeriesData.dataPoints)
                            
                            // Anomaly List
                            if !timeSeriesData.dataPoints.filter(\.isAnomaly).isEmpty {
                                AnomalyListView(anomalies: timeSeriesData.dataPoints.filter(\.isAnomaly))
                            }
                        }
                        .padding()
                    }
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("SIM #\(simCard.simId) - Zaman Serisi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Yenile") {
                        loadTimeSeriesData()
                    }
                }
            }
            .onChange(of: selectedPeriod) { _ in
                loadTimeSeriesData()
            }
            .onAppear {
                loadTimeSeriesData()
            }
        }
    }
    
    private func loadTimeSeriesData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await APIService.shared.getTimeSeriesData(simId: simCard.simId, period: selectedPeriod)
                await MainActor.run {
                    isLoading = false
                    if response.status {
                        timeSeriesData = response.data
                    } else {
                        errorMessage = response.messages.first ?? "Veri yüklenemedi"
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct TimeSeriesSummaryView: View {
    let summary: TimeSeriesSummary
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            SummaryCard(title: "Toplam Kullanım", value: String(format: "%.0f MB", summary.totalMB), icon: "arrow.up.arrow.down")
            SummaryCard(title: "Günlük Ortalama", value: String(format: "%.1f MB", summary.averageDailyMB), icon: "chart.line.uptrend.xyaxis")
            SummaryCard(title: "Pik Gün", value: String(format: "%.0f MB", summary.peakDayMB), icon: "arrow.up.to.line")
            SummaryCard(title: "Anomali Günleri", value: "\(summary.anomalyDays) gün", icon: "exclamationmark.triangle")
            SummaryCard(title: "Roaming Günleri", value: "\(summary.roamingDays) gün", icon: "location")
            SummaryCard(title: "İnaktif Günler", value: "\(summary.inactiveDays) gün", icon: "pause")
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct TimeSeriesChartPlaceholder: View {
    let data: [TimeSeriesPoint]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Veri Kullanımı")
                .font(.headline)
                .padding(.leading)
            
            // Simple bar chart simulation
            VStack(spacing: 4) {
                ForEach(data.prefix(10)) { point in
                    HStack {
                        Text(formatDate(point.timestamp))
                            .font(.caption)
                            .frame(width: 80, alignment: .leading)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(point.isAnomaly ? Color.red : Color.blue)
                            .frame(width: CGFloat(point.mbUsed / 10), height: 20)
                        
                        Text(String(format: "%.1f MB", point.mbUsed))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return "---" }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "dd.MM"
        return displayFormatter.string(from: date)
    }
}

struct AnomalyListView: View {
    let anomalies: [TimeSeriesPoint]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Tespit Edilen Anomaliler")
                .font(.headline)
                .padding(.leading)
            
            LazyVStack(spacing: 8) {
                ForEach(anomalies) { anomaly in
                    AnomalyRowView(anomaly: anomaly)
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct AnomalyRowView: View {
    let anomaly: TimeSeriesPoint
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(formatDate(anomaly.timestamp))
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("\(String(format: "%.1f", anomaly.mbUsed)) MB kullanım")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                ForEach(anomaly.anomalyTypes, id: \.self) { type in
                    Image(systemName: type.icon)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Text(anomaly.anomalyTypes.first?.displayName ?? "Anomali")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(8)
        .background(Color.red.opacity(0.1))
        .cornerRadius(6)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return displayFormatter.string(from: date)
    }
}

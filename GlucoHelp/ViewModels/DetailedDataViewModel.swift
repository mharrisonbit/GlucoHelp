//
//  DetailedDataViewModel.swift
//  GlucoHelp
//
//  Created by Michael Harrison on 5/23/25.
//

import Foundation
import HealthKit


class DetailedDataViewModel: ObservableObject {
    @Published var a1c = 6.3
    @Published var timeSpan = "90 Days"
    @Published var timeSpanText = "Change timeframe to 2 weeks"
    @Published var swapTimeFrame = false
    let healthKitManager: HealthKitManager

    struct BloodGlucoseReading {
        let value: Double
        let date: Date
    }
    
    init(healthKitManager: HealthKitManager) {
        self.healthKitManager = healthKitManager
        buildA1cForDisplay()
    }

    func buildA1cForDisplay(days: Int = 90) {
        let recentReadings = getReadings(forLast: days)
        let glucoseValues = recentReadings.map { $0.value }
        
        guard !glucoseValues.isEmpty else { return }
        
        let total = glucoseValues.reduce(0, +)
        let averageGlucose = total / Double(glucoseValues.count)
        
        a1c = (averageGlucose + 46.7) / 28.7
    }


    func getReadings(forLast days: Int) -> [BloodGlucoseReading] {
        let calendar = Calendar.current
        let now = Date()
        
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: now) else {
            return []
        }
        
        let filtered = healthKitManager.bloodGlucoseReadings.filter { $0.timestamp >= startDate }
        
        return filtered.map { reading in
            BloodGlucoseReading(value: reading.value, date: reading.timestamp)
        }
    }



    
    public func testFunction(with isEnabled: Bool) {
        print("Toggle is now: \(isEnabled)")
        if(isEnabled){
            timeSpan = "2 Weeks"
            timeSpanText = "Change timeframe to 90 days"
            buildA1cForDisplay(days: 14)
        }
        else{
            timeSpan = "90 Days"
            timeSpanText = "Change timeframe to 2 weeks"
            buildA1cForDisplay()
        }
    }
    
}


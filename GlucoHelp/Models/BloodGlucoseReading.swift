//
//  BloodGlucoseReading.swift
//  GlucoHelp
//
//  Created by Michael Harrison on 5/17/25.
//

import Foundation
import HealthKit

struct BloodGlucoseReading: Identifiable, Codable {
    let id: UUID
    let value: Double
    let unit: String // "mg/dL" or "mmol/L"
    let timestamp: Date
    
    init(from sample: HKQuantitySample) {
        self.id = sample.uuid
        self.value = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .milli).unitDivided(by: .literUnit(with: .deci)))
        self.unit = "mg/dL"
        self.timestamp = sample.startDate
    }
} 

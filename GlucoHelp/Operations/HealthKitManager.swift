//
//  HealthKitManager.swift
//  GlucoHelp
//
//  Created by Michael Harrison on 5/17/25.
//

import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()
    @Published var bloodGlucoseReadings: [BloodGlucoseReading] = []
    
    // Define the units we'll use
    private let mgPerDLUnit = HKUnit.gramUnit(with: .milli).unitDivided(by: .literUnit(with: .deci))
    private let mmolPerLUnit = HKUnit.moleUnit(with: .milli, molarMass: HKUnitMolarMassBloodGlucose)
    
    private var localReadings: [BloodGlucoseReading] {
        get {
            if let data = UserDefaults.standard.data(forKey: "bloodGlucoseReadings"),
               let readings = try? JSONDecoder().decode([BloodGlucoseReading].self, from: data) {
                return readings
            }
            return []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: "bloodGlucoseReadings")
            }
        }
    }
    
    init() {
        // Load saved readings when initializing
        bloodGlucoseReadings = localReadings
    }
    
    func requestAuthorization() {
        // Check if HealthKit is available on this device
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        
        // Define the types we want to read from HealthKit
        guard let bloodGlucoseType = HKObjectType.quantityType(forIdentifier: .bloodGlucose) else {
            print("Blood glucose type is not available")
            return
        }
        
        // Request authorization
        healthStore.requestAuthorization(toShare: nil, read: [bloodGlucoseType]) { success, error in
            if success {
                print("HealthKit authorization granted")
                self.fetchBloodGlucoseData()
            } else if let error = error {
                print("HealthKit authorization failed: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchBloodGlucoseData() {
        guard let bloodGlucoseType = HKObjectType.quantityType(forIdentifier: .bloodGlucose) else {
            return
        }
        
        // Create a predicate for the last 90 days
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -90, to: now)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        
        // Create the query
        let query = HKSampleQuery(
            sampleType: bloodGlucoseType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { [weak self] query, samples, error in
            guard let samples = samples as? [HKQuantitySample] else {
                if let error = error {
                    print("Error fetching blood glucose data: \(error.localizedDescription)")
                }
                return
            }
            
            // Convert samples to our local model
            let readings = samples.map { BloodGlucoseReading(from: $0) }
            
            DispatchQueue.main.async {
                self?.bloodGlucoseReadings = readings
                self?.localReadings = readings // Save to local storage
            }
        }
        
        healthStore.execute(query)
    }
    
    // Helper function to get blood glucose value in mmol/L
    func getBloodGlucoseInMmolL(_ reading: BloodGlucoseReading) -> Double {
        // Convert mg/dL to mmol/L (divide by 18)
        return reading.value / 18.0
    }
    
    // Helper function to get blood glucose value in mg/dL
    func getBloodGlucoseInMgDL(_ reading: BloodGlucoseReading) -> Double {
        return reading.value
    }
} 

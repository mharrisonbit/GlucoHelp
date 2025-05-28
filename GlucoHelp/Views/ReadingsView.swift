//
//  Readings.swift
//  GlucoHelp
//
//  Created by Michael Harrison on 5/17/25.
//

import SwiftUI
import HealthKit

struct ReadingsView: View {
    @EnvironmentObject private var healthKitManager: HealthKitManager
    @State private var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            List {
                Section("Blood Glucose Readings (Last 90 Days)") {
                    if healthKitManager.bloodGlucoseReadings.isEmpty {
                        Text("No blood glucose readings available")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(healthKitManager.bloodGlucoseReadings) { reading in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(reading.timestamp, format: .dateTime)
                                        .font(.caption)
                                    if viewModel.showingMgDL {
                                        Text("\(healthKitManager.getBloodGlucoseInMgDL(reading), specifier: "%.0f") mg/dL")
                                            .font(.headline)
                                    } else {
                                        Text("\(healthKitManager.getBloodGlucoseInMmolL(reading), specifier: "%.1f") mmol/L")
                                            .font(.headline)
                                    }
                                }
                                Spacer()
                                Image(systemName: "drop.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }.onAppear {
                healthKitManager.requestAuthorization()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { viewModel.showingMgDL.toggle() }) {
                        Text(viewModel.showingMgDL ? "mg/dL" : "mmol/L")
                    }
                }
            }
            .refreshable {
                healthKitManager.fetchBloodGlucoseData()
            }
        }
    }
    
    func sortListOrder(){
        
    }
}



#Preview {
    ReadingsView()
        .environmentObject(HealthKitManager())
}

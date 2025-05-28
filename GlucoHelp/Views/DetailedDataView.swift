//
//  DetailedData.swift
//  GlucoHelp
//
//  Created by Michael Harrison on 5/17/25.
//

import SwiftUI

struct DetailedDataView: View {
    @EnvironmentObject private var healthKitManager: HealthKitManager
    @StateObject private var viewModel: DetailedDataViewModel

    init() {
        _viewModel = StateObject(wrappedValue: DetailedDataViewModel(healthKitManager: HealthKitManager()))
    }

    var body: some View {
        VStack(alignment: .leading) {
            Toggle(isOn: $viewModel.swapTimeFrame) {
                VStack {
                    Text(viewModel.timeSpanText)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .onChange(of: viewModel.swapTimeFrame) { oldValue, newValue in
                viewModel.testFunction(with: newValue)
            }

            Text("This is your estimated A1C \(viewModel.a1c, specifier: "%.1f")% for \(viewModel.timeSpan)")
                .font(.headline)
        }
    }
}

#Preview {
    DetailedDataView()
        .environmentObject(HealthKitManager())
}


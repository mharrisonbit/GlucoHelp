//
//  ContentView.swift
//  GlucoHelp
//
//  Created by Michael Harrison on 5/16/25.
//

import SwiftUI
import SwiftData

struct HomeTabbedView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var healthManager = HealthKitManager()
    @Query private var items: [Item]

    var body: some View {
        TabView {
            ReadingsView()
                .tabItem{
                    Image(systemName: "list.dash")
                    Text("Readings")
                }
                .environmentObject(healthManager)
            
            DetailedDataView()
                .tabItem {
                    Image(systemName: "chart.pie")
                    Text("Details")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .padding()
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    HomeTabbedView()
        .modelContainer(for: Item.self, inMemory: true)
}

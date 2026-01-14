//
//  PlantochiApp.swift
//  Plantochi
//
//  Created by Max on 15.01.2026.
//

import SwiftUI
import SwiftData

@main
struct PlantochiApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [PlantInstance.self, ActionLog.self, HomeEntity.self, KnowledgeNode.self, Quest.self])
    }
}

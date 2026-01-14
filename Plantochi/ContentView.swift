//
//  ContentView.swift
//  Plantochi
//
//  Created by Max on 15.01.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Дом", systemImage: "house.fill")
                }
                .tag(0)
            
            TodayView()
                .tabItem {
                    Label("Сегодня", systemImage: "calendar")
                }
                .tag(1)
            
            QuestsView()
                .tabItem {
                    Label("Квесты", systemImage: "star.fill")
                }
                .tag(2)
            
            KnowledgeView()
                .tabItem {
                    Label("Книга", systemImage: "book.fill")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Label("Профиль", systemImage: "person.circle.fill")
                }
                .tag(4)
        }
        .tint(AppTheme.Colors.primaryGreen)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [PlantInstance.self, ActionLog.self, HomeEntity.self], inMemory: true)
}

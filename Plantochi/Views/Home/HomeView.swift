//
//  HomeView.swift
//  Plantochi
//
//  Created by Max on 15.01.2026.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PlantInstance.createdAt) private var plants: [PlantInstance]
    @Query private var homeEntities: [HomeEntity]
    
    @State private var viewModel = HomeViewModel()
    @State private var showingAddPlant = false
    @State private var selectedPlant: PlantInstance?
    
    private var homeEntity: HomeEntity? {
        homeEntities.first ?? {
            let new = HomeEntity()
            modelContext.insert(new)
            try? modelContext.save()
            return new
        }()
    }
    
    private var overallHealth: Double {
        guard let home = homeEntity, !plants.isEmpty else { return 0.5 }
        return home.overallHealth(plants: plants)
    }
    
    // Изометрическая сетка: 3 колонки, максимум 4 ряда
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фон
                AppTheme.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        // Тотем дома вверху
                        HStack {
                            TotemView(health: overallHealth)
                            Spacer()
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.top, AppTheme.Spacing.md)
                        
                        // Заголовок
                        HStack {
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                                Text("Мой дом")
                                    .font(AppTheme.Typography.largeTitle)
                                    .foregroundColor(AppTheme.Colors.softBrown)
                                
                                Text("\(plants.count) растений")
                                    .font(AppTheme.Typography.subheadline)
                                    .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            // Кнопка добавления
                            Button(action: { showingAddPlant = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(AppTheme.Colors.primaryGreen)
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        
                        // Изометрическая сетка растений
                        if plants.isEmpty {
                            // Пустое состояние
                            VStack(spacing: AppTheme.Spacing.lg) {
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(AppTheme.Colors.primaryGreen.opacity(0.3))
                                
                                Text("Добавьте первое растение")
                                    .font(AppTheme.Typography.title2)
                                    .foregroundColor(AppTheme.Colors.softBrown)
                                
                                Text("Нажмите + чтобы начать")
                                    .font(AppTheme.Typography.body)
                                    .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.Spacing.xxl)
                        } else {
                            LazyVGrid(columns: columns, spacing: AppTheme.Spacing.md) {
                                ForEach(plants.prefix(12), id: \.id) { plant in
                                    PlantCardView(plant: plant) {
                                        selectedPlant = plant
                                    }
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.lg)
                        }
                        
                        Spacer(minLength: AppTheme.Spacing.xl)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddPlant) {
                AddPlantView()
            }
            .sheet(item: $selectedPlant) { plant in
                PlantDetailView(plant: plant)
            }
        }
        .onAppear {
            viewModel.loadData(modelContext: modelContext)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [PlantInstance.self, ActionLog.self, HomeEntity.self], inMemory: true)
}

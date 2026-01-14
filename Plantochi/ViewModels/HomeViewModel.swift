//
//  HomeViewModel.swift
//  Plantochi
//
//  Created by Max on 15.01.2026.
//

import Foundation
import SwiftData

@Observable
class HomeViewModel {
    var plants: [PlantInstance] = []
    var homeEntity: HomeEntity?
    
    func loadData(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<PlantInstance>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        
        do {
            plants = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch plants: \(error)")
            plants = []
        }
        
        // Загрузить или создать HomeEntity
        let homeDescriptor = FetchDescriptor<HomeEntity>()
        do {
            let homes = try modelContext.fetch(homeDescriptor)
            if let existing = homes.first {
                homeEntity = existing
            } else {
                let newHome = HomeEntity()
                modelContext.insert(newHome)
                homeEntity = newHome
                try? modelContext.save()
            }
        } catch {
            print("Failed to fetch home entity: \(error)")
        }
    }
    
    func addPlant(_ plant: PlantInstance, modelContext: ModelContext) {
        modelContext.insert(plant)
        plants.append(plant)
        try? modelContext.save()
    }
    
    func deletePlant(_ plant: PlantInstance, modelContext: ModelContext) {
        modelContext.delete(plant)
        plants.removeAll { $0.id == plant.id }
        try? modelContext.save()
    }
}

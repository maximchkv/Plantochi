//
//  PlantViewModel.swift
//  Plantochi
//
//  Created by Max on 15.01.2026.
//

import Foundation
import SwiftData

@Observable
class PlantViewModel {
    var plant: PlantInstance
    var actionLogs: [ActionLog] = []
    
    init(plant: PlantInstance) {
        self.plant = plant
    }
    
    func loadActionLogs(modelContext: ModelContext) {
        // SwiftData предикаты имеют ограничения с опциональными связями
        // Загружаем все логи и фильтруем вручную
        let descriptor = FetchDescriptor<ActionLog>(
            sortBy: [SortDescriptor(\.performedAt, order: .reverse)]
        )
        
        do {
            let allLogs = try modelContext.fetch(descriptor)
            // Фильтруем логи для текущего растения
            actionLogs = allLogs.filter { $0.plant?.id == plant.id }
        } catch {
            print("Failed to fetch action logs: \(error)")
            actionLogs = []
        }
    }
    
    func performAction(_ action: PlantAction, note: String? = nil, photoData: Data? = nil, modelContext: ModelContext) {
        let log = ActionLog(
            actionType: action,
            performedAt: Date(),
            note: note,
            photoData: photoData
        )
        log.plant = plant
        
        modelContext.insert(log)
        
        // Обновить состояние растения в зависимости от действия
        updatePlantState(after: action)
        
        // Разблокировать связанные узлы знаний
        unlockRelatedKnowledgeNodes(for: action, modelContext: modelContext)
        
        // Обновить логи
        actionLogs.insert(log, at: 0)
        
        try? modelContext.save()
    }
    
    private func unlockRelatedKnowledgeNodes(for action: PlantAction, modelContext: ModelContext) {
        let descriptor = FetchDescriptor<KnowledgeNode>()
        
        do {
            let allNodes = try modelContext.fetch(descriptor)
            // Найти узлы, связанные с этим действием
            let relatedNodes = allNodes.filter { node in
                node.relatedAction == action && !node.isUnlocked
            }
            
            // Разблокировать найденные узлы
            for node in relatedNodes {
                node.isUnlocked = true
                node.unlockedAt = Date()
            }
            
            if !relatedNodes.isEmpty {
                try? modelContext.save()
            }
        } catch {
            print("Failed to unlock knowledge nodes: \(error)")
        }
    }
    
    private func updatePlantState(after action: PlantAction) {
        switch action {
        case .watering:
            plant.moistureLevel = min(1.0, plant.moistureLevel + 0.3)
            plant.stressLevel = max(0.0, plant.stressLevel - 0.1)
        case .fertilizing:
            plant.stressLevel = max(0.0, plant.stressLevel - 0.15)
        case .rotating:
            plant.stressLevel = max(0.0, plant.stressLevel - 0.05)
        case .cleaning:
            plant.stressLevel = max(0.0, plant.stressLevel - 0.1)
        case .repotting:
            plant.moistureLevel = min(1.0, plant.moistureLevel + 0.2)
            plant.stressLevel = max(0.0, plant.stressLevel - 0.2)
        case .pruning:
            plant.stressLevel = max(0.0, plant.stressLevel - 0.1)
        }
    }
    
    // Симуляция постепенного изменения состояния (можно вызывать периодически)
    func simulateTimePassage() {
        // Влажность постепенно уменьшается
        plant.moistureLevel = max(0.0, plant.moistureLevel - 0.01)
        
        // Если влажность низкая, стресс увеличивается
        if plant.moistureLevel < 0.3 {
            plant.stressLevel = min(1.0, plant.stressLevel + 0.02)
        }
    }
}

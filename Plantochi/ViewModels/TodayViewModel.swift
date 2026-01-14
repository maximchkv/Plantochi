//
//  TodayViewModel.swift
//  Plantochi
//
//  Created by Max on 15.01.2026.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Action Execution Window
enum ActionWindow: String {
    case early = "Ранний"
    case normal = "Нормальный"
    case late = "Поздний"
    case missed = "Пропущен"
    
    var color: Color {
        switch self {
        case .early: return AppTheme.Colors.healthy
        case .normal: return AppTheme.Colors.needsAttention
        case .late: return AppTheme.Colors.atRisk
        case .missed: return AppTheme.Colors.atRisk
        }
    }
    
    var icon: String {
        switch self {
        case .early: return "✨"
        case .normal: return "💚"
        case .late: return "⚠️"
        case .missed: return "🔴"
        }
    }
}

// MARK: - Recommended Action
struct RecommendedAction: Identifiable {
    let id: UUID
    let plant: PlantInstance
    let action: PlantAction
    let daysSinceLastAction: Int?
    let window: ActionWindow
    let riskLevel: Double // 0-1
    let daysUntilOptimal: Int? // Сколько дней до оптимального окна (для ранних действий)
    
    var riskColor: Color {
        if riskLevel > 0.7 {
            return AppTheme.Colors.atRisk
        } else if riskLevel > 0.4 {
            return AppTheme.Colors.needsAttention
        } else {
            return AppTheme.Colors.healthy
        }
    }
    
    var riskIcon: String {
        if riskLevel > 0.7 {
            return "🔴"
        } else if riskLevel > 0.4 {
            return "⚠️"
        } else {
            return "💚"
        }
    }
    
    var recommendationText: String {
        switch window {
        case .early:
            if let days = daysUntilOptimal {
                return "Можно сделать через \(days) дн."
            }
            return "Можно сделать сейчас"
        case .normal:
            return "Рекомендуется сделать"
        case .late:
            return "Лучше сделать в ближайшее время"
        case .missed:
            return "Важно сделать как можно скорее"
        }
    }
}

@Observable
class TodayViewModel {
    var recommendedActions: [RecommendedAction] = []
    var plants: [PlantInstance] = []
    var knowledgeNodes: [KnowledgeNode] = []
    
    // MARK: - Load Data
    func loadData(modelContext: ModelContext) {
        loadPlants(modelContext: modelContext)
        loadKnowledgeNodes(modelContext: modelContext)
        calculateRecommendations(modelContext: modelContext)
    }
    
    private func loadKnowledgeNodes(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<KnowledgeNode>()
        
        do {
            knowledgeNodes = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch knowledge nodes: \(error)")
            knowledgeNodes = []
        }
    }
    
    // MARK: - Get Related Knowledge Nodes
    func getRelatedKnowledgeNodes(for action: PlantAction) -> [KnowledgeNode] {
        knowledgeNodes.filter { node in
            node.relatedAction == action && node.isUnlocked
        }
    }
    
    private func loadPlants(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<PlantInstance>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        
        do {
            plants = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch plants: \(error)")
            plants = []
        }
    }
    
    // MARK: - Calculate Recommendations
    private func calculateRecommendations(modelContext: ModelContext) {
        var recommendations: [RecommendedAction] = []
        
        for plant in plants {
            // Получаем последние действия для каждого типа
            let lastActions = getLastActionsForPlant(plant: plant, modelContext: modelContext)
            
            // Для каждого типа действия проверяем, нужно ли его рекомендовать
            for action in PlantAction.allCases {
                let lastActionDate = lastActions[action]
                let recommendation = calculateActionRecommendation(
                    plant: plant,
                    action: action,
                    lastActionDate: lastActionDate
                )
                
                if let recommendation = recommendation {
                    recommendations.append(recommendation)
                }
            }
        }
        
        // Фильтруем: показываем только действия с достаточным приоритетом
        // Исключаем ранние действия с очень низким риском (риск < 0.2)
        let filtered = recommendations.filter { recommendation in
            if recommendation.window == .early && recommendation.riskLevel < 0.2 {
                return false
            }
            return true
        }
        
        // Сортируем по уровню риска (высокий риск первым)
        recommendedActions = filtered.sorted { $0.riskLevel > $1.riskLevel }
    }
    
    private func getLastActionsForPlant(plant: PlantInstance, modelContext: ModelContext) -> [PlantAction: Date] {
        let descriptor = FetchDescriptor<ActionLog>(
            sortBy: [SortDescriptor(\.performedAt, order: .reverse)]
        )
        
        var lastActions: [PlantAction: Date] = [:]
        
        do {
            let allLogs = try modelContext.fetch(descriptor)
            let plantLogs = allLogs.filter { $0.plant?.id == plant.id }
            
            for log in plantLogs {
                if lastActions[log.action] == nil {
                    lastActions[log.action] = log.performedAt
                }
            }
        } catch {
            print("Failed to fetch action logs: \(error)")
        }
        
        return lastActions
    }
    
    private func calculateActionRecommendation(
        plant: PlantInstance,
        action: PlantAction,
        lastActionDate: Date?
    ) -> RecommendedAction? {
        let intervalDays = action.defaultIntervalDays
        let now = Date()
        
        // Если действия никогда не было, рекомендовать через неделю после добавления растения
        guard let lastDate = lastActionDate else {
            let daysSincePlantAdded = Calendar.current.dateComponents([.day], from: plant.createdAt, to: now).day ?? 0
            
            // Для полива рекомендовать сразу, для остальных - через неделю
            if action == .watering && daysSincePlantAdded >= 0 {
                return RecommendedAction(
                    id: UUID(),
                    plant: plant,
                    action: action,
                    daysSinceLastAction: nil,
                    window: .normal,
                    riskLevel: 0.3,
                    daysUntilOptimal: nil
                )
            } else if daysSincePlantAdded >= 7 {
                return RecommendedAction(
                    id: UUID(),
                    plant: plant,
                    action: action,
                    daysSinceLastAction: nil,
                    window: .normal,
                    riskLevel: 0.4,
                    daysUntilOptimal: nil
                )
            }
            return nil
        }
        
        let daysSince = Calendar.current.dateComponents([.day], from: lastDate, to: now).day ?? 0
        
        // Определяем окно выполнения
        let earlyThreshold = Int(Double(intervalDays) * 0.5) // 50% от интервала
        let lateThreshold = Int(Double(intervalDays) * 1.2) // 120% от интервала
        let missedThreshold = Int(Double(intervalDays) * 1.5) // 150% от интервала
        
        let window: ActionWindow
        let riskLevel: Double
        let daysUntilOptimal: Int?
        
        if daysSince < earlyThreshold {
            window = .early
            riskLevel = 0.1
            daysUntilOptimal = earlyThreshold - daysSince
        } else if daysSince <= intervalDays {
            window = .normal
            riskLevel = 0.3 + (Double(daysSince - earlyThreshold) / Double(intervalDays - earlyThreshold)) * 0.2
            daysUntilOptimal = nil
        } else if daysSince <= lateThreshold {
            window = .late
            riskLevel = 0.5 + (Double(daysSince - intervalDays) / Double(lateThreshold - intervalDays)) * 0.3
            daysUntilOptimal = nil
        } else {
            window = .missed
            riskLevel = 0.8 + min(0.2, Double(daysSince - missedThreshold) / Double(intervalDays) * 0.2)
            daysUntilOptimal = nil
        }
        
        // Учитываем состояние растения для корректировки риска
        let adjustedRisk = adjustRiskForPlantHealth(riskLevel: riskLevel, plant: plant, action: action)
        
        return RecommendedAction(
            id: UUID(),
            plant: plant,
            action: action,
            daysSinceLastAction: daysSince,
            window: window,
            riskLevel: adjustedRisk,
            daysUntilOptimal: daysUntilOptimal
        )
    }
    
    private func adjustRiskForPlantHealth(riskLevel: Double, plant: PlantInstance, action: PlantAction) -> Double {
        var adjusted = riskLevel
        
        // Если растение в плохом состоянии, увеличиваем приоритет полива и удобрения
        if plant.healthStatus == .atRisk {
            if action == .watering || action == .fertilizing {
                adjusted = min(1.0, adjusted + 0.2)
            }
        }
        
        // Если влажность очень низкая, полив становится критичным
        if action == .watering && plant.moistureLevel < 0.3 {
            adjusted = min(1.0, adjusted + 0.3)
        }
        
        return adjusted
    }
}

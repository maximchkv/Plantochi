//
//  DataModels.swift
//  Plantochi
//
//  Created by Max on 15.01.2026.
//

import Foundation
import SwiftData

// MARK: - Plant Type Enum
enum PlantType: String, Codable, CaseIterable {
    case succulent = "Суккулент"
    case ficus = "Фикус"
    case monstera = "Монстера"
    case pothos = "Потос"
    case snake = "Сансевиерия"
    case aloe = "Алоэ"
    case fern = "Папоротник"
    case spider = "Хлорофитум"
    
    var icon: String {
        switch self {
        case .succulent: return "🌵"
        case .ficus: return "🌳"
        case .monstera: return "🌿"
        case .pothos: return "🪴"
        case .snake: return "🌱"
        case .aloe: return "🌾"
        case .fern: return "🍃"
        case .spider: return "🪴"
        }
    }
}

// MARK: - Plant Action Enum
enum PlantAction: String, Codable, CaseIterable {
    case watering = "Полив"
    case fertilizing = "Удобрение"
    case rotating = "Поворот"
    case cleaning = "Очистка"
    case repotting = "Пересадка"
    case pruning = "Обрезка"
    
    var icon: String {
        switch self {
        case .watering: return "💧"
        case .fertilizing: return "🌱"
        case .rotating: return "🔄"
        case .cleaning: return "🧹"
        case .repotting: return "🪴"
        case .pruning: return "✂️"
        }
    }
    
    var description: String {
        switch self {
        case .watering: return "Увлажнение почвы"
        case .fertilizing: return "Подкормка питательными веществами"
        case .rotating: return "Поворот для равномерного роста"
        case .cleaning: return "Очистка листьев от пыли"
        case .repotting: return "Пересадка в новый горшок"
        case .pruning: return "Обрезка сухих листьев"
        }
    }
    
    var defaultIntervalDays: Int {
        switch self {
        case .watering: return 7
        case .fertilizing: return 30
        case .rotating: return 14
        case .cleaning: return 21
        case .repotting: return 365
        case .pruning: return 60
        }
    }
}

// MARK: - Plant Instance Model
@Model
final class PlantInstance {
    var id: UUID
    var name: String
    var plantType: String // PlantType rawValue
    var photoData: Data?
    var createdAt: Date
    var moistureLevel: Double // 0-1, скрытый параметр
    var stressLevel: Double // 0-1, скрытый параметр
    @Relationship(deleteRule: .cascade) var actionLogs: [ActionLog]?
    
    init(
        id: UUID = UUID(),
        name: String,
        plantType: PlantType,
        photoData: Data? = nil,
        createdAt: Date = Date(),
        moistureLevel: Double = 0.7,
        stressLevel: Double = 0.0
    ) {
        self.id = id
        self.name = name
        self.plantType = plantType.rawValue
        self.photoData = photoData
        self.createdAt = createdAt
        self.moistureLevel = moistureLevel
        self.stressLevel = stressLevel
        self.actionLogs = []
    }
    
    var type: PlantType {
        get {
            PlantType(rawValue: plantType) ?? .succulent
        }
        set {
            plantType = newValue.rawValue
        }
    }
    
    // Computed: визуальное состояние здоровья
    var healthStatus: HealthStatus {
        let health = (moistureLevel * 0.6) + ((1.0 - stressLevel) * 0.4)
        
        if health > 0.75 {
            return .healthy
        } else if health > 0.5 {
            return .needsAttention
        } else {
            return .atRisk
        }
    }
    
    // Текстовый сигнал настроения
    var moodSignal: String {
        switch healthStatus {
        case .healthy:
            return ["Выглядит отлично! 🌟", "Растёт и радуется ☀️", "В прекрасной форме ✨"].randomElement() ?? "Выглядит отлично!"
        case .needsAttention:
            return ["Нужна небольшая забота 💚", "Внимание не помешает 🌿", "Готово к уходу 🪴"].randomElement() ?? "Нужна небольшая забота"
        case .atRisk:
            return ["Требует внимания ⚠️", "Нужна помощь 🌱", "Важно проверить 🔍"].randomElement() ?? "Требует внимания"
        }
    }
}

enum HealthStatus {
    case healthy
    case needsAttention
    case atRisk
}

// MARK: - Action Log Model
@Model
final class ActionLog {
    var id: UUID
    var actionType: String // PlantAction rawValue
    var performedAt: Date
    var note: String?
    var photoData: Data?
    var plant: PlantInstance?
    
    init(
        id: UUID = UUID(),
        actionType: PlantAction,
        performedAt: Date = Date(),
        note: String? = nil,
        photoData: Data? = nil
    ) {
        self.id = id
        self.actionType = actionType.rawValue
        self.performedAt = performedAt
        self.note = note
        self.photoData = photoData
    }
    
    var action: PlantAction {
        get {
            PlantAction(rawValue: actionType) ?? .watering
        }
        set {
            actionType = newValue.rawValue
        }
    }
}

// MARK: - Home Entity Model
@Model
final class HomeEntity {
    var id: UUID
    var totemLevel: Int
    var lastUpdated: Date
    
    init(
        id: UUID = UUID(),
        totemLevel: Int = 1,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.totemLevel = totemLevel
        self.lastUpdated = lastUpdated
    }
    
    // Computed: общее здоровье дома (из всех растений)
    func overallHealth(plants: [PlantInstance]) -> Double {
        guard !plants.isEmpty else { return 0.5 }
        
        let totalHealth = plants.reduce(0.0) { sum, plant in
            let health = (plant.moistureLevel * 0.6) + ((1.0 - plant.stressLevel) * 0.4)
            return sum + health
        }
        
        return totalHealth / Double(plants.count)
    }
}

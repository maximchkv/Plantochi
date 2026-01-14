//
//  ProfileViewModel.swift
//  Plantochi
//
//  Created by Max on 15.01.2026.
//

import Foundation
import SwiftData

@Observable
class ProfileViewModel {
    var streaks: [Streak] = []
    var achievements: [Achievement] = []
    var plants: [PlantInstance] = []
    var actionLogs: [ActionLog] = []
    var quests: [Quest] = []
    var knowledgeNodes: [KnowledgeNode] = []
    
    // MARK: - Load Data
    func loadData(modelContext: ModelContext) {
        loadStreaks(modelContext: modelContext)
        loadAchievements(modelContext: modelContext)
        loadPlants(modelContext: modelContext)
        loadActionLogs(modelContext: modelContext)
        loadQuests(modelContext: modelContext)
        loadKnowledgeNodes(modelContext: modelContext)
        
        // Инициализировать стрики и достижения, если их нет
        if streaks.isEmpty {
            initializeStreaks(modelContext: modelContext)
        }
        
        if achievements.isEmpty {
            initializeAchievements(modelContext: modelContext)
        }
        
        // Обновить стрики и достижения
        updateStreaks(modelContext: modelContext)
        updateAchievements(modelContext: modelContext)
    }
    
    private func loadStreaks(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Streak>()
        do {
            streaks = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch streaks: \(error)")
            streaks = []
        }
    }
    
    private func loadAchievements(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Achievement>()
        do {
            achievements = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch achievements: \(error)")
            achievements = []
        }
    }
    
    private func loadPlants(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<PlantInstance>()
        do {
            plants = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch plants: \(error)")
            plants = []
        }
    }
    
    private func loadActionLogs(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<ActionLog>(
            sortBy: [SortDescriptor(\.performedAt, order: .reverse)]
        )
        do {
            actionLogs = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch action logs: \(error)")
            actionLogs = []
        }
    }
    
    private func loadQuests(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Quest>()
        do {
            quests = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch quests: \(error)")
            quests = []
        }
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
    
    // MARK: - Initialize Streaks
    private func initializeStreaks(modelContext: ModelContext) {
        for streakType in StreakType.allCases {
            let streak = Streak(streakType: streakType)
            modelContext.insert(streak)
        }
        
        do {
            try modelContext.save()
            loadStreaks(modelContext: modelContext)
        } catch {
            print("Failed to initialize streaks: \(error)")
        }
    }
    
    // MARK: - Initialize Achievements
    private func initializeAchievements(modelContext: ModelContext) {
        // Достижения за квесты
        let questAchievements = [
            ("Первый шаг", "Заверши свой первый квест", 1),
            ("Исследователь", "Заверши 5 квестов", 5),
            ("Мастер квестов", "Заверши 10 квестов", 10)
        ]
        
        for (title, description, target) in questAchievements {
            let achievement = Achievement(
                achievementType: .quest,
                title: title,
                achievementDescription: description,
                icon: "⭐",
                targetValue: target
            )
            modelContext.insert(achievement)
        }
        
        // Достижения за открытия
        let discoveryAchievements = [
            ("Любопытный", "Открой 5 узлов знаний", 5),
            ("Учёный", "Открой 15 узлов знаний", 15),
            ("Эксперт", "Открой все узлы знаний", 30)
        ]
        
        for (title, description, target) in discoveryAchievements {
            let achievement = Achievement(
                achievementType: .discovery,
                title: title,
                achievementDescription: description,
                icon: "🔍",
                targetValue: target
            )
            modelContext.insert(achievement)
        }
        
        // Достижения за поведение
        let behaviorAchievements = [
            ("Заботливый", "Выполни 10 действий", 10),
            ("Садовник", "Выполни 50 действий", 50),
            ("Мастер ухода", "Выполни 100 действий", 100)
        ]
        
        for (title, description, target) in behaviorAchievements {
            let achievement = Achievement(
                achievementType: .behavior,
                title: title,
                achievementDescription: description,
                icon: "💚",
                targetValue: target
            )
            modelContext.insert(achievement)
        }
        
        // Достижения за регулярность
        let regularityAchievements = [
            ("Неделя заботы", "7 дней подряд входов", 7),
            ("Месяц заботы", "30 дней подряд входов", 30),
            ("Год заботы", "365 дней подряд входов", 365)
        ]
        
        for (title, description, target) in regularityAchievements {
            let achievement = Achievement(
                achievementType: .regularity,
                title: title,
                achievementDescription: description,
                icon: "📅",
                targetValue: target
            )
            modelContext.insert(achievement)
        }
        
        do {
            try modelContext.save()
            loadAchievements(modelContext: modelContext)
        } catch {
            print("Failed to initialize achievements: \(error)")
        }
    }
    
    // MARK: - Update Streaks
    private func updateStreaks(modelContext: ModelContext) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        for streak in streaks {
            let lastDate = calendar.startOfDay(for: streak.lastActivityDate)
            let daysSince = calendar.dateComponents([.day], from: lastDate, to: today).day ?? 0
            
            switch streak.type {
            case .login:
                // Обновляется при каждом открытии приложения
                if daysSince == 0 {
                    // Сегодня уже засчитано - ничего не делаем
                    continue
                } else if daysSince == 1 {
                    // Вчера был вход - продолжаем стрик
                    streak.currentLength += 1
                    streak.lastActivityDate = Date()
                    if streak.currentLength > streak.longestStreak {
                        streak.longestStreak = streak.currentLength
                    }
                } else {
                    // Пропуск - фиксируем, но не сбрасываем стрик
                    // Если это первый вход (currentLength == 0), начинаем стрик
                    if streak.currentLength == 0 {
                        streak.currentLength = 1
                        streak.lastActivityDate = Date()
                    } else {
                        streak.missedDates.append(Date())
                    }
                }
                
            case .action:
                // Обновляется при выполнении действий
                let todayActions = actionLogs.filter { log in
                    calendar.isDate(log.performedAt, inSameDayAs: today)
                }
                
                if !todayActions.isEmpty {
                    if daysSince == 0 {
                        continue
                    } else if daysSince == 1 {
                        streak.currentLength += 1
                        streak.lastActivityDate = Date()
                        if streak.currentLength > streak.longestStreak {
                            streak.longestStreak = streak.currentLength
                        }
                    } else if daysSince > 1 {
                        streak.missedDates.append(Date())
                    }
                }
                
            case .quest:
                // Обновляется при завершении квестов
                let todayCompletedQuests = quests.filter { quest in
                    if let completedAt = quest.completedAt {
                        return calendar.isDate(completedAt, inSameDayAs: today)
                    }
                    return false
                }
                
                if !todayCompletedQuests.isEmpty {
                    if daysSince == 0 {
                        continue
                    } else if daysSince == 1 {
                        streak.currentLength += 1
                        streak.lastActivityDate = Date()
                        if streak.currentLength > streak.longestStreak {
                            streak.longestStreak = streak.currentLength
                        }
                    } else if daysSince > 1 {
                        streak.missedDates.append(Date())
                    }
                }
                
            case .observation:
                // Пока не реализовано - можно добавить позже
                break
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to update streaks: \(error)")
        }
    }
    
    // MARK: - Update Achievements
    private func updateAchievements(modelContext: ModelContext) {
        for achievement in achievements {
            var shouldUpdate = false
            var newValue = achievement.currentValue
            var newProgress: Double = 0.0
            
            switch achievement.type {
            case .quest:
                let completedQuests = quests.filter { $0.state == .completed }.count
                newValue = completedQuests
                shouldUpdate = newValue != achievement.currentValue
                
            case .discovery:
                let unlockedNodes = knowledgeNodes.filter { $0.isUnlocked }.count
                newValue = unlockedNodes
                shouldUpdate = newValue != achievement.currentValue
                
            case .behavior:
                newValue = actionLogs.count
                shouldUpdate = newValue != achievement.currentValue
                
            case .regularity:
                if let loginStreak = streaks.first(where: { $0.type == .login }) {
                    newValue = loginStreak.currentLength
                    shouldUpdate = newValue != achievement.currentValue
                }
            }
            
            if let target = achievement.targetValue {
                newProgress = min(1.0, Double(newValue) / Double(target))
            }
            
            if shouldUpdate {
                achievement.currentValue = newValue
                achievement.progress = newProgress
                
                // Разблокировать достижение, если достигнута цель
                if !achievement.isUnlocked && newValue >= (achievement.targetValue ?? 0) {
                    achievement.unlockedAt = Date()
                }
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to update achievements: \(error)")
        }
    }
    
    // MARK: - Statistics
    var totalActions: Int {
        actionLogs.count
    }
    
    var totalPlants: Int {
        plants.count
    }
    
    var completedQuestsCount: Int {
        quests.filter { $0.state == .completed }.count
    }
    
    var unlockedKnowledgeNodes: Int {
        knowledgeNodes.filter { $0.isUnlocked }.count
    }
    
    var unlockedAchievements: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    var totalAchievements: Int {
        achievements.count
    }
}

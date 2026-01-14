//
//  KnowledgeViewModel.swift
//  Plantochi
//
//  Created by Max on 15.01.2026.
//

import Foundation
import SwiftData

@Observable
class KnowledgeViewModel {
    var knowledgeNodes: [KnowledgeNode] = []
    var quests: [Quest] = []
    
    // Группировка узлов по типам
    var indicatorNodes: [KnowledgeNode] {
        knowledgeNodes.filter { $0.type == .indicator && $0.isUnlocked }
    }
    
    var actionNodes: [KnowledgeNode] {
        knowledgeNodes.filter { $0.type == .action && $0.isUnlocked }
    }
    
    var consequenceNodes: [KnowledgeNode] {
        knowledgeNodes.filter { $0.type == .consequence && $0.isUnlocked }
    }
    
    var lockedNodes: [KnowledgeNode] {
        knowledgeNodes.filter { !$0.isUnlocked }
    }
    
    // Квесты по состояниям
    var activeQuests: [Quest] {
        quests.filter { $0.state == .active }
    }
    
    var completedQuests: [Quest] {
        quests.filter { $0.state == .completed }
    }
    
    var upcomingQuests: [Quest] {
        quests.filter { $0.state == .upcoming }
    }
    
    // MARK: - Load Data
    func loadData(modelContext: ModelContext) {
        loadKnowledgeNodes(modelContext: modelContext)
        loadQuests(modelContext: modelContext)
        
        // Если нет данных, создать начальные
        if knowledgeNodes.isEmpty {
            seedInitialData(modelContext: modelContext)
        }
    }
    
    private func loadKnowledgeNodes(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<KnowledgeNode>()
        
        do {
            let fetched = try modelContext.fetch(descriptor)
            // Сортируем вручную, так как SortDescriptor может иметь проблемы с @Model
            knowledgeNodes = fetched.sorted { first, second in
                if first.isUnlocked != second.isUnlocked {
                    return first.isUnlocked && !second.isUnlocked
                }
                return first.title < second.title
            }
        } catch {
            print("Failed to fetch knowledge nodes: \(error)")
            knowledgeNodes = []
        }
    }
    
    private func loadQuests(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Quest>(
            sortBy: [
                SortDescriptor(\.questState),
                SortDescriptor(\.createdAt, order: .reverse)
            ]
        )
        
        do {
            quests = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch quests: \(error)")
            quests = []
        }
    }
    
    // MARK: - Unlock Node
    func unlockNode(_ node: KnowledgeNode, modelContext: ModelContext) {
        guard !node.isUnlocked else { return }
        
        node.isUnlocked = true
        node.unlockedAt = Date()
        
        do {
            try modelContext.save()
            loadKnowledgeNodes(modelContext: modelContext)
        } catch {
            print("Failed to unlock node: \(error)")
        }
    }
    
    // MARK: - Quest Management
    func startQuest(_ quest: Quest, modelContext: ModelContext) {
        guard quest.state == .upcoming else { return }
        
        quest.state = .active
        
        do {
            try modelContext.save()
            loadQuests(modelContext: modelContext)
        } catch {
            print("Failed to start quest: \(error)")
        }
    }
    
    func completeQuest(_ quest: Quest, modelContext: ModelContext) {
        guard quest.state == .active else { return }
        
        quest.state = .completed
        quest.completedAt = Date()
        
        // Разблокировать связанные узлы знаний
        for nodeId in quest.nodeIds {
            if let node = knowledgeNodes.first(where: { $0.id == nodeId }) {
                unlockNode(node, modelContext: modelContext)
            }
        }
        
        do {
            try modelContext.save()
            loadQuests(modelContext: modelContext)
            loadKnowledgeNodes(modelContext: modelContext)
        } catch {
            print("Failed to complete quest: \(error)")
        }
    }
    
    // MARK: - Find Related Nodes
    func findRelatedNodes(for node: KnowledgeNode) -> [KnowledgeNode] {
        node.relatedNodeIds.compactMap { nodeId in
            knowledgeNodes.first { $0.id == nodeId }
        }
    }
    
    // MARK: - Seed Initial Data
    private func seedInitialData(modelContext: ModelContext) {
        // Создаём начальные узлы знаний
        
        // 1. Индикатор: Сухие листья
        let dryLeavesIndicator = KnowledgeNode(
            nodeType: .indicator,
            title: "Сухие кончики листьев",
            nodeDescription: "Растение сигнализирует о недостатке влаги",
            observation: "Обрати внимание на кончики листьев — они становятся коричневыми и сухими",
            whyImportant: "Это ранний признак обезвоживания. Если заметить вовремя, можно легко помочь растению",
            isUnlocked: true,
            unlockedAt: Date()
        )
        
        // 2. Действие: Полив
        let wateringAction = KnowledgeNode(
            nodeType: .action,
            title: "Правильный полив",
            nodeDescription: "Как поливать растение, чтобы оно получало достаточно влаги",
            observation: "Проверь почву пальцем — если верхний слой сухой, пора поливать",
            whyImportant: "Регулярный полив поддерживает здоровье корневой системы и помогает растению расти",
            isUnlocked: true,
            unlockedAt: Date(),
            relatedActionType: .watering,
            relatedNodeIds: [dryLeavesIndicator.id]
        )
        
        // 3. Последствие: Здоровый рост
        let healthyGrowth = KnowledgeNode(
            nodeType: .consequence,
            title: "Здоровый рост",
            nodeDescription: "Когда растение получает достаточно влаги, оно активно растёт",
            observation: "Новые листья появляются регулярно, растение выглядит свежим",
            whyImportant: "Здоровое растение не только красиво, но и очищает воздух и создаёт уют",
            isUnlocked: false,
            relatedNodeIds: [wateringAction.id]
        )
        
        // 4. Индикатор: Пожелтение листьев
        let yellowLeaves = KnowledgeNode(
            nodeType: .indicator,
            title: "Пожелтение листьев",
            nodeDescription: "Листья меняют цвет — это может быть признаком разных проблем",
            observation: "Обрати внимание, какие листья желтеют — нижние или верхние, старые или новые",
            whyImportant: "Разные причины пожелтения требуют разных действий",
            isUnlocked: false,
            relatedNodeIds: [dryLeavesIndicator.id]
        )
        
        // 5. Действие: Очистка листьев
        let cleaningAction = KnowledgeNode(
            nodeType: .action,
            title: "Очистка листьев",
            nodeDescription: "Регулярная очистка помогает растению дышать",
            observation: "Пыль на листьях мешает фотосинтезу и может привлекать вредителей",
            whyImportant: "Чистые листья лучше поглощают свет и выглядят красивее",
            isUnlocked: false,
            relatedActionType: .cleaning,
            relatedNodeIds: [yellowLeaves.id]
        )
        
        // Вставляем узлы
        modelContext.insert(dryLeavesIndicator)
        modelContext.insert(wateringAction)
        modelContext.insert(healthyGrowth)
        modelContext.insert(yellowLeaves)
        modelContext.insert(cleaningAction)
        
        // Создаём начальный квест
        let firstQuest = Quest(
            title: "Первое знакомство",
            questDescription: "Добавь своё первое растение и узнай основы ухода",
            questState: .upcoming,
            nodeIds: [dryLeavesIndicator.id, wateringAction.id],
            riskLevel: 0.0
        )
        
        modelContext.insert(firstQuest)
        
        do {
            try modelContext.save()
            loadData(modelContext: modelContext)
        } catch {
            print("Failed to seed initial data: \(error)")
        }
    }
}

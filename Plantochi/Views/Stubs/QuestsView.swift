//
//  QuestsView.swift
//  Plantochi
//
//  Created by Max on 15.01.2026.
//

import SwiftUI
import SwiftData

struct QuestsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = KnowledgeViewModel()
    @State private var selectedQuest: Quest?
    @State private var selectedSection: QuestSection = .active
    
    enum QuestSection: String, CaseIterable {
        case active = "Активные"
        case completed = "Завершённые"
        case upcoming = "Скоро"
    }
    
    var filteredQuests: [Quest] {
        switch selectedSection {
        case .active:
            return viewModel.activeQuests
        case .completed:
            return viewModel.completedQuests
        case .upcoming:
            return viewModel.upcomingQuests
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                if viewModel.quests.isEmpty {
                    // Пустое состояние
                    VStack(spacing: AppTheme.Spacing.lg) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.Colors.accentTerracotta.opacity(0.3))
                        
                        Text("Квесты")
                            .font(AppTheme.Typography.title)
                            .foregroundColor(AppTheme.Colors.softBrown)
                        
                        Text("Обучающие квесты появятся здесь")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: AppTheme.Spacing.lg) {
                            // Заголовок
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                                Text("Квесты")
                                    .font(AppTheme.Typography.largeTitle)
                                    .foregroundColor(AppTheme.Colors.softBrown)
                                
                                Text("\(viewModel.activeQuests.count) активных")
                                    .font(AppTheme.Typography.subheadline)
                                    .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .padding(.top, AppTheme.Spacing.md)
                            
                            // Сегментированный контрол
                            Picker("Секция", selection: $selectedSection) {
                                ForEach(QuestSection.allCases, id: \.self) { section in
                                    Text(section.rawValue).tag(section)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            
                            // Список квестов
                            if filteredQuests.isEmpty {
                                VStack(spacing: AppTheme.Spacing.md) {
                                    Image(systemName: selectedSection == .active ? "checkmark.circle" : "clock")
                                        .font(.system(size: 40))
                                        .foregroundColor(AppTheme.Colors.softBrown.opacity(0.3))
                                    
                                    Text(emptyStateMessage)
                                        .font(AppTheme.Typography.body)
                                        .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppTheme.Spacing.xl)
                            } else {
                                LazyVStack(spacing: AppTheme.Spacing.md) {
                                    ForEach(filteredQuests, id: \.id) { quest in
                                        QuestCard(quest: quest, viewModel: viewModel) {
                                            selectedQuest = quest
                                        }
                                    }
                                }
                                .padding(.horizontal, AppTheme.Spacing.lg)
                            }
                            
                            Spacer(minLength: AppTheme.Spacing.xl)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedQuest) { quest in
                QuestDetailView(quest: quest, viewModel: viewModel)
            }
            .onAppear {
                viewModel.loadData(modelContext: modelContext)
            }
        }
    }
    
    private var emptyStateMessage: String {
        switch selectedSection {
        case .active:
            return "Нет активных квестов"
        case .completed:
            return "Пока нет завершённых квестов"
        case .upcoming:
            return "Нет предстоящих квестов"
        }
    }
}

// MARK: - Quest Card
struct QuestCard: View {
    let quest: Quest
    let viewModel: KnowledgeViewModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                // Заголовок и статус
                HStack {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text(quest.title)
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.softBrown)
                            .multilineTextAlignment(.leading)
                        
                        Text(quest.questDescription)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    // Статус бейдж
                    Text(quest.state.rawValue)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(quest.state.color)
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(quest.state.color.opacity(0.1))
                        )
                }
                
                // Индикатор риска (если есть)
                if quest.riskLevel > 0 {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Circle()
                            .fill(riskColor)
                            .frame(width: 8, height: 8)
                        
                        Text("Риск: \(Int(quest.riskLevel * 100))%")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                    }
                }
                
                // Дедлайн (если есть)
                if let deadline = quest.deadline {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Colors.softBrown.opacity(0.5))
                        
                        Text("До \(deadline, style: .date)")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                    }
                }
                
                // Связанные узлы знаний
                if !quest.nodeIds.isEmpty {
                    let nodes = quest.nodeIds.compactMap { id in
                        viewModel.knowledgeNodes.first { $0.id == id }
                    }
                    
                    if !nodes.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppTheme.Spacing.sm) {
                                ForEach(nodes, id: \.id) { node in
                                    HStack(spacing: 4) {
                                        Text(node.type.icon)
                                            .font(.system(size: 12))
                                        Text(node.title)
                                            .font(AppTheme.Typography.caption)
                                            .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                                    }
                                    .padding(.horizontal, AppTheme.Spacing.sm)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(node.type.color.opacity(0.1))
                                    )
                                }
                            }
                        }
                    }
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(AppTheme.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                            .stroke(quest.state.color.opacity(0.3), lineWidth: quest.state == .active ? 2 : 0)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var riskColor: Color {
        if quest.riskLevel > 0.7 {
            return AppTheme.Colors.atRisk
        } else if quest.riskLevel > 0.4 {
            return AppTheme.Colors.needsAttention
        } else {
            return AppTheme.Colors.healthy
        }
    }
}

// MARK: - Quest Detail View
struct QuestDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let quest: Quest
    @State var viewModel: KnowledgeViewModel
    
    var questNodes: [KnowledgeNode] {
        quest.nodeIds.compactMap { id in
            viewModel.knowledgeNodes.first { $0.id == id }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                    // Заголовок
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text(quest.title)
                            .font(AppTheme.Typography.title)
                            .foregroundColor(AppTheme.Colors.softBrown)
                        
                        Text(quest.questDescription)
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.softBrown.opacity(0.8))
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.top, AppTheme.Spacing.md)
                    
                    // Статус
                    HStack {
                        Text("Статус:")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.softBrown)
                        
                        Text(quest.state.rawValue)
                            .font(AppTheme.Typography.body)
                            .foregroundColor(quest.state.color)
                            .padding(.horizontal, AppTheme.Spacing.sm)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(quest.state.color.opacity(0.1))
                            )
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    
                    // Дедлайн
                    if let deadline = quest.deadline {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Дедлайн: \(deadline, style: .date)")
                                .font(AppTheme.Typography.body)
                                .foregroundColor(AppTheme.Colors.softBrown.opacity(0.8))
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
                    }
                    
                    // Связанные узлы знаний
                    if !questNodes.isEmpty {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                            Text("Узлы знаний в квесте")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(AppTheme.Colors.softBrown)
                                .padding(.horizontal, AppTheme.Spacing.lg)
                            
                            ForEach(questNodes, id: \.id) { node in
                                HStack(spacing: AppTheme.Spacing.md) {
                                    ZStack {
                                        Circle()
                                            .fill(node.type.color.opacity(0.2))
                                            .frame(width: 40, height: 40)
                                        
                                        Text(node.type.icon)
                                            .font(.system(size: 20))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                                        Text(node.title)
                                            .font(AppTheme.Typography.subheadline)
                                            .foregroundColor(AppTheme.Colors.softBrown)
                                        
                                        Text(node.type.rawValue)
                                            .font(AppTheme.Typography.caption)
                                            .foregroundColor(node.type.color)
                                    }
                                    
                                    Spacer()
                                    
                                    if node.isUnlocked {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(AppTheme.Colors.primaryGreen)
                                    } else {
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(Color.gray.opacity(0.5))
                                    }
                                }
                                .padding(.horizontal, AppTheme.Spacing.lg)
                            }
                        }
                    }
                    
                    // Кнопки действий
                    if quest.state == .upcoming {
                        Button(action: {
                            viewModel.startQuest(quest, modelContext: modelContext)
                        }) {
                            Text("Начать квест")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppTheme.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                                        .fill(AppTheme.Colors.primaryGreen)
                                )
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.top, AppTheme.Spacing.md)
                    } else if quest.state == .active {
                        // Проверяем, все ли узлы разблокированы
                        let allUnlocked = questNodes.allSatisfy { $0.isUnlocked }
                        
                        if allUnlocked {
                            Button(action: {
                                viewModel.completeQuest(quest, modelContext: modelContext)
                                dismiss()
                            }) {
                                Text("Завершить квест")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, AppTheme.Spacing.md)
                                    .background(
                                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                                            .fill(AppTheme.Colors.primaryGreen)
                                    )
                            }
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .padding(.top, AppTheme.Spacing.md)
                        } else {
                            Text("Разблокируй все узлы знаний, чтобы завершить квест")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, AppTheme.Spacing.lg)
                                .padding(.top, AppTheme.Spacing.md)
                        }
                    }
                    
                    Spacer(minLength: AppTheme.Spacing.xl)
                }
            }
            .background(AppTheme.Colors.backgroundGradient)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    QuestsView()
        .modelContainer(for: [KnowledgeNode.self, Quest.self], inMemory: true)
}

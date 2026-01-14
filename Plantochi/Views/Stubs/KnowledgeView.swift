//
//  KnowledgeView.swift
//  Plantochi
//
//  Created by Max on 15.01.2026.
//

import SwiftUI
import SwiftData

struct KnowledgeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = KnowledgeViewModel()
    @State private var selectedSection: KnowledgeSection = .all
    @State private var selectedNode: KnowledgeNode?
    
    enum KnowledgeSection: String, CaseIterable {
        case all = "Все"
        case indicators = "Индикаторы"
        case actions = "Действия"
        case consequences = "Последствия"
    }
    
    var filteredNodes: [KnowledgeNode] {
        let nodes = viewModel.knowledgeNodes.filter { $0.isUnlocked }
        
        switch selectedSection {
        case .all:
            return nodes
        case .indicators:
            return nodes.filter { $0.type == .indicator }
        case .actions:
            return nodes.filter { $0.type == .action }
        case .consequences:
            return nodes.filter { $0.type == .consequence }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                if viewModel.knowledgeNodes.isEmpty {
                    // Пустое состояние
                    VStack(spacing: AppTheme.Spacing.lg) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.Colors.secondaryGreen.opacity(0.3))
                        
                        Text("Книга знаний")
                            .font(AppTheme.Typography.title)
                            .foregroundColor(AppTheme.Colors.softBrown)
                        
                        Text("Узлы знаний появятся здесь по мере изучения")
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
                                Text("Книга знаний")
                                    .font(AppTheme.Typography.largeTitle)
                                    .foregroundColor(AppTheme.Colors.softBrown)
                                
                                Text("\(viewModel.knowledgeNodes.filter { $0.isUnlocked }.count) открыто из \(viewModel.knowledgeNodes.count)")
                                    .font(AppTheme.Typography.subheadline)
                                    .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .padding(.top, AppTheme.Spacing.md)
                            
                            // Сегментированный контрол
                            Picker("Секция", selection: $selectedSection) {
                                ForEach(KnowledgeSection.allCases, id: \.self) { section in
                                    Text(section.rawValue).tag(section)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            
                            // Список узлов
                            if filteredNodes.isEmpty {
                                VStack(spacing: AppTheme.Spacing.md) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(AppTheme.Colors.softBrown.opacity(0.3))
                                    
                                    Text("В этой секции пока нет открытых узлов")
                                        .font(AppTheme.Typography.body)
                                        .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppTheme.Spacing.xl)
                            } else {
                                LazyVStack(spacing: AppTheme.Spacing.md) {
                                    ForEach(filteredNodes, id: \.id) { node in
                                        KnowledgeNodeCard(node: node) {
                                            selectedNode = node
                                        }
                                    }
                                }
                                .padding(.horizontal, AppTheme.Spacing.lg)
                            }
                            
                            // Заблокированные узлы (если есть)
                            if !viewModel.lockedNodes.isEmpty && selectedSection == .all {
                                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                                    Text("Ещё не открыто")
                                        .font(AppTheme.Typography.title2)
                                        .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                                        .padding(.horizontal, AppTheme.Spacing.lg)
                                    
                                    LazyVStack(spacing: AppTheme.Spacing.md) {
                                        ForEach(viewModel.lockedNodes, id: \.id) { node in
                                            LockedKnowledgeNodeCard(node: node)
                                        }
                                    }
                                    .padding(.horizontal, AppTheme.Spacing.lg)
                                }
                                .padding(.top, AppTheme.Spacing.lg)
                            }
                            
                            Spacer(minLength: AppTheme.Spacing.xl)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedNode) { node in
                KnowledgeNodeDetailView(node: node, viewModel: viewModel)
            }
            .onAppear {
                viewModel.loadData(modelContext: modelContext)
            }
        }
    }
}

// MARK: - Knowledge Node Card
struct KnowledgeNodeCard: View {
    let node: KnowledgeNode
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.Spacing.md) {
                // Иконка типа
                ZStack {
                    Circle()
                        .fill(node.type.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Text(node.type.icon)
                        .font(.system(size: 24))
                }
                
                // Информация
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(node.title)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.softBrown)
                        .multilineTextAlignment(.leading)
                    
                    Text(node.nodeDescription)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Метка типа
                    Text(node.type.rawValue)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(node.type.color)
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(node.type.color.opacity(0.1))
                        )
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.softBrown.opacity(0.5))
            }
            .padding(AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(AppTheme.Colors.cardBackground)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Locked Knowledge Node Card
struct LockedKnowledgeNodeCard: View {
    let node: KnowledgeNode
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Заблокированная иконка
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "lock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color.gray.opacity(0.5))
            }
            
            // Информация (затемнённая)
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(node.title)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(Color.gray.opacity(0.5))
                    .strikethrough()
                
                Text("Откроется позже")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(Color.gray.opacity(0.4))
            }
            
            Spacer()
        }
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

// MARK: - Knowledge Node Detail View
struct KnowledgeNodeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let node: KnowledgeNode
    let viewModel: KnowledgeViewModel
    
    var relatedNodes: [KnowledgeNode] {
        viewModel.findRelatedNodes(for: node)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                    // Заголовок с иконкой
                    HStack(spacing: AppTheme.Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(node.type.color.opacity(0.2))
                                .frame(width: 60, height: 60)
                            
                            Text(node.type.icon)
                                .font(.system(size: 30))
                        }
                        
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text(node.title)
                                .font(AppTheme.Typography.title)
                                .foregroundColor(AppTheme.Colors.softBrown)
                            
                            Text(node.type.rawValue)
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(node.type.color)
                                .padding(.horizontal, AppTheme.Spacing.sm)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(node.type.color.opacity(0.1))
                                )
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.top, AppTheme.Spacing.md)
                    
                    // Описание
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        Text("Описание")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.softBrown)
                        
                        Text(node.nodeDescription)
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.softBrown.opacity(0.8))
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    
                    // Что наблюдать
                    if let observation = node.observation {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                            HStack {
                                Text("👁️")
                                Text("Что наблюдать")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(AppTheme.Colors.softBrown)
                            }
                            
                            Text(observation)
                                .font(AppTheme.Typography.body)
                                .foregroundColor(AppTheme.Colors.softBrown.opacity(0.8))
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
                    }
                    
                    // Почему важно
                    if let whyImportant = node.whyImportant {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                            HStack {
                                Text("💡")
                                Text("Почему это важно")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(AppTheme.Colors.softBrown)
                            }
                            
                            Text(whyImportant)
                                .font(AppTheme.Typography.body)
                                .foregroundColor(AppTheme.Colors.softBrown.opacity(0.8))
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
                    }
                    
                    // Связанные узлы
                    if !relatedNodes.isEmpty {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                            Text("Связанные знания")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(AppTheme.Colors.softBrown)
                                .padding(.horizontal, AppTheme.Spacing.lg)
                            
                            ForEach(relatedNodes, id: \.id) { relatedNode in
                                HStack(spacing: AppTheme.Spacing.sm) {
                                    Text(relatedNode.type.icon)
                                    Text(relatedNode.title)
                                        .font(AppTheme.Typography.subheadline)
                                        .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                                }
                                .padding(.horizontal, AppTheme.Spacing.lg)
                            }
                        }
                    }
                    
                    // Дата открытия
                    if let unlockedAt = node.unlockedAt {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text("Открыто")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.softBrown.opacity(0.5))
                            
                            Text(unlockedAt, style: .date)
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
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
    KnowledgeView()
        .modelContainer(for: [KnowledgeNode.self, Quest.self], inMemory: true)
}

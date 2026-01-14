//
//  TodayView.swift
//  Plantochi
//
//  Created by Max on 15.01.2026.
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TodayViewModel()
    @State private var selectedAction: RecommendedAction?
    @State private var selectedPlant: PlantInstance?
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                if viewModel.recommendedActions.isEmpty {
                    // Пустое состояние
                    VStack(spacing: AppTheme.Spacing.lg) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.Colors.primaryGreen.opacity(0.3))
                        
                        Text("Всё в порядке")
                            .font(AppTheme.Typography.title)
                            .foregroundColor(AppTheme.Colors.softBrown)
                        
                        Text("На сегодня нет рекомендованных действий")
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
                                Text("Сегодня")
                                    .font(AppTheme.Typography.largeTitle)
                                    .foregroundColor(AppTheme.Colors.softBrown)
                                
                                Text("\(viewModel.recommendedActions.count) рекомендаций")
                                    .font(AppTheme.Typography.subheadline)
                                    .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .padding(.top, AppTheme.Spacing.md)
                            
                            // Список рекомендованных действий
                            LazyVStack(spacing: AppTheme.Spacing.md) {
                                ForEach(viewModel.recommendedActions) { recommendation in
                                    RecommendedActionCard(
                                        recommendation: recommendation,
                                        relatedNodes: viewModel.getRelatedKnowledgeNodes(for: recommendation.action)
                                    ) {
                                        selectedAction = recommendation
                                        selectedPlant = recommendation.plant
                                    }
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            
                            Spacer(minLength: AppTheme.Spacing.xl)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedAction) { action in
                if let plant = selectedPlant {
                    ActionSheetView(plant: plant)
                }
            }
            .onAppear {
                viewModel.loadData(modelContext: modelContext)
            }
            .refreshable {
                viewModel.loadData(modelContext: modelContext)
            }
        }
    }
}

// MARK: - Recommended Action Card
struct RecommendedActionCard: View {
    let recommendation: RecommendedAction
    let relatedNodes: [KnowledgeNode]
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                // Заголовок с растением и действием
                HStack {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text(recommendation.plant.name)
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.softBrown)
                        
                        HStack(spacing: AppTheme.Spacing.sm) {
                            Text(recommendation.action.icon)
                                .font(.system(size: 20))
                            
                            Text(recommendation.action.rawValue)
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(AppTheme.Colors.softBrown.opacity(0.8))
                        }
                    }
                    
                    Spacer()
                    
                    // Индикатор риска
                    VStack(spacing: AppTheme.Spacing.xs) {
                        Text(recommendation.riskIcon)
                            .font(.system(size: 24))
                        
                        // Окно выполнения
                        Text(recommendation.window.rawValue)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(recommendation.window.color)
                            .padding(.horizontal, AppTheme.Spacing.sm)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(recommendation.window.color.opacity(0.1))
                            )
                    }
                }
                
                // Рекомендация
                Text(recommendation.recommendationText)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                    .multilineTextAlignment(.leading)
                
                // Связанные узлы знаний (если есть)
                if !relatedNodes.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppTheme.Spacing.sm) {
                            ForEach(relatedNodes.prefix(3), id: \.id) { node in
                                HStack(spacing: 4) {
                                    Text(node.type.icon)
                                        .font(.system(size: 12))
                                    Text(node.title)
                                        .font(AppTheme.Typography.caption)
                                        .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                                        .lineLimit(1)
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
                
                // Дополнительная информация
                HStack(spacing: AppTheme.Spacing.md) {
                    if let daysSince = recommendation.daysSinceLastAction {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.Colors.softBrown.opacity(0.5))
                            
                            Text("\(daysSince) дн. назад")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                        }
                    }
                    
                    if let daysUntil = recommendation.daysUntilOptimal {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.Colors.softBrown.opacity(0.5))
                            
                            Text("Оптимально через \(daysUntil) дн.")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                        }
                    }
                    
                    Spacer()
                    
                    // Визуальный индикатор риска (полоска)
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(recommendation.riskColor)
                                .frame(width: geometry.size.width * recommendation.riskLevel, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .frame(maxWidth: 60)
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(AppTheme.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                            .stroke(recommendation.window.color.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    TodayView()
        .modelContainer(for: [PlantInstance.self, ActionLog.self, HomeEntity.self, KnowledgeNode.self, Quest.self], inMemory: true)
}

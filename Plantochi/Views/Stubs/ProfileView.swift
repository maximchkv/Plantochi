//
//  ProfileView.swift
//  Plantochi
//
//  Created by Max on 15.01.2026.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ProfileViewModel()
    @State private var selectedSection: ProfileSection = .streaks
    
    enum ProfileSection: String, CaseIterable {
        case streaks = "Стрики"
        case achievements = "Достижения"
        case statistics = "Статистика"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // Заголовок
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text("Профиль")
                                .font(AppTheme.Typography.largeTitle)
                                .foregroundColor(AppTheme.Colors.softBrown)
                            
                            Text("Твои достижения и прогресс")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.top, AppTheme.Spacing.md)
                        
                        // Сегментированный контрол
                        Picker("Секция", selection: $selectedSection) {
                            ForEach(ProfileSection.allCases, id: \.self) { section in
                                Text(section.rawValue).tag(section)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        
                        // Контент в зависимости от выбранной секции
                        switch selectedSection {
                        case .streaks:
                            streaksSection
                        case .achievements:
                            achievementsSection
                        case .statistics:
                            statisticsSection
                        }
                        
                        Spacer(minLength: AppTheme.Spacing.xl)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadData(modelContext: modelContext)
            }
            .refreshable {
                viewModel.loadData(modelContext: modelContext)
            }
        }
    }
    
    // MARK: - Streaks Section
    private var streaksSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            if viewModel.streaks.isEmpty {
                emptyStateView(message: "Стрики появятся здесь")
            } else {
                LazyVStack(spacing: AppTheme.Spacing.md) {
                    ForEach(viewModel.streaks, id: \.id) { streak in
                        StreakCard(streak: streak)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
            }
        }
    }
    
    // MARK: - Achievements Section
    private var achievementsSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Прогресс разблокировки
            VStack(spacing: AppTheme.Spacing.xs) {
                Text("\(viewModel.unlockedAchievements) из \(viewModel.totalAchievements)")
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(AppTheme.Colors.softBrown)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.Colors.primaryGreen, AppTheme.Colors.secondaryGreen],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * (Double(viewModel.unlockedAchievements) / Double(max(1, viewModel.totalAchievements))),
                                height: 12
                            )
                    }
                }
                .frame(height: 12)
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            
            // Группировка по типам
            let groupedAchievements = Dictionary(grouping: viewModel.achievements) { $0.type }
            
            ForEach(AchievementType.allCases, id: \.self) { type in
                if let achievements = groupedAchievements[type], !achievements.isEmpty {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        HStack {
                            Text(type.icon)
                            Text(type.rawValue)
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(AppTheme.Colors.softBrown)
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        
                        LazyVStack(spacing: AppTheme.Spacing.sm) {
                            ForEach(achievements, id: \.id) { achievement in
                                AchievementCard(achievement: achievement)
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
                    }
                }
            }
        }
    }
    
    // MARK: - Statistics Section
    private var statisticsSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: AppTheme.Spacing.md),
                GridItem(.flexible(), spacing: AppTheme.Spacing.md)
            ], spacing: AppTheme.Spacing.md) {
                StatCard(
                    icon: "🌿",
                    title: "Растений",
                    value: "\(viewModel.totalPlants)"
                )
                
                StatCard(
                    icon: "✋",
                    title: "Действий",
                    value: "\(viewModel.totalActions)"
                )
                
                StatCard(
                    icon: "⭐",
                    title: "Квестов",
                    value: "\(viewModel.completedQuestsCount)"
                )
                
                StatCard(
                    icon: "🔍",
                    title: "Знаний",
                    value: "\(viewModel.unlockedKnowledgeNodes)"
                )
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            
            // История заботы (последние действия)
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                Text("История заботы")
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(AppTheme.Colors.softBrown)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                
                if viewModel.actionLogs.isEmpty {
                    emptyStateView(message: "Пока нет действий")
                        .padding(.horizontal, AppTheme.Spacing.lg)
                } else {
                    LazyVStack(spacing: AppTheme.Spacing.sm) {
                        ForEach(viewModel.actionLogs.prefix(10), id: \.id) { log in
                            ActionHistoryRow(log: log)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                }
            }
        }
    }
    
    private func emptyStateView(message: String) -> some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "info.circle")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.Colors.softBrown.opacity(0.3))
            
            Text(message)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xl)
    }
}

// MARK: - Streak Card
struct StreakCard: View {
    let streak: Streak
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Text(streak.type.icon)
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(streak.type.rawValue)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.softBrown)
                    
                    Text("Текущая серия: \(streak.currentLength) дн.")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: AppTheme.Spacing.xs) {
                    Text("\(streak.currentLength)")
                        .font(AppTheme.Typography.title)
                        .foregroundColor(AppTheme.Colors.primaryGreen)
                    
                    if streak.longestStreak > streak.currentLength {
                        Text("Рекорд: \(streak.longestStreak)")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.softBrown.opacity(0.5))
                    }
                }
            }
            
            // Пропуски (если есть)
            if !streak.missedDates.isEmpty {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.Colors.softBrown.opacity(0.5))
                    
                    Text("Пропусков: \(streak.missedDates.count)")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(AppTheme.Colors.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Achievement Card
struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Иконка
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? AppTheme.Colors.primaryGreen.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Text(achievement.icon)
                    .font(.system(size: 24))
                    .opacity(achievement.isUnlocked ? 1.0 : 0.5)
            }
            
            // Информация
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(achievement.title)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(achievement.isUnlocked ? AppTheme.Colors.softBrown : Color.gray.opacity(0.5))
                
                Text(achievement.achievementDescription)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                    .lineLimit(2)
                
                // Прогресс (если есть цель)
                if let target = achievement.targetValue, !achievement.isUnlocked {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Text("\(achievement.currentValue) / \(target)")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 6)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(AppTheme.Colors.primaryGreen)
                                    .frame(width: geometry.size.width * achievement.progress, height: 6)
                            }
                        }
                        .frame(height: 6)
                        .frame(maxWidth: 60)
                    }
                }
            }
            
            Spacer()
            
            // Статус
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppTheme.Colors.primaryGreen)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(Color.gray.opacity(0.5))
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(achievement.isUnlocked ? AppTheme.Colors.cardBackground : Color.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                        .stroke(achievement.isUnlocked ? AppTheme.Colors.primaryGreen.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        )
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text(icon)
                .font(.system(size: 40))
            
            Text(value)
                .font(AppTheme.Typography.title)
                .foregroundColor(AppTheme.Colors.softBrown)
            
            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .fill(AppTheme.Colors.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Action History Row
struct ActionHistoryRow: View {
    let log: ActionLog
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Text(log.action.icon)
                .font(.system(size: 24))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(AppTheme.Colors.primaryGreen.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(log.action.rawValue)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.softBrown)
                
                if let plant = log.plant {
                    Text(plant.name)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                }
                
                Text(log.performedAt, style: .relative)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.softBrown.opacity(0.5))
            }
            
            Spacer()
        }
        .padding(AppTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                .fill(AppTheme.Colors.cardBackground.opacity(0.5))
        )
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [PlantInstance.self, ActionLog.self, HomeEntity.self, KnowledgeNode.self, Quest.self, Streak.self, Achievement.self], inMemory: true)
}

//
//  PlantDetailView.swift
//  Plantochi
//
//  Created by Max on 15.01.2026.
//

import SwiftUI
import SwiftData

struct PlantDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let plant: PlantInstance
    @State private var viewModel: PlantViewModel
    @State private var selectedMode: DetailMode = .view
    @State private var showingActions = false
    
    enum DetailMode: String, CaseIterable {
        case view = "Вид"
        case details = "Детали"
    }
    
    init(plant: PlantInstance) {
        self.plant = plant
        _viewModel = State(initialValue: PlantViewModel(plant: plant))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Segmented Control для режимов
                    Picker("Режим", selection: $selectedMode) {
                        ForEach(DetailMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.top, AppTheme.Spacing.md)
                    
                    if selectedMode == .view {
                        viewModeContent
                    } else {
                        detailsModeContent
                    }
                }
            }
            .background(AppTheme.Colors.backgroundGradient)
            .navigationTitle(plant.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingActions) {
                ActionSheetView(plant: plant)
            }
            .onAppear {
                viewModel.loadActionLogs(modelContext: modelContext)
            }
        }
    }
    
    // MARK: - View Mode (Вид)
    private var viewModeContent: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            // Крупный визуал растения
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                plant.healthStatus.color.opacity(0.2),
                                plant.healthStatus.color.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                
                Text(plant.type.icon)
                    .font(.system(size: 100))
                    .breathing(duration: 2.5, scaleRange: 0.90...1.10)
            }
            .padding(.top, AppTheme.Spacing.lg)
            
            // Настроение (текстовый сигнал)
            VStack(spacing: AppTheme.Spacing.sm) {
                Text(plant.moodSignal)
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(AppTheme.Colors.softBrown)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                
                // Индикатор состояния
                HStack(spacing: AppTheme.Spacing.sm) {
                    Circle()
                        .fill(plant.healthStatus.color)
                        .frame(width: 16, height: 16)
                        .shadow(color: plant.healthStatus.color.opacity(0.5), radius: 6)
                    
                    Text(healthStatusText)
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                }
            }
            
            // Кнопка действий
            Button(action: { showingActions = true }) {
                HStack {
                    Image(systemName: "hand.tap.fill")
                    Text("Все действия")
                }
                .font(AppTheme.Typography.headline)
                .foregroundColor(.white)
                .padding(.vertical, AppTheme.Spacing.md)
                .padding(.horizontal, AppTheme.Spacing.xl)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                        .fill(AppTheme.Colors.primaryGreen)
                )
            }
            .padding(.top, AppTheme.Spacing.md)
        }
    }
    
    // MARK: - Details Mode (Детали)
    private var detailsModeContent: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Визуальные индикаторы (не цифры)
            VStack(spacing: AppTheme.Spacing.md) {
                Text("Состояние")
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(AppTheme.Colors.softBrown)
                
                // Индикатор влажности
                IndicatorView(
                    title: "Влажность",
                    level: plant.moistureLevel,
                    color: AppTheme.Colors.primaryGreen,
                    icon: "💧"
                )
                
                // Индикатор стресса (обратный)
                IndicatorView(
                    title: "Комфорт",
                    level: 1.0 - plant.stressLevel,
                    color: AppTheme.Colors.accentTerracotta,
                    icon: "🌿"
                )
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            
            Divider()
                .padding(.horizontal, AppTheme.Spacing.lg)
            
            // История действий
            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                Text("История заботы")
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(AppTheme.Colors.softBrown)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                
                if viewModel.actionLogs.isEmpty {
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "clock")
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.Colors.softBrown.opacity(0.3))
                        
                        Text("Пока нет действий")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.xl)
                } else {
                    ForEach(viewModel.actionLogs.prefix(10), id: \.id) { log in
                        ActionLogRowView(log: log)
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                }
            }
            
            // Кнопка действий
            Button(action: { showingActions = true }) {
                HStack {
                    Image(systemName: "hand.tap.fill")
                    Text("Выполнить действие")
                }
                .font(AppTheme.Typography.headline)
                .foregroundColor(.white)
                .padding(.vertical, AppTheme.Spacing.md)
                .padding(.horizontal, AppTheme.Spacing.xl)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                        .fill(AppTheme.Colors.primaryGreen)
                )
            }
            .padding(.top, AppTheme.Spacing.md)
            .padding(.horizontal, AppTheme.Spacing.lg)
        }
    }
    
    private var healthStatusText: String {
        switch plant.healthStatus {
        case .healthy:
            return "Здоровое"
        case .needsAttention:
            return "Нужно внимание"
        case .atRisk:
            return "Требует заботы"
        }
    }
}

struct IndicatorView: View {
    let title: String
    let level: Double // 0-1
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            HStack {
                Text(icon)
                Text(title)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Фон
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)
                    
                    // Заполнение
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.6), color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * level, height: 20)
                        .animation(.spring(response: 0.5), value: level)
                }
            }
            .frame(height: 20)
        }
    }
}

struct ActionLogRowView: View {
    let log: ActionLog
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Иконка действия
            Text(log.action.icon)
                .font(.system(size: 24))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(AppTheme.Colors.primaryGreen.opacity(0.1))
                )
            
            // Информация
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(log.action.rawValue)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.softBrown)
                
                if let note = log.note, !note.isEmpty {
                    Text(note)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                        .lineLimit(1)
                }
                
                Text(log.performedAt, style: .relative)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.softBrown.opacity(0.5))
            }
            
            Spacer()
        }
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                .fill(AppTheme.Colors.cardBackground)
        )
    }
}

#Preview {
    let plant = PlantInstance(name: "Монстера", plantType: .monstera)
    return PlantDetailView(plant: plant)
        .modelContainer(for: [PlantInstance.self, ActionLog.self, HomeEntity.self], inMemory: true)
}

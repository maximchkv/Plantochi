//
//  ActionSheetView.swift
//  Plantochi
//
//  Created by Max on 15.01.2026.
//

import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct ActionSheetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let plant: PlantInstance
    @State private var viewModel: PlantViewModel
    
    @State private var selectedAction: PlantAction?
    @State private var note: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var showingNoteInput = false
    
    init(plant: PlantInstance) {
        self.plant = plant
        _viewModel = State(initialValue: PlantViewModel(plant: plant))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Заголовок
                    VStack(spacing: AppTheme.Spacing.xs) {
                        Text(plant.name)
                            .font(AppTheme.Typography.title)
                            .foregroundColor(AppTheme.Colors.softBrown)
                        
                        Text("Выберите действие")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                    }
                    .padding(.top, AppTheme.Spacing.md)
                    
                    // Список действий
                    VStack(spacing: AppTheme.Spacing.md) {
                        ForEach(PlantAction.allCases, id: \.self) { action in
                            ActionRowView(
                                action: action,
                                isSelected: selectedAction == action
                            ) {
                                selectedAction = action
                                performAction(action)
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    
                    Spacer()
                }
            }
            .background(AppTheme.Colors.backgroundGradient)
            .navigationTitle("Действия")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingNoteInput) {
                NoteInputView(
                    note: $note,
                    photoData: $photoData,
                    onSave: {
                        if let action = selectedAction {
                            viewModel.performAction(action, note: note.isEmpty ? nil : note, photoData: photoData, modelContext: modelContext)
                            dismiss()
                        }
                    }
                )
            }
            .onAppear {
                viewModel.loadActionLogs(modelContext: modelContext)
            }
        }
    }
    
    private func performAction(_ action: PlantAction) {
        // Анимация подтверждения
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            // Можно добавить haptic feedback
        }
        
        // Предложить добавить заметку/фото
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showingNoteInput = true
        }
    }
}

struct ActionRowView: View {
    let action: PlantAction
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.Spacing.md) {
                // Иконка
                Text(action.icon)
                    .font(.system(size: 32))
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(AppTheme.Colors.primaryGreen.opacity(0.1))
                    )
                
                // Информация
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(action.rawValue)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.softBrown)
                    
                    Text(action.description)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Индикатор выбора
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.primaryGreen)
                }
            }
            .padding(AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(AppTheme.Colors.cardBackground)
                    .shadow(color: AppTheme.Colors.primaryGreen.opacity(isSelected ? 0.3 : 0.1), radius: isSelected ? 8 : 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(isSelected ? AppTheme.Colors.primaryGreen : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NoteInputView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var note: String
    @Binding var photoData: Data?
    let onSave: () -> Void
    
    @State private var selectedPhoto: PhotosPickerItem?
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Поле для заметки
                TextField("Добавить заметку (необязательно)", text: $note, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                
                // Выбор фото
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    HStack {
                        Image(systemName: "photo")
                        Text("Добавить фото")
                    }
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.primaryGreen)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                            .stroke(AppTheme.Colors.primaryGreen, lineWidth: 2)
                    )
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .onChange(of: selectedPhoto) { _, newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self) {
                            photoData = data
                        }
                    }
                }
                
                // Предпросмотр фото
                if let photoData = photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .cornerRadius(AppTheme.CornerRadius.medium)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                }
                
                Spacer()
            }
            .padding(.top, AppTheme.Spacing.lg)
            .background(AppTheme.Colors.backgroundGradient)
            .navigationTitle("Заметка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Пропустить") {
                        onSave()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        onSave()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    let plant = PlantInstance(name: "Монстера", plantType: .monstera)
    return ActionSheetView(plant: plant)
        .modelContainer(for: [PlantInstance.self, ActionLog.self, HomeEntity.self, KnowledgeNode.self, Quest.self], inMemory: true)
}

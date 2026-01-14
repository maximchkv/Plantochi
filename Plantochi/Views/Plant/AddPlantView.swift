//
//  AddPlantView.swift
//  Plantochi
//
//  Created by Max on 15.01.2026.
//

import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct AddPlantView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var plantName: String = ""
    @State private var selectedType: PlantType = .succulent
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var previewImage: UIImage?
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // Заголовок
                    Text("Новое растение")
                        .font(AppTheme.Typography.largeTitle)
                        .foregroundColor(AppTheme.Colors.softBrown)
                        .padding(.top, AppTheme.Spacing.lg)
                    
                    // Превью фото или иконка
                    Group {
                        if let previewImage = previewImage {
                            Image(uiImage: previewImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(AppTheme.Colors.primaryGreen, lineWidth: 3)
                                )
                        } else {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                AppTheme.Colors.primaryGreen.opacity(0.2),
                                                AppTheme.Colors.secondaryGreen.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 150, height: 150)
                                
                                Text(selectedType.icon)
                                    .font(.system(size: 70))
                            }
                        }
                    }
                    .padding(.top, AppTheme.Spacing.md)
                    
                    // Выбор фото
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        HStack {
                            Image(systemName: "photo.badge.plus")
                            Text(previewImage == nil ? "Добавить фото" : "Изменить фото")
                        }
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.Colors.primaryGreen)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                                .stroke(AppTheme.Colors.primaryGreen, lineWidth: 2)
                        )
                    }
                    .onChange(of: selectedPhoto) { _, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                photoData = data
                                previewImage = UIImage(data: data)
                            }
                        }
                    }
                    
                    // Поле имени
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text("Имя растения")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.softBrown)
                        
                        TextField("Например: Монстера Маша", text: $plantName)
                            .textFieldStyle(.roundedBorder)
                            .font(AppTheme.Typography.body)
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    
                    // Выбор типа
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        Text("Тип растения")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.Colors.softBrown)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                        
                        LazyVGrid(columns: columns, spacing: AppTheme.Spacing.md) {
                            ForEach(PlantType.allCases, id: \.self) { type in
                                PlantTypeCard(
                                    type: type,
                                    isSelected: selectedType == type
                                ) {
                                    selectedType = type
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
                    }
                    
                    // Кнопка сохранения
                    Button(action: savePlant) {
                        Text("Добавить растение")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                                    .fill(canSave ? AppTheme.Colors.primaryGreen : Color.gray.opacity(0.5))
                            )
                    }
                    .disabled(!canSave)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.top, AppTheme.Spacing.md)
                    .padding(.bottom, AppTheme.Spacing.xl)
                }
            }
            .background(AppTheme.Colors.backgroundGradient)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var canSave: Bool {
        !plantName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private func savePlant() {
        let trimmedName = plantName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        let plant = PlantInstance(
            name: trimmedName,
            plantType: selectedType,
            photoData: photoData
        )
        
        modelContext.insert(plant)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save plant: \(error)")
        }
    }
}

struct PlantTypeCard: View {
    let type: PlantType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: AppTheme.Spacing.xs) {
                Text(type.icon)
                    .font(.system(size: 40))
                
                Text(type.rawValue)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.softBrown)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(isSelected ? AppTheme.Colors.primaryGreen.opacity(0.2) : AppTheme.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                            .stroke(isSelected ? AppTheme.Colors.primaryGreen : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AddPlantView()
        .modelContainer(for: [PlantInstance.self, ActionLog.self, HomeEntity.self], inMemory: true)
}

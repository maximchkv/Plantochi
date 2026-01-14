//
//  PlantCardView.swift
//  Plantochi
//
//  Created by Max on 15.01.2026.
//

import SwiftUI

struct PlantCardView: View {
    let plant: PlantInstance
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: AppTheme.Spacing.sm) {
                // Иконка растения
                Text(plant.type.icon)
                    .font(.system(size: 50))
                    .breathing(duration: 2.5 + Double.random(in: -0.5...0.5), scaleRange: 0.92...1.08)
                
                // Имя
                Text(plant.name)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.softBrown)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                // Индикатор состояния
                Circle()
                    .fill(plant.healthStatus.color)
                    .frame(width: 12, height: 12)
                    .shadow(color: plant.healthStatus.color.opacity(0.5), radius: 4)
            }
            .frame(width: 100, height: 120)
            .padding(AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(AppTheme.Colors.cardBackground)
                    .shadow(color: plant.healthStatus.color.opacity(0.2), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(plant.healthStatus.color.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    let plant = PlantInstance(name: "Монстера", plantType: .monstera)
    return PlantCardView(plant: plant) {
        print("Tapped")
    }
    .padding()
    .background(AppTheme.Colors.backgroundGradient)
}

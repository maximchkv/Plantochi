//
//  TotemView.swift
//  Plantochi
//
//  Created by Max on 15.01.2026.
//

import SwiftUI

struct TotemView: View {
    let health: Double // 0-1
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            // Простой тотем - растёт в зависимости от здоровья
            ZStack {
                // Тело тотема
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.Colors.primaryGreen,
                                AppTheme.Colors.secondaryGreen
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 40, height: 60 * health)
                    .shadow(color: AppTheme.Colors.primaryGreen.opacity(0.3), radius: 8)
                
                // Голова тотема
                Circle()
                    .fill(AppTheme.Colors.accentTerracotta)
                    .frame(width: 30, height: 30)
                    .offset(y: -35)
                    .breathing(duration: 2.0, scaleRange: 0.95...1.05)
            }
            
            Text("Дом")
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
        }
    }
}

#Preview {
    TotemView(health: 0.8)
        .padding()
        .background(AppTheme.Colors.backgroundGradient)
}

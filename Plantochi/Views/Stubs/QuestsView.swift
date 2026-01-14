//
//  QuestsView.swift
//  Plantochi
//
//  Created by Max on 15.01.2026.
//

import SwiftUI

struct QuestsView: View {
    var body: some View {
        NavigationView {
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.Colors.backgroundGradient)
            .navigationTitle("Квесты")
        }
    }
}

#Preview {
    QuestsView()
}

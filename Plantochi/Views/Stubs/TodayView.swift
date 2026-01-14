//
//  TodayView.swift
//  Plantochi
//
//  Created by Max on 15.01.2026.
//

import SwiftUI

struct TodayView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: AppTheme.Spacing.lg) {
                Image(systemName: "calendar")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.Colors.primaryGreen.opacity(0.3))
                
                Text("Сегодня")
                    .font(AppTheme.Typography.title)
                    .foregroundColor(AppTheme.Colors.softBrown)
                
                Text("Рекомендованные действия появятся здесь")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.lg)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.Colors.backgroundGradient)
            .navigationTitle("Сегодня")
        }
    }
}

#Preview {
    TodayView()
}

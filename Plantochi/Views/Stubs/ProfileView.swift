//
//  ProfileView.swift
//  Plantochi
//
//  Created by Max on 15.01.2026.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: AppTheme.Spacing.lg) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.Colors.primaryGreen.opacity(0.3))
                
                Text("Профиль")
                    .font(AppTheme.Typography.title)
                    .foregroundColor(AppTheme.Colors.softBrown)
                
                Text("Ачивки, стрики и статистика появятся здесь")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.lg)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.Colors.backgroundGradient)
            .navigationTitle("Профиль")
        }
    }
}

#Preview {
    ProfileView()
}

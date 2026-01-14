//
//  KnowledgeView.swift
//  Plantochi
//
//  Created by Max on 15.01.2026.
//

import SwiftUI

struct KnowledgeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: AppTheme.Spacing.lg) {
                Image(systemName: "book.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.Colors.secondaryGreen.opacity(0.3))
                
                Text("Книга знаний")
                    .font(AppTheme.Typography.title)
                    .foregroundColor(AppTheme.Colors.softBrown)
                
                Text("Граф знаний и открытые узлы появятся здесь")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.softBrown.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.lg)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.Colors.backgroundGradient)
            .navigationTitle("Книга")
        }
    }
}

#Preview {
    KnowledgeView()
}

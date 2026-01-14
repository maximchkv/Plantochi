//
//  AppTheme.swift
//  Plantochi
//
//  Created by Max on 15.01.2026.
//

import SwiftUI

struct AppTheme {
    // MARK: - Colors
    struct Colors {
        // Основные цвета
        static let primaryGreen = Color(red: 0.3, green: 0.6, blue: 0.4)
        static let secondaryGreen = Color(red: 0.4, green: 0.7, blue: 0.5)
        static let accentTerracotta = Color(red: 0.8, green: 0.5, blue: 0.4)
        static let warmBeige = Color(red: 0.95, green: 0.93, blue: 0.88)
        static let softBrown = Color(red: 0.6, green: 0.5, blue: 0.4)
        
        // Состояния здоровья
        static let healthy = Color(red: 0.4, green: 0.7, blue: 0.5)
        static let needsAttention = Color(red: 0.9, green: 0.7, blue: 0.3)
        static let atRisk = Color(red: 0.9, green: 0.5, blue: 0.4)
        
        // Фоны
        static let backgroundGradient = LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.93, blue: 0.88),
                Color(red: 0.92, green: 0.90, blue: 0.85)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let cardBackground = Color.white.opacity(0.8)
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 17, weight: .regular, design: .rounded)
        static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
        static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 20
        static let xlarge: CGFloat = 28
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let small = Shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        static let medium = Shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        static let large = Shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
    }
    
    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - Health Status Color Extension
extension HealthStatus {
    var color: Color {
        switch self {
        case .healthy:
            return AppTheme.Colors.healthy
        case .needsAttention:
            return AppTheme.Colors.needsAttention
        case .atRisk:
            return AppTheme.Colors.atRisk
        }
    }
}

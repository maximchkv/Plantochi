//
//  BreathingAnimation.swift
//  Plantochi
//
//  Created by Max on 15.01.2026.
//

import SwiftUI

struct BreathingAnimation: ViewModifier {
    @State private var isBreathing = false
    let duration: Double
    let scaleRange: ClosedRange<Double>
    
    init(duration: Double = 3.0, scaleRange: ClosedRange<Double> = 0.95...1.05) {
        self.duration = duration
        self.scaleRange = scaleRange
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isBreathing ? scaleRange.upperBound : scaleRange.lowerBound)
            .animation(
                Animation.easeInOut(duration: duration)
                    .repeatForever(autoreverses: true),
                value: isBreathing
            )
            .onAppear {
                isBreathing = true
            }
    }
}

extension View {
    func breathing(duration: Double = 3.0, scaleRange: ClosedRange<Double> = 0.95...1.05) -> some View {
        modifier(BreathingAnimation(duration: duration, scaleRange: scaleRange))
    }
}

import SwiftUI

struct NumberRevealAnimation: View {
    let targetNumber: Int
    let duration: Double
    let onComplete: (() -> Void)?
    
    @State private var currentNumber: Int = 0
    @State private var isAnimating: Bool = false
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color("QodeGold").opacity(0.3),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 10,
                        endRadius: 100
                    )
                )
                .scaleEffect(isAnimating ? 1.5 : 0.5)
                .opacity(isAnimating ? 0.8 : 0)
                .animation(.easeInOut(duration: 0.6), value: isAnimating)
            
            // Number
            Text("\(currentNumber)")
                .font(.system(size: 120, weight: .bold, design: .rounded))
                .foregroundColor(Color("QodeGold"))
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
                .opacity(opacity)
                .overlay(
                    // Shine effect
                    Text("\(currentNumber)")
                        .font(.system(size: 120, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white.opacity(0.8), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .mask(
                            Text("\(currentNumber)")
                                .font(.system(size: 120, weight: .bold, design: .rounded))
                        )
                )
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        isAnimating = true
        
        // Calculate steps for slot machine effect
        let totalSteps = 30
        let stepDuration = duration / Double(totalSteps)
        
        // Slot machine spin
        for step in 0..<totalSteps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(step) * stepDuration) {
                withAnimation(.easeOut(duration: stepDuration)) {
                    if step < totalSteps - 5 {
                        // Fast spinning phase
                        currentNumber = Int.random(in: 1...9)
                        rotation = Double.random(in: -10...10)
                        scale = 0.9 + Double.random(in: 0...0.2)
                    } else if step < totalSteps - 1 {
                        // Slow down phase
                        let progress = Double(step - (totalSteps - 5)) / 4.0
                        currentNumber = weightedRandom(toward: targetNumber, progress: progress)
                        rotation = rotation * 0.5
                        scale = 1.0
                    } else {
                        // Final reveal
                        currentNumber = targetNumber
                        rotation = 0
                        scale = 1.2
                        
                        // Pulse effect
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            scale = 1.0
                        }
                        
                        // Haptic feedback
                        HapticManager.shared.notification(type: .success)
                        
                        onComplete?()
                    }
                }
            }
        }
    }
    
    private func weightedRandom(toward target: Int, progress: Double) -> Int {
        let random = Int.random(in: 1...9)
        if Double.random(in: 0...1) < progress {
            return target
        }
        return random
    }
}

struct AnimatedNumberView: View {
    let number: Int
    let size: CGFloat
    let animated: Bool
    
    @State private var displayNumber: Int = 0
    @State private var scale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Glow effect for Master Numbers
            if isMasterNumber {
                Circle()
                    .fill(Color("QodeGold"))
                    .frame(width: size * 1.5, height: size * 1.5)
                    .blur(radius: 20)
                    .opacity(glowOpacity)
            }
            
            Text("\(displayNumber)")
                .font(.system(size: size, weight: .bold, design: .rounded))
                .foregroundColor(isMasterNumber ? Color("QodeGold") : .primary)
                .scaleEffect(scale)
        }
        .onAppear {
            if animated {
                animateNumber()
            } else {
                displayNumber = number
            }
        }
        .onChange(of: number) { newNumber in
            if animated {
                animateNumber()
            } else {
                displayNumber = newNumber
            }
        }
    }
    
    private var isMasterNumber: Bool {
        [11, 22, 33].contains(number)
    }
    
    private func animateNumber() {
        // Count up animation
        let steps = min(number, 20)
        let duration = 0.5
        
        for step in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(step) * (duration / Double(steps))) {
                withAnimation(.easeOut) {
                    displayNumber = (number * step) / steps
                }
            }
        }
        
        // Master number glow
        if isMasterNumber {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                glowOpacity = 0.6
            }
            
            HapticManager.shared.notification(type: .success)
        }
    }
}

struct CardFlipView: View {
    let frontContent: AnyView
    let backContent: AnyView
    @State private var isFlipped = false
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            frontContent
                .opacity(rotation < 90 ? 1 : 0)
            
            backContent
                .opacity(rotation >= 90 ? 1 : 0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .rotation3DEffect(
            .degrees(rotation),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.5
        )
        .onTapGesture {
            flipCard()
        }
    }
    
    private func flipCard() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            rotation = isFlipped ? 0 : 180
        }
        isFlipped.toggle()
        
        HapticManager.shared.impact(style: .medium)
    }
}

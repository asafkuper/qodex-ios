//
//  QXNumberCounter.swift
//  QodeX Number Counting Animations
//  Reference: Robinhood, Revolut number animations
//

import SwiftUI

// MARK: - Number Counter View
public struct QXNumberCounter: View {
    let targetValue: Int
    let duration: TimeInterval
    let font: Font
    let color: Color
    let showPlus: Bool
    let format: NumberFormat
    
    @State private var displayValue: Int = 0
    @State private var timer: Timer?
    @State private var isAnimating = false
    
    public enum NumberFormat {
        case plain
        case lifePath // Single digit 1-9
        case masterNumber // 11, 22, 33
        case percentage
        case padded // For dates (01, 02, etc.)
    }
    
    public init(
        value: Int,
        duration: TimeInterval = 1.5,
        font: Font = QXFont.displayLarge,
        color: Color = QXColor.gold,
        showPlus: Bool = false,
        format: NumberFormat = .plain
    ) {
        self.targetValue = value
        self.duration = duration
        self.font = font
        self.color = color
        self.showPlus = showPlus
        self.format = format
    }
    
    public var body: some View {
        Text(displayText)
            .font(font)
            .foregroundStyle(
                LinearGradient(
                    colors: [color, color.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 0)
            .onAppear {
                startAnimation()
            }
            .onChange(of: targetValue) { _, _ in
                startAnimation()
            }
    }
    
    private var displayText: String {
        let prefix = (showPlus && displayValue > 0) ? "+" : ""
        
        switch format {
        case .plain:
            return "\(prefix)\(displayValue)"
        case .lifePath:
            return "\(prefix)\(displayValue)"
        case .masterNumber:
            return "\(prefix)\(displayValue)"
        case .percentage:
            return "\(prefix)\(displayValue)%"
        case .padded:
            return String(format: "%02d", displayValue)
        }
    }
    
    private func startAnimation() {
        timer?.invalidate()
        isAnimating = true
        
        let steps = 30
        let stepDuration = duration / Double(steps)
        let increment = Double(targetValue) / Double(steps)
        
        var currentStep = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
            currentStep += 1
            
            if currentStep >= steps {
                displayValue = targetValue
                timer.invalidate()
                isAnimating = false
                QXHaptic.countComplete()
            } else {
                // Easing function for smooth deceleration
                let progress = Double(currentStep) / Double(steps)
                let easedProgress = 1 - pow(1 - progress, 3) // Cubic ease out
                displayValue = Int(Double(targetValue) * easedProgress)
                
                // Haptic tick every few steps
                if currentStep % 5 == 0 {
                    QXHaptic.countTick()
                }
            }
        }
    }
}

// MARK: - Rolling Number Counter
public struct QXRollingNumberCounter: View {
    let value: Int
    let digitCount: Int
    let font: Font
    let color: Color
    
    public init(
        value: Int,
        digitCount: Int = 2,
        font: Font = QXFont.displayLarge,
        color: Color = QXColor.gold
    ) {
        self.value = value
        self.digitCount = digitCount
        self.font = font
        self.color = color
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<digitCount, id: \.self) { index in
                let digit = getDigit(at: index)
                QXDigitRoll(digit: digit, font: font, color: color)
                    .id("\(index)-\(digit)")
            }
        }
    }
    
    private func getDigit(at index: Int) -> Int {
        let stringValue = String(format: "%0\(digitCount)d", value)
        let reversedIndex = digitCount - 1 - index
        guard reversedIndex < stringValue.count else { return 0 }
        let char = stringValue[stringValue.index(stringValue.startIndex, offsetBy: reversedIndex)]
        return Int(String(char)) ?? 0
    }
}

// MARK: - Individual Digit Roll
struct QXDigitRoll: View {
    let digit: Int
    let font: Font
    let color: Color
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ForEach(0..10) { i in
                    Text("\(i)")
                        .font(font)
                        .foregroundColor(color)
                        .frame(width: geo.size.width, height: geo.size.height)
                }
            }
            .offset(y: -CGFloat(digit) * geo.size.height)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: digit)
        }
        .frame(width: 60, height: 80)
        .clipped()
    }
}

// MARK: - Animated Number Ring
public struct QXNumberRing: View {
    let number: Int
    let size: CGFloat
    let lineWidth: CGFloat
    let color: Color
    let showGlow: Bool
    
    @State private var progress: CGFloat = 0
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    public init(
        number: Int,
        size: CGFloat = 200,
        lineWidth: CGFloat = 4,
        color: Color = QXColor.gold,
        showGlow: Bool = true
    ) {
        self.number = number
        self.size = size
        self.lineWidth = lineWidth
        self.color = color
        self.showGlow = showGlow
    }
    
    public var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            
            // Animated progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [color, color.opacity(0.5)],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            // Glow effect
            if showGlow {
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: lineWidth * 2)
                    .blur(radius: 10)
                    .opacity(progress > 0.9 ? 1 : 0)
            }
            
            // Number
            Text("\(number)")
                .font(.system(size: size * 0.4, weight: .thin, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [color, color.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .scaleEffect(scale)
                .opacity(opacity)
        }
        .frame(width: size, height: size)
        .onAppear {
            // Ring animation
            withAnimation(.easeInOut(duration: 1.5)) {
                progress = 1.0
            }
            
            // Number animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    scale = 1.0
                    opacity = 1.0
                }
                QXHaptic.premiumUnlock()
            }
        }
    }
}

// MARK: - Counting Stat Card
public struct QXCountingStatCard: View {
    let title: String
    let value: Int
    let previousValue: Int?
    let unit: String?
    let trend: Trend?
    let color: Color
    
    public enum Trend {
        case up, down, neutral
        
        var icon: String {
            switch self {
            case .up: return "arrow.up"
            case .down: return "arrow.down"
            case .neutral: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return QXColor.success
            case .down: return QXColor.error
            case .neutral: return QXColor.stardust
            }
        }
    }
    
    @State private var displayValue: Int = 0
    @State private var showTrend = false
    
    public init(
        title: String,
        value: Int,
        previousValue: Int? = nil,
        unit: String? = nil,
        trend: Trend? = nil,
        color: Color = QXColor.gold
    ) {
        self.title = title
        self.value = value
        self.previousValue = previousValue
        self.unit = unit
        self.trend = trend
        self.color = color
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(QXColor.stardust)
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                QXNumberCounter(
                    value: value,
                    duration: 1.2,
                    font: .system(size: 36, weight: .bold, design: .rounded),
                    color: color
                )
                
                if let unit = unit {
                    Text(unit)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(color.opacity(0.7))
                }
            }
            
            if let trend = trend {
                HStack(spacing: 4) {
                    Image(systemName: trend.icon)
                        .font(.system(size: 12))
                    
                    if let previousValue = previousValue {
                        let change = value - previousValue
                        let percentage = previousValue > 0 ? (change * 100) / previousValue : 0
                        Text("\(percentage > 0 ? "+" : "")\(percentage)%")
                            .font(.system(size: 12))
                    }
                }
                .foregroundColor(trend.color)
                .opacity(showTrend ? 1 : 0)
                .offset(y: showTrend ? 0 : 10)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(QXColor.deepVoid)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showTrend = true
                }
            }
        }
    }
}

// MARK: - Slot Machine Number
public struct QXSlotMachineNumber: View {
    let targetNumber: Int
    let font: Font
    let color: Color
    
    @State private var displayNumbers: [Int] = [0, 0]
    @State private var isAnimating = false
    
    public init(
        number: Int,
        font: Font = QXFont.displayLarge,
        color: Color = QXColor.gold
    ) {
        self.targetNumber = number
        self.font = font
        self.color = color
    }
    
    public var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<displayNumbers.count, id: \.self) { index in
                SingleSlotDigit(
                    digit: displayNumbers[index],
                    font: font,
                    color: color,
                    delay: Double(index) * 0.3
                )
            }
        }
        .onAppear {
            animateToTarget()
        }
    }
    
    private func animateToTarget() {
        let digits = String(targetNumber).compactMap { Int(String($0)) }
        
        // Animate each digit with increasing delay
        for (index, targetDigit) in digits.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.3) {
                animateDigit(at: index, to: targetDigit)
            }
        }
    }
    
    private func animateDigit(at index: Int, to target: Int) {
        var current = 0
        let steps = target + 10 // Go around once then to target
        
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            current += 1
            
            if current >= steps {
                displayNumbers[index] = target
                timer.invalidate()
                QXHaptic.countTick()
            } else {
                displayNumbers[index] = current % 10
            }
        }
    }
}

// MARK: - Single Slot Digit
struct SingleSlotDigit: View {
    let digit: Int
    let font: Font
    let color: Color
    let delay: Double
    
    @State private var blur: CGFloat = 0
    
    var body: some View {
        Text("\(digit)")
            .font(font)
            .foregroundColor(color)
            .blur(radius: blur)
            .onChange(of: digit) { _, _ in
                withAnimation(.easeOut(duration: 0.05)) {
                    blur = 2
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.easeIn(duration: 0.05)) {
                        blur = 0
                    }
                }
            }
    }
}

// MARK: - Life Path Reveal Animation
public struct QXLifePathReveal: View {
    let lifePathNumber: Int
    let onComplete: (() -> Void)?
    
    @State private var phase: RevealPhase = .idle
    @State private var particles: [RevealParticle] = []
    
    enum RevealPhase {
        case idle, building, revealing, complete
    }
    
    public init(lifePathNumber: Int, onComplete: (() -> Void)? = nil) {
        self.lifePathNumber = lifePathNumber
        self.onComplete = onComplete
    }
    
    public var body: some View {
        ZStack {
            // Particle effects
            ForEach(particles) { particle in
                RevealParticleView(particle: particle)
            }
            
            // Number with ring
            QXNumberRing(number: lifePathNumber, size: 220, showGlow: true)
                .opacity(phase == .revealing || phase == .complete ? 1 : 0)
                .scaleEffect(phase == .complete ? 1 : 0.5)
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: phase)
        }
        .onAppear {
            startRevealSequence()
        }
    }
    
    private func startRevealSequence() {
        phase = .building
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            phase = .revealing
            createParticles()
            QXHaptic.successPattern()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            phase = .complete
            onComplete?()
        }
    }
    
    private func createParticles() {
        for i in 0..<30 {
            let particle = RevealParticle(
                angle: Double(i) * 12,
                distance: 150 + Double.random(in: -50...50),
                color: [QXColor.gold, QXColor.goldGlow, .white].randomElement()!
            )
            particles.append(particle)
        }
        
        // Animate particles
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                particles.removeAll()
            }
        }
    }
}

// MARK: - Reveal Particle
struct RevealParticle: Identifiable {
    let id = UUID()
    let angle: Double
    let distance: Double
    let color: Color
}

struct RevealParticleView: View {
    let particle: RevealParticle
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        Circle()
            .fill(particle.color)
            .frame(width: 4, height: 4)
            .offset(
                x: cos(particle.angle * .pi / 180) * particle.distance,
                y: sin(particle.angle * .pi / 180) * particle.distance
            )
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    scale = CGFloat.random(in: 0.5...2)
                }
                withAnimation(.easeIn(duration: 1.0).delay(0.5)) {
                    opacity = 0
                }
            }
    }
}

// MARK: - Preview
#Preview("Number Counter") {
    VStack(spacing: 40) {
        // Simple counter
        QXNumberCounter(value: 42, duration: 1.5)
        
        // Rolling counter
        QXRollingNumberCounter(value: 87, digitCount: 2)
        
        // Number ring
        QXNumberRing(number: 7, size: 150)
        
        // Stat card
        QXCountingStatCard(
            title: "Days Active",
            value: 128,
            previousValue: 100,
            unit: "days",
            trend: .up
        )
        .padding(.horizontal)
        
        // Slot machine
        QXSlotMachineNumber(number: 23)
    }
    .padding()
    .background(QXColor.cosmicBlack)
}

//
//  TodayView.swift
//  Premium Today Screen - Production SwiftUI
//  Personalized readings based on Life Path + Universal Day
//  Inspired by Linear, Craft, Arc Browser
//

import SwiftUI

struct TodayView: View {
    @StateObject private var viewModel = TodayViewModel()
    @State private var displayNumber: Int = 0
    @State private var numberScale: CGFloat = 1.0
    @State private var ringRotation: Double = 0
    @State private var showFullReading = false
    
    // User's Life Path (would come from UserStore in production)
    var userLifePath: Int = 8
    
    var body: some View {
        ZStack {
            // Background gradient
            backgroundGradient
            
            // Floating glow orbs
            glowOrbs
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Number Display
                    numberDisplaySection
                    
                    // Vibe text - Personalized
                    vibeSection
                    
                    // Energy Level Indicator
                    energyIndicator
                    
                    // Personalized Insight Card
                    insightCard
                    
                    // Personalized Advice Card
                    adviceCard
                    
                    // Best Activities Card
                    activitiesCard
                    
                    // Power Hours Card
                    powerHoursCard
                    
                    // CTA Button
                    ctaButton
                }
            }
        }
        .onAppear {
            viewModel.loadReading()
            animateNumber()
        }
        .sheet(isPresented: $showFullReading) {
            FullReadingView(reading: viewModel.reading)
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hex: "0A0A0F"),
                Color(hex: "0d0d14")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Glow Orbs
    
    private var glowOrbs: some View {
        GeometryReader { geometry in
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            energyColor.opacity(0.15),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: geometry.size.width - 100, y: -100)
            
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.purple.opacity(0.1),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: -150, y: geometry.size.height * 0.4)
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("QODE")
                .font(.system(size: 32, weight: .bold, design: .default))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.goldBright, .goldPrimary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(viewModel.reading?.universalDayTitle ?? "Today's Energy")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.starlightTertiary)
            
            // Life Path indicator
            HStack(spacing: 6) {
                Image(systemName: "person.fill")
                    .font(.system(size: 10))
                Text("Life Path \(userLifePath)")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(.goldPrimary.opacity(0.8))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.goldPrimary.opacity(0.1))
            )
        }
        .padding(.top, 20)
        .padding(.bottom, 30)
    }
    
    // MARK: - Number Display
    
    private var numberDisplaySection: some View {
        ZStack {
            // Outer rotating ring
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            energyColor,
                            Color.clear
                        ]),
                        center: .center
                    ),
                    lineWidth: 3
                )
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(ringRotation))
            
            // Inner counter-rotating ring
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            energyColor.opacity(0.6),
                            Color.clear
                        ]),
                        center: .center
                    ),
                    lineWidth: 2
                )
                .frame(width: 250, height: 250)
                .rotationEffect(.degrees(-ringRotation * 1.5))
                .opacity(0.6)
            
            // Number container
            ZStack {
                // Glow background
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                energyColor.opacity(0.15),
                                Color.clear
                            ]),
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                
                // Glass border
                Circle()
                    .stroke(energyColor.opacity(0.3), lineWidth: 1)
                
                // The number
                Text("\(displayNumber)")
                    .font(.system(size: 100, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [energyColor.opacity(1.2), energyColor],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: energyColor.opacity(0.5), radius: 30, x: 0, y: 0)
                    .scaleEffect(numberScale)
            }
            .frame(width: 200, height: 200)
        }
        .frame(height: 320)
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }
        }
    }
    
    // MARK: - Vibe Section
    
    private var vibeSection: some View {
        VStack(spacing: 8) {
            Text(viewModel.reading?.lifePathTitle ?? "Your Path")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.starlight)
            
            Text(viewModel.reading?.personalizedSummary ?? "Personalized for you")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.starlightTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Energy Indicator
    
    private var energyIndicator: some View {
        HStack(spacing: 8) {
            Image(systemName: viewModel.reading?.energy.iconName ?? "circle.fill")
                .foregroundColor(energyColor)
            
            Text(viewModel.reading?.energy.displayText ?? "Today's Energy")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(energyColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(energyColor.opacity(0.1))
        )
        .overlay(
            Capsule()
                .stroke(energyColor.opacity(0.3), lineWidth: 1)
        )
        .padding(.bottom, 20)
    }
    
    // MARK: - Insight Card
    
    private var insightCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(energyColor)
                        .frame(width: 8, height: 8)
                        .shadow(color: energyColor, radius: 10, x: 0, y: 0)
                    
                    Text("Today's Insight")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(energyColor)
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
                
                Text(viewModel.reading?.insight ?? "Your personalized insight will appear here.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.starlightSecondary)
                    .lineSpacing(4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    // MARK: - Advice Card
    
    private var adviceCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.goldPrimary)
                    
                    Text("Guidance")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.goldPrimary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
                
                Text(viewModel.reading?.advice ?? "Your personalized guidance will appear here.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.starlightSecondary)
                    .lineSpacing(4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    // MARK: - Activities Card
    
    private var activitiesCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.goldPrimary)
                    
                    Text("Best Activities")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.goldPrimary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
                
                FlowLayout(spacing: 8) {
                    ForEach(viewModel.reading?.bestActivities ?? ["Reflection", "Planning"], id: \.self) { activity in
                        ActivityPill(text: activity)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    // MARK: - Power Hours Card
    
    private var powerHoursCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.goldPrimary)
                        .frame(width: 8, height: 8)
                        .shadow(color: .goldPrimary, radius: 10, x: 0, y: 0)
                    
                    Text("Power Hours")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.goldPrimary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
                
                HStack(spacing: 12) {
                    ForEach([
                        ("9:00", "AM"),
                        ("2:00", "PM"),
                        ("7:00", "PM")
                    ], id: \.0) { time, period in
                        HourPill(time: time, period: period)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }
    
    // MARK: - CTA Button
    
    private var ctaButton: some View {
        PremiumButton(title: "View Full Reading", icon: "sparkles") {
            showFullReading = true
        }
        .accessibilityLabel("View Full Reading")
        .accessibilityHint("Opens detailed daily numerology reading")
        .padding(.horizontal, 20)
        .padding(.bottom, 100)
    }
    
    // MARK: - Helpers
    
    private var energyColor: Color {
        guard let energy = viewModel.reading?.energy else {
            return .goldPrimary
        }
        return Color(hex: energy.colorHex)
    }
    
    private func animateNumber() {
        let targetNumber = viewModel.reading?.universalDay ?? 8
        let duration = 0.8
        let steps = 20
        let stepDuration = duration / Double(steps)
        
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(i) * stepDuration)) {
                displayNumber = (targetNumber * i) / steps
            }
        }
        
        // Pulse at end
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                numberScale = 1.05
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    numberScale = 1.0
                }
            }
        }
    }
}

// MARK: - Activity Pill

struct ActivityPill: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.starlight)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

// MARK: - Full Reading View

struct FullReadingView: View {
    let reading: PersonalizedReading?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if let reading = reading {
                        // Header
                        VStack(spacing: 8) {
                            Text("Universal Day \(reading.universalDay)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.goldPrimary)
                            
                            Text("Life Path \(reading.lifePath): \(reading.lifePathTitle)")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.starlight)
                            
                            Text(reading.personalizedSummary)
                                .font(.system(size: 14))
                                .foregroundColor(.starlightTertiary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Energy indicator
                        HStack(spacing: 8) {
                            Image(systemName: reading.energy.iconName)
                            Text(reading.energy.displayText)
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: reading.energy.colorHex))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: reading.energy.colorHex).opacity(0.1))
                        )
                        
                        // Insight
                        DetailCard(title: "Today's Insight", icon: "sparkles", content: reading.insight)
                        
                        // Advice
                        DetailCard(title: "Guidance", icon: "lightbulb", content: reading.advice)
                        
                        // Activities
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Best Activities", systemImage: "star")
                                .font(.system(size: 17, weight: .semibold))
                            
                            ForEach(reading.bestActivities, id: \.self) { activity in
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.goldPrimary)
                                    Text(activity)
                                        .foregroundColor(.starlightSecondary)
                                    Spacer()
                                }
                            }
                        }
                        .padding(20)
                        .background(Color(hex: "1a1a24"))
                        .cornerRadius(16)
                        
                    } else {
                        Text("Loading your personalized reading...")
                            .foregroundColor(.starlightTertiary)
                    }
                }
                .padding(.horizontal, 20)
            }
            .background(Color(hex: "0A0A0F"))
            .navigationTitle("Full Reading")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DetailCard: View {
    let title: String
    let icon: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.goldPrimary)
            
            Text(content)
                .font(.system(size: 15))
                .foregroundColor(.starlightSecondary)
                .lineSpacing(4)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "1a1a24"))
        .cornerRadius(16)
    }
}

// MARK: - Hour Pill

struct HourPill: View {
    let time: String
    let period: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(time)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.goldPrimary)
            
            Text(period)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.starlightTertiary)
        }
        .frame(minWidth: 70)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.goldPrimary.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.goldPrimary.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Preview

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
            .preferredColorScheme(.dark)
    }
}

//
//  BirthChartView.swift
//  Interactive visual birth chart
//

import SwiftUI

struct BirthChartView: View {
    let chart: NumerologyChart
    @State private var selectedNumber: ChartNumber?
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            QodeXColors.cosmicBlack.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    chartHeader
                    
                    // Interactive Chart
                    ZStack {
                        // Background sacred geometry
                        SacredGeometryBackground()
                            .opacity(0.1)
                        
                        // Main chart
                        NumerologyWheel(chart: chart, selectedNumber: $selectedNumber)
                            .frame(width: 320, height: 320)
                            .rotationEffect(.degrees(rotation))
                            .gesture(
                                RotationGesture()
                                    .onChanged { angle in
                                        rotation = angle.degrees
                                    }
                            )
                    }
                    .padding(.vertical, 20)
                    
                    // Selected number detail
                    if let number = selectedNumber {
                        NumberDetailCard(number: number)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    // All numbers grid
                    allNumbersGrid
                    
                    // Cycles section
                    cyclesSection
                }
                .padding(.vertical, 20)
            }
        }
        .navigationTitle("Your Birth Chart")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var chartHeader: some View {
        VStack(spacing: 8) {
            Text("\(chart.fullName)")
                .font(QodeXTypography.headline)
                .foregroundStyle(QodeXColors.pureWhite)
            
            Text(formattedBirthDate)
                .font(QodeXTypography.body)
                .foregroundStyle(QodeXColors.stardust)
            
            HStack(spacing: 16) {
                Label("Life Path \(chart.lifePath)", systemImage: "number.circle.fill")
                    .font(QodeXTypography.caption)
                    .foregroundStyle(QodeXColors.gold)
                
                Label("Personal Year \(chart.personalYear)", systemImage: "calendar")
                    .font(QodeXTypography.caption)
                    .foregroundStyle(QodeXColors.mysticPurple)
            }
        }
    }
    
    private var allNumbersGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Core Numbers")
                .font(QodeXTypography.headline)
                .foregroundStyle(QodeXColors.pureWhite)
                .padding(.horizontal, 20)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                NumberCard(
                    title: "Life Path",
                    number: chart.lifePath,
                    subtitle: lifePathName(chart.lifePath),
                    color: QodeXColors.gold,
                    isMaster: [11, 22, 33].contains(chart.lifePath)
                )
                
                NumberCard(
                    title: "Expression",
                    number: chart.expression,
                    subtitle: "How you express",
                    color: QodeXColors.mysticPurple,
                    isMaster: [11, 22, 33].contains(chart.expression)
                )
                
                NumberCard(
                    title: "Soul Urge",
                    number: chart.soulUrge,
                    subtitle: "Heart's desire",
                    color: QodeXColors.cosmicTeal,
                    isMaster: [11, 22, 33].contains(chart.soulUrge)
                )
                
                NumberCard(
                    title: "Personality",
                    number: chart.personality,
                    subtitle: "Outer self",
                    color: QodeXColors.stardust,
                    isMaster: false
                )
                
                NumberCard(
                    title: "Birthday",
                    number: chart.birthday,
                    subtitle: "Special gift",
                    color: QodeXColors.gold,
                    isMaster: [11, 22, 33].contains(chart.birthday)
                )
                
                NumberCard(
                    title: "Maturity",
                    number: chart.maturity,
                    subtitle: "Later life path",
                    color: QodeXColors.mysticPurple,
                    isMaster: [11, 22, 33].contains(chart.maturity)
                )
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var cyclesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Life Cycles")
                .font(QodeXTypography.headline)
                .foregroundStyle(QodeXColors.pureWhite)
                .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                ForEach(chart.pinnacles.indices, id: \.self) { index in
                    let pinnacle = chart.pinnacles[index]
                    PinnacleRow(
                        number: index + 1,
                        pinnacle: pinnacle,
                        isCurrent: isCurrentPinnacle(pinnacle)
                    )
                }
            }
            .padding(.horizontal, 20)
            
            // Challenges
            VStack(alignment: .leading, spacing: 12) {
                Text("Challenges to Master")
                    .font(QodeXTypography.headline)
                    .foregroundStyle(QodeXColors.pureWhite)
                    .padding(.horizontal, 20)
                
                HStack(spacing: 12) {
                    ForEach(chart.challenges, id: \.self) { challenge in
                        ChallengeBadge(number: challenge)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 16)
        }
    }
    
    private var formattedBirthDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: chart.birthDate)
    }
    
    private func lifePathName(_ number: Int) -> String {
        let names = [
            1: "The Leader", 2: "The Peacemaker", 3: "The Creative",
            4: "The Builder", 5: "The Freedom Seeker", 6: "The Nurturer",
            7: "The Seeker", 8: "The Powerhouse", 9: "The Humanitarian",
            11: "The Intuitive", 22: "The Master Builder", 33: "The Master Teacher"
        ]
        return names[number] ?? "Unknown"
    }
    
    private func isCurrentPinnacle(_ pinnacle: Pinnacle) -> Bool {
        let age = Calendar.current.dateComponents([.year], from: chart.birthDate, to: Date()).year ?? 0
        return age >= pinnacle.ageStart && (pinnacle.ageEnd == nil || age <= pinnacle.ageEnd!)
    }
}

// MARK: - Numerology Wheel

struct NumerologyWheel: View {
    let chart: NumerologyChart
    @Binding var selectedNumber: ChartNumber?
    
    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(QodeXColors.gold.opacity(0.3), lineWidth: 2)
            
            // Inner rings for each number
            ForEach(ChartNumber.allCases) { number in
                NumberArc(
                    number: number,
                    value: valueFor(number),
                    isSelected: selectedNumber == number
                )
                .onTapGesture {
                    withAnimation(.spring()) {
                        selectedNumber = selectedNumber == number ? nil : number
                    }
                }
            }
            
            // Center
            ZStack {
                Circle()
                    .fill(QodeXColors.deepVoid)
                    .frame(width: 80, height: 80)
                
                VStack(spacing: 2) {
                    Text("\(chart.lifePath)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(QodeXColors.gold)
                    
                    Text("Life Path")
                        .font(.system(size: 10))
                        .foregroundStyle(QodeXColors.stardust)
                }
            }
        }
    }
    
    private func valueFor(_ number: ChartNumber) -> Int {
        switch number {
        case .lifePath: return chart.lifePath
        case .expression: return chart.expression
        case .soulUrge: return chart.soulUrge
        case .personality: return chart.personality
        case .birthday: return chart.birthday
        case .maturity: return chart.maturity
        }
    }
}

struct NumberArc: View {
    let number: ChartNumber
    let value: Int
    let isSelected: Bool
    
    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = geo.size.width / 2 - 30
            let startAngle = angleFor(number) - 30
            let endAngle = angleFor(number) + 30
            
            ZStack {
                // Arc background
                Path { path in
                    path.addArc(
                        center: center,
                        radius: radius,
                        startAngle: .degrees(startAngle),
                        endAngle: .degrees(endAngle),
                        clockwise: false
                    )
                }
                .stroke(colorFor(number).opacity(isSelected ? 1 : 0.5), lineWidth: isSelected ? 4 : 2)
                
                // Number position
                let numberAngle = angleFor(number)
                let numberX = center.x + radius * cos(CGFloat(numberAngle) * .pi / 180)
                let numberY = center.y + radius * sin(CGFloat(numberAngle) * .pi / 180)
                
                VStack(spacing: 2) {
                    Text("\(value)")
                        .font(.system(size: isSelected ? 24 : 18, weight: .bold))
                        .foregroundStyle(colorFor(number))
                    
                    Text(number.shortName)
                        .font(.system(size: 8))
                        .foregroundStyle(QodeXColors.stardust)
                }
                .position(x: numberX, y: numberY)
            }
        }
    }
    
    private func angleFor(_ number: ChartNumber) -> Double {
        switch number {
        case .lifePath: return -90
        case .expression: return -30
        case .soulUrge: return 30
        case .personality: return 90
        case .birthday: return 150
        case .maturity: return 210
        }
    }
    
    private func colorFor(_ number: ChartNumber) -> Color {
        switch number {
        case .lifePath: return QodeXColors.gold
        case .expression: return QodeXColors.mysticPurple
        case .soulUrge: return QodeXColors.cosmicTeal
        case .personality: return QodeXColors.stardust
        case .birthday: return QodeXColors.gold
        case .maturity: return QodeXColors.mysticPurple
        }
    }
}

enum ChartNumber: CaseIterable, Identifiable {
    case lifePath, expression, soulUrge, personality, birthday, maturity
    
    var id: Self { self }
    
    var shortName: String {
        switch self {
        case .lifePath: return "LP"
        case .expression: return "EX"
        case .soulUrge: return "SU"
        case .personality: return "PE"
        case .birthday: return "BD"
        case .maturity: return "MA"
        }
    }
}

// MARK: - Supporting Views

struct NumberCard: View {
    let title: String
    let number: Int
    let subtitle: String
    let color: Color
    let isMaster: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(QodeXColors.stardust)
                
                Spacer()
                
                if isMaster {
                    Text("MASTER")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(QodeXColors.cosmicBlack)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(color)
                        .cornerRadius(4)
                }
            }
            
            Text("\(number)")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(color)
            
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundStyle(QodeXColors.stardust)
                .lineLimit(1)
        }
        .padding(12)
        .background(QodeXColors.deepVoid)
        .cornerRadius(12)
    }
}

struct NumberDetailCard: View {
    let number: ChartNumber
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(fullName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(QodeXColors.pureWhite)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(QodeXColors.stardust)
                }
            }
            
            Text(description)
                .font(.system(size: 14))
                .foregroundStyle(QodeXColors.stardust)
                .lineLimit(3)
            
            Button("Learn More →") {}
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(QodeXColors.gold)
        }
        .padding(16)
        .background(QodeXColors.deepVoid)
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
    
    private var fullName: String {
        switch number {
        case .lifePath: return "Life Path Number"
        case .expression: return "Expression Number"
        case .soulUrge: return "Soul Urge Number"
        case .personality: return "Personality Number"
        case .birthday: return "Birthday Number"
        case .maturity: return "Maturity Number"
        }
    }
    
    private var description: String {
        switch number {
        case .lifePath:
            return "Your Life Path reveals your life's purpose, strengths, and the path you're meant to walk."
        case .expression:
            return "Your Expression number shows your natural talents and how you express yourself to the world."
        case .soulUrge:
            return "Your Soul Urge reveals what your heart truly desires and what motivates you at the deepest level."
        case .personality:
            return "Your Personality number shows how others perceive you and your outer demeanor."
        case .birthday:
            return "Your Birthday number reveals a special gift or talent you brought into this life."
        case .maturity:
            return "Your Maturity number indicates the energy that will guide you in your later years."
        }
    }
}

struct PinnacleRow: View {
    let number: Int
    let pinnacle: Pinnacle
    let isCurrent: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Number
            ZStack {
                Circle()
                    .fill(isCurrent ? QodeXColors.gold.opacity(0.2) : QodeXColors.starlight)
                    .frame(width: 44, height: 44)
                
                Text("\(pinnacle.number)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(isCurrent ? QodeXColors.gold : QodeXColors.pureWhite)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Pinnacle \(number)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(QodeXColors.pureWhite)
                    
                    if isCurrent {
                        Text("CURRENT")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(QodeXColors.cosmicBlack)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(QodeXColors.gold)
                            .cornerRadius(4)
                    }
                }
                
                Text("Ages \(pinnacle.ageStart)-\(pinnacle.ageEnd ?? 99)")
                    .font(.system(size: 12))
                    .foregroundStyle(QodeXColors.stardust)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(QodeXColors.stardust)
        }
        .padding(12)
        .background(QodeXColors.deepVoid)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrent ? QodeXColors.gold.opacity(0.5) : Color.clear, lineWidth: 1)
        )
    }
}

struct ChallengeBadge: View {
    let number: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(number)")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(QodeXColors.pureWhite)
            
            Text("Challenge")
                .font(.system(size: 10))
                .foregroundStyle(QodeXColors.stardust)
        }
        .frame(width: 70, height: 70)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(QodeXColors.deepVoid)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview

#Preview {
    let chart = NumerologyChart(
        lifePath: 7,
        expression: 3,
        soulUrge: 9,
        personality: 5,
        birthday: 8,
        maturity: 1,
        challenges: [1, 0, 2, 1],
        pinnacles: [
            Pinnacle(number: 6, ageStart: 0, ageEnd: 35),
            Pinnacle(number: 9, ageStart: 36, ageEnd: 44),
            Pinnacle(number: 6, ageStart: 45, ageEnd: 53),
            Pinnacle(number: 3, ageStart: 54, ageEnd: nil)
        ],
        personalYear: 3,
        personalMonth: 8,
        personalDay: 5,
        birthDate: Date(),
        fullName: "Shani Ben-David"
    )
    
    BirthChartView(chart: chart)
}

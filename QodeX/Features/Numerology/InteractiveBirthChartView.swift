import SwiftUI
import Combine

// MARK: - Enhanced Interactive Birth Chart
struct InteractiveBirthChartView: View {
    @StateObject private var viewModel = BirthChartViewModel()
    @State private var rotation: Double = 0
    @State private var selectedNumber: Int? = nil
    @State private var showParticleEffect = false
    
    var body: some View {
        ZStack {
            // Deep space background
            CosmicBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Header
                    ChartHeader(name: viewModel.userName, date: viewModel.birthDate)
                    
                    // Interactive Wheel
                    ZStack {
                        // Outer ring with numbers
                        GeometryReader { geometry in
                            let size = min(geometry.size.width, geometry.size.height)
                            let radius = size / 2 - 40
                            
                            ZStack {
                                // Background rings
                                ForEach(0..<5) { i in
                                    Circle()
                                        .stroke(
                                            Color.gold.opacity(0.1 - Double(i) * 0.02),
                                            lineWidth: 1
                                        )
                                        .scaleEffect(1.0 - Double(i) * 0.15)
                                }
                                
                                // Rotating number wheel
                                RotatingNumberWheel(
                                    numbers: viewModel.coreNumbers,
                                    radius: radius,
                                    rotation: $rotation,
                                    selectedNumber: $selectedNumber
                                )
                                .rotationEffect(.degrees(rotation))
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            withAnimation(.interactiveSpring()) {
                                                rotation += value.translation.width * 0.5
                                            }
                                        }
                                )
                                
                                // Center info
                                CenterInfoView(
                                    selectedNumber: selectedNumber,
                                    lifePath: viewModel.lifePath
                                )
                            }
                        }
                        .frame(height: 360)
                    }
                    
                    // Number selection indicator
                    if let selected = selectedNumber {
                        SelectedNumberDetail(number: selected)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    // Core Numbers Grid
                    CoreNumbersGrid(numbers: viewModel.coreNumbers) { number in
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            selectedNumber = number
                            showParticleEffect = true
                        }
                    }
                    
                    // Life Cycles Section
                    LifeCyclesSection(cycles: viewModel.lifeCycles)
                    
                    // Compatibility Preview
                    CompatibilityPreview()
                }
                .padding()
            }
        }
        .sheet(item: $selectedNumber) { number in
            NumberDetailSheet(number: number)
        }
    }
}

// MARK: - View Model
class BirthChartViewModel: ObservableObject {
    @Published var userName = "Alexandra"
    @Published var birthDate = Date()
    @Published var lifePath = 7
    
    var coreNumbers: [CoreNumber] {
        [
            CoreNumber(value: 7, type: .lifePath, position: 0),
            CoreNumber(value: 3, type: .expression, position: 1),
            CoreNumber(value: 6, type: .soulUrge, position: 2),
            CoreNumber(value: 9, type: .personality, position: 3),
            CoreNumber(value: 4, type: .birthday, position: 4),
            CoreNumber(value: 5, type: .maturity, position: 5),
        ]
    }
    
    var lifeCycles: [LifeCycle] {
        [
            LifeCycle(age: "0-28", number: 3, phase: "Formative"),
            LifeCycle(age: "29-56", number: 7, phase: "Productive"),
            LifeCycle(age: "57+", number: 1, phase: "Harvest"),
        ]
    }
}

// MARK: - Models
struct CoreNumber: Identifiable, Hashable {
    let id = UUID()
    let value: Int
    let type: NumberType
    let position: Int
    
    var color: Color {
        switch type {
        case .lifePath: return .gold
        case .expression: return .purple
        case .soulUrge: return .pink
        case .personality: return .blue
        case .birthday: return .green
        case .maturity: return .orange
        }
    }
    
    var description: String {
        switch type {
        case .lifePath: return "Your life's journey"
        case .expression: return "How you express yourself"
        case .soulUrge: return "Your inner desires"
        case .personality: return "How others see you"
        case .birthday: return "Your special gift"
        case .maturity: return "Your later years"
        }
    }
}

enum NumberType: String {
    case lifePath = "Life Path"
    case expression = "Expression"
    case soulUrge = "Soul Urge"
    case personality = "Personality"
    case birthday = "Birthday"
    case maturity = "Maturity"
}

struct LifeCycle: Identifiable {
    let id = UUID()
    let age: String
    let number: Int
    let phase: String
}

// MARK: - Views
struct ChartHeader: View {
    let name: String
    let date: Date
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(name)'s Birth Chart")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(date.formatted(date: .long, time: .omitted))
                .font(.subheadline)
                .foregroundColor(.secondaryText)
        }
    }
}

struct RotatingNumberWheel: View {
    let numbers: [CoreNumber]
    let radius: CGFloat
    @Binding var rotation: Double
    @Binding var selectedNumber: Int?
    
    var body: some View {
        ZStack {
            ForEach(Array(numbers.enumerated()), id: \.element.id) { index, number in
                let angle = Double(index) * (360.0 / Double(numbers.count))
                let radians = angle * .pi / 180
                let x = radius * cos(radians)
                let y = radius * sin(radians)
                
                NumberNode(
                    number: number,
                    isSelected: selectedNumber == number.value
                )
                .position(
                    x: radius + 40 + x,
                    y: radius + 40 + y
                )
                .onTapGesture {
                    withAnimation(.spring()) {
                        selectedNumber = number.value
                    }
                }
            }
        }
    }
}

struct NumberNode: View {
    let number: CoreNumber
    let isSelected: Bool
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            // Glow effect for selected
            if isSelected {
                Circle()
                    .fill(number.color.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .blur(radius: 10)
                    .scaleEffect(isPulsing ? 1.2 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: isPulsing
                    )
                    .onAppear { isPulsing = true }
            }
            
            // Main circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            isSelected ? number.color : Color.deepSpace,
                            Color.cosmicBlack
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 64, height: 64)
                .overlay(
                    Circle()
                        .stroke(
                            isSelected ? number.color : Color.white.opacity(0.2),
                            lineWidth: isSelected ? 3 : 1
                        )
                )
                .shadow(
                    color: isSelected ? number.color.opacity(0.5) : Color.clear,
                    radius: isSelected ? 10 : 0
                )
            
            // Number
            VStack(spacing: 0) {
                Text("\(number.value)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : .white)
                
                Text(number.type.rawValue)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondaryText)
            }
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(), value: isSelected)
    }
}

struct CenterInfoView: View {
    let selectedNumber: Int?
    let lifePath: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.gold.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 100
                    )
                )
            
            VStack(spacing: 4) {
                if let selected = selectedNumber {
                    Text("\(selected)")
                        .font(.system(size: 48, weight: .thin, design: .rounded))
                        .foregroundColor(.gold)
                    
                    Text("Selected")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                } else {
                    Text("\(lifePath)")
                        .font(.system(size: 48, weight: .thin, design: .rounded))
                        .foregroundColor(.gold)
                    
                    Text("Life Path")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
            }
        }
        .frame(width: 120, height: 120)
    }
}

struct SelectedNumberDetail: View {
    let number: Int
    
    var body: some View {
        HStack {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.gold)
            
            Text("Tap to see full interpretation")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gold)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.deepSpace)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gold.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct CoreNumbersGrid: View {
    let numbers: [CoreNumber]
    let onSelect: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Core Numbers")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(numbers) { number in
                    CoreNumberCard(number: number) {
                        onSelect(number.value)
                    }
                }
            }
        }
    }
}

struct CoreNumberCard: View {
    let number: CoreNumber
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Number circle
                ZStack {
                    Circle()
                        .fill(number.color.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Text("\(number.value)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(number.color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(number.type.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text(number.description)
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.deepSpace)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LifeCyclesSection: View {
    let cycles: [LifeCycle]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Life Cycles")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(cycles) { cycle in
                    LifeCycleRow(cycle: cycle)
                }
            }
        }
    }
}

struct LifeCycleRow: View {
    let cycle: LifeCycle
    
    var body: some View {
        HStack(spacing: 16) {
            // Age range
            VStack(alignment: .center, spacing: 2) {
                Text(cycle.age)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gold)
            }
            .frame(width: 60)
            
            // Timeline bar
            TimelineBar(number: cycle.number)
            
            // Phase
            VStack(alignment: .trailing, spacing: 2) {
                Text(cycle.phase)
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .frame(width: 80)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.deepSpace)
        )
    }
}

struct TimelineBar: View {
    let number: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 8)
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.gold, .goldLight],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(number) / 9, height: 8)
                    .cornerRadius(4)
            }
        }
        .frame(height: 8)
    }
}

struct CompatibilityPreview: View {
    var body: some View {
        Button(action: {}) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Compatibility Check")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("See how you match with others")
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "heart.fill")
                    .font(.title2)
                    .foregroundColor(.pink)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.pink.opacity(0.2), Color.purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.pink.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NumberDetailSheet: View {
    let number: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Number header
                    Text("\(number)")
                        .font(.system(size: 100, weight: .thin, design: .rounded))
                        .foregroundColor(.gold)
                    
                    Text(NumberTypeDescriptions.titles[number] ?? "")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    // Full description
                    VStack(alignment: .leading, spacing: 16) {
                        DetailSection(title: "Core Meaning", content: NumberTypeDescriptions.meanings[number] ?? "")
                        
                        DetailSection(title: "Strengths", content: NumberTypeDescriptions.strengths[number]?.joined(separator: " • ") ?? "")
                        
                        DetailSection(title: "Challenges", content: NumberTypeDescriptions.challenges[number]?.joined(separator: " • ") ?? "")
                        
                        DetailSection(title: "Famous Examples", content: NumberTypeDescriptions.famous[number]?.joined(separator: ", ") ?? "")
                    }
                    .padding()
                }
            }
            .navigationTitle("Number \(number)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .background(Color.cosmicBlack.ignoresSafeArea())
        }
    }
}

struct DetailSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gold)
            
            Text(content)
                .font(.body)
                .foregroundColor(.white)
                .lineSpacing(4)
        }
    }
}

// MARK: - Data
struct NumberTypeDescriptions {
    static let titles: [Int: String] = [
        1: "The Leader",
        2: "The Diplomat",
        3: "The Creator",
        4: "The Builder",
        5: "The Adventurer",
        6: "The Nurturer",
        7: "The Seeker",
        8: "The Powerhouse",
        9: "The Humanitarian"
    ]
    
    static let meanings: [Int: String] = [
        1: "Number 1 represents independence, leadership, and new beginnings. You are a pioneer with strong willpower and determination.",
        7: "Number 7 represents spirituality, analysis, and wisdom. You are a seeker of truth with deep intuitive abilities."
    ]
    
    static let strengths: [Int: [String]] = [
        1: ["Leadership", "Independence", "Creativity", "Ambition"],
        7: ["Intuition", "Analysis", "Spirituality", "Wisdom"]
    ]
    
    static let challenges: [Int: [String]] = [
        1: ["Stubbornness", "Isolation", "Impatience"],
        7: ["Overthinking", "Detachment", "Perfectionism"]
    ]
    
    static let famous: [Int: [String]] = [
        1: ["Steve Jobs", "Lady Gaga", "Martin Luther King Jr."],
        7: ["Leonardo da Vinci", "Princess Diana", "Stephen Hawking"]
    ]
}

// MARK: - Preview
struct InteractiveBirthChartView_Previews: PreviewProvider {
    static var previews: some View {
        InteractiveBirthChartView()
            .preferredColorScheme(.dark)
    }
}

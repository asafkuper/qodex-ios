import SwiftUI
import Combine

// MARK: - Enhanced Daily Qode View
struct DailyQodeView: View {
    @StateObject private var viewModel = DailyQodeViewModel()
    @State private var isAnimating = false
    @State private var showDetail = false
    
    var body: some View {
        ZStack {
            // Animated background
            CosmicBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Date header
                    DateHeader()
                    
                    // Main number display
                    ZStack {
                        // Outer glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.gold.opacity(0.3),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 50,
                                    endRadius: 150
                                )
                            )
                            .frame(width: 280, height: 280)
                            .blur(radius: 20)
                            .scaleEffect(isAnimating ? 1.1 : 0.9)
                            .animation(
                                Animation.easeInOut(duration: 3)
                                    .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                            .accessibilityHidden(true)
                        
                        // Number circle
                        Button(action: { showDetail = true }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.deepSpace,
                                                Color.cosmicBlack
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 200, height: 200)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                Color.gold.opacity(0.5),
                                                lineWidth: 2
                                            )
                                    )
                                    .shadow(
                                        color: Color.gold.opacity(0.3),
                                        radius: 20,
                                        x: 0,
                                        y: 0
                                    )
                                
                                VStack(spacing: 8) {
                                    Text("Today's Qode")
                                        .font(.caption)
                                        .foregroundColor(.secondaryText)
                                    
                                    Text("\(viewModel.dailyNumber)")
                                        .font(.system(size: 80, weight: .thin, design: .rounded))
                                        .foregroundColor(.gold)
                                }
                            }
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .accessibilityLabel("Today's Qode number is \(viewModel.dailyNumber). Double tap for details.")
                    }
                    .onAppear { isAnimating = true }
                    
                    // Insight card
                    InsightCard(
                        title: viewModel.insightTitle,
                        description: viewModel.insightDescription,
                        affirmation: viewModel.affirmation
                    )
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(viewModel.insightTitle). \(viewModel.insightDescription). Affirmation: \(viewModel.affirmation)")
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        ActionButton(
                            icon: "book.fill",
                            title: "Read More",
                            action: { showDetail = true }
                        )
                        .accessibilityLabel("Read more about today's Qode")
                        
                        ActionButton(
                            icon: "square.and.arrow.up",
                            title: "Share",
                            action: { viewModel.shareQode() }
                        )
                        .accessibilityLabel("Share today's Qode")
                    }
                    
                    // Weekly preview
                    WeeklyPreview(selectedDay: viewModel.selectedDay)
                        .accessibilityLabel("Weekly Qode preview")
                }
                .padding()
            }
        }
        .sheet(isPresented: $showDetail) {
            QodeDetailView(number: viewModel.dailyNumber)
        }
        .accessibilityLabel("Daily Qode view")
    }
}

// MARK: - ViewModel
class DailyQodeViewModel: ObservableObject {
    @Published var dailyNumber: Int = 7
    @Published var selectedDay = Date()
    
    var insightTitle: String {
        QodeInsights.titles[dailyNumber] ?? "Day of Reflection"
    }
    
    var insightDescription: String {
        QodeInsights.descriptions[dailyNumber] ?? "A day for inner wisdom and spiritual connection."
    }
    
    var affirmation: String {
        QodeInsights.affirmations[dailyNumber] ?? "I trust my inner guidance."
    }
    
    func shareQode() {
        // Share implementation
    }
}

// MARK: - Supporting Views
struct DateHeader: View {
    var body: some View {
        VStack(spacing: 4) {
            Text(Date().formatted(.dateTime.weekday(.wide)))
                .font(.title3)
                .foregroundColor(.gold)
            
            Text(Date().formatted(.dateTime.day().month(.wide).year()))
                .font(.caption)
                .foregroundColor(.secondaryText)
        }
        .textCase(.uppercase)
        .tracking(2)
    }
}

struct InsightCard: View {
    let title: String
    let description: String
    let affirmation: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondaryText)
                .lineSpacing(4)
            
            Divider()
                .background(Color.gold.opacity(0.3))
            
            HStack(spacing: 8) {
                Image(systemName: "quote.opening")
                    .foregroundColor(.gold)
                    .font(.caption)
                
                Text(affirmation)
                    .font(.callout)
                    .italic()
                    .foregroundColor(.gold)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.deepSpace)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gold.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.1))
            )
            .overlay(
                Capsule()
                    .stroke(Color.gold.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct WeeklyPreview: View {
    let selectedDay: Date
    let days = ["S", "M", "T", "W", "T", "F", "S"]
    let numbers = [5, 6, 7, 8, 9, 1, 2]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                ForEach(0..<7) { index in
                    DayPreview(
                        day: days[index],
                        number: numbers[index],
                        isSelected: index == 2
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.deepSpace)
        )
    }
}

struct DayPreview: View {
    let day: String
    let number: Int
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(day)
                .font(.caption2)
                .foregroundColor(isSelected ? .gold : .secondaryText)
            
            Text("\(number)")
                .font(.headline)
                .foregroundColor(isSelected ? .gold : .white)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(isSelected ? Color.gold.opacity(0.2) : Color.clear)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.gold : Color.clear, lineWidth: 1)
                        )
                )
        }
    }
}

struct QodeDetailView: View {
    let number: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Number header
                    Text("\(number)")
                        .font(.system(size: 120, weight: .thin, design: .rounded))
                        .foregroundColor(.gold)
                    
                    // Full interpretation
                    VStack(alignment: .leading, spacing: 20) {
                        SectionHeader(title: "Today's Energy")
                        
                        Text(QodeInsights.fullDescriptions[number] ?? "")
                            .font(.body)
                            .foregroundColor(.secondaryText)
                            .lineSpacing(6)
                        
                        SectionHeader(title: "Best Activities")
                        
                        ActivityList(activities: QodeInsights.activities[number] ?? [])
                        
                        SectionHeader(title: "Things to Avoid")
                        
                        ActivityList(activities: QodeInsights.avoidances[number] ?? [])
                    }
                    .padding()
                }
            }
            .navigationTitle("Your Daily Qode")
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

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.white)
            .padding(.top, 8)
    }
}

struct ActivityList: View {
    let activities: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(activities, id: \.self) { activity in
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.gold)
                    
                    Text(activity)
                        .font(.body)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Data
struct QodeInsights {
    static let titles: [Int: String] = [
        1: "Day of New Beginnings",
        2: "Day of Partnership", 
        3: "Day of Creativity",
        4: "Day of Foundation",
        5: "Day of Change",
        6: "Day of Harmony",
        7: "Day of Wisdom",
        8: "Day of Power",
        9: "Day of Completion"
    ]
    
    static let descriptions: [Int: String] = [
        1: "Today carries the energy of initiation and leadership. It's a perfect day to start new projects and take decisive action.",
        2: "Cooperation and diplomacy are highlighted today. Focus on relationships and finding balance in partnerships.",
        3: "Creative energy flows freely today. Express yourself through art, writing, or any form of creative communication.",
        4: "Build solid foundations today. Focus on organization, planning, and creating lasting structures in your life.",
        5: "Change is in the air. Embrace flexibility and be open to new experiences and unexpected opportunities.",
        6: "Nurture yourself and others today. Focus on home, family, and creating beauty in your environment.",
        7: "Go within today. Research, analysis, and spiritual pursuits are favored. Trust your intuition.",
        8: "Abundance and achievement are today's themes. Focus on business, finances, and manifesting your goals.",
        9: "A day of completion and letting go. Release what no longer serves you and prepare for new cycles."
    ]
    
    static let affirmations: [Int: String] = [
        1: "I am a confident leader and creator.",
        2: "I create harmonious relationships with ease.",
        3: "My creativity flows freely and joyfully.",
        4: "I build solid foundations for my dreams.",
        5: "I embrace change with courage and excitement.",
        6: "I nurture myself and others with love.",
        7: "I trust my inner wisdom and intuition.",
        8: "I am abundant and successful in all I do.",
        9: "I release the old and welcome the new."
    ]
    
    static let fullDescriptions: [Int: String] = [
        1: "The number 1 represents new beginnings, leadership, and independence. Today, you are being called to step forward with confidence and take initiative. This is a powerful day for starting fresh projects, making important decisions, and asserting your individuality. The universe supports your courage to stand out and lead the way.",
        2: "The number 2 embodies partnership, diplomacy, and harmony. Today invites you to focus on your relationships and practice patience and cooperation. This is an ideal day for negotiations, collaborations, and bringing balance to any conflicts. Trust your intuition and work with others rather than pushing solo.",
        3: "The number 3 radiates creativity, self-expression, and joy. Today is infused with vibrant energy that supports all forms of artistic and communicative endeavors. Share your ideas, engage in creative projects, and connect with others through laughter and lightheartedness. Your words have power today.",
        4: "The number 4 symbolizes stability, hard work, and building foundations. Today calls for discipline and methodical progress. Focus on organizing your space, creating systems, and tackling tasks that require attention to detail. The energy of 4 rewards patience and persistence with lasting results.",
        5: "The number 5 brings freedom, adventure, and dynamic change. Today holds exciting possibilities and unexpected opportunities. Embrace flexibility, try something new, and break free from routine. The energy supports travel, learning, and stepping outside your comfort zone.",
        6: "The number 6 represents love, responsibility, and domestic harmony. Today centers on home, family, and service to others. Focus on creating beauty in your environment, nurturing relationships, and finding balance between giving and receiving. This is a day for healing and emotional connection.",
        7: "The number 7 represents spiritual awakening, inner wisdom, and deep introspection. Today, the universe invites you to look beyond the surface and seek deeper truths. This is a day for research, analysis, and connecting with your higher self. The energy of 7 supports meditation, study, and any activity that requires focused attention and discernment.",
        8: "The number 8 embodies abundance, power, and material success. Today's energy supports business ventures, financial decisions, and manifesting prosperity. Focus on your ambitions and take practical steps toward your goals. The number 8 reminds you that you have the power to create the wealth and success you desire.",
        9: "The number 9 signifies completion, compassion, and universal love. Today is about wrapping up loose ends, letting go of what no longer serves you, and preparing for new cycles. Practice forgiveness, engage in humanitarian efforts, and trust that endings make way for beautiful new beginnings."
    ]
    
    static let activities: [Int: [String]] = [
        1: ["Start a new project", "Take initiative at work", "Exercise leadership", "Make bold decisions", "Focus on self-development"],
        2: ["Have important conversations", "Seek compromise", "Practice active listening", "Collaborate with others", "Nurture close relationships"],
        3: ["Engage in creative hobbies", "Write or journal", "Socialize with friends", "Express your feelings", "Brainstorm new ideas"],
        4: ["Organize your space", "Create schedules and plans", "Focus on practical tasks", "Review finances", "Build or fix something"],
        5: ["Try something new", "Take a different route", "Learn a new skill", "Meet new people", "Embrace spontaneity"],
        6: ["Spend time with family", "Cook a meal for loved ones", "Decorate or beautify your home", "Practice self-care", "Help someone in need"],
        7: ["Meditation and contemplation", "Research and study", "Writing and journaling", "Nature walks", "Spiritual reading"],
        8: ["Financial planning", "Career advancement activities", "Physical exercise", "Set ambitious goals", "Take calculated risks"],
        9: ["Complete pending tasks", "Donate or volunteer", "Practice forgiveness", "Clean and declutter", "Reflect on your journey"]
    ]
    
    static let avoidances: [Int: [String]] = [
        1: ["Procrastination", "Following others blindly", "Avoiding responsibility", "Being overly aggressive", "Isolation"],
        2: ["Conflict and arguments", "Making hasty decisions", "Ignoring your own needs", "Being overly critical", "Rushing into commitments"],
        3: ["Being overly serious", "Suppressing emotions", "Gossip or negativity", "Overcommitting", "Ignoring practical matters"],
        4: ["Taking shortcuts", "Reckless spending", "Ignoring details", "Being rigid or stubborn", "Starting without planning"],
        5: ["Rigid routines", "Overcommitting", "Ignoring responsibilities", "Impulsive risks", "Staying in your comfort zone"],
        6: ["Neglecting self-care", "Taking on too much", "Perfectionism", "Avoiding necessary conflicts", "Overworking"],
        7: ["Superficial conversations", "Impulsive decisions", "Over-scheduling", "Excessive socializing", "Material pursuits"],
        8: ["Being reckless with money", "Procrastination on goals", "Micromanaging others", "Ignoring ethics for gain", "Work-life imbalance"],
        9: ["Starting major new projects", "Holding grudges", "Clinging to the past", "Selfish behavior", "Ignoring closure"]
    ]
}

// MARK: - Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Preview
struct DailyQodeView_Previews: PreviewProvider {
    static var previews: some View {
        DailyQodeView()
            .preferredColorScheme(.dark)
    }
}

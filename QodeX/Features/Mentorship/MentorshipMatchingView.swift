//
//  MentorshipMatchingView.swift
//  Connect members for numerology mentorship
//

import SwiftUI

struct MentorshipMatchingView: View {
    @StateObject private var viewModel = MentorshipViewModel()
    
    var body: some View {
        ZStack {
            QodeXColors.cosmicBlack.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    mentorshipHeader
                    
                    // My mentor/mentee status
                    if let myMentor = viewModel.myMentor {
                        myMentorSection(mentor: myMentor)
                    }
                    
                    if !viewModel.myMentees.isEmpty {
                        myMenteesSection
                    }
                    
                    // Find matches
                    if viewModel.canBeMentee || viewModel.canBeMentor {
                        findMatchesSection
                    }
                    
                    // Community mentors
                    featuredMentorsSection
                }
                .padding(.vertical, 20)
            }
        }
        .navigationTitle("Mentorship")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var mentorshipHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Numerology Mentorship")
                .font(QodeXTypography.title)
                .foregroundStyle(QodeXColors.pureWhite)
            
            Text("Learn from experienced practitioners or guide others on their journey")
                .font(QodeXTypography.body)
                .foregroundStyle(QodeXColors.stardust)
        }
        .padding(.horizontal, 20)
    }
    
    private func myMentorSection(mentor: MentorProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Mentor")
                    .font(QodeXTypography.headline)
                    .foregroundStyle(QodeXColors.pureWhite)
                
                Spacer()
                
                Button("Change") {}
                    .font(.system(size: 12))
                    .foregroundStyle(QodeXColors.gold)
            }
            .padding(.horizontal, 20)
            
            MentorCard(mentor: mentor, showConnectButton: false)
                .padding(.horizontal, 20)
            
            // Quick actions
            HStack(spacing: 12) {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "message.fill")
                        Text("Message")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(QodeXColors.cosmicBlack)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(QodeXColors.gold)
                    .cornerRadius(12)
                }
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Schedule")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(QodeXColors.pureWhite)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(QodeXColors.starlight)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var myMenteesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Mentees")
                    .font(QodeXTypography.headline)
                    .foregroundStyle(QodeXColors.pureWhite)
                
                Spacer()
                
                Text("\(viewModel.myMentees.count)/3")
                    .font(.system(size: 14))
                    .foregroundStyle(QodeXColors.stardust)
            }
            .padding(.horizontal, 20)
            
            ForEach(viewModel.myMentees) { mentee in
                MenteeRow(mentee: mentee)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var findMatchesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Find Your Match")
                .font(QodeXTypography.headline)
                .foregroundStyle(QodeXColors.pureWhite)
                .padding(.horizontal, 20)
            
            if viewModel.canBeMentee {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Looking for a Mentor")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(QodeXColors.pureWhite)
                    
                    Text("These experienced practitioners are compatible with your chart")
                        .font(.system(size: 13))
                        .foregroundStyle(QodeXColors.stardust)
                    
                    ForEach(viewModel.suggestedMentors) { mentor in
                        MentorCard(mentor: mentor, showConnectButton: true)
                    }
                }
                .padding(16)
                .background(QodeXColors.deepVoid)
                .cornerRadius(16)
                .padding(.horizontal, 20)
            }
            
            if viewModel.canBeMentor {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Become a Mentor")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(QodeXColors.pureWhite)
                    
                    Text("Share your knowledge with members whose charts align with yours")
                        .font(.system(size: 13))
                        .foregroundStyle(QodeXColors.stardust)
                    
                    ForEach(viewModel.suggestedMentees) { mentee in
                        MenteeMatchCard(mentee: mentee)
                    }
                    
                    Button(action: { viewModel.applyAsMentor() }) {
                        HStack {
                            Image(systemName: "star.fill")
                            Text("Apply to be a Mentor")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(QodeXColors.cosmicBlack)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(QodeXColors.gold)
                        .cornerRadius(12)
                    }
                }
                .padding(16)
                .background(QodeXColors.deepVoid)
                .cornerRadius(16)
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var featuredMentorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Featured Mentors")
                    .font(QodeXTypography.headline)
                    .foregroundStyle(QodeXColors.pureWhite)
                
                Spacer()
                
                Button("See All") {}
                    .font(.system(size: 12))
                    .foregroundStyle(QodeXColors.gold)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.featuredMentors) { mentor in
                        FeaturedMentorCard(mentor: mentor)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Supporting Views

struct MentorCard: View {
    let mentor: MentorProfile
    let showConnectButton: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(QodeXColors.starlight)
                    .frame(width: 60, height: 60)
                
                Text(mentor.initials)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(QodeXColors.pureWhite)
                
                if mentor.isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(QodeXColors.gold)
                        .background(Circle().fill(QodeXColors.cosmicBlack))
                        .offset(x: 20, y: 20)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(mentor.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(QodeXColors.pureWhite)
                    
                    if mentor.isShani {
                        Text("SHANI")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(QodeXColors.cosmicBlack)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(QodeXColors.gold)
                            .cornerRadius(4)
                    }
                }
                
                Text(mentor.title)
                    .font(.system(size: 13))
                    .foregroundStyle(QodeXColors.stardust)
                
                HStack(spacing: 12) {
                    Label("\(mentor.menteeCount)", systemImage: "person.2")
                    Label("\(mentor.rating, specifier: "%.1f")", systemImage: "star.fill")
                }
                .font(.system(size: 12))
                .foregroundStyle(QodeXColors.stardust)
                
                // Compatibility badge
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 10))
                    Text("\(mentor.compatibilityScore)% compatible")
                        .font(.system(size: 11))
                }
                .foregroundStyle(QodeXColors.cosmicTeal)
            }
            
            Spacer()
            
            if showConnectButton {
                Button(action: {}) {
                    Text("Connect")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(QodeXColors.cosmicBlack)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(QodeXColors.gold)
                        .cornerRadius(20)
                }
            }
        }
        .padding(16)
        .background(QodeXColors.deepVoid)
        .cornerRadius(16)
    }
}

struct MenteeRow: View {
    let mentee: MenteeProfile
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(QodeXColors.starlight)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(mentee.initials)
                        .font(.system(size: 16))
                        .foregroundStyle(QodeXColors.pureWhite)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(mentee.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(QodeXColors.pureWhite)
                
                Text("Member since \(mentee.joinDate)")
                    .font(.system(size: 12))
                    .foregroundStyle(QodeXColors.stardust)
            }
            
            Spacer()
            
            // Progress indicator
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(mentee.progress)%")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(QodeXColors.gold)
                
                Text("journey complete")
                    .font(.system(size: 10))
                    .foregroundStyle(QodeXColors.stardust)
            }
        }
        .padding(12)
        .background(QodeXColors.deepVoid)
        .cornerRadius(12)
    }
}

struct MenteeMatchCard: View {
    let mentee: MenteeProfile
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(QodeXColors.starlight)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(mentee.initials)
                        .font(.system(size: 16))
                        .foregroundStyle(QodeXColors.pureWhite)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(mentee.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(QodeXColors.pureWhite)
                
                Text("Life Path \(mentee.lifePath) • Seeking guidance")
                    .font(.system(size: 12))
                    .foregroundStyle(QodeXColors.stardust)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(QodeXColors.gold)
            }
        }
        .padding(12)
        .background(QodeXColors.starlight.opacity(0.3))
        .cornerRadius(12)
    }
}

struct FeaturedMentorCard: View {
    let mentor: MentorProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(QodeXColors.starlight)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text(mentor.initials)
                            .font(.system(size: 18))
                            .foregroundStyle(QodeXColors.pureWhite)
                    )
                
                Spacer()
                
                if mentor.isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(QodeXColors.gold)
                }
            }
            
            Text(mentor.name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(QodeXColors.pureWhite)
            
            Text(mentor.specialty)
                .font(.system(size: 12))
                .foregroundStyle(QodeXColors.stardust)
                .lineLimit(2)
            
            HStack(spacing: 8) {
                Label("\(mentor.menteeCount)", systemImage: "person.2")
                    .font(.system(size: 11))
                
                Label("\(mentor.rating, specifier: "%.1f")", systemImage: "star.fill")
                    .font(.system(size: 11))
            }
            .foregroundStyle(QodeXColors.stardust)
        }
        .frame(width: 150)
        .padding(12)
        .background(QodeXColors.deepVoid)
        .cornerRadius(16)
    }
}

// MARK: - View Model

class MentorshipViewModel: ObservableObject {
    @Published var myMentor: MentorProfile?
    @Published var myMentees: [MenteeProfile] = []
    @Published var canBeMentee = true
    @Published var canBeMentor = false
    @Published var suggestedMentors: [MentorProfile] = []
    @Published var suggestedMentees: [MenteeProfile] = []
    @Published var featuredMentors: [MentorProfile] = []
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        myMentor = MentorProfile(
            id: "1",
            name: "Shani",
            initials: "S",
            title: "Creator of QodeX",
            specialty: "Master Numerologist",
            menteeCount: 47,
            rating: 5.0,
            isVerified: true,
            isShani: true,
            compatibilityScore: 100
        )
        
        myMentees = [
            MenteeProfile(id: "2", name: "Alex M.", initials: "AM", lifePath: 3, joinDate: "Jan 2024", progress: 65),
            MenteeProfile(id: "3", name: "Jordan K.", initials: "JK", lifePath: 7, joinDate: "Dec 2023", progress: 82)
        ]
        
        suggestedMentors = [
            MentorProfile(
                id: "4",
                name: "Maria Santos",
                initials: "MS",
                title: "Numerology Teacher",
                specialty: "Life Path Mastery",
                menteeCount: 23,
                rating: 4.9,
                isVerified: true,
                isShani: false,
                compatibilityScore: 87
            ),
            MentorProfile(
                id: "5",
                name: "David Chen",
                initials: "DC",
                title: "Spiritual Coach",
                specialty: "Master Numbers",
                menteeCount: 15,
                rating: 4.8,
                isVerified: true,
                isShani: false,
                compatibilityScore: 82
            )
        ]
        
        featuredMentors = suggestedMentors + [
            MentorProfile(
                id: "6",
                name: "Emma Wilson",
                initials: "EW",
                title: "Intuitive Guide",
                specialty: "Soul Urge Analysis",
                menteeCount: 31,
                rating: 4.9,
                isVerified: true,
                isShani: false,
                compatibilityScore: 0
            )
        ]
        
        suggestedMentees = [
            MenteeProfile(id: "7", name: "Sam T.", initials: "ST", lifePath: 5, joinDate: "Feb 2024", progress: 0),
            MenteeProfile(id: "8", name: "Riley P.", initials: "RP", lifePath: 9, joinDate: "Mar 2024", progress: 0)
        ]
    }
    
    func applyAsMentor() {
        // Submit application
    }
}

// MARK: - Models

struct MentorProfile: Identifiable {
    let id: String
    let name: String
    let initials: String
    let title: String
    let specialty: String
    let menteeCount: Int
    let rating: Double
    let isVerified: Bool
    let isShani: Bool
    let compatibilityScore: Int
}

struct MenteeProfile: Identifiable {
    let id: String
    let name: String
    let initials: String
    let lifePath: Int
    let joinDate: String
    let progress: Int
}

// MARK: - Preview

#Preview {
    MentorshipMatchingView()
}

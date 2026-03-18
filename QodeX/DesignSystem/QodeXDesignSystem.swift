import SwiftUI

// MARK: - Design System Views
// Note: Colors and Typography are defined in Colors.swift (QXColor, QXFont, QXSpacing)

// MARK: - Login Screen (Design System Example)

struct LoginView_Example: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Cosmic Background
            QXColor.cosmicBlack
                .ignoresSafeArea()
            
            // Sacred Geometry Background Pattern
            SacredGeometryBackground()
                .opacity(0.1)
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo & Title
                VStack(spacing: 16) {
                    // Animated Sacred Geometry Logo
                    ZStack {
                        Circle()
                            .stroke(QXColor.gold.opacity(0.3), lineWidth: 1)
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .stroke(QXColor.gold.opacity(0.5), lineWidth: 1)
                            .frame(width: 100, height: 100)
                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                            .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: isAnimating)
                        
                        // Hexagon
                        HexagonShape()
                            .stroke(QXColor.gold, lineWidth: 2)
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(isAnimating ? -360 : 0))
                            .animation(.linear(duration: 30).repeatForever(autoreverses: false), value: isAnimating)
                        
                        Text("Q")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(QXColor.gold)
                    }
                    
                    VStack(spacing: 8) {
                        Text("QodeX")
                            .font(QXFont.title)
                            .foregroundStyle(QXColor.starlight)
                        
                        Text("INNER CIRCLE")
                            .font(QXFont.caption)
                            .tracking(4)
                            .foregroundStyle(QXColor.gold)
                    }
                }
                
                Spacer()
                
                // Login Form
                VStack(spacing: 20) {
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("EMAIL")
                            .font(QXFont.caption)
                            .foregroundStyle(QXColor.starlight.opacity(0.5))
                        
                        TextField("", text: $email)
                            .textFieldStyle(QodeXTextFieldStyle())
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PASSWORD")
                            .font(QXFont.caption)
                            .foregroundStyle(QXColor.starlight.opacity(0.5))
                        
                        SecureField("", text: $password)
                            .textFieldStyle(QodeXTextFieldStyle())
                    }
                    
                    // Forgot Password
                    HStack {
                        Spacer()
                        Button("Forgot Password?") {}
                            .font(QXFont.caption)
                            .foregroundStyle(QXColor.gold.opacity(0.8))
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Login Button
                Button(action: {}) {
                    HStack {
                        Text("Enter the Circle")
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(QXColor.cosmicBlack)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [QXColor.gold, QXColor.goldGlow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 32)
                
                // Not a member
                HStack(spacing: 4) {
                    Text("Not a member?")
                        .foregroundStyle(QXColor.starlight.opacity(0.5))
                    Button("Join QodeX") {}
                        .foregroundStyle(QXColor.gold)
                }
                .font(QXFont.caption)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Dashboard View (Design System Example)

struct DashboardView_Example: View {
    var body: some View {
        ZStack {
            QXColor.cosmicBlack
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome back,")
                                .font(QXFont.body)
                                .foregroundStyle(QXColor.starlight.opacity(0.5))
                            Text("Seeker")
                                .font(QXFont.headline)
                                .foregroundStyle(QXColor.starlight)
                        }
                        
                        Spacer()
                        
                        // Profile Avatar
                        ZStack {
                            Circle()
                                .fill(QXColor.sacredGeometry)
                                .frame(width: 48, height: 48)
                            
                            Text("S")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(QXColor.gold)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Daily Qode Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Today's Qode")
                                .font(QXFont.headline)
                                .foregroundStyle(QXColor.starlight)
                            
                            Spacer()
                            
                            Image(systemName: "sparkles")
                                .foregroundStyle(QXColor.gold)
                        }
                        
                        HStack(spacing: 20) {
                            // Number Display
                            VStack(spacing: 8) {
                                Text("7")
                                    .font(.system(size: 64, weight: .bold))
                                    .foregroundStyle(QXColor.gold)
                                
                                Text("The Seeker")
                                    .font(QXFont.caption)
                                    .foregroundStyle(QXColor.starlight)
                            }
                            .frame(width: 120)
                            
                            Divider()
                                .background(QXColor.sacredGeometry)
                            
                            // Description
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Analysis & Understanding")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(QXColor.starlight)
                                
                                Text("A day for introspection and seeking deeper truths. Trust your intuition.")
                                    .font(QXFont.caption)
                                    .foregroundStyle(QXColor.starlight.opacity(0.5))
                                    .lineLimit(3)
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(QXColor.deepVoid)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(QXColor.gold.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    
                    // Quick Actions Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        QuickActionCard(
                            icon: "number.circle.fill",
                            title: "My Qode",
                            subtitle: "Personal Matrix",
                            color: QXColor.cosmicPurple
                        )
                        
                        QuickActionCard(
                            icon: "book.closed.fill",
                            title: "Teachings",
                            subtitle: "Shani's Library",
                            color: QXColor.nebulaBlue
                        )
                        
                        QuickActionCard(
                            icon: "video.fill",
                            title: "Live Sessions",
                            subtitle: "Member Calls",
                            color: QXColor.gold
                        )
                        
                        QuickActionCard(
                            icon: "person.3.fill",
                            title: "Community",
                            subtitle: "Inner Circle",
                            color: Color(hex: "E85D75")
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Recent Teachings
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Recent Teachings")
                                .font(QXFont.headline)
                                .foregroundStyle(QXColor.starlight)
                            
                            Spacer()
                            
                            Button("See All") {}
                                .font(QXFont.caption)
                                .foregroundStyle(QXColor.gold)
                        }
                        
                        VStack(spacing: 12) {
                            TeachingRow(
                                title: "The Master Numbers",
                                duration: "45 min",
                                isNew: true
                            )
                            
                            TeachingRow(
                                title: "Decoding Your Life Path",
                                duration: "32 min",
                                isNew: false
                            )
                            
                            TeachingRow(
                                title: "Timing & Cycles",
                                duration: "28 min",
                                isNew: false
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
        }
    }
}

// MARK: - Qode Calculator View (Design System Example)

struct CalculatorView_Example: View {
    @State private var birthDate = Date()
    @State private var fullName = ""
    @State private var showingResults = false
    
    var body: some View {
        ZStack {
            QXColor.cosmicBlack
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Qode Calculator")
                            .font(QXFont.title)
                            .foregroundStyle(QXColor.starlight)
                        
                        Text("Discover your energetic blueprint")
                            .font(QXFont.body)
                            .foregroundStyle(QXColor.starlight.opacity(0.5))
                    }
                    .padding(.top, 20)
                    
                    // Input Section
                    VStack(spacing: 24) {
                        // Birth Date
                        VStack(alignment: .leading, spacing: 12) {
                            Text("BIRTH DATE")
                                .font(QXFont.caption)
                                .foregroundStyle(QXColor.starlight.opacity(0.5))
                            
                            DatePicker(
                                "",
                                selection: $birthDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                            .padding(16)
                            .background(QXColor.deepVoid)
                            .cornerRadius(12)
                            .colorMultiply(QXColor.gold)
                        }
                        
                        // Full Name
                        VStack(alignment: .leading, spacing: 12) {
                            Text("FULL NAME AT BIRTH")
                                .font(QXFont.caption)
                                .foregroundStyle(QXColor.starlight.opacity(0.5))
                            
                            TextField("Enter your full name", text: $fullName)
                                .textFieldStyle(QodeXTextFieldStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Calculate Button
                    Button(action: { showingResults = true }) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Decode My Qode")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundStyle(QXColor.cosmicBlack)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [QXColor.gold, QXColor.goldGlow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 20)
                    
                    // Results Preview (shown after calculation)
                    if showingResults {
                        VStack(spacing: 20) {
                            // Life Path Number
                            QodeResultCard(
                                number: "7",
                                title: "Life Path Number",
                                description: "The Seeker. Deeply analytical and introspective. You are here to seek truth and understanding.",
                                color: QXColor.cosmicPurple
                            )
                            
                            // Expression Number
                            QodeResultCard(
                                number: "3",
                                title: "Expression Number",
                                description: "The Creative. Self-expression and communication are your gifts. You bring joy through creativity.",
                                color: QXColor.nebulaBlue
                            )
                            
                            // Soul Urge Number
                            QodeResultCard(
                                number: "9",
                                title: "Soul Urge Number",
                                description: "The Humanitarian. Your heart yearns to serve humanity and make the world better.",
                                color: QXColor.gold
                            )
                        }
                        .padding(.horizontal, 20)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                    
                    Spacer(minLength: 40)
                }
            }
        }
    }
}

// MARK: - Supporting Components

struct QodeXTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_self._Label>) -> some View {
        configuration
            .padding(16)
            .background(QXColor.deepVoid)
            .cornerRadius(12)
            .foregroundStyle(QXColor.starlight)
            .tint(QXColor.gold)
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(QXColor.starlight)
                
                Text(subtitle)
                    .font(QXFont.caption)
                    .foregroundStyle(QXColor.starlight.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(QXColor.deepVoid)
        )
    }
}

struct TeachingRow: View {
    let title: String
    let duration: String
    let isNew: Bool
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                // Thumbnail
                RoundedRectangle(cornerRadius: 8)
                    .fill(QXColor.sacredGeometry)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "play.fill")
                            .foregroundStyle(QXColor.gold)
                            .accessibilityHidden(true)
                    )
                    .accessibilityLabel("Video thumbnail")
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(QXColor.starlight)
                        
                        if isNew {
                            Text("NEW")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(QXColor.cosmicBlack)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(QXColor.gold)
                                .cornerRadius(4)
                                .accessibilityLabel("New content")
                        }
                    }
                    
                    Text(duration)
                        .font(QXFont.caption)
                        .foregroundStyle(QXColor.starlight.opacity(0.5))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(QXColor.starlight.opacity(0.5))
                    .accessibilityHidden(true)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(QXColor.deepVoid)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibleButton(
            label: "\(title), \(duration) video\(isNew ? ", new" : "")",
            hint: "Double tap to play teaching"
        )
        .minimumTouchTarget()
    }
}

struct QodeResultCard: View {
    let number: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                // Number Circle
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 64, height: 64)
                    
                    Text(number)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(QXColor.starlight)
                    
                    Text("Core Number")
                        .font(QXFont.caption)
                        .foregroundStyle(QXColor.starlight.opacity(0.5))
                }
                
                Spacer()
            }
            
            Text(description)
                .font(QXFont.body)
                .foregroundStyle(QXColor.starlight)
                .lineLimit(3)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(QXColor.deepVoid)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        for i in 0..<6 {
            let angle = Double(i) * .pi / 3 - .pi / 2
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview

#Preview {
    LoginView_Example()
}

#Preview("Dashboard") {
    DashboardView_Example()
}

#Preview("Calculator") {
    CalculatorView_Example()
}

import SwiftUI
import FirebaseAuth

struct AuthFlowView: View {
    @State private var showLogin = true
    @State private var showForgotPassword = false
    
    var body: some View {
        ZStack {
            SacredGeometryBackground()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo
                VStack(spacing: QXSpacing.md) {
                    Text("QodeX")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(QXColor.gold)
                    
                    Text("Decode Your Matrix")
                        .font(QXFont.body)
                        .foregroundColor(QXColor.starlight.opacity(0.7))
                }
                .padding(.bottom, QXSpacing.xxl)
                
                // Auth Form
                GlassCard {
                    VStack(spacing: QXSpacing.lg) {
                        if showForgotPassword {
                            ForgotPasswordView(onBack: { showForgotPassword = false })
                        } else if showLogin {
                            LoginView(showForgotPassword: $showForgotPassword)
                        } else {
                            SignUpView()
                        }
                        
                        if !showForgotPassword {
                            // Toggle
                            Button(action: { 
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showLogin.toggle()
                                }
                            }) {
                                Text(showLogin ? "New to QodeX? Create account" : "Already a member? Sign in")
                                    .font(QXFont.caption)
                                    .foregroundColor(QXColor.gold)
                            }
                        }
                    }
                }
                .padding(.horizontal, QXSpacing.lg)
                
                Spacer()
                
                // Footer
                HStack(spacing: 4) {
                    Text("By continuing, you agree to our")
                        .font(.system(size: 12))
                        .foregroundColor(QXColor.starlight.opacity(0.4))
                    
                    Link("Terms", destination: URL(string: "https://qodex.academy/terms")!)
                        .font(.system(size: 12))
                        .foregroundColor(QXColor.gold.opacity(0.8))
                    
                    Text("and")
                        .font(.system(size: 12))
                        .foregroundColor(QXColor.starlight.opacity(0.4))
                    
                    Link("Privacy", destination: URL(string: "https://qodex.academy/privacy")!)
                        .font(.system(size: 12))
                        .foregroundColor(QXColor.gold.opacity(0.8))
                }
                .multilineTextAlignment(.center)
                .padding(.bottom, QXSpacing.lg)
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

struct LoginView: View {
    @StateObject private var authManager = AuthManager.shared
    @Binding var showForgotPassword: Bool
    @State private var email = ""
    @State private var password = ""
    
    private var isValidEmail: Bool {
        let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
        return NSPredicate(format: "SELF MATCHES[c] %@", emailRegex).evaluate(with: email)
    }
    
    var body: some View {
        VStack(spacing: QXSpacing.lg) {
            Text("Welcome Back")
                .font(QXFont.title)
                .foregroundColor(QXColor.starlight)
            
            VStack(spacing: QXSpacing.md) {
                QXTextField(
                    title: "Email",
                    text: $email,
                    icon: "envelope",
                    keyboardType: .emailAddress
                )
                
                QXTextField(
                    title: "Password",
                    text: $password,
                    icon: "lock",
                    isSecure: true
                )
            }
            
            // Forgot Password
            Button(action: { showForgotPassword = true }) {
                Text("Forgot Password?")
                    .font(QXFont.caption)
                    .foregroundColor(QXColor.gold)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            if let error = authManager.error?.localizedDescription {
                Text(error)
                    .font(QXFont.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            QXButton(
                title: authManager.isLoading ? "Entering..." : "Enter the Circle",
                icon: "sparkles",
                style: .gold
            ) {
                Task {
                    _ = await authManager.signIn(email: email, password: password)
                }
            }
            .disabled(email.isEmpty || password.isEmpty || !isValidEmail || authManager.isLoading)
            .opacity(email.isEmpty || password.isEmpty || !isValidEmail ? 0.6 : 1)
        }
    }
}

struct SignUpView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    
    private var isValidEmail: Bool {
        let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
        return NSPredicate(format: "SELF MATCHES[c] %@", emailRegex).evaluate(with: email)
    }
    
    private var passwordStrength: PasswordStrength {
        calculatePasswordStrength(password)
    }
    
    var body: some View {
        VStack(spacing: QXSpacing.lg) {
            Text("Begin Your Journey")
                .font(QXFont.title)
                .foregroundColor(QXColor.starlight)
            
            VStack(spacing: QXSpacing.md) {
                QXTextField(
                    title: "Your Name",
                    text: $name,
                    icon: "person"
                )
                
                QXTextField(
                    title: "Email",
                    text: $email,
                    icon: "envelope",
                    keyboardType: .emailAddress
                )
                .overlay(
                    HStack {
                        Spacer()
                        if !email.isEmpty {
                            Image(systemName: isValidEmail ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                .foregroundColor(isValidEmail ? .green : .red)
                                .padding(.trailing, 12)
                        }
                    }
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    QXTextField(
                        title: "Password",
                        text: $password,
                        icon: "lock",
                        isSecure: true
                    )
                    
                    if !password.isEmpty {
                        PasswordStrengthBar(strength: passwordStrength)
                    }
                }
            }
            
            if let error = authManager.error?.localizedDescription {
                Text(error)
                    .font(QXFont.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            QXButton(
                title: authManager.isLoading ? "Creating..." : "Create Account",
                icon: "person.badge.plus",
                style: .primary
            ) {
                Task {
                    _ = await authManager.signUp(email: email, password: password, fullName: name, birthDate: Date())
                }
            }
            .disabled(name.isEmpty || email.isEmpty || password.isEmpty || !isValidEmail || passwordStrength == .weak || authManager.isLoading)
            .opacity(name.isEmpty || email.isEmpty || password.isEmpty || !isValidEmail || passwordStrength == .weak ? 0.6 : 1)
        }
    }
    
    private func calculatePasswordStrength(_ password: String) -> PasswordStrength {
        var score = 0
        
        if password.count >= 8 { score += 1 }
        if password.range(of: "[A-Z]", options: .regularExpression) != nil { score += 1 }
        if password.range(of: "[0-9]", options: .regularExpression) != nil { score += 1 }
        if password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil { score += 1 }
        
        switch score {
        case 0...1: return .weak
        case 2: return .fair
        case 3: return .good
        case 4: return .strong
        default: return .weak
        }
    }
}

enum PasswordStrength {
    case weak, fair, good, strong
    
    var color: Color {
        switch self {
        case .weak: return .red
        case .fair: return .orange
        case .good: return .yellow
        case .strong: return .green
        }
    }
    
    var label: String {
        switch self {
        case .weak: return "Weak"
        case .fair: return "Fair"
        case .good: return "Good"
        case .strong: return "Strong"
        }
    }
}

struct PasswordStrengthBar: View {
    let strength: PasswordStrength
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<4) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(barColor(for: index))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 4)
        
        Text(strength.label)
            .font(.caption2)
            .foregroundColor(strength.color)
    }
    
    private func barColor(for index: Int) -> Color {
        let strengthIndex: Int = {
            switch strength {
            case .weak: return 0
            case .fair: return 1
            case .good: return 2
            case .strong: return 3
            }
        }()
        
        return index <= strengthIndex ? strength.color : Color.white.opacity(0.2)
    }
}

struct ForgotPasswordView: View {
    let onBack: () -> Void
    @StateObject private var authManager = AuthManager.shared
    @State private var email = ""
    @State private var resetSent = false
    
    private var isValidEmail: Bool {
        let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
        return NSPredicate(format: "SELF MATCHES[c] %@", emailRegex).evaluate(with: email)
    }
    
    var body: some View {
        VStack(spacing: QXSpacing.lg) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(QXColor.gold)
                }
                Spacer()
            }
            
            Text("Reset Password")
                .font(QXFont.title)
                .foregroundColor(QXColor.starlight)
            
            if resetSent {
                VStack(spacing: 16) {
                    Image(systemName: "envelope.badge.shield.half.filled")
                        .font(.system(size: 48))
                        .foregroundColor(QXColor.gold)
                    
                    Text("Check your email")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("We've sent a password reset link to \(email)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button(action: onBack) {
                        Text("Back to Sign In")
                            .fontWeight(.semibold)
                            .foregroundColor(QXColor.gold)
                    }
                }
                .padding(.vertical, 32)
            } else {
                Text("Enter your email address and we'll send you a link to reset your password.")
                    .font(.subheadline)
                    .foregroundColor(QXColor.starlight.opacity(0.7))
                    .multilineTextAlignment(.center)
                
                QXTextField(
                    title: "Email",
                    text: $email,
                    icon: "envelope",
                    keyboardType: .emailAddress
                )
                
                if let error = authManager.error?.localizedDescription {
                    Text(error)
                        .font(QXFont.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                
                QXButton(
                    title: authManager.isLoading ? "Sending..." : "Send Reset Link",
                    icon: "envelope.fill",
                    style: .gold
                ) {
                    Task {
                        await sendResetLink()
                    }
                }
                .disabled(email.isEmpty || !isValidEmail || authManager.isLoading)
                .opacity(email.isEmpty || !isValidEmail ? 0.6 : 1)
            }
        }
    }
    
    private func sendResetLink() async {
        let result = await authManager.sendPasswordReset(email: email)
        switch result {
        case .success:
            await MainActor.run {
                resetSent = true
            }
        case .failure(let error):
            await MainActor.run {
                authManager.error = error
            }
        }
    }
}

struct QXTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: QXSpacing.md) {
            Image(systemName: icon)
                .foregroundColor(QXColor.gold.opacity(0.7))
                .frame(width: 24)
            
            if isSecure {
                SecureField(title, text: $text)
                    .foregroundColor(QXColor.starlight)
            } else {
                TextField(title, text: $text)
                    .foregroundColor(QXColor.starlight)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.never)
            }
        }
        .padding(QXSpacing.md)
        .background(QXColor.sacredGeometry)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(QXColor.gold.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    AuthFlowView()
}

import SwiftUI

struct SignUpView: View {
    @StateObject private var appState = AppStateManager.shared
    @StateObject private var coreDataManager = CoreDataManager.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
            VStack(spacing: DesignConstants.extraLargeSpacing) {
            // Back dugme gore levo
            HStack {
                Button(action: {
                    appState.navigateTo(.splash)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                        Text("Back")
                            .font(DesignConstants.bodyFont)
                    }
                    .foregroundColor(DesignConstants.textColor)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Capsule())
                }
                Spacer()
            }
            .padding(.horizontal, DesignConstants.largeSpacing)
            .padding(.top, 44)
                // Header
                VStack(spacing: DesignConstants.mediumSpacing) {
                    Text("Create Account")
                        .font(DesignConstants.titleFont)
                        .fontWeight(.bold)
                        .foregroundColor(DesignConstants.textColor)
                    
                    Text("Start your journey to better habits")
                        .font(DesignConstants.bodyFont)
                        .foregroundColor(DesignConstants.textColor.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                // Form
                VStack(spacing: DesignConstants.largeSpacing) {
                    VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                        Text("Email")
                            .font(DesignConstants.bodyFont)
                            .fontWeight(.medium)
                            .foregroundColor(DesignConstants.textColor)
                        
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(CustomTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                        Text("Password")
                            .font(DesignConstants.bodyFont)
                            .fontWeight(.medium)
                            .foregroundColor(DesignConstants.textColor)
                        
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(CustomTextFieldStyle())
                            .textContentType(.password)
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.never)
                    }
                    VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                        Text("Confirm Password")
                            .font(DesignConstants.bodyFont)
                            .fontWeight(.medium)
                            .foregroundColor(DesignConstants.textColor)
                        
                        SecureField("Confirm your password", text: $confirmPassword)
                            .textFieldStyle(CustomTextFieldStyle())
                            .textContentType(.password)
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.never)
                    }
                }
                // Sign Up button
                Button(action: signUp) {
                    Text("Create Account")
                        .font(DesignConstants.buttonFont)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: DesignConstants.buttonHeight)
                        .background(canSignUp ? DesignConstants.primaryColor : DesignConstants.primaryColor.opacity(0.5))
                        .cornerRadius(DesignConstants.mediumCornerRadius)
                }
                .disabled(!canSignUp)
                // Login link
                HStack {
                    Text("Already have an account?")
                        .font(DesignConstants.bodyFont)
                        .foregroundColor(DesignConstants.textColor.opacity(0.7))
                    Button("Sign In") {
                        appState.navigateTo(.login)
                    }
                    .font(DesignConstants.bodyFont)
                    .foregroundColor(DesignConstants.primaryColor)
                }
                // Google Sign-In Button (UI only)
                Button(action: handleGoogleSignIn) {
                    HStack {
                        Image(systemName: "globe")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("Continue with Google")
                            .font(DesignConstants.buttonFont)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: DesignConstants.buttonHeight)
                    .background(Color(red: 0.22, green: 0.47, blue: 0.97))
                    .cornerRadius(DesignConstants.mediumCornerRadius)
                }
                .padding(.vertical, DesignConstants.smallSpacing)
                Spacer()
            }
            .padding(.horizontal, DesignConstants.largeSpacing)
            .background(DesignConstants.backgroundColor)
        .edgesIgnoringSafeArea(.top)
            .alert("Sign Up Error", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
        }
    }
    
    private var canSignUp: Bool {
        !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && password == confirmPassword
    }
    
    private func signUp() {
        // Validate email format
        guard email.contains("@") && email.contains(".") else {
            alertMessage = "Please enter a valid email address"
            showAlert = true
            return
        }
        
        // Validate password length
        guard password.count >= 6 else {
            alertMessage = "Password must be at least 6 characters long"
            showAlert = true
            return
        }
        
        // Create user profile
        _ = coreDataManager.createUserProfile(email: email, name: name)
        
        // Authenticate and navigate to main app
        appState.authenticate()
    }
    
    private func handleGoogleSignIn() {
        // TODO: Integrate Google Sign-In SDK
        // For now, simulate successful login
        appState.authenticate()
    }
}

struct LoginView: View {
    @StateObject private var appState = AppStateManager.shared
    @StateObject private var coreDataManager = CoreDataManager.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
            VStack(spacing: DesignConstants.extraLargeSpacing) {
            // Back dugme gore levo
            HStack {
                Button(action: {
                    appState.navigateTo(.splash)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                        Text("Back")
                            .font(DesignConstants.bodyFont)
                    }
                    .foregroundColor(DesignConstants.textColor)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Capsule())
                }
                Spacer()
            }
            .padding(.horizontal, DesignConstants.largeSpacing)
            .padding(.top, 44)
                // Header
                VStack(spacing: DesignConstants.mediumSpacing) {
                    Text("Welcome Back")
                        .font(DesignConstants.titleFont)
                        .fontWeight(.bold)
                        .foregroundColor(DesignConstants.textColor)
                    
                    Text("Continue your habit journey")
                        .font(DesignConstants.bodyFont)
                        .foregroundColor(DesignConstants.textColor.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                // Form
                VStack(spacing: DesignConstants.largeSpacing) {
                    VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                        Text("Email")
                            .font(DesignConstants.bodyFont)
                            .fontWeight(.medium)
                            .foregroundColor(DesignConstants.textColor)
                        
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(CustomTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                        Text("Password")
                            .font(DesignConstants.bodyFont)
                            .fontWeight(.medium)
                            .foregroundColor(DesignConstants.textColor)
                        
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(CustomTextFieldStyle())
                            .textContentType(.password)
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.never)
                    }
                }
                // Login button
                Button(action: login) {
                    Text("Sign In")
                        .font(DesignConstants.buttonFont)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: DesignConstants.buttonHeight)
                        .background(canLogin ? DesignConstants.primaryColor : DesignConstants.primaryColor.opacity(0.5))
                        .cornerRadius(DesignConstants.mediumCornerRadius)
                }
                .disabled(!canLogin)
                // Sign Up link
                HStack {
                    Text("Don't have an account?")
                        .font(DesignConstants.bodyFont)
                        .foregroundColor(DesignConstants.textColor.opacity(0.7))
                    Button("Sign Up") {
                        appState.navigateTo(.signUp)
                    }
                    .font(DesignConstants.bodyFont)
                    .foregroundColor(DesignConstants.primaryColor)
                }
                // Google Sign-In Button (UI only)
                Button(action: handleGoogleSignIn) {
                    HStack {
                        Image(systemName: "globe")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("Continue with Google")
                            .font(DesignConstants.buttonFont)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: DesignConstants.buttonHeight)
                    .background(Color(red: 0.22, green: 0.47, blue: 0.97))
                    .cornerRadius(DesignConstants.mediumCornerRadius)
                }
                .padding(.vertical, DesignConstants.smallSpacing)
                Spacer()
            }
            .padding(.horizontal, DesignConstants.largeSpacing)
            .background(DesignConstants.backgroundColor)
        .edgesIgnoringSafeArea(.top)
            .alert("Login Error", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
        }
    }
    
    private var canLogin: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    private func login() {
        // Validate email format
        guard email.contains("@") && email.contains(".") else {
            alertMessage = "Please enter a valid email address"
            showAlert = true
            return
        }
        
        // Simulate login process
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // In a real app, you would handle authentication here
            appState.authenticate()
        }
    }
    
    private func handleGoogleSignIn() {
        // TODO: Integrate Google Sign-In SDK
        // For now, simulate successful login
        appState.authenticate()
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(DesignConstants.mediumSpacing)
            .background(Color.white)
            .cornerRadius(DesignConstants.mediumCornerRadius)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    SignUpView()
} 
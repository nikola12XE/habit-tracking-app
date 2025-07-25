import SwiftUI

// 1. LOGIN VIEW
struct LoginView: View {
    @StateObject private var appState = AppStateManager.shared
    @State private var email = ""
    @State private var password = ""
    @State private var showForgotPassword = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.93, green: 0.93, blue: 0.93).ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer().frame(height: 90)
                // Back arrow and title in a row
                HStack(alignment: .center, spacing: 24) {
                    Button(action: { appState.navigateTo(.splash) }) {
                        Image("back_arrow") // Asset: back_arrow
                            .resizable()
                            .frame(width: 32, height: 32)
                    }
                    Text("LOG IN")
                        .font(Font.custom("Thunder-BoldLC", size: 82))
                        .foregroundColor(.black)
                        .frame(height: 62, alignment: .bottom)
                    Spacer()
                }
                .padding(.leading, 24)
                .frame(height: 62)
                Spacer().frame(height: 42)
                // Form fields
                VStack(alignment: .leading, spacing: 18) {
                    CustomInputField(label: "Email", text: $email, placeholder: "Enter your email")
                    CustomInputField(label: "Password", text: $password, placeholder: "Enter your password", isSecure: true)
                    // Forgot Password
                    HStack {
                        Spacer()
                        Button("Forgot Password?") { showForgotPassword = true }
                            .font(Font.custom("Inter-Regular", size: 16))
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal, 24)
                Spacer().frame(height: 42)
                // Google button
                HStack {
                    Spacer()
                    Button(action: { /* Google sign in */ }) {
                        HStack(spacing: 10) {
                            Image("google_logo") // Asset: google_logo
                                .resizable()
                                .frame(width: 26, height: 26)
                            Text("Continue with Google")
                                .font(Font.custom("Inter-SemiBold", size: 14))
                                .kerning(-0.28) // -2% letter spacing
                                .foregroundColor(.black)
                        }
                        .frame(width: 270, height: 62)
                        .background(Color.white)
                        .cornerRadius(100)
                        .overlay(RoundedRectangle(cornerRadius: 100).stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1))
                    }
                    Spacer()
                }
                .padding(.top, 0)
                // Already have account
                HStack(spacing: 6) {
                    Spacer()
                    Text("Already have Account?")
                        .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                        .font(Font.custom("Inter-Regular", size: 16))
                    Button("Sign Up") { appState.navigateTo(.signUp) }
                        .font(Font.custom("Inter-Medium", size: 16))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.top, 20)
                Spacer()
            }
            // Log In button at the bottom
            HStack {
                Spacer()
                Button(action: { /* Log in logic */ }) {
                    Text("Log In")
                        .font(Font.custom("Inter-SemiBold", size: 20))
                        .foregroundColor(.white)
                        .frame(width: 200, height: 62)
                        .background(Color.black)
                        .cornerRadius(100)
                }
                Spacer()
            }
            .padding(.bottom, 32)
        }
        .fullScreenCover(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
    }
}

// 2. SIGN UP VIEW
struct SignUpView: View {
    @StateObject private var appState = AppStateManager.shared
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.93, green: 0.93, blue: 0.93).ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer().frame(height: 90)
                // Back arrow and title in a row
                HStack(alignment: .center, spacing: 24) {
                    Button(action: { appState.navigateTo(.splash) }) {
                        Image("back_arrow")
                            .resizable()
                            .frame(width: 32, height: 32)
                    }
                    Text("SIGN UP")
                        .font(Font.custom("Thunder-BoldLC", size: 82))
                        .foregroundColor(.black)
                        .frame(height: 62, alignment: .bottom)
                    Spacer()
                }
                .padding(.leading, 24)
                .frame(height: 62)
                Spacer().frame(height: 42)
                // Form fields
                VStack(alignment: .leading, spacing: 18) {
                    CustomInputField(label: "First Name", text: $firstName, placeholder: "Enter your first name")
                    CustomInputField(label: "Last Name", text: $lastName, placeholder: "Enter your last name")
                    CustomInputField(label: "Email", text: $email, placeholder: "Enter your email")
                    CustomInputField(label: "Password", text: $password, placeholder: "Enter your password", isSecure: true)
                }
                .padding(.horizontal, 24)
                Spacer().frame(height: 42)
                // Google button
                HStack {
                    Spacer()
                    Button(action: { /* Google sign up */ }) {
                        HStack(spacing: 10) {
                            Image("google_logo")
                                .resizable()
                                .frame(width: 26, height: 26)
                            Text("Continue with Google")
                                .font(Font.custom("Inter-SemiBold", size: 14))
                                .kerning(-0.28) // -2% letter spacing
                                .foregroundColor(.black)
                        }
                        .frame(width: 270, height: 62)
                        .background(Color.white)
                        .cornerRadius(100)
                        .overlay(RoundedRectangle(cornerRadius: 100).stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1))
                    }
                    Spacer()
                }
                .padding(.top, 0)
                // Don’t have account
                HStack(spacing: 6) {
                    Spacer()
                    Text("Don’t have Account?")
                        .foregroundColor(Color(hex: "8F8F8F"))
                        .font(Font.custom("Inter-Regular", size: 16))
                    Button("Log In") { appState.navigateTo(.login) }
                        .font(Font.custom("Inter-Medium", size: 16))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.top, 20)
                Spacer()
            }
            // Sign Up button at the bottom
            HStack {
                Spacer()
                Button(action: { /* Sign up logic */ }) {
                    Text("Sign Up")
                        .font(Font.custom("Inter-SemiBold", size: 20))
                        .foregroundColor(.white)
                        .frame(width: 200, height: 62)
                        .background(Color.black)
                        .cornerRadius(100)
                }
                Spacer()
            }
            .padding(.bottom, 32)
        }
    }
}

// Custom input field for consistent style
struct CustomInputField: View {
    var label: String
    @Binding var text: String
    var placeholder: String
    var isSecure: Bool = false
    @State private var isEditing: Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(Font.custom("Inter-Regular", size: 12))
                .foregroundColor(Color(hex: "8F8F8F"))
                .kerning(-0.24) // -2% letter spacing
            if isSecure {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "E4E4E4"))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "767676").opacity(0.3), lineWidth: 1))
                        .frame(height: 48)
                    if text.isEmpty {
                        Text(placeholder)
                            .padding(.horizontal, 16)
                            .font(Font.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(Color(hex: "8F8F8F"))
                    }
                    SecureField("", text: $text)
                        .padding(.horizontal, 16)
                        .font(Font.custom("Inter-SemiBold", size: 16))
                        .foregroundColor(Color(hex: "8F8F8F"))
                }
            } else {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "E4E4E4"))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "767676").opacity(0.3), lineWidth: 1))
                        .frame(height: 48)
                    if text.isEmpty {
                        Text(placeholder)
                            .padding(.horizontal, 16)
                            .font(Font.custom("Inter-SemiBold", size: 16))
                            .foregroundColor(Color(hex: "8F8F8F"))
                    }
                    TextField("", text: $text)
                        .padding(.horizontal, 16)
                        .font(Font.custom("Inter-SemiBold", size: 16))
                        .foregroundColor(Color(hex: "8F8F8F"))
                }
            }
        }
    }
}

// 3. FORGOT PASSWORD VIEW
struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var showReset = false
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.93, green: 0.93, blue: 0.93).ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer().frame(height: 90)
                HStack(alignment: .center, spacing: 24) {
                    Button(action: { dismiss() }) {
                        Image("back_arrow")
                            .resizable()
                            .frame(width: 32, height: 32)
                    }
                    Text("FORGOT PASSWORD")
                        .font(Font.custom("Thunder-BoldLC", size: 82))
                        .foregroundColor(.black)
                        .frame(height: 62, alignment: .bottom)
                    Spacer()
                }
                .padding(.leading, 24)
                .frame(height: 62)
                Spacer().frame(height: 42)
                HStack {
                    Text("Enter your email and we will send you email with verification link")
                        .font(Font.custom("Inter-Regular", size: 16))
                        .foregroundColor(Color(hex: "8F8F8F"))
                        .padding(.leading, 24)
                        .lineLimit(2)
                    Spacer()
                }
                Spacer().frame(height: 32)
                VStack(alignment: .leading, spacing: 18) {
                    CustomInputField(label: "Email", text: $email, placeholder: "Enter your email")
                }
                .padding(.horizontal, 24)
                Spacer().frame(height: 42)
                HStack {
                    Text("Didn’t get a code?")
                        .foregroundColor(Color(hex: "8F8F8F"))
                        .font(Font.custom("Inter-Regular", size: 16))
                    Button("Resend") { /* resend logic */ }
                        .font(Font.custom("Inter-Medium", size: 16))
                        .foregroundColor(.black)
                }
                .padding(.top, 16)
                .padding(.bottom, 32)
                Spacer()
            }
            Button(action: { showReset = true }) {
                Text("Continue")
                    .font(Font.custom("Inter-SemiBold", size: 20))
                    .foregroundColor(.white)
                    .frame(width: 200, height: 62)
                    .background(Color.black)
                    .cornerRadius(100)
            }
            .padding(.bottom, 32)
        }
        .fullScreenCover(isPresented: $showReset) {
            ResetPasswordView()
        }
    }
}

// 4. RESET PASSWORD VIEW
struct ResetPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.93, green: 0.93, blue: 0.93).ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer().frame(height: 90)
                HStack(alignment: .center, spacing: 24) {
                    Button(action: { dismiss() }) {
                        Image("back_arrow")
                            .resizable()
                            .frame(width: 32, height: 32)
                    }
                    Text("RESET PASSWORD")
                        .font(Font.custom("Thunder-BoldLC", size: 82))
                        .foregroundColor(.black)
                        .frame(height: 62, alignment: .bottom)
                    Spacer()
                }
                .padding(.leading, 24)
                .frame(height: 62)
                Spacer().frame(height: 42)
                HStack {
                    Text("Enter your new password")
                        .font(Font.custom("Inter-Regular", size: 16))
                        .foregroundColor(Color(hex: "8F8F8F"))
                        .padding(.leading, 24)
                    Spacer()
                }
                Spacer().frame(height: 32)
                VStack(alignment: .leading, spacing: 18) {
                    CustomInputField(label: "New Password", text: $newPassword, placeholder: "Enter new password", isSecure: true)
                    CustomInputField(label: "Confirm Password", text: $confirmPassword, placeholder: "Confirm password", isSecure: true)
                }
                .padding(.horizontal, 24)
                Spacer()
            }
            Button(action: { /* Reset logic */ }) {
                Text("Continue")
                    .font(Font.custom("Inter-SemiBold", size: 20))
                    .foregroundColor(.white)
                    .frame(width: 200, height: 62)
                    .background(Color.black)
                    .cornerRadius(100)
            }
            .padding(.bottom, 32)
        }
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
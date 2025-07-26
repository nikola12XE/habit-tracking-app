import SwiftUI

// 1. LOGIN VIEW
struct LoginView: View {
    @StateObject private var appState = AppStateManager.shared
    @State private var email = ""
    @State private var password = ""
    @State private var showForgotPassword = false
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.93, green: 0.93, blue: 0.93).ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer().frame(height: 90)
                // Back arrow and title in a row
                HStack(alignment: .firstTextBaseline, spacing: 24) {
                    Button(action: { appState.navigateTo(.splash) }) {
                        Image("back_arrow") // Asset: back_arrow
                            .resizable()
                            .frame(width: 32, height: 32)
                            .alignmentGuide(.firstTextBaseline) { d in d[.bottom] + 12 }
                    }
                    Text("LOG IN")
                        .font(Font.custom("Thunder-BoldLC", size: 82))
                        .foregroundColor(.black)
                        .alignmentGuide(.firstTextBaseline) { d in d[.firstTextBaseline] }
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
                            .font(.system(size: 15, weight: .medium))
                            .kerning(-0.3)
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
                                .font(.system(size: 15, weight: .semibold))
                                .kerning(-0.6) // -4% letter spacing
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
                        .font(.system(size: 15, weight: .medium))
                        .kerning(-0.3)
                        .foregroundColor(Color(hex: "8F8F8F"))
                    Button("Sign Up") { appState.navigateTo(.signUp) }
                        .font(.system(size: 15, weight: .medium))
                        .kerning(-0.3)
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
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 200, height: 62)
                        .background(Color.black)
                        .cornerRadius(100)
                }
                Spacer()
            }
            .padding(.bottom, keyboardHeight > 0 ? keyboardHeight + 24 : 32)
            .animation(.easeInOut(duration: 0.3), value: keyboardHeight)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
        .ignoresSafeArea(.keyboard)
        .onTapGesture {
            UIApplication.shared.endEditing()
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
    @State private var keyboardHeight: CGFloat = 0
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.93, green: 0.93, blue: 0.93).ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer().frame(height: 90)
                // Back arrow and title in a row
                HStack(alignment: .firstTextBaseline, spacing: 24) {
                    Button(action: { appState.navigateTo(.splash) }) {
                        Image("back_arrow")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .alignmentGuide(.firstTextBaseline) { d in d[.bottom] + 12 }
                    }
                    Text("SIGN UP")
                        .font(Font.custom("Thunder-BoldLC", size: 82))
                        .foregroundColor(.black)
                        .alignmentGuide(.firstTextBaseline) { d in d[.firstTextBaseline] }
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
                                .font(.system(size: 15, weight: .semibold))
                                .kerning(-0.6) // -4% letter spacing
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
                // Don't have account
                HStack(spacing: 6) {
                    Spacer()
                    Text("Don't have Account?")
                        .font(.system(size: 15, weight: .medium))
                        .kerning(-0.3)
                        .foregroundColor(Color(hex: "8F8F8F"))
                    Button("Log In") { appState.navigateTo(.login) }
                        .font(.system(size: 15, weight: .medium))
                        .kerning(-0.3)
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
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 200, height: 62)
                        .background(Color.black)
                        .cornerRadius(100)
                }
                Spacer()
            }
            .padding(.bottom, keyboardHeight > 0 ? keyboardHeight + 24 : 32)
            .animation(.easeInOut(duration: 0.3), value: keyboardHeight)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
        .ignoresSafeArea(.keyboard)
        .onTapGesture {
            UIApplication.shared.endEditing()
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
                        .frame(height: 42)
                    if text.isEmpty {
                        Text(placeholder)
                            .padding(.horizontal, 16)
                            .font(Font.custom("Inter-SemiBold", size: 15))
                            .foregroundColor(Color(hex: "8F8F8F"))
                    }
                    SecureField("", text: $text)
                        .padding(.horizontal, 16)
                        .font(Font.custom("Inter-SemiBold", size: 15))
                        .foregroundColor(Color(hex: "0C0C0C"))
                }
            } else {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "E4E4E4"))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "767676").opacity(0.3), lineWidth: 1))
                        .frame(height: 42)
                    if text.isEmpty {
                        Text(placeholder)
                            .padding(.horizontal, 16)
                            .font(Font.custom("Inter-SemiBold", size: 15))
                            .foregroundColor(Color(hex: "8F8F8F"))
                    }
                    TextField("", text: $text)
                        .padding(.horizontal, 16)
                        .font(Font.custom("Inter-SemiBold", size: 15))
                        .foregroundColor(Color(hex: "0C0C0C"))
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
    @State private var keyboardHeight: CGFloat = 0
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.93, green: 0.93, blue: 0.93).ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer().frame(height: 90)
                HStack(alignment: .firstTextBaseline, spacing: 24) {
                    Button(action: { dismiss() }) {
                        Image("back_arrow")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .alignmentGuide(.firstTextBaseline) { d in d[.bottom] + 12 }
                    }
                    HStack {
                        Text("FORGOT\nPASSWORD")
                            .font(Font.custom("Thunder-BoldLC", size: 82))
                            .foregroundColor(.black)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .alignmentGuide(.firstTextBaseline) { d in d[.firstTextBaseline] }
                        Spacer()
                    }
                }
                .padding(.leading, 24)
                .frame(height: 120)
                Spacer().frame(height: 24)
                HStack {
                    Text("Enter your email and we will send\nyou email with verification link")
                        .font(Font.custom("Inter-Regular", size: 16))
                        .foregroundColor(Color(hex: "8F8F8F"))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.leading, 80)
                Spacer().frame(height: 32)
                VStack(alignment: .leading, spacing: 18) {
                    CustomInputField(label: "Email", text: $email, placeholder: "Enter your email")
                }
                .padding(.horizontal, 24)
                Spacer().frame(height: 20)
                HStack(spacing: 6) {
                    Spacer()
                    Text("Didn't get a code?")
                        .font(.system(size: 15, weight: .medium))
                        .kerning(-0.3)
                        .foregroundColor(Color(hex: "8F8F8F"))
                    Button("Resend") { /* resend logic */ }
                        .font(.system(size: 15, weight: .medium))
                        .kerning(-0.3)
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.bottom, 32)
                Spacer()
            }
            Button(action: { showReset = true }) {
                Text("Continue")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 200, height: 62)
                    .background(Color.black)
                    .cornerRadius(100)
            }
            .padding(.bottom, keyboardHeight > 0 ? keyboardHeight + 24 : 32)
            .animation(.easeInOut(duration: 0.3), value: keyboardHeight)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
        .ignoresSafeArea(.keyboard)
        .onTapGesture {
            UIApplication.shared.endEditing()
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
    @State private var keyboardHeight: CGFloat = 0
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.93, green: 0.93, blue: 0.93).ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer().frame(height: 90)
                HStack(alignment: .firstTextBaseline, spacing: 24) {
                    Button(action: { dismiss() }) {
                        Image("back_arrow")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .alignmentGuide(.firstTextBaseline) { d in d[.bottom] + 12 }
                    }
                    HStack {
                        Text("RESET\nPASSWORD")
                            .font(Font.custom("Thunder-BoldLC", size: 82))
                            .foregroundColor(.black)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .alignmentGuide(.firstTextBaseline) { d in d[.firstTextBaseline] }
                        Spacer()
                    }
                }
                .padding(.leading, 24)
                .frame(height: 120)
                Spacer().frame(height: 20)
                HStack {
                    Text("Enter your new password")
                        .font(Font.custom("Inter-Regular", size: 16))
                        .foregroundColor(Color(hex: "8F8F8F"))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.leading, 80)
                Spacer().frame(height: 32)
                VStack(alignment: .leading, spacing: 18) {
                    CustomInputField(label: "New Password", text: $newPassword, placeholder: "Enter your new password", isSecure: true)
                    CustomInputField(label: "Confirm Password", text: $confirmPassword, placeholder: "Confirm your password", isSecure: true)
                }
                .padding(.horizontal, 24)
                Spacer()
            }
            Button(action: { /* Reset password logic */ }) {
                Text("Reset Password")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 200, height: 62)
                    .background(Color.black)
                    .cornerRadius(100)
            }
            .padding(.bottom, keyboardHeight > 0 ? keyboardHeight + 24 : 32)
            .animation(.easeInOut(duration: 0.3), value: keyboardHeight)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
        .ignoresSafeArea(.keyboard)
        .onTapGesture {
            UIApplication.shared.endEditing()
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

// Extension to hide keyboard
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    SignUpView()
} 
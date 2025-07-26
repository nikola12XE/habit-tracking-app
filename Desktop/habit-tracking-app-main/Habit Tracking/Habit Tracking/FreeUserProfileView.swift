import SwiftUI
import UIKit

struct FreeUserProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var coreDataManager = CoreDataManager.shared
    @State private var sheetDragOffset: CGFloat = 0
    @State private var milestoneCount = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Pull-down indicator (draggable handle)
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color(red: 0.8, green: 0.8, blue: 0.8))
                    .frame(width: 36, height: 5)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                
                // Invisible extended touch area for easier dragging
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 20)
            }
            .gesture(
                // Drag gesture only on handle area to dismiss sheet
                DragGesture()
                    .onChanged { value in
                        if value.translation.height > 0 {
                            // Allow downward drag and move sheet with finger
                            sheetDragOffset = value.translation.height
                        } else {
                            // Block upward drag to prevent sheet expansion
                            sheetDragOffset = 0
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            if value.translation.height > 150 {
                                // Dismiss sheet if dragged down far enough
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                // Snap back to original position
                                sheetDragOffset = 0
                            }
                        }
                    }
            )
            
            // Profile header with close button only (no edit button for non-logged users)
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    
                    // Close button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.9, green: 0.9, blue: 0.9))
                                .frame(width: 38, height: 38)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
            
            // "Your Free plan is expiring in 4 days" message
            Text("Your Free plan is expiring in 4 days")
                .font(.system(size: 16, weight: .regular, design: .default))
                .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            
            // Scrollable content
            ScrollView {
                VStack(spacing: 28) {
                    // Upgrade to Premium section
                    upgradeToPremiumSection
                    
                    // Account Details section
                    accountDetailsSection
                    
                    // Notifications section
                    notificationsSection
                    
                    // Links section
                    linksSection
                }
                .padding(.horizontal, 24)
            }
            
            // Sign Up / Log In buttons
            signUpLogInButtons
        }
        .background(Color(hex: "EDEDED"))
        .clipShape(RoundedCorner(radius: 40, corners: [.topLeft, .topRight]))
        .ignoresSafeArea()
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(.clear)
        .offset(y: sheetDragOffset)
    }
    
    // MARK: - Section Views
    
    private var upgradeToPremiumSection: some View {
        VStack(spacing: 18) {
            // Black container with upgrade info
            VStack(spacing: 18) {
                // Top row with "Upgrade to Premium" and "$2.99"
                HStack {
                    HStack(spacing: 4) {
                        Text("Upgrade to")
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .foregroundColor(.white)
                        
                        Text("Premium")
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "FF9A1E"), Color(hex: "FEC22B")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    
                    Spacer()
                    
                    Text("$2.99")
                        .font(.system(size: 13, weight: .medium, design: .default))
                        .foregroundColor(.white)
                }
                
                // Bottom row with current plan
                HStack {
                    Text("Your Current Plan")
                        .font(.system(size: 17, weight: .medium, design: .default))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text("Free")
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black)
                            .cornerRadius(40)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(Color(hex: "EDEDED"))
                .cornerRadius(8)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 16)
            .background(Color(hex: "0C0C0C"))
            .cornerRadius(12)
        }
    }
    
    private var accountDetailsSection: some View {
        VStack(spacing: 12) {
            Text("Account Details")
                .font(.system(size: 13, weight: .regular, design: .default))
                .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                // Edit Goal
                Button(action: {
                    // Action for Edit Goal
                }) {
                    HStack {
                        Text("Edit Goal")
                            .font(.system(size: 15, weight: .semibold, design: .default))
                            .foregroundColor(Color(hex: "0C0C0C"))
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Text("Grow Portfolio")
                                .font(.system(size: 15, weight: .regular, design: .default))
                                .foregroundColor(Color(hex: "0C0C0C"))
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 15)
                }
                .background(Color(hex: "E5E5E5"))
                .overlay(
                    Rectangle()
                        .stroke(Color(hex: "D9D9D9"), lineWidth: 1)
                )
                
                // See Milestones
                Button(action: {
                    // Action for See Milestones
                }) {
                    HStack {
                        Text("See Milestones")
                            .font(.system(size: 15, weight: .semibold, design: .default))
                            .foregroundColor(Color(hex: "0C0C0C"))
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Text("\(milestoneCount)")
                                .font(.system(size: 15, weight: .regular, design: .default))
                                .foregroundColor(Color(hex: "0C0C0C"))
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 15)
                }
                .background(Color(hex: "E5E5E5"))
                .overlay(
                    Rectangle()
                        .stroke(Color(hex: "D9D9D9"), lineWidth: 1)
                )
            }
        }
    }
    
    private var notificationsSection: some View {
        VStack(spacing: 12) {
            Text("Notifications")
                .font(.system(size: 13, weight: .regular, design: .default))
                .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                // Play Sound
                HStack {
                    Text("Play Sound")
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(Color(hex: "0C0C0C"))
                    
                    Spacer()
                    
                    // Toggle switch
                    Toggle("", isOn: .constant(true))
                        .labelsHidden()
                        .scaleEffect(0.8)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 15)
                .background(Color(hex: "E5E5E5"))
                .overlay(
                    Rectangle()
                        .stroke(Color(hex: "D9D9D9"), lineWidth: 1)
                )
                
                // Second reminder
                HStack {
                    Text("Second reminder")
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(Color(hex: "0C0C0C"))
                    
                    Spacer()
                    
                    // Toggle switch
                    Toggle("", isOn: .constant(true))
                        .labelsHidden()
                        .scaleEffect(0.8)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 15)
                .background(Color(hex: "E5E5E5"))
                .overlay(
                    Rectangle()
                        .stroke(Color(hex: "D9D9D9"), lineWidth: 1)
                )
                
                // Reminder Time
                HStack {
                    Text("Reminder Time")
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(Color(hex: "0C0C0C"))
                    
                    Spacer()
                    
                    Text("10:30 AM")
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(Color(hex: "0C0C0C"))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 15)
                .background(Color(hex: "E5E5E5"))
                .overlay(
                    Rectangle()
                        .stroke(Color(hex: "D9D9D9"), lineWidth: 1)
                )
            }
        }
    }
    
    private var linksSection: some View {
        VStack(spacing: 0) {
            // F&Q
            Button(action: {
                // Action for F&Q
            }) {
                HStack {
                    Text("F&Q")
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(Color(hex: "0C0C0C"))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 15)
            }
            
            // Privacy Policy
            Button(action: {
                // Action for Privacy Policy
            }) {
                HStack {
                    Text("Privacy Policy")
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(Color(hex: "0C0C0C"))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 15)
            }
            
            // Terms and Conditions
            Button(action: {
                // Action for Terms and Conditions
            }) {
                HStack {
                    Text("Terms and Conditions")
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(Color(hex: "0C0C0C"))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 15)
            }
            
            // Help and Support
            Button(action: {
                // Action for Help and Support
            }) {
                HStack {
                    Text("Help and Support")
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(Color(hex: "0C0C0C"))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 15)
            }
        }
    }
    
    private var signUpLogInButtons: some View {
        HStack(spacing: 10) {
            // Sign Up button
            Button(action: {
                // Navigate to sign up
            }) {
                Text("Sign Up")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                    .frame(width: 183, height: 62)
                    .background(Color(hex: "E4E4E4"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 100)
                            .stroke(Color(hex: "D9D9D9"), lineWidth: 1)
                    )
                    .cornerRadius(100)
            }
            
            // Log In button
            Button(action: {
                // Navigate to log in
            }) {
                Text("Log In")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 183, height: 62)
                    .background(Color.black)
                    .cornerRadius(100)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.bottom, 32)
        .onAppear {
            loadMilestoneCount()
        }
    }
    
    private func loadMilestoneCount() {
        let existingGoals = coreDataManager.fetchGoals()
        guard let goal = existingGoals.first else { 
            milestoneCount = 0
            return 
        }
        
        let progressDays = coreDataManager.fetchProgressDays(for: goal)
        milestoneCount = progressDays.filter { 
            let hasText = $0.milestoneText != nil && !($0.milestoneText?.isEmpty ?? true)
            let hasPhoto = $0.milestonePhoto != nil
            return hasText || hasPhoto
        }.count
    }
}



#Preview {
    FreeUserProfileView()
} 
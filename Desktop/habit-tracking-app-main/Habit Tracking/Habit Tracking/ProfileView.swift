import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var appState = AppStateManager.shared
    @StateObject private var coreDataManager = CoreDataManager.shared
    @State private var userProfile: UserProfile?
    @State private var showImagePicker = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false
    @State private var showGoalEdit = false
    @State private var showMilestones = false
    @State private var showPremium = false
    @State private var showFAQ = false
    @State private var showPrivacy = false
    @State private var showTerms = false
    @State private var showHelp = false
    @State private var showSecondReminder = false
    @State private var showReminderTime = false
    @State private var showPlaySound = false
    
        var body: some View {
        VStack(spacing: 0) {
            // Pull-down indicator
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color(red: 0.8, green: 0.8, blue: 0.8))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
            
            // Profile header with avatar and edit button
            HStack {
                // Avatar
                Image("person.fill")
                    .resizable()
                    .frame(width: 52, height: 52)
                    .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                .allowsHitTesting(false)
                
                // Edit button
                ZStack {
                    Circle()
                        .fill(Color(hex: "E5E5E5"))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "C9C9C9"), lineWidth: 1)
                        )
                    
                    Image("pencil")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                }
                .allowsHitTesting(false)
                
                Spacer()
                
                // Close button
                Button(action: {
                    appState.navigateTo(.main)
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
            
            // Name
            Text("Nina Skrbic")
                .font(.system(size: 24, weight: .semibold, design: .default))
                .tracking(-0.96) // -4% letter spacing (24 * 0.04 = 0.96)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, -2)
            
            // Scrollable content
            ScrollView {
                VStack(spacing: 32) {
                    // Account Details section
                    accountDetailsSection
                    
                    // Notifications section
                    notificationsSection
                    
                    // Links section
                    linksSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
            }
            
            // Log Out button at bottom
            logOutButton
        }
        .background(Color(hex: "EDEDED"))
        .clipShape(RoundedCorner(radius: 40, corners: [.topLeft, .topRight]))
        .ignoresSafeArea()
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(.clear)
        .onAppear {
            loadUserProfile()
        }
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    userProfile?.avatar = data
                    coreDataManager.updateUserProfile(userProfile!)
                }
            }
        }
        .fullScreenCover(isPresented: $showGoalEdit) {
            GoalEntryFlowView()
        }
        .sheet(isPresented: $showMilestones) {
            MilestonesView()
        }
        .sheet(isPresented: $showPremium) {
            PremiumView()
        }
        .sheet(isPresented: $showFAQ) {
            FAQView()
        }
        .sheet(isPresented: $showPrivacy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showTerms) {
            TermsConditionsView()
        }
        .sheet(isPresented: $showHelp) {
            HelpSupportView()
        }
        .sheet(isPresented: $showSecondReminder) {
            SecondReminderView()
        }
        .sheet(isPresented: $showReminderTime) {
            ReminderTimeView()
        }
        .sheet(isPresented: $showPlaySound) {
            PlaySoundView()
        }
    }
    
    private var accountDetailsSection: some View {
        VStack(spacing: 12) {
            // Section title
            Text("Account Details")
                .font(.custom("Inter_24pt-SemiBold", size: 13))
                .tracking(-0.26) // -2% letter spacing
                .foregroundColor(Color(hex: "8F8F8F"))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Settings items
            VStack(spacing: 0) {
                // Edit Goal
                Button(action: {
                    showGoalEdit = true
                }) {
                    HStack {
                        Text("Edit Goal")
                            .font(.custom("Inter_24pt-SemiBold", size: 15))
                            .fontWeight(.semibold)
                            .tracking(-0.3) // -2% letter spacing
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Text("Grow Portfolio")
                                .font(.custom("Inter_24pt-SemiBold", size: 15))
                                .tracking(-0.3) // -2% letter spacing
                                .foregroundColor(.black)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                        }
                    }
                    .frame(height: 48)
                    .padding(.horizontal, 18)
                    .background(Color(hex: "E5E5E5"))
                    .clipShape(RoundedCorner(radius: 8, corners: [.topLeft, .topRight]))
                    .overlay(
                        RoundedCorner(radius: 8, corners: [.topLeft, .topRight])
                            .stroke(Color(hex: "D9D9D9"), lineWidth: 1)
                    )
                }
                
                // See Milestones
                Button(action: {
                    showMilestones = true
                }) {
                    HStack {
                        Text("See Milestones")
                            .font(.custom("Inter_24pt-SemiBold", size: 15))
                            .fontWeight(.semibold)
                            .tracking(-0.3) // -2% letter spacing
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Text("5")
                                .font(.custom("Inter_24pt-SemiBold", size: 15))
                                .tracking(-0.3) // -2% letter spacing
                                .foregroundColor(.black)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                        }
                    }
                    .frame(height: 48)
                    .padding(.horizontal, 18)
                    .background(Color(hex: "E5E5E5"))
                    .cornerRadius(0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(Color(hex: "D9D9D9"), lineWidth: 1)
                    )
                }
                
                // Your Plan (Premium) with orange background and plus pattern
                Button(action: {
                    showPremium = true
                }) {
                    HStack {
                        Text("Your Plan")
                            .font(.custom("Inter_24pt-Bold", size: 15))
                            .fontWeight(.bold)
                            .tracking(-0.3) // -2% letter spacing
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Text("Premium")
                                .font(.custom("Inter_24pt-Bold", size: 15))
                                .tracking(-0.3) // -2% letter spacing
                                .foregroundColor(.white)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(height: 48)
                    .padding(.horizontal, 18)
                    .background(
                        ZStack {
                            Color(red: 1.0, green: 0.6, blue: 0.0)
                            
                            // Plus pattern overlay
                            HStack(spacing: 8) {
                                ForEach(0..<20, id: \.self) { _ in
                                    Image(systemName: "plus")
                                        .font(.system(size: 8))
                                        .foregroundColor(.white.opacity(0.3))
                                }
                            }
                        }
                    )
                    .clipShape(RoundedCorner(radius: 8, corners: [.bottomLeft, .bottomRight]))
                }
            }
        }
    }
    
    private var notificationsSection: some View {
        VStack(spacing: 12) {
            // Section title
            Text("Notifications")
                .font(.custom("Inter_24pt-SemiBold", size: 13))
                .tracking(-0.26) // -2% letter spacing
                .foregroundColor(Color(hex: "8F8F8F"))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Settings items
            VStack(spacing: 0) {
                // Second reminder
                Button(action: {
                    showSecondReminder = true
                }) {
                    HStack {
                        Text("Second reminder")
                            .font(.custom("Inter_24pt-SemiBold", size: 15))
                            .fontWeight(.semibold)
                            .tracking(-0.3) // -2% letter spacing
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        // Toggle switch
                        ZStack {
                            RoundedRectangle(cornerRadius: 40)
                                .fill(Color(hex: "4F9BFF"))
                                .frame(width: 60, height: 30)
                            
                            RoundedRectangle(cornerRadius: 40)
                                .fill(.white)
                                .frame(width: 33, height: 24)
                                .offset(x: 10.5)
                        }
                    }
                    .frame(height: 48)
                    .padding(.horizontal, 18)
                    .background(Color(hex: "E5E5E5"))
                    .clipShape(RoundedCorner(radius: 8, corners: [.topLeft, .topRight]))
                    .overlay(
                        RoundedCorner(radius: 8, corners: [.topLeft, .topRight])
                            .stroke(Color(hex: "D9D9D9"), lineWidth: 1)
                    )
                }
                
                // Reminder Time
                Button(action: {
                    showReminderTime = true
                }) {
                    HStack {
                        Text("Reminder Time")
                            .font(.custom("Inter_24pt-SemiBold", size: 15))
                            .fontWeight(.semibold)
                            .tracking(-0.3) // -2% letter spacing
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text("10:30 AM")
                            .font(.custom("Inter_24pt-SemiBold", size: 15))
                            .tracking(-0.3) // -2% letter spacing
                            .foregroundColor(.black)
                    }
                    .frame(height: 48)
                    .padding(.horizontal, 18)
                    .background(Color(hex: "E5E5E5"))
                    .cornerRadius(0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(Color(hex: "D9D9D9"), lineWidth: 1)
                    )
                }
                
                // Play Sound
                Button(action: {
                    showPlaySound = true
                }) {
                    HStack {
                        Text("Play Sound")
                            .font(.custom("Inter_24pt-SemiBold", size: 15))
                            .fontWeight(.semibold)
                            .tracking(-0.3) // -2% letter spacing
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        // Toggle switch
                        ZStack {
                            RoundedRectangle(cornerRadius: 40)
                                .fill(Color(hex: "4F9BFF"))
                                .frame(width: 60, height: 30)
                            
                            RoundedRectangle(cornerRadius: 40)
                                .fill(.white)
                                .frame(width: 33, height: 24)
                                .offset(x: 10.5)
                        }
                    }
                    .frame(height: 48)
                    .padding(.horizontal, 18)
                    .background(Color(hex: "E5E5E5"))
                    .clipShape(RoundedCorner(radius: 8, corners: [.bottomLeft, .bottomRight]))
                    .overlay(
                        RoundedCorner(radius: 8, corners: [.bottomLeft, .bottomRight])
                            .stroke(Color(hex: "D9D9D9"), lineWidth: 1)
                    )
                }
            }
        }
    }
    
    private var linksSection: some View {
        VStack(spacing: 0) {
            // FAQ
            Button(action: {
                showFAQ = true
            }) {
                HStack {
                    Text("FAQ")
                        .font(.custom("Inter_24pt-SemiBold", size: 15))
                        .fontWeight(.semibold)
                        .tracking(-0.3) // -2% letter spacing
                        .foregroundColor(.black)
                    
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
                showPrivacy = true
            }) {
                HStack {
                    Text("Privacy Policy")
                        .font(.custom("Inter_24pt-SemiBold", size: 15))
                        .fontWeight(.semibold)
                        .tracking(-0.3) // -2% letter spacing
                        .foregroundColor(.black)
                    
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
                showTerms = true
            }) {
                HStack {
                    Text("Terms and Conditions")
                        .font(.custom("Inter_24pt-SemiBold", size: 15))
                        .fontWeight(.semibold)
                        .tracking(-0.3) // -2% letter spacing
                        .foregroundColor(.black)
                    
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
                showHelp = true
            }) {
                HStack {
                    Text("Help and Support")
                        .font(.custom("Inter_24pt-SemiBold", size: 15))
                        .fontWeight(.semibold)
                        .tracking(-0.3) // -2% letter spacing
                        .foregroundColor(.black)
                    
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
    
    private var logOutButton: some View {
        VStack(spacing: 16) {
            Button(action: {
                showLogoutAlert = true
            }) {
                Text("Log Out")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 1)
                    )
            }
            .padding(.horizontal, 24)
            
            // Delete Account text
            Text("Delete Account")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
        }
        .padding(.bottom, 32)
        .alert("Log Out", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                logout()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }
    
    private func loadUserProfile() {
        // Load user profile logic
    }
    
    private func logout() {
        // Logout logic
        appState.navigateTo(.splash)
    }
    
    private func deleteAccount() {
        // Delete account logic
        appState.navigateTo(.splash)
    }
}

// MARK: - Supporting Views

struct MilestonesView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Milestones")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Milestones")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PremiumView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Premium")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FAQView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("FAQ")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("FAQ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TermsConditionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Terms and Conditions")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Terms and Conditions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct HelpSupportView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Help and Support")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Help and Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SecondReminderView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Second Reminder")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Second Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ReminderTimeView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Reminder Time")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Reminder Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PlaySoundView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Play Sound")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Play Sound")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
} 
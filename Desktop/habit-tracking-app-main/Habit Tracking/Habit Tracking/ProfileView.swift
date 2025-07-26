import SwiftUI
import PhotosUI
import UIKit

// MARK: - Profile Views Organization
// 
// ProfileView - Main router that decides which profile to show based on user type
// PremiumProfileView - Full featured profile for premium/subscribed users  
// FreeUserProfileView - Limited profile for free users (in separate file)
// Anonymous users will show FreeUserProfileView for now

// MARK: - Premium Profile View
struct PremiumProfileView: View {
    @StateObject private var appState = AppStateManager.shared
    @Environment(\.presentationMode) var presentationMode
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
    @State private var showEditProfile = false
    @State private var firstName = "Nina"
    @State private var lastName = "Skrbic"
    @State private var dragOffset: CGFloat = 0
    @State private var showDeleteAccount = false
    @State private var thresholdReached = false
    @State private var sheetDragOffset: CGFloat = 0

    
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
            
            // Profile header with avatar and edit button (no longer draggable)
            VStack(spacing: 0) {
                HStack {
                    // Avatar
                    Image("person.fill")
                        .resizable()
                        .frame(width: 52, height: 52)
                        .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                    .allowsHitTesting(false)
                    
                    // Edit button
                    Button(action: {
                        showEditProfile = true
                    }) {
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
                    }
                    
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
                
                // Name
                Text("\(firstName) \(lastName)")
                    .font(.system(size: 24, weight: .semibold, design: .default))
                    .tracking(-0.96) // -4% letter spacing (24 * 0.04 = 0.96)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, -2)
            }
            
            // Scrollable content with drag detection
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
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Only detect upward drag when at top of scroll for Log Out reveal
                        if value.translation.height < 0 && abs(value.translation.height) > 20 {
                            if !showDeleteAccount {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                                
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    dragOffset = -60
                                    showDeleteAccount = true
                                    thresholdReached = true
                                }
                            }
                        }
                    }
            )

            
            // Log Out button at bottom
            logOutButton
        }
        .background(Color(hex: "EDEDED"))
        .clipShape(RoundedCorner(radius: 40, corners: [.topLeft, .topRight]))
        .ignoresSafeArea()
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(.clear)
        .offset(y: sheetDragOffset)
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
            EditGoalView(showGoalEdit: $showGoalEdit)
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
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(firstName: $firstName, lastName: $lastName)
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
                            .font(.system(size: 16, weight: .bold, design: .default))
                            .tracking(-0.3) // -2% letter spacing
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Text("Premium")
                                .font(.system(size: 15, weight: .semibold, design: .default))
                                .tracking(-0.3) // -2% letter spacing
                                .foregroundColor(Color(hex: "0C0C0C"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white)
                                .cornerRadius(100)
                            
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
                            
                            // Pattern background overlay - single image covering entire button
                            Image("pattern_background")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(-20) // Extend pattern 20px beyond button boundaries
                                .clipped()
                                .opacity(1.0)
                        }
                    )
                    .overlay(
                        RoundedCorner(radius: 8, corners: [.bottomLeft, .bottomRight])
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "FF9A1E"), Color(hex: "FEC22B")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
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
            
            
            // Delete Account
            Button(action: {
                showDeleteAlert = true
            }) {
                HStack {
                    Text("Delete Account")
                        .font(.custom("Inter_24pt-SemiBold", size: 15))
                        .fontWeight(.semibold)
                        .tracking(-0.3) // -2% letter spacing
                        .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 15)
            }
            
            // Extra space for better positioning when scrolled to bottom
            Spacer()
                .frame(height: 20)
        }
    }
    
        private var logOutButton: some View {
        VStack(spacing: 0) {
            // Log Out Button moves up when Delete Account appears
            Button(action: {
                showLogoutAlert = true
            }) {
                Text("Log Out")
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .tracking(-0.64) // -4% letter spacing (16 * 0.04 = 0.64)
                    .foregroundColor(.black)
                    .frame(width: 200, height: 62)
                    .background(Color(hex: "E4E4E4"))
                    .cornerRadius(100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 100)
                            .stroke(Color(hex: "D9D9D9"), lineWidth: 1)
                    )
            }
            .offset(y: dragOffset)
            
            // Delete Account Button appears below with spacing
            if showDeleteAccount {
                Spacer()
                    .frame(height: 16)
                
                Text("Double tap to hide")
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
                    .padding(.bottom, 8)
                
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Text("Delete Account")
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .tracking(-0.64)
                        .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                        .frame(width: 200, height: 62)
                        .background(Color.clear)
                        .cornerRadius(100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(Color(red: 0.56, green: 0.56, blue: 0.56), lineWidth: 1)
                        )
                }
                .gesture(
                    TapGesture(count: 2)
                        .onEnded {
                            // Double tap to hide
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                dragOffset = 0
                                showDeleteAccount = false
                                thresholdReached = false
                            }
                        }
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.bottom, 32)
        .alert("Log Out", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                logout()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
        .alert("Delete Account", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {
                // Reset scroll state when cancelled
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    dragOffset = 0
                    showDeleteAccount = false
                    thresholdReached = false
                }
            }
            Button("Delete Account", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
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
        // Reset scroll state
        dragOffset = 0
        showDeleteAccount = false
        thresholdReached = false
        
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

// MARK: - Premium Edit Profile View
struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var firstName: String
    @Binding var lastName: String
    @State private var email = "ninaskrbic@gmail.com"
    @State private var sheetDragOffset: CGFloat = 0
    
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
            
            // Profile avatar with + icon
            ZStack {
                // Only Profile_Icon_Big (no circle background)
                Image("Profile_Icon_Big")
                    .resizable()
                    .frame(width: 96, height: 96)
                    .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                
                // Plus icon overlay - positioned at bottom right, aligned with profile icon
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 38, height: 38)
                                .overlay(
                                    Circle()
                                        .stroke(Color(red: 0.93, green: 0.93, blue: 0.93), lineWidth: 5)
                                )
                            
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .frame(width: 96, height: 96) // Define exact frame for positioning
            .padding(.top, 40)
            .padding(.bottom, 34)
            
            // Form fields
            VStack(spacing: 18) {
                // First Name
                VStack(spacing: 8) {
                    HStack {
                        Text("First Name")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                        Spacer()
                    }
                    
                    TextField("", text: $firstName)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color(red: 0.047, green: 0.047, blue: 0.047))
                        .padding(.horizontal, 16)
                        .frame(height: 42)
                        .background(Color(red: 0.894, green: 0.894, blue: 0.894))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(red: 0.46, green: 0.46, blue: 0.46).opacity(0.28), lineWidth: 1)
                        )
                        .cornerRadius(8)
                }
                
                // Last Name
                VStack(spacing: 8) {
                    HStack {
                        Text("Last Name")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                        Spacer()
                    }
                    
                    TextField("", text: $lastName)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color(red: 0.047, green: 0.047, blue: 0.047))
                        .padding(.horizontal, 16)
                        .frame(height: 42)
                        .background(Color(red: 0.894, green: 0.894, blue: 0.894))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(red: 0.46, green: 0.46, blue: 0.46).opacity(0.28), lineWidth: 1)
                        )
                        .cornerRadius(8)
                }
                
                // Email
                VStack(spacing: 8) {
                    HStack {
                        Text("Email")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                        Spacer()
                    }
                    
                    TextField("", text: $email)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color(red: 0.047, green: 0.047, blue: 0.047))
                        .padding(.horizontal, 16)
                        .frame(height: 42)
                        .background(Color(red: 0.894, green: 0.894, blue: 0.894))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(red: 0.46, green: 0.46, blue: 0.46).opacity(0.28), lineWidth: 1)
                        )
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Bottom buttons
            HStack(spacing: 10) {
                // Cancel button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 114, height: 62)
                        .background(Color(red: 0.894, green: 0.894, blue: 0.894))
                        .overlay(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1)
                        )
                        .cornerRadius(100)
                }
                
                // Save Details button
                Button(action: {
                    // Save logic here
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save Details")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 200, height: 62)
                        .background(Color.black)
                        .cornerRadius(100)
                }
            }
            .padding(.horizontal, 58)
            .padding(.bottom, 32)
        }
        .background(Color(hex: "EDEDED"))
        .clipShape(RoundedCorner(radius: 40, corners: [.topLeft, .topRight]))
        .ignoresSafeArea()
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(.clear)
        .offset(y: sheetDragOffset)
    }
}

// MARK: - Main Profile Router
struct ProfileView: View {
    @State private var userType: UserType = .premium // This will be set from backend/app state
    
    var body: some View {
        switch userType {
        case .premium:
            PremiumProfileView()
        case .free:
            FreeUserProfileView()
        case .anonymous:
            FreeUserProfileView() // For now, same as free - can create separate later
        }
    }
}

enum UserType {
    case premium
    case free  
    case anonymous
}

// MARK: - Edit Goal View (Onboarding with Back Arrow)
struct EditGoalView: View {
    @Binding var showGoalEdit: Bool
    
    var body: some View {
        ZStack {
            // Same background as onboarding
            Color(red: 0.93, green: 0.93, blue: 0.93).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Back arrow area (same as login screen)
                VStack(spacing: 0) {
                    Spacer().frame(height: 90)
                    
                    // Back arrow - same positioning as login screen
                    HStack(alignment: .firstTextBaseline, spacing: 24) {
                        Button(action: { 
                            showGoalEdit = false 
                        }) {
                            Image("back_arrow")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .alignmentGuide(.firstTextBaseline) { d in d[.bottom] + 12 }
                        }
                        Spacer()
                    }
                    .padding(.leading, 24)
                    .frame(height: 62)
                }
                
                // Onboarding flow content (adjusted for back arrow space)
                GoalEntryFlowView()
                    .padding(.top, -90) // Reduce top padding since we added back arrow area
            }
        }
    }
}

#Preview {
    ProfileView()
} 
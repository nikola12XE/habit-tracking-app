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
    @State private var currentGoalText = "Grow Portfolio" // Default text
    @State private var profileImageData: Data?
    @State private var showMilestoneEdit = false
    @State private var selectedMilestone: ProgressDay?
    @State private var dragOffset: CGFloat = 0
    @State private var showDeleteAccount = false
    @State private var thresholdReached = false
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
            
            // Profile header with avatar and edit button (no longer draggable)
            VStack(spacing: 0) {
                HStack {
                    // Avatar - show selected image or default icon
                    Group {
                        if let profileImageData = profileImageData,
                           let uiImage = UIImage(data: profileImageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 52, height: 52)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 5)
                                )
                        } else {
                            Image("person.fill")
                                .resizable()
                                .frame(width: 52, height: 52)
                                .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                        }
                    }
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
            loadCurrentGoalText()
            loadMilestoneCount()
        }
        .onChange(of: showMilestones) { _, isShowing in
            if !isShowing {
                // Reload milestone count when sheet is dismissed
                loadMilestoneCount()
            }
        }
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    userProfile?.avatar = data
                    coreDataManager.updateUserProfile(userProfile!)
                }
            }
        }
        .onChange(of: profileImageData) { _, newData in
            if let userProfile = userProfile {
                userProfile.avatar = newData
                coreDataManager.updateUserProfile(userProfile)
                // Notify MainTrackingView to update profile image
                NotificationCenter.default.post(name: NSNotification.Name("ProfileImageUpdated"), object: nil)
            }
        }
        .fullScreenCover(isPresented: $showGoalEdit) {
            EditGoalView(showGoalEdit: $showGoalEdit, currentGoalText: $currentGoalText)
        }
        .sheet(isPresented: $showMilestones) {
            MilestonesView(onEditMilestone: { milestone in
                // Close milestones sheet and open milestone edit
                showMilestones = false
                selectedMilestone = milestone
                // Small delay to ensure milestones sheet is closed before opening edit
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showMilestoneEdit = true
                }
            })
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
            EditProfileView(firstName: $firstName, lastName: $lastName, profileImageData: $profileImageData, userProfile: userProfile, coreDataManager: coreDataManager)
        }
        .sheet(isPresented: $showMilestoneEdit) {
            if let milestone = selectedMilestone {
                MilestonePopupView(progressDay: milestone, isPresented: $showMilestoneEdit)
                    .onDisappear {
                        // Reload milestone count when edit is complete
                        loadMilestoneCount()
                    }
            }
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
                            Text(currentGoalText)
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
                            Text("\(milestoneCount)")
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
        if let profile = coreDataManager.fetchUserProfile() {
            userProfile = profile
            profileImageData = profile.avatar
            
            // Split name into firstName and lastName
            if let name = profile.name {
                let nameComponents = name.components(separatedBy: " ")
                firstName = nameComponents.first ?? "Nina"
                lastName = nameComponents.count > 1 ? nameComponents.dropFirst().joined(separator: " ") : "Skrbic"
            }
        } else {
            // Create user profile if it doesn't exist
            userProfile = coreDataManager.createUserProfile(email: "ninaskrbic@gmail.com", name: "\(firstName) \(lastName)")
            profileImageData = nil
        }
    }
    
    private func loadCurrentGoalText() {
        let existingGoals = coreDataManager.fetchGoals()
        guard let goal = existingGoals.first else { return }
        currentGoalText = goal.goalText ?? "Grow Portfolio"
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
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var coreDataManager = CoreDataManager.shared
    @State private var milestones: [ProgressDay] = []
    @State private var currentGoal: Goal?
    @State private var sheetDragOffset: CGFloat = 0
    let onEditMilestone: (ProgressDay) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 0) {
                // Drag handle
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color(red: 0.8, green: 0.8, blue: 0.8))
                    .frame(width: 36, height: 5)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                
                // Title with trophy icon and close button
                HStack {
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Image("Trophy")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                        Text("\(milestones.count) Milestones")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    // Close button - same style as EditProfileView
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
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.height > 0 {
                            sheetDragOffset = value.translation.height
                        } else {
                            sheetDragOffset = 0
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            if value.translation.height > 150 {
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                sheetDragOffset = 0
                            }
                        }
                    }
            )
            
            // Content
            if milestones.isEmpty {
                // Empty state
                VStack(spacing: 24) {
                    Image("Trophy")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .opacity(0.3)
                    
                    VStack(spacing: 8) {
                        Text("No milestones yet")
                            .font(.custom("Inter_24pt-SemiBold", size: 18))
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        Text("Complete your daily goals and add milestones to track your progress")
                            .font(.custom("Inter_24pt-Regular", size: 14))
                            .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 60)
            } else {
                // Milestones list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(Array(milestones.enumerated()), id: \.element.id) { index, milestone in
                            MilestoneCardView(milestone: milestone, index: index) {
                                onEditMilestone(milestone)
                            }
                        }
                        
                        // Extra space at bottom
                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }
            }
        }
        .background(Color(hex: "EDEDED"))
        .clipShape(RoundedCorner(radius: 40, corners: [.topLeft, .topRight]))
        .presentationDetents([.fraction(1.0)])
        .presentationDragIndicator(.hidden)
        .presentationBackground(.clear)
        .offset(y: sheetDragOffset)
        .ignoresSafeArea(.container, edges: .bottom)
        .onAppear {
            loadMilestones()
        }
    }
    
    private func loadMilestones() {
        let goals = coreDataManager.fetchGoals()
        currentGoal = goals.first
        
        if let goal = currentGoal {
            let progressDays = coreDataManager.fetchProgressDays(for: goal)
            milestones = progressDays.filter { 
                let hasText = $0.milestoneText != nil && !($0.milestoneText?.isEmpty ?? true)
                let hasPhoto = $0.milestonePhoto != nil
                return hasText || hasPhoto
            }.sorted { ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast) } // Most recent first
        }
    }
}

struct MilestoneCardView: View {
    let milestone: ProgressDay
    let index: Int
    let onEdit: () -> Void
    
    private var hasText: Bool {
        milestone.milestoneText != nil && !(milestone.milestoneText?.isEmpty ?? true)
    }
    
    private var hasPhoto: Bool {
        milestone.milestonePhoto != nil
    }
    
    private var rotationAngle: Double {
        return index % 2 == 0 ? 1.0 : -1.0
    }
    
    var body: some View {
        ZStack {
            if hasPhoto {
                // Card with photo (with or without text)
                photoCard
            } else {
                // Text-only card with orange gradient
                textOnlyCard
            }
        }
        .rotationEffect(.degrees(rotationAngle))
    }
    
    @ViewBuilder
    private var photoCard: some View {
        ZStack {
            // Background image
            if let photoData = milestone.milestonePhoto,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 372, height: 227)
                    .clipped()
            }
            
            // Dark gradient overlay
            LinearGradient(
                stops: [
                    .init(color: Color.black.opacity(0), location: 0.4978),
                    .init(color: Color.black.opacity(0.7), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Content overlay
            VStack {
                HStack {
                    Spacer()
                    
                    // Edit icon
                    Button(action: {
                        onEdit()
                    }) {
                        Image("edit")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.top, 16)
                .padding(.trailing, 16)
                
                Spacer()
                
                // Bottom content
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        // Date
                        Text(dateString(from: milestone.date ?? Date()))
                            .font(.custom("Inter_24pt-Medium", size: 14))
                            .foregroundColor(.white.opacity(0.7))
                        
                        // Text (if exists)
                        if hasText, let milestoneText = milestone.milestoneText {
                            Text(milestoneText)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(2)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 16)
                .padding(.leading, 16)
            }
        }
        .frame(width: 372, height: 227)
        .background(Color(hex: "D9D9D9"))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.white, lineWidth: 8)
        )
        .cornerRadius(6)
        .shadow(color: Color.black.opacity(0.05), radius: 22, x: 0, y: 24)
    }
    
    @ViewBuilder
    private var textOnlyCard: some View {
        ZStack {
            // Orange gradient background
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "FF9A1E"), location: 0.0384),
                    .init(color: Color(hex: "FEC22B"), location: 0.9963)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            
            // Content
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    // Date
                    Text(dateString(from: milestone.date ?? Date()))
                        .font(.custom("Inter_24pt-Medium", size: 14))
                        .foregroundColor(.white.opacity(0.7))
                    
                    // Text
                    if let milestoneText = milestone.milestoneText {
                        Text(milestoneText)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                // Edit icon
                Button(action: {
                    onEdit()
                }) {
                    Image("edit")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(width: 372, height: 76)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.white, lineWidth: 8)
        )
        .cornerRadius(6)
        .shadow(color: Color.black.opacity(0.05), radius: 22, x: 0, y: 24)
    }
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd. MM. yyyy."
        return formatter.string(from: date)
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
    @Binding var profileImageData: Data?
    let userProfile: UserProfile?
    let coreDataManager: CoreDataManager
    @State private var email = "ninaskrbic@gmail.com"
    @State private var sheetDragOffset: CGFloat = 0
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showImageActionSheet = false
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    
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
                // Profile image - show selected image or default icon
                if let profileImageData = profileImageData,
                   let uiImage = UIImage(data: profileImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 96, height: 96)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 5)
                        )
                } else {
                    // Default Profile_Icon_Big (no circle background)
                    Image("Profile_Icon_Big")
                        .resizable()
                        .frame(width: 96, height: 96)
                        .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                }
                
                // Plus icon overlay - positioned at bottom right, aligned with profile icon
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showImageActionSheet = true
                        }) {
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
                    saveProfileDetails()
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
        .presentationDetents([.fraction(1.0)])
        .presentationDragIndicator(.hidden)
        .presentationBackground(.clear)
        .offset(y: sheetDragOffset)
        .ignoresSafeArea(.container, edges: .bottom)
        .actionSheet(isPresented: $showImageActionSheet) {
            ActionSheet(
                title: Text("Add Photo"),
                message: Text("Choose how you want to add a photo"),
                buttons: [
                    .default(Text("Take Photo")) {
                        showCamera = true
                    },
                    .default(Text("Choose from Library")) {
                        showPhotoLibrary = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showCamera) {
            CameraView(photoData: $profileImageData)
                .onDisappear {
                    // Notify when camera photo is captured
                    if profileImageData != nil {
                        NotificationCenter.default.post(name: NSNotification.Name("ProfileImageUpdated"), object: nil)
                    }
                }
        }
        .photosPicker(isPresented: $showPhotoLibrary, selection: $selectedPhoto, matching: .images)
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    profileImageData = data
                    // Notify MainTrackingView to update profile image
                    NotificationCenter.default.post(name: NSNotification.Name("ProfileImageUpdated"), object: nil)
                }
            }
        }
        .onAppear {
            // Load email and name from userProfile when view appears
            if let userProfile = userProfile {
                email = userProfile.email ?? "ninaskrbic@gmail.com"
                
                // Split name into firstName and lastName
                if let name = userProfile.name {
                    let nameComponents = name.components(separatedBy: " ")
                    firstName = nameComponents.first ?? "Nina"
                    lastName = nameComponents.count > 1 ? nameComponents.dropFirst().joined(separator: " ") : "Skrbic"
                }
            }
        }
    }
    
    private func saveProfileDetails() {
        if let userProfile = userProfile {
            userProfile.name = "\(firstName) \(lastName)"
            userProfile.email = email
            userProfile.avatar = profileImageData
            coreDataManager.updateUserProfile(userProfile)
            NotificationCenter.default.post(name: NSNotification.Name("ProfileImageUpdated"), object: nil)
        }
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
    @Binding var currentGoalText: String
    
    var body: some View {
        ZStack {
            // Same background as onboarding
            Color(red: 0.93, green: 0.93, blue: 0.93).ignoresSafeArea()
            
            // 100% identical onboarding flow with back arrow
            EditGoalEntryFlowView(
                onComplete: { 
                    showGoalEdit = false 
                },
                currentGoalText: $currentGoalText
            )
        }
    }
}

// MARK: - Edit Goal Entry Flow View (100% identical to original with back arrow)
struct EditGoalEntryFlowView: View {
    let onComplete: () -> Void
    @Binding var currentGoalText: String
    
    @StateObject private var appState = AppStateManager.shared
    @StateObject private var coreDataManager = CoreDataManager.shared
    
    @State private var currentPage = 0
    @State private var goalText = ""
    @State private var selectedDays: Set<Int> = [0, 1, 2, 3, 4] // Pre-select MTWTF
    @State private var reminderEnabled = false
    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    @State private var isEditing = true // Always editing in this flow
    @State private var existingGoal: Goal?
    @State private var keyboardHeight: CGFloat = 0
    @State private var slideDirection: SlideDirection = .forward
    @State private var headerTextBottom: CGFloat = 0
    @FocusState private var isTextFieldFocused: Bool
    @State private var hasChanges = false
    @State private var showConfirmation = false
    
    enum SlideDirection {
        case forward, backward
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Progress dots with back arrow horizontally aligned
                HStack {
                    // Back arrow aligned with progress dots
                    Button(action: handleBack) {
                        Image("back_arrow")
                            .resizable()
                            .frame(width: 32, height: 32)
                    }
                    .padding(.leading, 24)
                    
                    Spacer()
                    
                    // Progress dots (centered)
                    HStack(spacing: 12) {
                        ForEach(0..<3) { index in  // Changed back from 4 to 3
                            ProgressDot(
                                isActive: index == currentPage,
                                isCompleted: index < currentPage,
                                index: index
                            )
                        }
                    }
                    
                    Spacer()
                    
                    // Invisible spacer to balance layout
                    Color.clear
                        .frame(width: 32, height: 32)
                        .padding(.trailing, 24)
                }
                .padding(.top, 40)
                
                headerView
                stepContentView
                Spacer() // Da popuni prostor
            }
            // Continue dugme na dnu (100% identično)
            VStack {
                Spacer()
                Button(action: handleContinue) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(canContinue ? .white : Color.black.opacity(0.4))
                        .frame(width: 200, height: 62)
                        .background(canContinue ? Color.black : Color.black.opacity(0.05))
                        .cornerRadius(100)
                }
                .disabled(!canContinue)
                .padding(.bottom, keyboardHeight > 0 ? keyboardHeight + 24 : 24)
                .animation(.easeInOut(duration: 0.3), value: keyboardHeight)
            }
        }
        .onAppear {
            loadExistingGoal()
            subscribeToKeyboardNotifications()
        }
        .onDisappear {
            unsubscribeFromKeyboardNotifications()
        }
        .ignoresSafeArea(.keyboard)
        .alert("Are you sure you want\nto edit your goal?", isPresented: $showConfirmation) {
            Button("Edit Goal") {
                applyChanges()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("The updated goal will take effect from today, while all previous entries will stay saved.")
        }
    }
    
    private var headerView: some View {
        Group {
            if currentPage == 0 {
                VStack(spacing: 0) {
                    Text("MY BIGGEST")
                        .font(.custom("Thunder-BoldLC", size: 54))
                        .foregroundColor(Color(red: 0.047, green: 0.047, blue: 0.047))
                        .multilineTextAlignment(.center)
                    Text("GOAL IS TO")
                        .font(.custom("Thunder-BoldLC", size: 54))
                        .foregroundColor(Color(red: 0.047, green: 0.047, blue: 0.047))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 32)
                .padding(.bottom, 54)
            } else if currentPage == 1 {
                Text("AND I NEED TO\nWORK ON IT")
                    .font(.custom("Thunder-BoldLC", size: 54))
                    .foregroundColor(Color(red: 0.047, green: 0.047, blue: 0.047))
                    .multilineTextAlignment(.center)
                    .padding(.top, 32)
                    .padding(.bottom, 54)
            } else if currentPage == 2 {
                Text("AT")
                    .font(.custom("Thunder-BoldLC", size: 54))
                    .foregroundColor(Color(red: 0.047, green: 0.047, blue: 0.047))
                    .multilineTextAlignment(.center)
                    .padding(.top, 32)
                    .padding(.bottom, 54)
            }
        }
    }
    
    private var stepContentView: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                step1View(width: geo.size.width, height: geo.size.height)
                step2View(width: geo.size.width, height: geo.size.height)
                step3View(width: geo.size.width, height: geo.size.height)
            }
            .frame(width: geo.size.width * 3, alignment: .leading) // Back to 3 steps
            .contentShape(Rectangle())
            .offset(x: -CGFloat(currentPage) * geo.size.width)
            .animation(.easeInOut(duration: 0.6), value: currentPage)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width > 40 && currentPage > 0 {
                            slideDirection = .backward
                            handleBack()
                        } else if value.translation.width < -40 && currentPage < 2 && canContinue {
                            slideDirection = .forward
                            handleContinue()
                        }
                    }
            )
        }
    }
    
    private func step1View(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            // Header height (fiksno)
            let headerHeight: CGFloat = 40 + 66 + 32 + 54 * 2
            let buttonHeight: CGFloat = 62
            let buttonBottomPadding: CGFloat = 24
            // Gde je vrh dugmeta
            let buttonTop: CGFloat = keyboardHeight > 0
                ? height - keyboardHeight - buttonBottomPadding - buttonHeight
                : height - buttonBottomPadding - buttonHeight
            // Ako tastatura NIJE podignuta, input je na istoj visini kao na drugom koraku
            let centerY: CGFloat = keyboardHeight > 0
                ? (headerHeight + buttonTop) / 2 - 140 + 30 - 20 - 10 // dodatno podigni za 10px
                : (headerHeight + buttonTop) / 2 - 120 - 20 - 10
            VStack(spacing: 0) {
                AnimatedTypewriterTextField(goalText: $goalText, isFocused: $isTextFieldFocused)
                    .onChange(of: goalText) { oldValue, newValue in checkForChanges() }
                Text("Enter your goal")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 0.047, green: 0.047, blue: 0.047).opacity(0.7))
                    .padding(.top, 14)
            }
            .frame(width: width)
            .position(x: width / 2, y: centerY)
            .animation(.easeInOut(duration: 0.6), value: keyboardHeight)
        }
        .frame(width: width)
    }
    
    private func step2View(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            // Header height (fiksno)
            let headerHeight: CGFloat = 40 + 66 + 32 + 54 * 2
            let buttonHeight: CGFloat = 62
            let buttonBottomPadding: CGFloat = 24
            // Gde je vrh dugmeta
            let buttonTop: CGFloat = keyboardHeight > 0
                ? height - keyboardHeight - buttonBottomPadding - buttonHeight
                : height - buttonBottomPadding - buttonHeight
            // Ista pozicija kao prvi korak
            let centerY: CGFloat = keyboardHeight > 0
                ? (headerHeight + buttonTop) / 2 - 140 + 30 - 20 - 10
                : (headerHeight + buttonTop) / 2 - 120 - 20 - 10
            VStack(spacing: 0) {
                HStack(spacing: 2) {
                    ForEach(0..<7) { dayIndex in
                        DaySelectionButton(
                            day: dayNames[dayIndex],
                            isSelected: selectedDays.contains(dayIndex),
                            action: {
                                if selectedDays.contains(dayIndex) {
                                    selectedDays.remove(dayIndex)
                                } else {
                                    selectedDays.insert(dayIndex)
                                }
                                checkForChanges()
                            }
                        )
                    }
                }
                Text("Select your days")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 0.047, green: 0.047, blue: 0.047).opacity(0.7))
                    .padding(.top, 14)
            }
            .frame(width: width)
            .position(x: width / 2, y: centerY)
        }
        .frame(width: width)
    }
    
    private func step3View(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            // Header height (fiksno)
            let headerHeight: CGFloat = 40 + 66 + 32 + 54 * 2
            let buttonHeight: CGFloat = 62
            let buttonBottomPadding: CGFloat = 24
            // Gde je vrh dugmeta
            let buttonTop: CGFloat = keyboardHeight > 0
                ? height - keyboardHeight - buttonBottomPadding - buttonHeight
                : height - buttonBottomPadding - buttonHeight
            // Ista pozicija kao prvi korak
            let centerY: CGFloat = keyboardHeight > 0
                ? (headerHeight + buttonTop) / 2 - 140 + 30 - 20 - 10
                : (headerHeight + buttonTop) / 2 - 120 - 20 - 10
            VStack(spacing: 0) {
                ReminderInputView(
                    reminderEnabled: $reminderEnabled,
                    reminderTime: $reminderTime
                )
                .onChange(of: reminderEnabled) { oldValue, newValue in checkForChanges() }
                .onChange(of: reminderTime) { oldValue, newValue in checkForChanges() }
            }
            .frame(width: width)
            .position(x: width / 2, y: centerY)
            .animation(.easeInOut(duration: 0.3), value: keyboardHeight)
        }
        .frame(width: width)
    }
    
    private var canContinue: Bool {
        switch currentPage {
        case 0: return !goalText.isEmpty
        case 1: return !selectedDays.isEmpty
        case 2: return true
        default: return false
        }
    }
    
    private func handleContinue() {
        if currentPage < 2 && canContinue {
            // Skloni tastaturu ako je na prvom koraku
            if currentPage == 0 {
                isTextFieldFocused = false
            }
            slideDirection = .forward
            withAnimation(.easeInOut(duration: 0.6)) {
                currentPage += 1
            }
        } else if currentPage == 2 {
            // From step 3 (reminder) - check if user made changes
            if hasChanges {
                // Show confirmation popup
                showConfirmation = true
            } else {
                // No changes made, just close
                onComplete()
            }
        }
    }
    
    private func handleBack() {
        if currentPage > 0 {
            slideDirection = .backward
            withAnimation(.easeInOut(duration: 0.6)) {
                currentPage -= 1
            }
        } else {
            // First page - close the edit flow
            onComplete()
        }
    }
    
    private func checkForChanges() {
        guard let goal = existingGoal else { return }
        
        let originalGoalText = goal.goalText ?? ""
        let originalDays = Set((goal.selectedDays as? [NSNumber])?.map { $0.intValue } ?? [])
        let originalReminderEnabled = goal.reminderEnabled
        let originalReminderTime = goal.reminderTime
        
        hasChanges = goalText != originalGoalText ||
                    selectedDays != originalDays ||
                    reminderEnabled != originalReminderEnabled ||
                    reminderTime != originalReminderTime
    }
    
    private func applyChanges() {
        // Simply update the existing goal
        // The changes will take effect from today while keeping previous entries
        updateExistingGoal()
        onComplete()
    }
    
    private func updateExistingGoal() {
        let existingGoals = coreDataManager.fetchGoals()
        guard let goal = existingGoals.first else { return }
        
        goal.goalText = goalText
        goal.selectedDays = Array(selectedDays).map { NSNumber(value: $0) } as NSArray
        goal.reminderEnabled = reminderEnabled
        goal.reminderTime = reminderEnabled ? reminderTime : nil
        
        coreDataManager.save()
        
        // Update the display text in main profile
        currentGoalText = goalText
    }
    
    private func loadExistingGoal() {
        let existingGoals = coreDataManager.fetchGoals()
        guard let goal = existingGoals.first else { return }
        
        existingGoal = goal
        goalText = goal.goalText ?? ""
        if let nsNumbers = goal.selectedDays as? [NSNumber] {
            selectedDays = Set(nsNumbers.map { $0.intValue })
        } else {
            selectedDays = [0, 1, 2, 3, 4]
        }
        reminderEnabled = goal.reminderEnabled
        reminderTime = goal.reminderTime ?? Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    }
    
    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notif in
            if let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                let keyWindow = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap { $0.windows }
                    .first { $0.isKeyWindow }
                let bottomInset = keyWindow?.safeAreaInsets.bottom ?? 0
                keyboardHeight = frame.height - bottomInset
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardHeight = 0
        }
    }
    
    private func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private let dayNames = ["M", "T", "W", "T", "F", "S", "S"]
}

// Note: ReminderInputView and CustomSwitch components are already defined in GoalEntryFlowView.swift

#Preview {
    ProfileView()
} 
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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignConstants.largeSpacing) {
                    // Avatar and name
                    avatarSection
                    
                    // Profile fields
                    profileFieldsSection
                    
                    // Goal section
                    goalSection
                    
                    // Notifications
                    notificationsSection
                    
                    // Links
                    linksSection
                    
                    // Actions
                    actionsSection
                }
                .padding(.horizontal, DesignConstants.largeSpacing)
                .padding(.bottom, DesignConstants.extraLargeSpacing)
            }
            .background(DesignConstants.backgroundColor)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        appState.navigateTo(.main)
                    }
                    .foregroundColor(DesignConstants.primaryColor)
                }
            }
        }
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
        .alert("Log Out", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                logout()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
        .alert("Delete Account", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
        .fullScreenCover(isPresented: $showGoalEdit) {
            GoalEntryFlowView()
        }
    }
    
    private var avatarSection: some View {
        VStack(spacing: DesignConstants.mediumSpacing) {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                if let avatarData = userProfile?.avatar, let uiImage = UIImage(data: avatarData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(DesignConstants.primaryColor, lineWidth: 3)
                        )
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(DesignConstants.primaryColor)
                }
            }
            
            Text(userProfile?.name ?? "User Name")
                .font(DesignConstants.subtitleFont)
                .fontWeight(.semibold)
                .foregroundColor(DesignConstants.textColor)
        }
        .padding(.top, DesignConstants.largeSpacing)
    }
    
    private var profileFieldsSection: some View {
        VStack(spacing: DesignConstants.mediumSpacing) {
            ProfileFieldView(
                title: "Email Address",
                value: userProfile?.email ?? "user@example.com",
                isEditable: false
            )
            
            ProfileFieldView(
                title: "Your Plan",
                value: userProfile?.plan == "free" ? "Free Plan" : "Premium Plan",
                isEditable: false
            )
        }
        .padding(DesignConstants.largeSpacing)
        .background(Color.white)
        .cornerRadius(DesignConstants.largeCornerRadius)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var goalSection: some View {
        VStack(spacing: DesignConstants.mediumSpacing) {
            HStack {
                Text("Your Goal")
                    .font(DesignConstants.subtitleFont)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignConstants.textColor)
                
                Spacer()
                
                Button("Edit") {
                    showGoalEdit = true
                }
                .font(DesignConstants.bodyFont)
                .foregroundColor(DesignConstants.primaryColor)
            }
            
            let goals = coreDataManager.fetchGoals()
            if let goal = goals.first {
                VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                    Text(goal.goalText ?? "No goal set")
                        .font(DesignConstants.bodyFont)
                        .foregroundColor(DesignConstants.textColor)
                    
                    if let selectedDays = goal.selectedDays, !selectedDays.isEmpty {
                        Text("Days: \(formatSelectedDays(selectedDays))")
                            .font(DesignConstants.captionFont)
                            .foregroundColor(DesignConstants.textColor.opacity(0.7))
                    }
                    
                    if goal.reminderEnabled {
                        Text("Reminder: \(formatReminderTime(goal.reminderTime))")
                            .font(DesignConstants.captionFont)
                            .foregroundColor(DesignConstants.textColor.opacity(0.7))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(DesignConstants.mediumSpacing)
                .background(DesignConstants.backgroundColor)
                .cornerRadius(DesignConstants.mediumCornerRadius)
            } else {
                Text("No goal set yet")
                    .font(DesignConstants.bodyFont)
                    .foregroundColor(DesignConstants.textColor.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(DesignConstants.mediumSpacing)
                    .background(DesignConstants.backgroundColor)
                    .cornerRadius(DesignConstants.mediumCornerRadius)
            }
        }
        .padding(DesignConstants.largeSpacing)
        .background(Color.white)
        .cornerRadius(DesignConstants.largeCornerRadius)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var notificationsSection: some View {
        VStack(spacing: DesignConstants.mediumSpacing) {
            HStack {
                Text("Notifications")
                    .font(DesignConstants.subtitleFont)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignConstants.textColor)
                
                Spacer()
            }
            
            VStack(spacing: DesignConstants.smallSpacing) {
                Toggle("Send Reminder", isOn: Binding(
                    get: { userProfile?.reminderEnabled ?? true },
                    set: { newValue in
                        userProfile?.reminderEnabled = newValue
                        if let profile = userProfile {
                            coreDataManager.updateUserProfile(profile)
                        }
                    }
                ))
                .font(DesignConstants.bodyFont)
                
                if userProfile?.reminderEnabled == true {
                    DatePicker("Reminder Time", selection: Binding(
                        get: { userProfile?.reminderTime ?? Date() },
                        set: { newValue in
                            userProfile?.reminderTime = newValue
                            if let profile = userProfile {
                                coreDataManager.updateUserProfile(profile)
                            }
                        }
                    ), displayedComponents: .hourAndMinute)
                    .font(DesignConstants.bodyFont)
                }
                
                Toggle("Second reminder", isOn: Binding(
                    get: { userProfile?.secondReminder ?? false },
                    set: { newValue in
                        userProfile?.secondReminder = newValue
                        if let profile = userProfile {
                            coreDataManager.updateUserProfile(profile)
                        }
                    }
                ))
                .font(DesignConstants.bodyFont)
                
                Toggle("Play sound", isOn: Binding(
                    get: { userProfile?.playSound ?? true },
                    set: { newValue in
                        userProfile?.playSound = newValue
                        if let profile = userProfile {
                            coreDataManager.updateUserProfile(profile)
                        }
                    }
                ))
                .font(DesignConstants.bodyFont)
            }
        }
        .padding(DesignConstants.largeSpacing)
        .background(Color.white)
        .cornerRadius(DesignConstants.largeCornerRadius)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var linksSection: some View {
        VStack(spacing: DesignConstants.smallSpacing) {
            ProfileLinkView(title: "Milestones", icon: "trophy.fill") {
                // Navigate to milestones
            }
            
            ProfileLinkView(title: "FAQ", icon: "questionmark.circle.fill") {
                // Navigate to FAQ
            }
            
            ProfileLinkView(title: "Privacy", icon: "lock.fill") {
                // Navigate to Privacy
            }
            
            ProfileLinkView(title: "Terms", icon: "doc.text.fill") {
                // Navigate to Terms
            }
            
            ProfileLinkView(title: "Support", icon: "message.fill") {
                // Navigate to Support
            }
        }
        .padding(DesignConstants.largeSpacing)
        .background(Color.white)
        .cornerRadius(DesignConstants.largeCornerRadius)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var actionsSection: some View {
        VStack(spacing: DesignConstants.mediumSpacing) {
            Button("Log Out") {
                showLogoutAlert = true
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button("Delete Account") {
                showDeleteAlert = true
            }
            .foregroundColor(DesignConstants.errorColor)
            .font(DesignConstants.bodyFont)
        }
    }
    
    private func loadUserProfile() {
        userProfile = coreDataManager.fetchUserProfile()
        
        if userProfile == nil {
            // Create default profile
            userProfile = coreDataManager.createUserProfile(
                email: "user@example.com",
                name: "User Name"
            )
        }
    }
    
    private func formatSelectedDays(_ days: [Int]) -> String {
        let dayNames = ["M", "T", "W", "T", "F", "S", "S"]
        return days.map { dayNames[$0] }.joined(separator: ", ")
    }
    
    private func formatReminderTime(_ date: Date?) -> String {
        guard let date = date else { return "Not set" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func logout() {
        appState.logout()
    }
    
    private func deleteAccount() {
        // Handle account deletion logic
        appState.logout()
    }
}

struct ProfileFieldView: View {
    let title: String
    let value: String
    let isEditable: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                Text(title)
                    .font(DesignConstants.captionFont)
                    .foregroundColor(DesignConstants.textColor.opacity(0.7))
                
                Text(value)
                    .font(DesignConstants.bodyFont)
                    .foregroundColor(DesignConstants.textColor)
            }
            
            Spacer()
            
            if isEditable {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(DesignConstants.textColor.opacity(0.5))
            }
        }
    }
}

struct ProfileLinkView: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(DesignConstants.primaryColor)
                    .frame(width: 24)
                
                Text(title)
                    .font(DesignConstants.bodyFont)
                    .foregroundColor(DesignConstants.textColor)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(DesignConstants.textColor.opacity(0.5))
            }
        }
        .padding(.vertical, DesignConstants.smallSpacing)
    }
}

#Preview {
    ProfileView()
} 
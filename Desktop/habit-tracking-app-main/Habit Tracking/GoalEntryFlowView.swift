import SwiftUI

struct GoalEntryFlowView: View {
    @StateObject private var appState = AppStateManager.shared
    @StateObject private var coreDataManager = CoreDataManager.shared
    
    @State private var currentPage = 0
    @State private var goalText = ""
    @State private var selectedDays: Set<Int> = []
    @State private var reminderEnabled = false
    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    @State private var isEditing = false
    @State private var existingGoal: Goal?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress dots
                HStack(spacing: DesignConstants.smallSpacing) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? DesignConstants.primaryColor : DesignConstants.primaryColor.opacity(0.3))
                            .frame(width: 12, height: 12)
                            .animation(.easeInOut(duration: DesignConstants.shortAnimation), value: currentPage)
                    }
                }
                .padding(.top, DesignConstants.largeSpacing)
                .padding(.bottom, DesignConstants.extraLargeSpacing)
                
                // Page content
                TabView(selection: $currentPage) {
                    // Page 1: Goal Text
                    GoalTextPage(goalText: $goalText)
                        .tag(0)
                    
                    // Page 2: Frequency
                    FrequencyPage(selectedDays: $selectedDays)
                        .tag(1)
                    
                    // Page 3: Reminder
                    ReminderPage(
                        reminderEnabled: $reminderEnabled,
                        reminderTime: $reminderTime
                    )
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: DesignConstants.mediumAnimation), value: currentPage)
                
                // Bottom button
                VStack {
                    Button(action: handleContinue) {
                        Text(currentPage == 2 ? (isEditing ? "Update Goal" : "Create Goal") : "Continue")
                            .font(DesignConstants.buttonFont)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: DesignConstants.buttonHeight)
                            .background(canContinue ? DesignConstants.primaryColor : DesignConstants.primaryColor.opacity(0.5))
                            .cornerRadius(DesignConstants.mediumCornerRadius)
                    }
                    .disabled(!canContinue)
                    .padding(.horizontal, DesignConstants.largeSpacing)
                    .padding(.bottom, DesignConstants.largeSpacing)
                }
            }
            .background(DesignConstants.backgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(isEditing ? "Cancel" : "Cancel") {
                        if isEditing {
                            appState.navigateTo(.main)
                        } else {
                            appState.navigateTo(.splash)
                        }
                    }
                    .foregroundColor(DesignConstants.primaryColor)
                }
            }
        }
        .onAppear {
            loadExistingGoal()
        }
    }
    
    private var canContinue: Bool {
        switch currentPage {
        case 0:
            return !goalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 1:
            return !selectedDays.isEmpty
        case 2:
            return true
        default:
            return false
        }
    }
    
    private func loadExistingGoal() {
        let goals = coreDataManager.fetchGoals()
        if let goal = goals.first {
            existingGoal = goal
            isEditing = true
            
            // Load existing data
            goalText = goal.goalText ?? ""
            selectedDays = Set(goal.selectedDays ?? [])
            reminderEnabled = goal.reminderEnabled
            reminderTime = goal.reminderTime ?? Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
        }
    }
    
    private func handleContinue() {
        if currentPage < 2 {
            withAnimation {
                currentPage += 1
            }
        } else {
            if isEditing {
                updateGoal()
            } else {
                createGoal()
            }
        }
    }
    
    private func createGoal() {
        _ = coreDataManager.createGoal(
            text: goalText,
            selectedDays: Array(selectedDays),
            reminderEnabled: reminderEnabled,
            reminderTime: reminderEnabled ? reminderTime : nil
        )
        
        // Navigate to main tracking screen
        appState.navigateTo(.main)
    }
    
    private func updateGoal() {
        guard let goal = existingGoal else { return }
        
        goal.goalText = goalText
        goal.selectedDays = Array(selectedDays)
        goal.reminderEnabled = reminderEnabled
        goal.reminderTime = reminderEnabled ? reminderTime : nil
        
        coreDataManager.save()
        
        // Navigate to main tracking screen
        appState.navigateTo(.main)
    }
}

// MARK: - Page 1: Goal Text
struct GoalTextPage: View {
    @Binding var goalText: String
    
    var body: some View {
        VStack(spacing: DesignConstants.extraLargeSpacing) {
            Spacer()
            
            VStack(spacing: DesignConstants.largeSpacing) {
                Text("MY BIGGEST GOAL IS TO")
                    .font(DesignConstants.subtitleFont)
                    .foregroundColor(DesignConstants.textColor)
                    .multilineTextAlignment(.center)
                
                TextField("Enter your goal...", text: $goalText, axis: .vertical)
                    .font(DesignConstants.bodyFont)
                    .padding(DesignConstants.largeSpacing)
                    .background(Color.white)
                    .cornerRadius(DesignConstants.mediumCornerRadius)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .lineLimit(3...6)
            }
            .padding(.horizontal, DesignConstants.largeSpacing)
            
            Spacer()
        }
    }
}

// MARK: - Page 2: Frequency
struct FrequencyPage: View {
    @Binding var selectedDays: Set<Int>
    
    var body: some View {
        VStack(spacing: DesignConstants.extraLargeSpacing) {
            Spacer()
            
            VStack(spacing: DesignConstants.largeSpacing) {
                Text("AND I NEED TO WORK ON IT")
                    .font(DesignConstants.subtitleFont)
                    .foregroundColor(DesignConstants.textColor)
                    .multilineTextAlignment(.center)
                
                // Day selector
                HStack(spacing: DesignConstants.mediumSpacing) {
                    ForEach(0..<7, id: \.self) { dayIndex in
                        DayButton(
                            day: DesignConstants.dayNames[dayIndex],
                            isSelected: selectedDays.contains(dayIndex),
                            action: {
                                if selectedDays.contains(dayIndex) {
                                    selectedDays.remove(dayIndex)
                                } else {
                                    selectedDays.insert(dayIndex)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, DesignConstants.largeSpacing)
            }
            
            Spacer()
        }
    }
}

struct DayButton: View {
    let day: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(day)
                .font(DesignConstants.bodyFont)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : DesignConstants.primaryColor)
                .frame(width: 40, height: 40)
                .background(isSelected ? DesignConstants.primaryColor : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignConstants.smallCornerRadius)
                        .stroke(DesignConstants.primaryColor, lineWidth: 2)
                )
                .cornerRadius(DesignConstants.smallCornerRadius)
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

// MARK: - Page 3: Reminder
struct ReminderPage: View {
    @Binding var reminderEnabled: Bool
    @Binding var reminderTime: Date
    
    var body: some View {
        VStack(spacing: DesignConstants.extraLargeSpacing) {
            Spacer()
            
            VStack(spacing: DesignConstants.largeSpacing) {
                Text("AT")
                    .font(DesignConstants.subtitleFont)
                    .foregroundColor(DesignConstants.textColor)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: DesignConstants.mediumSpacing) {
                    Toggle("Set Reminder", isOn: $reminderEnabled)
                        .font(DesignConstants.bodyFont)
                        .foregroundColor(DesignConstants.textColor)
                        .padding(.horizontal, DesignConstants.largeSpacing)
                    
                    if reminderEnabled {
                        DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                            .padding(.horizontal, DesignConstants.largeSpacing)
                            .transition(.opacity.combined(with: .scale))
                    }
                }
                .padding(DesignConstants.largeSpacing)
                .background(Color.white)
                .cornerRadius(DesignConstants.mediumCornerRadius)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            .padding(.horizontal, DesignConstants.largeSpacing)
            
            Spacer()
        }
        .animation(.easeInOut(duration: DesignConstants.shortAnimation), value: reminderEnabled)
    }
}

#Preview {
    GoalEntryFlowView()
} 
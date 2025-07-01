import SwiftUI
import Combine

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
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color(red: 0.93, green: 0.93, blue: 0.93).ignoresSafeArea()
            
            if currentPage == 0 {
                // Goal Entry Page
                VStack {
                    // Progress dots
                    HStack(spacing: 12) {
                        ForEach(0..<3) { index in
                            Capsule()
                                .fill(index == currentPage ? Color.black : Color.gray.opacity(0.6))
                                .frame(width: index == currentPage ? 44 : 10, height: 10)
                                .animation(.easeInOut(duration: 0.35), value: currentPage)
                                .cornerRadius(100)
                        }
                    }
                    .padding(.top, 40)
                    // Header u dva reda
                    Text("MY BIGGEST\nGOAL IS TO")
                        .font(.custom("Thunder-BoldLC", size: 54))
                        .foregroundColor(Color(red: 0.047, green: 0.047, blue: 0.047))
                        .multilineTextAlignment(.center)
                        .padding(.top, 66) // increased by 30px
                        .padding(.bottom, 32)
                    Spacer()
                    // Input polje centrirano između headera i dugmeta
                    AnimatedTypewriterTextField(goalText: $goalText)
                        .padding(.top, -15)
                    Spacer()
                    // Continue dugme
                    Button(action: handleContinue) {
                        Text("Continue")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(goalText.isEmpty ? Color.black.opacity(0.4) : .white)
                            .frame(width: 200, height: 62)
                            .background(goalText.isEmpty ? Color.black.opacity(0.05) : Color.black)
                            .cornerRadius(100)
                    }
                    .disabled(goalText.isEmpty)
                    .padding(.bottom, 24)
                }
                .padding(.bottom, keyboardHeight)
                .animation(.easeOut(duration: 0.25), value: keyboardHeight)
            } else if currentPage == 1 {
                // Day Selection Page
                VStack {
                    // Progress dots
                    HStack(spacing: 12) {
                        ForEach(0..<3) { index in
                            Capsule()
                                .fill(index == currentPage ? Color.black : Color.gray.opacity(0.6))
                                .frame(width: index == currentPage ? 44 : 10, height: 10)
                                .animation(.easeInOut(duration: 0.35), value: currentPage)
                                .cornerRadius(100)
                        }
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // Header
                    Text("AND I NEED TO WORK ON IT")
                        .font(.custom("Thunder-BoldLC", size: 54))
                        .foregroundColor(Color(red: 0.047, green: 0.047, blue: 0.047))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Day selection
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
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 46)
                    
                    // Select frequency text
                    Text("Select frequency")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.047, green: 0.047, blue: 0.047))
                        .padding(.top, 14)
                    
                    Spacer()
                    
                    // Continue button
                    Button(action: handleContinue) {
                        Text("Continue")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(selectedDays.isEmpty ? Color.black.opacity(0.4) : .white)
                            .frame(width: 200, height: 62)
                            .background(selectedDays.isEmpty ? Color.black.opacity(0.05) : Color.black)
                            .cornerRadius(100)
                    }
                    .disabled(selectedDays.isEmpty)
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear {
            subscribeToKeyboardNotifications()
        }
        .onDisappear {
            unsubscribeFromKeyboardNotifications()
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
            if let nsNumbers = goal.selectedDays as? [NSNumber] {
                selectedDays = Set(nsNumbers.map { $0.intValue })
            } else {
                selectedDays = []
            }
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
        goal.selectedDays = Array(selectedDays).map { NSNumber(value: $0) } as NSArray
        goal.reminderEnabled = reminderEnabled
        goal.reminderTime = reminderEnabled ? reminderTime : nil
        
        coreDataManager.save()
        
        // Navigate to main tracking screen
        appState.navigateTo(.main)
    }
    
    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notif in
            if let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = frame.height - (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)
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

struct AnimatedTypewriterTextField: View {
    @Binding var goalText: String
    @State private var isEditing = false
    @FocusState private var isFocused: Bool
    @State private var placeholderIndex = 0
    @State private var displayedPlaceholder = ""
    @State private var typing = true
    @State private var charIndex = 0
    @State private var erase = false
    @State private var textWidth: CGFloat = 215
    let placeholders = [
        "Workout",
        "Read a Book",
        "Learn Spanish",
        "Cook More",
        "Meditate",
        "Walk Outside",
        "Sleep Early"
    ]
    let minWidth: CGFloat = 215
    let height: CGFloat = 52
    let placeholderFont = Font.custom("Inter_24pt-SemiBold", size: 16)
    let typingSpeed = 0.12
    let pauseDuration = 1.2
    let horizontalMargin: CGFloat = 18
    
    var body: some View {
        GeometryReader { geo in
            let maxWidth = geo.size.width - 2 * horizontalMargin
            ZStack(alignment: .center) {
                // Pozadina i border
                RoundedRectangle(cornerRadius: 38)
                    .fill(Color(red: 0.894, green: 0.894, blue: 0.894))
                    .frame(width: inputWidth(maxWidth: maxWidth), height: height)
                    .overlay(
                        RoundedRectangle(cornerRadius: 38)
                            .stroke(Color(red: 0.46, green: 0.46, blue: 0.46).opacity(0.28), lineWidth: 1)
                    )
                // Invisible text for width calculation
                Text(goalText.isEmpty ? displayedPlaceholder : goalText)
                    .font(goalText.isEmpty ? placeholderFont : .custom("Inter_24pt-SemiBold", size: 24))
                    .background(GeometryReader { proxy in
                        Color.clear.onAppear { textWidth = max(proxy.size.width + 40, minWidth) }
                            .onChange(of: goalText) { _ in textWidth = max(proxy.size.width + 40, minWidth) }
                    })
                    .opacity(0)
                // TextField
                TextField("", text: $goalText, onEditingChanged: { editing in
                    isEditing = editing
                })
                .focused($isFocused)
                .frame(width: inputWidth(maxWidth: maxWidth), height: height)
                .font(.custom("Inter_24pt-SemiBold", size: 24))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                // Typewriter placeholder
                if goalText.isEmpty && !isEditing {
                    Text(displayedPlaceholder)
                        .font(placeholderFont)
                        .foregroundColor(Color.gray.opacity(0.6))
                        .frame(width: inputWidth(maxWidth: maxWidth), height: height)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
            .contentShape(Rectangle()) // Make entire area tappable
            .onTapGesture {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isFocused = true
                }
            }
            .onAppear {
                startTypewriter()
            }
            .onChange(of: goalText) { newValue in
                if !newValue.isEmpty {
                    isFocused = true
                }
            }
        }
        .frame(height: height)
    }
    
    private func inputWidth(maxWidth: CGFloat) -> CGFloat {
        min(max(textWidth, minWidth), maxWidth)
    }
    
    private func startTypewriter() {
        displayedPlaceholder = ""
        typing = true
        charIndex = 0
        erase = false
        typeNextChar()
    }
    private func typeNextChar() {
        guard goalText.isEmpty else { return }
        let currentPlaceholder = placeholders[placeholderIndex]
        if typing {
            if charIndex < currentPlaceholder.count {
                let nextChar = currentPlaceholder[currentPlaceholder.index(currentPlaceholder.startIndex, offsetBy: charIndex)]
                displayedPlaceholder.append(nextChar)
                charIndex += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + typingSpeed) {
                    typeNextChar()
                }
            } else {
                typing = false
                DispatchQueue.main.asyncAfter(deadline: .now() + pauseDuration) {
                    erase = true
                    eraseLastChar()
                }
            }
        }
    }
    private func eraseLastChar() {
        guard goalText.isEmpty else { return }
        if erase && !displayedPlaceholder.isEmpty {
            displayedPlaceholder.removeLast()
            DispatchQueue.main.asyncAfter(deadline: .now() + typingSpeed/2) {
                eraseLastChar()
            }
        } else if erase {
            erase = false
            charIndex = 0
            placeholderIndex = (placeholderIndex + 1) % placeholders.count
            typing = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                typeNextChar()
            }
        }
    }
}

struct DaySelectionButton: View {
    let day: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(day)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : Color(red: 0.56, green: 0.56, blue: 0.56))
                .frame(width: 48, height: 48)
                .background(
                    isSelected ? Color.black : Color(red: 0.9, green: 0.9, blue: 0.9)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 106)
                        .stroke(
                            isSelected ? Color.clear : Color(red: 0.79, green: 0.79, blue: 0.79),
                            lineWidth: 1
                        )
                )
                .cornerRadius(106)
        }
        .scaleEffect(isSelected ? 1.0 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    GoalEntryFlowView()
} 
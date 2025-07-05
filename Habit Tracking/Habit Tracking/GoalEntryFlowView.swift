import SwiftUI
import Combine
import UIKit

struct GoalEntryFlowView: View {
    @StateObject private var appState = AppStateManager.shared
    @StateObject private var coreDataManager = CoreDataManager.shared
    
    @State private var currentPage = 0
    @State private var goalText = ""
    @State private var selectedDays: Set<Int> = [0, 1, 2, 3, 4] // Pre-select MTWTF
    @State private var reminderEnabled = false
    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    @State private var isEditing = false
    @State private var existingGoal: Goal?
    @State private var keyboardHeight: CGFloat = 0
    @State private var slideDirection: SlideDirection = .forward
    @State private var headerTextBottom: CGFloat = 0
    @FocusState private var isTextFieldFocused: Bool
    
    enum SlideDirection {
        case forward, backward
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                progressDotsView
                headerView
                stepContentView
                Spacer() // Da popuni prostor
            }
            // Continue dugme na dnu
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
            subscribeToKeyboardNotifications()
        }
        .onDisappear {
            unsubscribeFromKeyboardNotifications()
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private var progressDotsView: some View {
        HStack(spacing: 12) {
            ForEach(0..<3) { index in
                ProgressDot(
                    isActive: index == currentPage,
                    isCompleted: index < currentPage,
                    index: index
                )
            }
        }
        .padding(.top, 40)
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
            } else if currentPage == 1 {
                Text("AND I NEED TO\nWORK ON IT")
                    .font(.custom("Thunder-BoldLC", size: 54))
                    .foregroundColor(Color(red: 0.047, green: 0.047, blue: 0.047))
                    .multilineTextAlignment(.center)
            } else {
                VStack(spacing: 0) {
                Text("AT")
                    .font(.custom("Thunder-BoldLC", size: 54))
                    .foregroundColor(Color(red: 0.047, green: 0.047, blue: 0.047))
                    .multilineTextAlignment(.center)
                    Text(" ") // prazna linija za poravnanje
                        .font(.custom("Thunder-BoldLC", size: 54))
                        .foregroundColor(.clear)
                }
            }
        }
        .padding(.top, 66)
        .padding(.bottom, 32)
    }
    
    private var stepContentView: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                step1View(width: geo.size.width, height: geo.size.height)
                step2View(width: geo.size.width, height: geo.size.height)
                step3View(width: geo.size.width, height: geo.size.height)
            }
            .frame(width: geo.size.width * 3, alignment: .leading)
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
                            }
                        )
                    }
                }
                .padding(.horizontal, 46)
                Text("Select frequency")
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
            }
            .frame(width: width)
            .position(x: width / 2, y: centerY)
            .animation(.easeInOut(duration: 0.3), value: keyboardHeight)
        }
        .frame(width: width)
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
                selectedDays = [0, 1, 2, 3, 4] // Default to MTWTF if no existing data
            }
            reminderEnabled = goal.reminderEnabled
            reminderTime = goal.reminderTime ?? Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
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
            if isEditing {
                updateGoal()
            } else {
                createGoal()
            }
            appState.navigateTo(.main)
        }
    }
    
    private func handleBack() {
        if currentPage > 0 {
            slideDirection = .backward
            withAnimation(.easeInOut(duration: 0.6)) {
                currentPage -= 1
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
    @FocusState private var isFocusedInternal: Bool
    var isFocused: FocusState<Bool>.Binding? = nil
    @State private var isEditing = false
    @State private var placeholderIndex = 0
    @State private var displayedPlaceholder = ""
    @State private var typing = true
    @State private var charIndex = 0
    @State private var erase = false

    let placeholders = [
        "Workout", "Read a Book", "Learn Spanish", "Cook More", "Meditate", "Walk Outside", "Sleep Early"
    ]
    let width: CGFloat = 215
    let height: CGFloat = 52
    let placeholderFont = Font.custom("Inter_24pt-SemiBold", size: 16)
    let typingSpeed = 0.12
    let pauseDuration = 1.2

    var body: some View {
        GeometryReader { geo in
            let maxWidth = geo.size.width - 36
            let textWidth = textWidthFor(goalText)
            let dynamicWidth = min(max(width, textWidth + 32), maxWidth)
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 38)
                .fill(Color(red: 0.894, green: 0.894, blue: 0.894))
                    .frame(width: dynamicWidth, height: height)
                .overlay(
                    RoundedRectangle(cornerRadius: 38)
                        .stroke(Color(red: 0.46, green: 0.46, blue: 0.46).opacity(0.28), lineWidth: 1)
                )
            TextField("", text: $goalText, onEditingChanged: { editing in
                isEditing = editing
            })
            .focused(isFocused ?? $isFocusedInternal)
            .textFieldStyle(PlainTextFieldStyle())
                .frame(width: dynamicWidth, height: height)
            .font(placeholderFont)
            .tracking(-0.16)
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
                .padding(.horizontal, 18)
            .keyboardType(.default)
            .submitLabel(.done)
            if goalText.isEmpty && !isEditing {
                Text(displayedPlaceholder)
                    .font(placeholderFont)
                    .tracking(-0.16)
                    .foregroundColor(Color.gray.opacity(0.6))
                        .frame(width: dynamicWidth, height: height)
                    .multilineTextAlignment(.center)
                    .allowsHitTesting(false)
            }
        }
            .frame(width: geo.size.width, height: height)
        .contentShape(Rectangle())
        .onTapGesture {
            (isFocused ?? $isFocusedInternal).wrappedValue = true
        }
        .onAppear {
            startTypewriter()
        }
        .onChange(of: goalText) { newValue in
            if !newValue.isEmpty {
                (isFocused ?? $isFocusedInternal).wrappedValue = true
            }
        }
        }
        .frame(height: height)
    }

    private func textWidthFor(_ text: String) -> CGFloat {
        let font = UIFont(name: "Inter_24pt-SemiBold", size: 16) ?? UIFont.systemFont(ofSize: 16)
        let attributes = [NSAttributedString.Key.font: font]
        let size = (text as NSString).size(withAttributes: attributes)
        return size.width
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

struct ProgressDot: View {
    let isActive: Bool
    let isCompleted: Bool
    let index: Int
    
    var body: some View {
        Capsule()
            .fill(dotColor)
            .frame(width: dotWidth, height: 10)
            .animation(.easeInOut(duration: 0.6), value: dotWidth)
            .animation(.easeInOut(duration: 0.6), value: dotColor)
            .cornerRadius(100)
    }
    
    private var dotColor: Color {
        if isActive {
            return Color.black
        } else if isCompleted {
            return Color.black
        } else {
            return Color.gray.opacity(0.6)
        }
    }
    
    private var dotWidth: CGFloat {
        if isActive {
            return 44
        } else {
            return 10
        }
    }
}

// Custom transition za header
struct FastRemoveMove: ViewModifier {
    let direction: GoalEntryFlowView.SlideDirection
    let isIdentity: Bool
    func body(content: Content) -> some View {
        content
            .offset(x: isIdentity ? 0 : (direction == .forward ? -160 : 160))
            .opacity(isIdentity ? 1 : 0)
            .animation(.easeInOut(duration: isIdentity ? 0 : 0.18), value: direction)
    }
}

extension AnyTransition {
    static func fastRemoveMove(direction: GoalEntryFlowView.SlideDirection) -> AnyTransition {
        .asymmetric(
            insertion: .move(edge: direction == .forward ? .trailing : .leading),
            removal: .modifier(
                active: FastRemoveMove(direction: direction, isIdentity: false),
                identity: FastRemoveMove(direction: direction, isIdentity: true)
            )
        )
    }
}

// ReminderInputView - input 180pt, centriran, switch levo, tracking -0.16
struct ReminderInputView: View {
    @Binding var reminderEnabled: Bool
    @Binding var reminderTime: Date
    @State private var showPicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Spacer() // uklonjen da bi poravnanje bilo isto kao u ostalim koracima
            ZStack {
                // Input tačno centriran
                Button(action: {
                    if !reminderEnabled {
                        reminderEnabled = true
                    }
                    showPicker = true
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 38)
                            .fill(Color(red: 0.894, green: 0.894, blue: 0.894))
                            .frame(width: 180, height: 52)
                            .overlay(
                                RoundedRectangle(cornerRadius: 38)
                                    .stroke(Color(red: 0.46, green: 0.46, blue: 0.46).opacity(0.28), lineWidth: 1)
                            )
                        Text(timeString)
                            .font(.custom("Inter_24pt-SemiBold", size: 16))
                            .tracking(-0.16)
                            .foregroundColor(reminderEnabled ? Color(red: 0.047, green: 0.047, blue: 0.047) : Color.gray.opacity(0.6))
                    }
                }
                .disabled(false)
                .frame(width: 180, height: 52)
                .frame(maxWidth: .infinity, alignment: .center)
                .zIndex(1)
                // Switch overlay, 10pt desno od inputa
                CustomSwitch(isOn: $reminderEnabled)
                    .frame(width: 74, height: 40)
                    .offset(x: (180/2) + 10 + (74/2))
                    .zIndex(2)
            }
            .frame(height: 52)
            // Tekst 14pt ispod inputa
            Text("Set Reminder")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(red: 0.047, green: 0.047, blue: 0.047).opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.top, 14)
            // Spacer(minLength: 0) // uklonjen da bi poravnanje bilo isto kao u ostalim koracima
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            // Default state ON
            reminderEnabled = true
        }
        // Sheet za time picker
        .sheet(isPresented: $showPicker) {
            VStack {
                DatePicker("Select Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .environment(\ .locale, Locale(identifier: "en_US_POSIX"))
                Button("Done") { showPicker = false }
                    .padding()
            }
            .presentationDetents([.height(300)])
            .background(
                Color(.systemBackground)
                    .clipShape(RoundedCorner(radius: 200, corners: [.topLeft, .topRight]))
                    .padding(.top, -160)
            )
        }
    }
    var timeString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: reminderTime)
    }
}

// Za overlay centriranje (nije obavezno koristiti, ali ostavljeno za preciznost)
struct InputCenteringKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct CustomSwitch: View {
    @Binding var isOn: Bool
    var body: some View {
        Button(action: { isOn.toggle() }) {
            ZStack(alignment: isOn ? .trailing : .leading) {
                RoundedRectangle(cornerRadius: 40)
                    .fill(isOn ? Color.black : Color(red: 0.828, green: 0.828, blue: 0.828))
                    .frame(width: 74, height: 40)
                RoundedRectangle(cornerRadius: 40)
                    .fill(Color.white)
                    .frame(width: 44, height: 30)
                    .padding(.horizontal, 5)
                    .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
            }
            .animation(.easeInOut(duration: 0.18), value: isOn)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// PreferenceKey za header bottom
struct HeaderBottomKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// Reader za header bottom
struct PreferenceReader: View {
    @Binding var headerTextBottom: CGFloat
    var body: some View {
        GeometryReader { proxy in
            Color.clear.preference(key: HeaderBottomKey.self, value: proxy.frame(in: .global).maxY)
        }
        .onPreferenceChange(HeaderBottomKey.self) { value in
            headerTextBottom = value
        }
    }
}

struct UIKitTextFieldWrapper: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFirstResponder: Bool
    var font: UIFont?
    var textColor: UIColor = .black
    var textAlignment: NSTextAlignment = .center
    var onEditingChanged: ((Bool) -> Void)? = nil

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.font = font
        textField.textColor = textColor
        textField.textAlignment = textAlignment
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textChanged), for: .editingChanged)
        textField.backgroundColor = UIColor(red: 0.894, green: 0.894, blue: 0.894, alpha: 1)
        textField.layer.cornerRadius = 38
        textField.layer.borderColor = UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 0.28).cgColor
        textField.layer.borderWidth = 1
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.font = font
        uiView.textColor = textColor
        uiView.textAlignment = textAlignment
        if isFirstResponder && !uiView.isFirstResponder {
            print("🟢 Calling becomeFirstResponder on UITextField")
            uiView.becomeFirstResponder()
        } else if !isFirstResponder && uiView.isFirstResponder {
            print("🟡 Calling resignFirstResponder on UITextField")
            uiView.resignFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: UIKitTextFieldWrapper
        init(_ parent: UIKitTextFieldWrapper) {
            self.parent = parent
        }
        @objc func textChanged(_ sender: UITextField) {
            parent.text = sender.text ?? ""
        }
        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.isFirstResponder = true
            parent.onEditingChanged?(true)
        }
        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.isFirstResponder = false
            parent.onEditingChanged?(false)
        }
    }
}

#Preview {
    GoalEntryFlowView()
} 
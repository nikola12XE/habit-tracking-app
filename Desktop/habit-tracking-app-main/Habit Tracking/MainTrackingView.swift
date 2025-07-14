import SwiftUI

struct MainTrackingView: View {
    @StateObject private var appState = AppStateManager.shared
    @StateObject private var coreDataManager = CoreDataManager.shared
    @State private var currentGoal: Goal?
    @State private var progressDays: [ProgressDay] = []
    @State private var currentMonth = Date()
    @State private var showProfile = false
    @State private var showMilestonePopup = false
    @State private var selectedProgressDay: ProgressDay?
    @State private var fallingFlowers: [FallingFlower] = []
    @State private var showAddMilestoneButton = false
    @State private var showNoGoalAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignConstants.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: DesignConstants.largeSpacing) {
                    // Header
                    headerView
                    
                    // Monthly grid
                    monthlyGridView
                    
                    Spacer()
                    
                    // Add Milestone button
                    if showAddMilestoneButton {
                        addMilestoneButton
                    }
                }
                .padding(.horizontal, DesignConstants.largeSpacing)
                
                // Falling flowers overlay
                ForEach(fallingFlowers) { flower in
                    FallingFlowerView(flower: flower)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loadData()
            }
            .onReceive(appState.$currentScreen) { screen in
                if screen == .main {
                    loadData()
                }
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            .sheet(isPresented: $showMilestonePopup) {
                if let selectedProgressDay = selectedProgressDay {
                    MilestonePopupView(progressDay: selectedProgressDay)
                }
            }
            .alert("No Goal Set", isPresented: $showNoGoalAlert) {
                Button("Set Goal") {
                    appState.navigateTo(.goalEntry)
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("You need to set a goal first to start tracking your progress.")
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignConstants.smallSpacing) {
                Text("Your Progress on")
                    .font(DesignConstants.captionFont)
                    .foregroundColor(DesignConstants.textColor.opacity(0.7))
                
                if let goal = currentGoal {
                    Text(goal.goalText ?? "Loading...")
                        .font(DesignConstants.subtitleFont)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignConstants.textColor)
                        .lineLimit(2)
                } else {
                    Text("No goal set")
                        .font(DesignConstants.subtitleFont)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignConstants.textColor.opacity(0.7))
                }
            }
            
            Spacer()
            
            Button(action: { 
                showProfile = true
            }) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(DesignConstants.primaryColor)
            }
        }
        .padding(.top, DesignConstants.largeSpacing)
    }
    
    private var monthlyGridView: some View {
        VStack(spacing: DesignConstants.mediumSpacing) {
            // Month navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(DesignConstants.primaryColor)
                }
                
                Spacer()
                
                VStack(spacing: DesignConstants.smallSpacing) {
                    Text(monthYearString)
                        .font(DesignConstants.subtitleFont)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignConstants.textColor)
                    
                    // Show available days info
                    if let goal = currentGoal, let selectedDays = goal.selectedDays, !selectedDays.isEmpty {
                        let availableDays = countAvailableDaysInMonth()
                        Text("\(availableDays) days to work on")
                            .font(DesignConstants.captionFont)
                            .foregroundColor(DesignConstants.textColor.opacity(0.7))
                    }
                }
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(DesignConstants.primaryColor)
                }
            }
            
            // Progress grid (not calendar)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: DesignConstants.smallSpacing) {
                ForEach(Array(progressDaysForMonth.enumerated()), id: \.offset) { index, progressData in
                    ProgressDayCellView(
                        dayNumber: index + 1,
                        progressDay: progressData.progressDay,
                        date: progressData.date,
                        onTap: { progressDay in
                            handleDayTap(progressDay: progressDay, date: progressData.date)
                        }
                    )
                }
            }
        }
        .padding(DesignConstants.largeSpacing)
        .background(Color.white)
        .cornerRadius(DesignConstants.largeCornerRadius)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var addMilestoneButton: some View {
        Button("Add Milestone") {
            // This will be handled by the day tap
        }
        .buttonStyle(PrimaryButtonStyle())
        .transition(.opacity.combined(with: .scale))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeOut(duration: DesignConstants.shortAnimation)) {
                    showAddMilestoneButton = false
                }
            }
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var progressDaysForMonth: [(progressDay: ProgressDay?, date: Date)] {
        guard let goal = currentGoal, let selectedDays = goal.selectedDays else {
            return []
        }
        
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 30
        
        var progressDays: [(ProgressDay?, Date)] = []
        
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                if shouldShowDay(date) {
                    let progressDay = progressDayForDate(date)
                    progressDays.append((progressDay, date))
                }
            }
        }
        
        return progressDays
    }
    
    private func shouldShowDay(_ date: Date) -> Bool {
        guard let goal = currentGoal, let selectedDays = goal.selectedDays else {
            return true // Show all days if no goal or no selected days
        }
        
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let adjustedWeekday = (weekday + 5) % 7 // Convert to Monday = 0, Sunday = 6
        
        return selectedDays.contains(adjustedWeekday)
    }
    
    private func loadData() {
        let goals = coreDataManager.fetchGoals()
        currentGoal = goals.first
        
        if let goal = currentGoal {
            progressDays = coreDataManager.fetchProgressDays(for: goal)
        } else {
            // No goal set, show alert
            showNoGoalAlert = true
        }
    }
    
    private func progressDayForDate(_ date: Date) -> ProgressDay? {
        return progressDays.first { progressDay in
            Calendar.current.isDate(progressDay.date ?? Date.distantPast, inSameDayAs: date)
        }
    }
    
    private func handleDayTap(progressDay: ProgressDay?, date: Date) {
        guard let goal = currentGoal else { 
            showNoGoalAlert = true
            return 
        }
        
        if let progressDay = progressDay {
            print("[DEBUG] handleDayTap: progressDay već postoji za datum: \(date), flowerType: \(progressDay.flowerType ?? "nil")")
            // Day already has progress - show milestone popup
            selectedProgressDay = progressDay
            showMilestonePopup = true
        } else {
            // Dodaj random flower index od 1 do 19 kao string
            let randomFlowerIndex = Int.random(in: 1...19)
            let flowerType = String(randomFlowerIndex)
            print("[DEBUG] handleDayTap: kreiram novi progressDay za datum: \(date), flowerType: \(flowerType)")
            // Kreiraj novi progress day sa flowerType
            let newProgressDay = coreDataManager.createProgressDay(for: goal, date: date, flowerType: flowerType)
            progressDays.append(newProgressDay)
            // Animate flower growth
            animateFlowerGrowth(at: date)
            // Show add milestone button
            withAnimation(.easeIn(duration: DesignConstants.shortAnimation)) {
                showAddMilestoneButton = true
            }
        }
    }
    
    private func animateFlowerGrowth(at date: Date) {
        // Create falling flowers
        for _ in 0..<5 {
            let flower = FallingFlower(
                id: UUID(),
                type: DesignConstants.randomFlowerType(),
                startPosition: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: -50
                ),
                endPosition: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: UIScreen.main.bounds.height + 50
                )
            )
            fallingFlowers.append(flower)
        }
        
        // Remove flowers after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            fallingFlowers.removeAll()
        }
    }
    
    private func previousMonth() {
        withAnimation {
            currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation {
            currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func countAvailableDaysInMonth() -> Int {
        return progressDaysForMonth.count
    }
}

struct ProgressDayCellView: View {
    let dayNumber: Int
    let progressDay: ProgressDay?
    let date: Date
    let onTap: (ProgressDay?) -> Void
    
    @State private var isPressed = false
    @State private var showFlower = false
    @State private var hideNumber = false
    
    var body: some View {
        Button(action: {
            print("[DEBUG] Button tap: dayNumber=\(dayNumber), date=\(date), progressDay.completed=\(progressDay?.completed ?? false), flowerType=\(progressDay?.flowerType ?? "nil")")
            if progressDay == nil {
                // Pokreni animaciju
                withAnimation(.easeInOut(duration: 0.25)) {
                    hideNumber = true
                }
                // Prikaži cvet sa scale animacijom
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        showFlower = true
                    }
                }
                // Pozovi onTap posle animacije
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onTap(progressDay)
                }
            } else {
                onTap(progressDay)
            }
        }) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(DesignConstants.primaryColor, lineWidth: 2)
                    )
                if let progressDay = progressDay, progressDay.completed {
                    if progressDay.milestoneText != nil {
                        // Trophy for milestone
                        Image(systemName: "trophy.fill")
                            .font(.title2)
                            .foregroundColor(DesignConstants.accentColor)
                    } else {
                        // Prikaz PNG cveta iz Flowers foldera
                        if let flowerType = progressDay.flowerType, let _ = Int(flowerType) {
                            let imageName = "Flowers/\(flowerType)"
                            let uiImage = UIImage(named: imageName)
                            print("[DEBUG] ProgressDayCellView: Pokušavam da učitam sliku '", imageName, "', UIImage je nil? ", uiImage == nil)
                            if let uiImage = uiImage {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 90, height: 90)
                                    .scaleEffect(showFlower ? 1.0 : 0.7)
                                    .opacity(showFlower ? 1.0 : 0.0)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showFlower)
                                    .offset(y: 0)
                            } else {
                                Text("NO IMG")
                                    .foregroundColor(.red)
                            }
                        } else {
                            // fallback na stari cvet
                            FlowerView(type: progressDay.flowerType ?? "flower_1")
                                .frame(width: 30, height: 30)
                        }
                    }
                } else {
                    Text("\(dayNumber)")
                        .font(DesignConstants.bodyFont)
                        .fontWeight(.medium)
                        .foregroundColor(DesignConstants.textColor)
                        .scaleEffect(hideNumber ? 0.7 : 1.0)
                        .opacity(hideNumber ? 0.0 : 1.0)
                        .animation(.easeInOut(duration: 0.25), value: hideNumber)
                }
            }
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.easeInOut(duration: DesignConstants.shortAnimation), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onAppear {
            print("[DEBUG] onAppear: dayNumber=\(dayNumber), date=\(date), progressDay.completed=\(progressDay?.completed ?? false), flowerType=\(progressDay?.flowerType ?? "nil")")
            if let progressDay = progressDay, progressDay.completed, let flowerType = progressDay.flowerType, Int(flowerType) != nil {
                showFlower = true
                hideNumber = true
            }
        }
    }
    
    private var backgroundColor: Color {
        if let progressDay = progressDay, progressDay.completed {
            return DesignConstants.successColor.opacity(0.2)
        } else {
            return Color.white
        }
    }
}

struct DayCellView: View {
    let date: Date
    let progressDay: ProgressDay?
    let onTap: (ProgressDay?) -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            onTap(progressDay)
        }) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(DesignConstants.primaryColor, lineWidth: 2)
                    )
                
                if let progressDay = progressDay, progressDay.completed {
                    if progressDay.milestoneText != nil {
                        // Trophy for milestone
                        Image(systemName: "trophy.fill")
                            .font(.title2)
                            .foregroundColor(DesignConstants.accentColor)
                    } else {
                        // Flower
                        FlowerView(type: progressDay.flowerType ?? "flower_1")
                            .frame(width: 30, height: 30)
                    }
                } else {
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(DesignConstants.bodyFont)
                        .fontWeight(.medium)
                        .foregroundColor(DesignConstants.textColor)
                }
            }
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.easeInOut(duration: DesignConstants.shortAnimation), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    private var backgroundColor: Color {
        if let progressDay = progressDay, progressDay.completed {
            return DesignConstants.successColor.opacity(0.2)
        } else {
            return Color.white
        }
    }
}

struct FallingFlower: Identifiable {
    let id: UUID
    let type: String
    let startPosition: CGPoint
    let endPosition: CGPoint
}

struct FallingFlowerView: View {
    let flower: FallingFlower
    @State private var position: CGPoint
    
    init(flower: FallingFlower) {
        self.flower = flower
        self._position = State(initialValue: flower.startPosition)
    }
    
    var body: some View {
        FlowerView(type: flower.type)
            .frame(width: 40, height: 40)
            .position(position)
            .blur(radius: 2)
            .opacity(0.7)
            .onAppear {
                withAnimation(.easeIn(duration: 3)) {
                    position = flower.endPosition
                }
            }
    }
}

// MARK: - FlowerView za prikaz PNG cvetova
struct FlowerView: View {
    let type: String

    var imageName: String {
        switch type.lowercased() {
        case "blue": return "SplashFlowerBlue"
        case "red": return "SplashFlowerRed"
        default: return "SplashFlowerBlue" // fallback
        }
    }

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
    }
}

#Preview {
    MainTrackingView()
} 
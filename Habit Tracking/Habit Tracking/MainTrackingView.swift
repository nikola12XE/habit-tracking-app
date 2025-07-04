import SwiftUI

struct MainTrackingView: View {
    @StateObject private var appState = AppStateManager.shared
    @StateObject private var coreDataManager = CoreDataManager.shared
    @State private var currentGoal: Goal? = nil
    @State private var progressDays: [ProgressDay] = []
    @State private var currentMonth = Date()
    @State private var showProfile = false
    @State private var showMilestonePopup = false
    @State private var selectedProgressDay: ProgressDay?
    @State private var fallingFlowers: [FallingFlower] = []
    @State private var showAddMilestoneButton = false
    @State private var showNoGoalAlert = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer().frame(height: 140)
                // HEADER
                ZStack(alignment: .top) {
                    Color.black
                        .frame(height: 260)
                        .clipShape(RoundedCorner(radius: 40, corners: [.bottomLeft, .bottomRight]))
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Your Progress on")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.top, 140)
                            .padding(.leading, 36)
                        HStack(alignment: .bottom, spacing: 16) {
                            Text(currentGoal?.goalText?.uppercased() ?? "GROW PORTFOLIO")
                                .font(Font.custom("Thunder-BoldLC", size: 75))
                                .foregroundColor(.white)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                                .alignmentGuide(.top) { d in d[.top] }
                            Spacer()
                            Button(action: { showProfile = true }) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0.85, green: 0.85, blue: 0.85))
                                        .frame(width: 48, height: 48)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 5)
                                        )
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                                }
                            }
                            .padding(.trailing, 24)
                            .padding(.bottom, 10)
                        }
                        .padding(.leading, 36)
                        .padding(.trailing, 0)
                        Spacer().frame(height: 24)
                    }
                }
                .frame(height: 260)
                .sheet(isPresented: $showProfile) {
                    ProfileView()
                }
                // KARTICA SA KALENDAROM
                ZStack {
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .fill(Color(red: 0.93, green: 0.93, blue: 0.93))
                        .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
                    VStack(spacing: 50) {
                        // MAJ 2025
                        VStack(spacing: 0) {
                            HStack(spacing: 12) {
                                Spacer()
                                Text("MAY")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                Rectangle()
                                    .fill(Color(red: 0.9, green: 0.9, blue: 0.9))
                                    .frame(width: 1, height: 16)
                                Text("2025")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(.top, 32)
                            .padding(.bottom, 12)
                            CalendarGridView(days: ["06","06","07","06","07","06","06","07","06","07","06","16","17","06","07","06","23","24","06","07","06","23","31"]) // Primeri dana
                        }
                        Divider()
                            .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                        // JUN 2025
                        VStack(spacing: 0) {
                            HStack(spacing: 12) {
                                Spacer()
                                Text("JUN")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                Rectangle()
                                    .fill(Color(red: 0.9, green: 0.9, blue: 0.9))
                                    .frame(width: 1, height: 16)
                                Text("2025")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(.top, 32)
                            .padding(.bottom, 12)
                            CalendarGridView(days: ["06","06","07","06","07","06","07","06","07","06","07","13","14","06","07","06","07","06","07","06","07","06","07","06","07","06","07","06","07","06","07","06","07","06","07","06"]) // Primeri dana
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 0)
                    .padding(.bottom, 24)
                }
                .padding(.top, 24)
                .padding(.horizontal, 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        guard let goal = currentGoal,
              let nsNumbers = goal.selectedDays as? [NSNumber] else {
            return true // Show all days if no goal or no selected days
        }
        let selectedDays = nsNumbers.map { $0.intValue }
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
            // Day already has progress - show milestone popup
            selectedProgressDay = progressDay
            showMilestonePopup = true
        } else {
            // Create new progress day
            let newProgressDay = coreDataManager.createProgressDay(for: goal, date: date)
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
                    Text("\(dayNumber)")
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

// MARK: - CalendarGridView
struct CalendarGridView: View {
    let days: [String] // npr. ["06", "07", ...]
    let columns = Array(repeating: GridItem(.fixed(48), spacing: 8), count: 6)
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(days.indices, id: \.self) { idx in
                ZStack {
                    Circle()
                        .fill(Color(red: 0.9, green: 0.9, blue: 0.9))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .stroke(Color(red: 0.79, green: 0.79, blue: 0.79), lineWidth: 1)
                        )
                    Text(days[idx])
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                }
            }
        }
    }
}

// MARK: - RoundedCorner helper
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    MainTrackingView()
} 
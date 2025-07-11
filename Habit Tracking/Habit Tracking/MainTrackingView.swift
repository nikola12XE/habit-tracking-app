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
    @State private var calendarOffsetAnim: CGFloat = 0 // for animation
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Color.black.ignoresSafeArea()
                // HEADER (uvek na mestu, bez animacije)
                ZStack(alignment: .top) {
                    Color.black
                        .clipShape(RoundedCorner(radius: 40, corners: [.bottomLeft, .bottomRight]))
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Your Progress on")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.top, 100 - geometry.safeAreaInsets.top)
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
                            .zIndex(2) // ensure profile button is above calendar
                        }
                        .padding(.leading, 36)
                        .padding(.trailing, 0)
                    }
                }
                .sheet(isPresented: $showProfile) {
                    ProfileView()
                }
                // KALENDAR BLOK - SIVA POZADINA + ScrollView
                ZStack(alignment: .top) {
                    RoundedCorner(radius: 40, corners: [.topLeft, .topRight])
                        .fill(Color(red: 0.93, green: 0.93, blue: 0.93))
                        .ignoresSafeArea(edges: .bottom)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 32) {
                            ForEach(Array(monthsToDisplay.enumerated()), id: \.element) { idx, month in
                                MonthCalendarView(
                                    month: month,
                                    selectedDays: selectedDays,
                                    progressDays: progressDaysForMonth(month),
                                    onDayTap: { date in
                                        handleDayTap(progressDay: progressDayForDate(date), date: date)
                                    },
                                    isFirst: idx == 0
                                )
                                .padding(.top, idx == 0 ? 58 : 0) // Increase top padding for the first month
                            }
                        }
                        .padding(.bottom, 32)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    // Falling flowers overlay
                    ForEach(fallingFlowers) { flower in
                        FallingFlowerView(flower: flower)
                    }
                    // Add Milestone button
                    if showAddMilestoneButton {
                        VStack {
                            Spacer()
                            Button("Add Milestone") {
                                // This will be handled by the day tap
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .transition(.opacity.combined(with: .scale))
                            .padding(.horizontal, DesignConstants.largeSpacing)
                            .padding(.bottom, DesignConstants.largeSpacing)
                        }
                        .transition(.opacity.combined(with: .scale))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation(.easeOut(duration: DesignConstants.shortAnimation)) {
                                    showAddMilestoneButton = false
                                }
                            }
                        }
                    }
                }
                .offset(y: calendarOffsetAnim)
                .zIndex(1)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .onAppear {
                loadData()
                withAnimation(.easeInOut(duration: 0.5)) {
                    calendarOffsetAnim = calendarOffset
                }
            }
            .onChange(of: calendarOffset) { newValue in
                withAnimation(.easeInOut(duration: 0.5)) {
                    calendarOffsetAnim = newValue
                }
            }
        }
        .navigationBarHidden(true)
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
    
    // MARK: - Calendar Logic
    
    // Generiši niz meseci od prvog goala do danas + 12 meseci unapred
    var monthsToDisplay: [Date] {
        guard let firstGoalDate = firstGoalCreatedAt else { return [] }
        let calendar = Calendar.current
        let startOfFirstMonth = calendar.dateInterval(of: .month, for: firstGoalDate)?.start ?? firstGoalDate
        let now = Date()
        let startOfCurrentMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let monthsBack = calendar.dateComponents([.month], from: startOfFirstMonth, to: startOfCurrentMonth).month ?? 0
        let monthsForward = 12 // 12 meseci unapred
        
        return (-(monthsBack)...monthsForward).compactMap { offset in
            calendar.date(byAdding: .month, value: offset, to: startOfCurrentMonth)
        }
    }
    
    // Pronađi datum prvog goala
    var firstGoalCreatedAt: Date? {
        coreDataManager.fetchGoals().first?.createdAt
    }
    
    // Pronađi selektovane dane (npr. [0,1,2,3,4] za MTWTF)
    var selectedDays: [Int] {
        guard let goal = currentGoal, let nsNumbers = goal.selectedDays as? [NSNumber] else { 
            return Array(0...6) // Default: svi dani
        }
        return nsNumbers.map { $0.intValue }
    }
    
    // Generiši sve datume u mesecu koji su selektovani
    func daysForMonth(_ month: Date, selectedDays: [Int]) -> [Date] {
        var result: [Date] = []
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let startOfMonth = calendar.dateInterval(of: .month, for: month)?.start else {
            return result
        }
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                let weekday = (calendar.component(.weekday, from: date) + 5) % 7 // Monday=0, Sunday=6
                if selectedDays.contains(weekday) {
                    result.append(date)
                }
            }
        }
        return result
    }
    
    // Progress days za određeni mesec
    func progressDaysForMonth(_ month: Date) -> [ProgressDay] {
        let days = daysForMonth(month, selectedDays: selectedDays)
        return progressDays.filter { progressDay in
            guard let progressDate = progressDay.date else { return false }
            return days.contains { day in
                Calendar.current.isDate(progressDate, inSameDayAs: day)
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
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
    
    private func nextMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
    
    private func countAvailableDaysInMonth() -> Int {
        return progressDaysForMonth.count
    }
    
    var headerHeight: CGFloat {
        // Approximate header height based on font and paddings
        // Adjust this value if needed for pixel-perfect alignment
        180 // You may need to tweak this value to match your actual header height
    }
    
    // Computed property for dynamic offset
    var calendarOffset: CGFloat {
        let text = currentGoal?.goalText ?? ""
        // Heuristic: if text is long, assume it wraps
        return text.count > 12 ? 240 : 174
    }
}

// MARK: - MonthCalendarView
struct MonthCalendarView: View {
    let month: Date
    let selectedDays: [Int]
    let progressDays: [ProgressDay]
    let onDayTap: (Date) -> Void
    let isFirst: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header: naziv meseca i godina
            HStack(spacing: 12) {
                Spacer()
                Text(monthTitle)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 1, height: 16)
                Text(yearString)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.top, isFirst ? 0 : 32)
            .padding(.bottom, 24) // Increase bottom padding for more space above numbers
            
            // Grid: brojevi od 1 do N za selektovane dane
            let days = daysForMonth(month, selectedDays: selectedDays)
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(54), spacing: 8), count: 6), spacing: 20) {
                ForEach(days.indices, id: \.self) { idx in
                    let date = days[idx]
                    let isToday = Calendar.current.isDateInToday(date)
                    Button(action: { onDayTap(date) }) {
                        ZStack {
                            Circle()
                                .fill(isToday ? Color(hex: "4F9BFF").opacity(0.08) : backgroundColor(for: date))
                                .frame(width: 54, height: 54)
                                .overlay(
                                    Circle()
                                        .stroke(isToday ? Color(hex: "4F9BFF") : Color(red: 0.79, green: 0.79, blue: 0.79), lineWidth: 1)
                                )
                            if let progressDay = progressDayForDate(date), progressDay.completed {
                                if progressDay.milestoneText != nil {
                                    Image(systemName: "trophy.fill")
                                        .font(.title2)
                                        .foregroundColor(DesignConstants.accentColor)
                                } else {
                                    FlowerView(type: progressDay.flowerType ?? "flower_1")
                                        .frame(width: 34, height: 34)
                                }
                            } else {
                                Text("\(idx + 1)")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(isToday ? Color(hex: "4F9BFF") : Color(red: 0.56, green: 0.56, blue: 0.56))
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 24)
        }
    }
    
    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: month).uppercased()
    }
    
    var yearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: month)
    }
    
    func daysForMonth(_ month: Date, selectedDays: [Int]) -> [Date] {
        var result: [Date] = []
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let startOfMonth = calendar.dateInterval(of: .month, for: month)?.start else {
            return result
        }
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                let weekday = (calendar.component(.weekday, from: date) + 5) % 7 // Monday=0, Sunday=6
                if selectedDays.contains(weekday) {
                    result.append(date)
                }
            }
        }
        return result
    }
    
    func progressDayForDate(_ date: Date) -> ProgressDay? {
        return progressDays.first { progressDay in
            Calendar.current.isDate(progressDay.date ?? Date.distantPast, inSameDayAs: date)
        }
    }
    
    func backgroundColor(for date: Date) -> Color {
        if let progressDay = progressDayForDate(date), progressDay.completed {
            return DesignConstants.successColor.opacity(0.2)
        } else {
            return Color(red: 0.9, green: 0.9, blue: 0.9)
        }
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
                position = flower.endPosition
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

// MARK: - RoundedCorner helper
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// Add this helper for hex color:
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    MainTrackingView()
} 
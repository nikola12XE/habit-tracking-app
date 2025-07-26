import SwiftUI
import UIKit // Za vibraciju
import AVFoundation // Za zvuk

struct MainTrackingView: View {
    @StateObject private var appState = AppStateManager.shared
    @StateObject private var coreDataManager = CoreDataManager.shared
    @State private var currentGoal: Goal? = nil
    @State private var userProfile: UserProfile?
    @State private var profileImageData: Data?
    @State private var progressDays: [ProgressDay] = []
    @State private var currentMonth = Date()
    @State private var showProfile = false
    @State private var showMilestonePopup = false
    @State private var selectedProgressDay: ProgressDay?
    @State private var fallingFlowers: [FallingFlower] = []
    @State private var showAddMilestoneButton = false
    @State private var showNoGoalAlert = false
    @State private var calendarOffsetAnim: CGFloat = 0 // for animation
    @State private var lastFlowerIndex: Int? = nil
    @State private var isAnimatingFlowers = false
    @State private var currentAnimationID = UUID()
    @State private var clickedDate: Date? = nil
    @State private var milestoneTimer: Timer? = nil
    @State private var audioPlayer: AVAudioPlayer? = nil
    
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
                                    // Profile image or default icon
                                    if let profileImageData = profileImageData,
                                       let uiImage = UIImage(data: profileImageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 48, height: 48)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: 5)
                                            )
                                    } else {
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
                .onChange(of: showProfile) { _, isShowing in
                    if !isShowing {
                        // Profile sheet was dismissed, reload user profile
                        loadUserProfile()
                    }
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
                    .zIndex(1000) // Cvetovi iznad svega
                }
                .offset(y: calendarOffsetAnim)
                .zIndex(1)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .onAppear {
                loadData()
                loadUserProfile()
                withAnimation(.easeInOut(duration: 0.5)) {
                    calendarOffsetAnim = calendarOffset
                }
            }
            .onChange(of: calendarOffset) { newValue in
                withAnimation(.easeInOut(duration: 0.5)) {
                    calendarOffsetAnim = newValue
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ProfileImageUpdated"))) { _ in
                loadUserProfile()
            }
        }
        .navigationBarHidden(true)
        .overlay(
            GeometryReader { geometry in
                Group {
                if showAddMilestoneButton {
                        Button("Add Milestone") {
                            if let clickedDate = clickedDate {
                                // Kreiraj progress day ako ne postoji
                                if let goal = currentGoal {
                                    let progressDay = progressDayForDate(clickedDate) ?? coreDataManager.createProgressDay(for: goal, date: clickedDate)
                                    selectedProgressDay = progressDay
                                    showMilestonePopup = true
                                    showAddMilestoneButton = false
                                }
                            }
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 200, height: 62)
                        .background(Color.black)
                        .cornerRadius(100)
                        .transition(.asymmetric(insertion: .move(edge: .bottom).animation(.easeInOut(duration: 0.8)), removal: .move(edge: .bottom).animation(.easeInOut(duration: 0.8))))
                        .position(x: geometry.size.width / 2, y: geometry.size.height - 32) // 32px od dna ekrana
                        .zIndex(2000) // Preko svega
                        .transition(.asymmetric(insertion: .move(edge: .bottom).animation(.easeInOut(duration: 0.8)), removal: .move(edge: .bottom).animation(.easeInOut(duration: 0.8))))
                    }
                }
            }
        )
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
        .navigationBarHidden(true)
        .onReceive(appState.$currentScreen) { screen in
            if screen == .main {
                loadData()
            }
        }
        .overlay(
            Group {
                if showMilestonePopup, let selectedProgressDay = selectedProgressDay {
                    MilestonePopupView(progressDay: selectedProgressDay, isPresented: $showMilestonePopup)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        )
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
    
    // Generiši niz meseci od prvog goala do danas + unlimited meseci unapred
    var monthsToDisplay: [Date] {
        guard let firstGoalDate = firstGoalCreatedAt else { return [] }
        let calendar = Calendar.current
        let startOfFirstMonth = calendar.dateInterval(of: .month, for: firstGoalDate)?.start ?? firstGoalDate
        let now = Date()
        let startOfCurrentMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let monthsBack = calendar.dateComponents([.month], from: startOfFirstMonth, to: startOfCurrentMonth).month ?? 0
        let monthsForward = 60 // 60 meseci unapred (5 godina) - praktično unlimited
        
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
    
    private func loadUserProfile() {
        if let profile = coreDataManager.fetchUserProfile() {
            userProfile = profile
            profileImageData = profile.avatar
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
        
        // Proveri da li je datum u budućim mesecima (ne u trenutnom)
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        let dateMonth = calendar.component(.month, from: date)
        let dateYear = calendar.component(.year, from: date)
        
        // Onemogući klik na dane u budućim mesecima
        if dateYear > currentYear || (dateYear == currentYear && dateMonth > currentMonth) {
            return // Ne dozvoli klik na dane u budućim mesecima
        }
        
        if let progressDay = progressDay {
            // Day already has progress - show milestone popup
            selectedProgressDay = progressDay
            showMilestonePopup = true
        } else {
            // Vibracija kada se klikne na broj - neprekidna 1 sekunda
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.prepare()
            
            // Neprekidna vibracija 1 sekunda
            var vibrationCount = 0
            Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                notificationFeedback.notificationOccurred(.success)
                vibrationCount += 1
                if vibrationCount >= 100 { // 100 * 0.01s = 1s
                    timer.invalidate()
                }
            }
            
            // Pamti koji dan je kliknut
            clickedDate = date
            
            // Dodeli random flowerType od 1 do 14, ali ne isti kao prethodni
            var newFlowerIndex: Int
            repeat {
                newFlowerIndex = Int.random(in: 1...14)
            } while newFlowerIndex == lastFlowerIndex
            lastFlowerIndex = newFlowerIndex
            let randomFlower = String(newFlowerIndex)
            let newProgressDay = coreDataManager.createProgressDay(for: goal, date: date, flowerType: randomFlower)
            // Markiraj kao completed
            coreDataManager.updateProgressDay(newProgressDay, completed: true, flowerType: randomFlower)
            progressDays.append(newProgressDay)
            // Animacija cveta - sada prosleđujemo tip
            animateFlowerGrowth(type: randomFlower)
            
            // Resetuj timer za Add Milestone dugme
            milestoneTimer?.invalidate()
            
            // Prikazi dugme za milestone
            if !showAddMilestoneButton {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showAddMilestoneButton = true
                }
            }
            
            // Postavi novi timer za 5 sekundi
            milestoneTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
                withAnimation(.easeInOut(duration: 0.8)) {
                    showAddMilestoneButton = false
                    clickedDate = nil
                }
            }
        }
    }
    
    private func playSound() {
        guard let path = Bundle.main.path(forResource: "flower_sound", ofType: "mp3") else {
            print("⚠️ MP3 fajl 'flower_sound.mp3' nije pronađen!")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            print("🔊 Zvuk se reprodukuje...")
        } catch {
            print("⚠️ Greška pri puštanju zvuka: \(error)")
        }
    }
    
    private func animateFlowerGrowth(type: String) {
        // Ne brišemo prethodne cvetove - dozvoli paralelne animacije
        isAnimatingFlowers = true
        
        // Generiši novi ID za ovu animaciju
        let animationID = UUID()
        currentAnimationID = animationID
        
        // Create falling flowers istog tipa, različitih veličina
        let flowerSizes: [CGFloat] = [500, 400, 300, 250, 200, 180, 160, 140, 120, 100]
        
        for (index, size) in flowerSizes.enumerated() {
            let flower = FallingFlower(
                id: UUID(),
                type: type,
                startPosition: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: -300 - CGFloat(index * 50) // Počinju još više iznad ekrana
                ),
                endPosition: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: UIScreen.main.bounds.height + 100
                ),
                size: size,
                rotation: Double.random(in: -45...45), // Random rotacija
                delay: Double(index) * 0.2, // Delay za svaki sledeći cvet
                animationID: animationID // Dodaj ID animacije svakom cvetu
            )
            
            fallingFlowers.append(flower)
        }
        
        // Remove flowers after animation - proveri da li je ovo još uvek aktivna animacija
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            // Proveri da li je ovo još uvek aktivna animacija
            if self.currentAnimationID == animationID {
                withAnimation(.easeOut(duration: 0.5)) {
                    // Ukloni samo cvetove iz ove animacije
                    self.fallingFlowers.removeAll { flower in
                        flower.animationID == animationID
                    }
                    self.isAnimatingFlowers = false
                }
            }
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
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(54), spacing: 8), count: 6), spacing: 0) {
                ForEach(days.indices, id: \.self) { idx in
                    let date = days[idx]
                    let isToday = Calendar.current.isDateInToday(date)
                    Button(action: { onDayTap(date) }) {
                        ZStack {
                            let progressDay = progressDayForDate(date)
                            if let progressDay = progressDay, progressDay.completed {
                                ZStack {
                                    if progressDay.milestoneText == nil {
                                        FlowerView(type: progressDay.flowerType ?? "1")
                                            .frame(width: 94, height: 94)
                                            .id("flower-\(progressDay.date?.timeIntervalSince1970 ?? 0)")
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                    if progressDay.milestoneText != nil {
                                        FlowerView(type: "milestone")
                                            .frame(width: 94, height: 94)
                                            .id("milestone-\(progressDay.date?.timeIntervalSince1970 ?? 0)")
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .animation(.easeInOut(duration: 0.4), value: progressDay.milestoneText)
                            } else {
                                // Broj i krug animacija
                                ZStack {
                                    Circle()
                                        .fill(isToday ? Color(hex: "4F9BFF").opacity(0.08) : backgroundColor(for: date))
                                        .frame(width: 54, height: 54)
                                        .overlay(
                                            Circle()
                                                .stroke(isToday ? Color(hex: "4F9BFF") : Color(red: 0.79, green: 0.79, blue: 0.79), lineWidth: 1)
                                        )
                                    Text("\(idx + 1)")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(isToday ? Color(hex: "4F9BFF") : Color(red: 0.56, green: 0.56, blue: 0.56))
                                }
                            }
                        }
                        .frame(width: 70, height: 70)
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 12)
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
                    ZStack {
                        if progressDay.milestoneText == nil {
                            FlowerView(type: progressDay.flowerType ?? "flower_1")
                                .frame(width: 30, height: 30)
                                .id("flower-small-\(progressDay.date?.timeIntervalSince1970 ?? 0)")
                                .transition(.scale.combined(with: .opacity))
                        }
                        if progressDay.milestoneText != nil {
                            FlowerView(type: "milestone")
                                .frame(width: 30, height: 30)
                                .id("milestone-small-\(progressDay.date?.timeIntervalSince1970 ?? 0)")
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.easeInOut(duration: 0.4), value: progressDay.milestoneText)
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
                        FlowerView(type: "milestone")
                            .frame(width: 30, height: 30)
                            .transition(.scale.combined(with: .opacity))
                            .animation(.easeInOut(duration: 0.3), value: progressDay.milestoneText)
                    } else {
                        FlowerView(type: progressDay.flowerType ?? "flower_1")
                            .frame(width: 30, height: 30)
                            .transition(.scale.combined(with: .opacity))
                            .animation(.easeInOut(duration: 0.3), value: progressDay.milestoneText)
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
    let size: CGFloat
    let rotation: Double
    let delay: Double
    let animationID: UUID
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
            .frame(width: flower.size, height: flower.size)
            .rotationEffect(.degrees(flower.rotation))
            .position(position)
            .blur(radius: 12) // Smanjen blur
            .opacity(1.0) // 100% opacity
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + flower.delay) {
                    withAnimation(.easeIn(duration: 1.8)) { // Ubrzana animacija
                        position = flower.endPosition
                    }
                }
            }
    }
}

// MARK: - FlowerView za prikaz PNG cvetova
struct FlowerView: View {
    let type: String

    var imageName: String {
        // Ako je type broj od 1 do 19, koristi odgovarajući asset
        if let intType = Int(type), (1...19).contains(intType) {
            return "\(intType)"
        }
        // fallback na milestone
        if type == "milestone" { return "milestone" }
        // fallback na prvi cvet
        return "1"
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
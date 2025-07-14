import SwiftUI

class AppStateManager: ObservableObject {
    static let shared = AppStateManager()
    
    @Published var currentScreen: AppScreen = .splash
    @Published var hasCompletedOnboarding = false
    @Published var isAuthenticated = false
    
    private init() {}
    
    func navigateTo(_ screen: AppScreen) {
        withAnimation(.easeInOut(duration: DesignConstants.mediumAnimation)) {
            currentScreen = screen
        }
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        navigateTo(.main)
    }
    
    func authenticate() {
        isAuthenticated = true
        // Check if user has a goal, if not go to goal entry
        let coreDataManager = CoreDataManager.shared
        let goals = coreDataManager.fetchGoals()
        
        if goals.isEmpty {
            navigateTo(.goalEntry)
        } else {
            navigateTo(.main)
        }
    }
    
    func logout() {
        isAuthenticated = false
        navigateTo(.splash)
    }
}

enum AppScreen {
    case splash
    case signUp
    case login
    case goalEntry
    case main
}

struct AppStateView: View {
    @StateObject private var appState = AppStateManager.shared
    @StateObject private var coreDataManager = CoreDataManager.shared
    
    var body: some View {
        Group {
            switch appState.currentScreen {
            case .splash:
                SplashView()
            case .signUp:
                SignUpView()
            case .login:
                LoginView()
            case .goalEntry:
                GoalEntryFlowView()
            case .main:
                MainTrackingView()
            }
        }
        .environment(\.managedObjectContext, coreDataManager.container.viewContext)
    }
} 
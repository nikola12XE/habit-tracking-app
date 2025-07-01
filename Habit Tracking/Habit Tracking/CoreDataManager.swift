import CoreData
import SwiftUI

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "HabitTrackingModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - Goal Management
    func createGoal(text: String, selectedDays: [Int], reminderEnabled: Bool, reminderTime: Date?) -> Goal {
        let context = container.viewContext
        let goal = Goal(context: context)
        goal.id = UUID()
        goal.goalText = text
        goal.selectedDays = selectedDays.map { NSNumber(value: $0) } as NSArray
        goal.reminderEnabled = reminderEnabled
        goal.reminderTime = reminderTime
        goal.createdAt = Date()
        
        save()
        return goal
    }
    
    func fetchGoals() -> [Goal] {
        let request: NSFetchRequest<Goal> = Goal.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Goal.createdAt, ascending: false)]
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Error fetching goals: \(error)")
            return []
        }
    }
    
    func deleteGoal(_ goal: Goal) {
        let context = container.viewContext
        context.delete(goal)
        save()
    }
    
    // MARK: - Progress Day Management
    func createProgressDay(for goal: Goal, date: Date, flowerType: String? = nil) -> ProgressDay {
        let context = container.viewContext
        let progressDay = ProgressDay(context: context)
        progressDay.id = UUID()
        progressDay.goal = goal
        progressDay.date = date
        progressDay.completed = false
        progressDay.flowerType = flowerType
        
        save()
        return progressDay
    }
    
    func updateProgressDay(_ progressDay: ProgressDay, completed: Bool, flowerType: String? = nil) {
        progressDay.completed = completed
        if let flowerType = flowerType {
            progressDay.flowerType = flowerType
        }
        save()
    }
    
    func addMilestone(to progressDay: ProgressDay, text: String, photo: Data? = nil) {
        progressDay.milestoneText = text
        progressDay.milestonePhoto = photo
        save()
    }
    
    func fetchProgressDays(for goal: Goal) -> [ProgressDay] {
        let request: NSFetchRequest<ProgressDay> = ProgressDay.fetchRequest()
        request.predicate = NSPredicate(format: "goal == %@", goal)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ProgressDay.date, ascending: true)]
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Error fetching progress days: \(error)")
            return []
        }
    }
    
    // MARK: - User Profile Management
    func createUserProfile(email: String, name: String) -> UserProfile {
        let context = container.viewContext
        let profile = UserProfile(context: context)
        profile.id = UUID()
        profile.email = email
        profile.name = name
        profile.plan = "free"
        profile.reminderEnabled = true
        profile.reminderTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0))
        profile.playSound = true
        profile.secondReminder = false
        
        save()
        return profile
    }
    
    func fetchUserProfile() -> UserProfile? {
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        request.fetchLimit = 1
        
        do {
            return try container.viewContext.fetch(request).first
        } catch {
            print("Error fetching user profile: \(error)")
            return nil
        }
    }
    
    func updateUserProfile(_ profile: UserProfile) {
        save()
    }
} 

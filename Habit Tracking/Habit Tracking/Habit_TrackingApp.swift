//
//  Habit_TrackingApp.swift
//  Habit Tracking
//
//  Created by Nikolija Skrbic on 25. 6. 2025..
//

import SwiftUI

@main
struct Habit_TrackingApp: App {
    let coreDataManager = CoreDataManager.shared
    
    init() {
        // Uklonjen kod za ispis fontova
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataManager.container.viewContext)
        }
    }
}

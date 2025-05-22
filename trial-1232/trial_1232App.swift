//
//  trial_1232App.swift
//  trial-1232
//
//  Created by ABHINAV ANAND  on 23/05/25.
//

import SwiftUI

@main
struct trial_1232App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

//
//  DialogueApp.swift
//  Dialogue
//
//  Created by Porter Glines on 12/30/22.
//

import SwiftUI

@main
struct DialogueApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

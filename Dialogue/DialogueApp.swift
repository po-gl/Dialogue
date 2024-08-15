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
#if os(OSX)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State var chatFontSize: CGFloat = 14.0
#endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
#if os(OSX)
                .environment(\.chatFontSize, $chatFontSize)
#endif
                .onAppear {
                    Migrations.performModelMigrationGPT4oIfNeeded()
                }
        } .commands {
#if os(OSX)
            CommandGroup(replacing: .newItem, addition: {})
            CommandGroup(before: .toolbar) {
                Button("Zoom In") {
                    guard chatFontSize < 32 else { return }
                    Task {
                        chatFontSize += 2
                    }
                }
                .keyboardShortcut("=", modifiers: [.command])
                
                Button("Zoom Out") {
                    guard chatFontSize > 12 else { return }
                    Task {
                        chatFontSize -= 2
                    }
                }
                .keyboardShortcut("-", modifiers: [.command])
                
                Divider()
                Button("Reset Zoom") {
                    chatFontSize = 14.0
                }
                Divider()
            }
#endif
        }
    }
}

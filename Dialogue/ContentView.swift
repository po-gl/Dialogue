//
//  ContentView.swift
//  Dialogue
//
//  Created by Porter Glines on 12/30/22.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.undoManager) private var undoManager
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ChatPage()
            .onAppear {
                viewContext.undoManager = undoManager
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .inactive {
                    ChatData.saveContext(viewContext)
                }
            }
            .overlay(alignment: .top) {
                StatusBarBlur()
            }
    }
    
    
    @ViewBuilder
    private func StatusBarBlur() -> some View {
        Color.clear
            .background(.ultraThinMaterial)
            .brightness(colorScheme == .dark ? -0.1 : 0.02)
            .edgesIgnoringSafeArea(.top)
            .frame(height: 0)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

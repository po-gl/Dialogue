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
    
    
    var body: some View {
        ThreadsPage()
            .onAppear {
                viewContext.undoManager = undoManager
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .inactive {
                    ChatThreadData.saveContext(viewContext)
                }
            }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

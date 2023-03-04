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
    
    @State private var waiting: Bool = false
    private let titleEmoji = ["🤖", "🔮", "🌞", "👁️"]
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                ChatLog()
                VStack (spacing: 0) {
                    Spacer()
                    if waiting {
                        WaitingIndicator()
                            .padding(.bottom, 5)
                    }
                    AskView(waiting: $waiting)
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
            .toolbar {
                ToolbarView()
            }
            .onAppear {
                viewContext.undoManager = undoManager
            }
            .navigationTitle("Dialogue \(titleEmoji.randomElement()!)")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .introspectNavigationController { navController in
                navController.navigationBar.scrollEdgeAppearance = navController.navigationBar.standardAppearance
                navController.navigationBar.isTranslucent = true
            }
            .background(Color("Background"))
#elseif os(OSX)
            .background(Color("BackgroundMacOS"))
            .frame(minWidth: 400, idealWidth: 600, minHeight: 450, idealHeight: 800)
#endif
            
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

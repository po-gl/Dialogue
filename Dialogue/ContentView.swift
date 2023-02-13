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
                    WaitingIndicator()
                        .padding(.bottom, 5)
                        .opacity(waiting ? 1.0 : 0.0)
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

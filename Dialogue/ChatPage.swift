//
//  ChatPage.swift
//  Dialogue
//
//  Created by Porter Glines on 3/4/23.
//

import SwiftUI

struct ChatPage: View {
    private let titleEmoji = ["🤖", "🔮", "🌞", "👁️"]
    @State private var waiting: Bool = false
    
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

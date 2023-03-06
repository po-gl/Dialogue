//
//  ChatPage.swift
//  Dialogue
//
//  Created by Porter Glines on 3/4/23.
//

import SwiftUI

struct ChatPage: View {
    @State private var waiting: Bool = false
    
    var body: some View {
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
            ToolbarView()
        }
        .ignoresSafeArea(.container, edges: .bottom)
#if os(iOS)
        .background(Color("Background"))
#elseif os(OSX)
        .background(Color("BackgroundMacOS"))
        .frame(minWidth: 400, idealWidth: 600, minHeight: 450, idealHeight: 800)
#endif
    }
}

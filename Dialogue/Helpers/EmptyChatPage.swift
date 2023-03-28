//
//  EmptyChatPage.swift
//  Dialogue
//
//  Created by Porter Glines on 3/28/23.
//

import SwiftUI

struct EmptyChatPage: View {
    let width = 250.0
    
    var body: some View {
        ZStack (alignment: .bottomLeading) {
            Text("Add a new thread using the button at the bottom of the sidebar.")
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 20).fill(.quaternary))
                .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color("Outline"), lineWidth: 2))
                .padding(.horizontal, 5)
            
            Image(systemName: "arrow.down.backward")
                .font(.title2)
                .offset(x: -10, y: 17)
        }
        .frame(width: width)
        .opacity(0.4)
        .frame(minWidth: 400, idealWidth: 600, minHeight: 450, idealHeight: 800)
    }
}

struct EmptyChatPage_Previews: PreviewProvider {
    static var previews: some View {
        EmptyChatPage()
            .frame(width: 400, height: 400)
    }
}

//
//  EmptyChat.swift
//  Dialogue
//
//  Created by Porter Glines on 2/13/23.
//

import SwiftUI

struct EmptyChat: View {
    
    let width = 250.0
    
    var body: some View {
        ZStack {
            Text("Ask ChatGPT questions and dialogue will show up here")
                .font(.system(size: 14))
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 20).fill(.quaternary))
                .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color("Outline"), lineWidth: 2))
                .padding(.horizontal, 5)
            VStack {
                HStack {
                    Bubble()
                    Spacer()
                    Bubble()
                }
                Spacer()
                HStack {
                    Bubble()
                    Spacer()
                    Bubble()
                }
            }
        }
        .frame(width: width, height: 90)
        .opacity(0.4)
    }
    
    @ViewBuilder
    private func Bubble() -> some View {
        Circle()
            .fill(.quaternary)
            .overlay(Circle().stroke(Color("Outline"), lineWidth: 2))
            .frame(width: 12, height: 12)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyChat()
    }
}

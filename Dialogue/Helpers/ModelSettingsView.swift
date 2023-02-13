//
//  ModelSettingsView.swift
//  Dialogue
//
//  Created by Porter Glines on 2/11/23.
//

import SwiftUI

struct ModelSettingsView: View {
    @AppStorage("maxTokens") var maxTokens: Double = 150
    @AppStorage("messageMemory") private var messageMemory: Double = 2
    
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack (spacing: 10) {
#if os(iOS)
            RoundedRectangle(cornerRadius: 30)
                .frame(width: 50, height: 5)
                .opacity(0.2)
                .padding(5)
#endif
            GroupBox {
                VStack (alignment: .leading, spacing: 0) {
                    HStack (spacing: 0) {
                        Text("Max tokens:")
                            .font(.system(size: 14, weight: .medium))
                            .padding(.trailing, 20)
                        Text("\(Int(maxTokens))")
                            .font(.system(size: 14, weight: .medium))
                        Text("  ≈  \(Int(maxTokens*0.75)) words")
                            .font(.system(size: 16))
                            .opacity(0.6)
                    }
                    .padding(.bottom, 10)
                    .padding(.horizontal, 0)
                    Slider(value: $maxTokens, in: 150...2000, step: 50) {
                        Text("Max tokens")
                    } minimumValueLabel: {
                        Text("150")
                    } maximumValueLabel: {
                        Text("2000")
                    }
                    .tint(Color("ServerAccent"))
                }
            }
            
            GroupBox {
                VStack (alignment: .leading, spacing: 0) {
                    HStack (spacing: 0) {
                        Text("Memory:")
                            .font(.system(size: 14, weight: .medium))
                            .padding(.trailing, 20)
                        Text("\(Int(messageMemory)) messages")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .padding(.bottom, 10)
                    .padding(.horizontal, 0)
                    Slider(value: $messageMemory, in: 2...12, step: 1) {
                        Text("Max tokens")
                    } minimumValueLabel: {
                        Text("2")
                    } maximumValueLabel: {
                        Text("12")
                    }
                    .tint(Color("UserAccent"))
                }
            }
#if os(OSX)
            HStack {
                Spacer()
                Button(action: { isPresented = false} ) {
                    Text("Done")
                }
                .padding(.top)
            }
            .frame(width: 300)
#elseif os(iOS)
            Spacer()
#endif
        }
        .padding(.top, 10)
        .padding(25)
        .presentationDetents([.height(250)])
    }
}

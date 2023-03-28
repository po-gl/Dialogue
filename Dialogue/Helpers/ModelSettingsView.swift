//
//  ModelSettingsView.swift
//  Dialogue
//
//  Created by Porter Glines on 2/11/23.
//

import SwiftUI

struct ModelSettingsView: View {
    @AppStorage("maxTokens") var maxTokens: Double = 400
    @AppStorage("messageMemory") private var messageMemory: Double = 4
    
    @Binding var isPresented: Bool
    
    var body: some View {
#if os(iOS)
        ZStack {
            SettingsHeader()
            VStack (spacing: 15) {
                TokenSetting()
                MemorySetting()
                Spacer()
            }
            .padding(.top, 75)
            .padding(25)
        }
        .presentationDetents([.medium])
        
#elseif os(OSX)
        VStack (spacing: 15) {
            TokenSetting()
            MemorySetting()
            
            HStack {
                Spacer()
                Button(action: { isPresented = false} ) {
                    Text("Done")
                }
                .padding(.top)
            }
        }
        .padding(.top, 10)
        .padding(25)
        .presentationDetents([.medium])
#endif
    }
    
    
    @ViewBuilder private func SettingsHeader() -> some View {
        VStack {
            ZStack {
                HStack {
                    Button("Done") { isPresented = false }
                        .foregroundColor(Color("ServerAccent"))
                        .padding()
                    Spacer()
                }
                Text("Model Settings")
                    .font(.title3)
            }
            .frame(height: 65)
            .background(.thinMaterial)
            Spacer()
        }
    }
    
    @ViewBuilder private func TokenSetting() -> some View {
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
    }
    
    
    @ViewBuilder private func MemorySetting() -> some View {
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
    }
}

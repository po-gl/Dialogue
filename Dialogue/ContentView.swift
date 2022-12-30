//
//  ContentView.swift
//  Dialogue
//
//  Created by Porter Glines on 12/30/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var apiRequestHandler = ChatRequestHandler()
    @State private var inputText: String = ""
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            TextField("Ask...", text: $inputText)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(.green, style: StrokeStyle(lineWidth: 1.5)))
                .padding()
            
            Button(action: {
                self.apiRequestHandler.makeRequest(text: inputText)
            }) {
                Text("Send Request")
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 30.0).stroke(.blue, lineWidth: 1))
            }
            
            responseText()
            
            Spacer()
            Spacer()
        }
        .padding()
    }
    
    private func responseText() -> some View {
        return VStack {
            if let data = apiRequestHandler.responseData {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let choices = json["choices"] as? [[String: Any]] {
                        if let text = choices[0]["text"] as? String {
                            Text(text)
                        }
                    } else {
                        Text(String(data: apiRequestHandler.responseData!, encoding: .utf8) ?? "")
                    }
                }
            } else if apiRequestHandler.responseError != nil {
                Text(apiRequestHandler.responseError!.localizedDescription)
                    .foregroundColor(.red)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

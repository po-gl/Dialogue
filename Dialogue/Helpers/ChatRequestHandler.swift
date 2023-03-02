//
//  ChatRequestHandler.swift
//  Dialogue
//
//  Created by Porter Glines on 12/30/22.
//

import SwiftUI
import Combine

class ChatRequestHandler: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    var session = URLSession.shared
    @Published var responseData: Data?
    @AppStorage("maxTokens") var maxTokens: Double = 150
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEE M/d/Y")
        return formatter
    }()
    
    
    func makeRequest(chats: [[String: String]]) async {
        
        let preprompt = "You are an assistant is helpful, creative, clever, and very friendly. Knowledge cutoff: Sep 2021. Current Date: \(dateFormatter.string(from: Date()))."
        let prepromptData = getMessageInDataFormat(role: "system", content: preprompt)
        
        let messages: [[String: String]] = [prepromptData] + chats
        
        let apiKey = getApiKey("apikey.env")
        let model = "gpt-3.5-turbo"
        let temperature = 0.9
        let maxTokens = Int(self.maxTokens)
        let topP = 1
        let frequencyPenalty = 0.0
        let presencePenalty = 0.6
        
        let requestBody: [String: Any] = [
            "model": model,
            "messages": messages,
            "temperature": temperature,
            "max_tokens": maxTokens,
            "top_p": topP,
            "frequency_penalty": frequencyPenalty,
            "presence_penalty": presencePenalty,
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: requestBody)
        
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        print("Input prompt: \(String(reflecting: messages))")
        
        do {
            let (responseData, _) = try await session.upload(for: request, from: jsonData!)
            await MainActor.run {
                self.responseData = responseData
                print("URLResponseData:\(String(data:responseData, encoding: .utf8) ?? "")")
            }
        } catch {
            print("Error loading openai url: \(error.localizedDescription)")
        }
    }
    
    
    private func getApiKey(_ filepath: String) -> String {
        if let path = Bundle.main.path(forResource: filepath, ofType: "") {
            do {
                return try String(contentsOfFile: path, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
            } catch {
                print(error.localizedDescription)
            }
        }
        return ""
    }
    
    
    private func getMessageInDataFormat(role: String, content: String) -> [String: String] {
        return ["role": role, "content": content]
    }
}

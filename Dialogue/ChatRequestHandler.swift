//
//  ChatRequestHandler.swift
//  Dialogue
//
//  Created by Porter Glines on 12/30/22.
//

import Foundation
import Combine

class ChatRequestHandler: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var responseData: Data?
    @Published var responseError: Error?
    
    func makeRequest(text: String) {
        let apiKey = getApiKey("apikey.env")
        let model = "text-davinci-003"
        let prompt = text
        let temperature = 0.9
        let maxTokens = 150
        let topP = 1
        let frequencyPenalty = 0.0
        let presencePenalty = 0.6
        let stop = [" Human:", " AI:"]
        
        let requestBody: [String: Any] = [
            "model": model,
            "prompt": prompt,
            "temperature": temperature,
            "max_tokens": maxTokens,
            "top_p": topP,
            "frequency_penalty": frequencyPenalty,
            "presence_penalty": presencePenalty,
            "stop": stop
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: requestBody)
        
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/completions")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        URLSession.shared
            .dataTaskPublisher(for: request)
            .map { $0.data }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err):
                    self.responseError = err
                default:
                    break
                }
            }, receiveValue: { data in
                self.responseData = data
            })
            .store(in: &self.cancellables)
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
}

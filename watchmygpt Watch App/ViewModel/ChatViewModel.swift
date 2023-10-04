//
//  ChatViewModel.swift
//  watchmyai Watch App
//
//  Created by Sasan Rafat Nami on 03.10.23.
//
import Foundation

class ChatViewModel: ObservableObject {
    
    @Published var chatOutput: String = "How can I help you?"
    @Published var userInput: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isTyping: Bool = false
    @Published var messageContext: [[String: String]] = [
        ["role": "system", "content": "You are a helpful assistant."]
    ]
    
    func splitTextIntoSegments(text: String, maxWords: Int) -> [String] {
        let words = text.split(separator: " ")
        var segments: [String] = []
        var segment: [String] = []
        var wordCount = 0
        
        for word in words {
            segment.append(String(word))
            wordCount += 1
            
            if wordCount >= maxWords {
                segments.append(segment.joined(separator: " "))
                segment.removeAll()
                wordCount = 0
            }
        }
        
        if !segment.isEmpty {
            segments.append(segment.joined(separator: " "))
        }
        
        return segments
    }
    
    func sendSegments(segments: [String]) {
        for segment in segments {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.chatOutput += "\nGPT: \(segment)"
            }
        }
    }
    
    func sendMessage(retryCount: Int = 0) {
        
        isLoading = true
        isTyping = true
        
        let userMessage = ["role": "user", "content": userInput]
        messageContext.append(userMessage)
        
        _ = self.userInput
        
        func getAPIKey() -> String? {
            var apiKey: String?
            if let path = Bundle.main.path(forResource: "Config", ofType: "plist") {
                if let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
                    apiKey = dict["API_KEY"] as? String
                }
            }
            return apiKey
        }
        
        let urlString = "https://api.openai.com/v1/chat/completions"
        let apiKey = getAPIKey() ?? ""
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 500 // Setze Timeout auf 300 Sekunden
        
        let json: [String: Any] = ["model": "gpt-3.5-turbo", "messages": messageContext]
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.isTyping = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Fehler beim Senden der Anfrage: \(error)"
                }
                if retryCount < 3 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self?.sendMessage(retryCount: retryCount + 1)
                    }
                }
                return
            }
            
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
                    DispatchQueue.main.async { [weak self] in
                        if let strongSelf = self {
                            let content = decodedResponse.choices[0].message.content
                            let segments = strongSelf.splitTextIntoSegments(text: content, maxWords: 200)
                            
                            strongSelf.chatOutput += "\nYou: \(strongSelf.userInput)"
                            strongSelf.sendSegments(segments: segments)
                            
                            let assistantMessage = ["role": "assistant", "content": content]
                            strongSelf.messageContext.append(assistantMessage)
                            
                            strongSelf.userInput = ""
                        }
                    }
                } catch {
                    print("Error!")
                }
            }
        }.resume()
    }
    
    struct ChatResponse: Codable {
        struct Choice: Codable {
            let message: Message
        }
        struct Message: Codable {
            let role: String
            let content: String
        }
        let choices: [Choice]
    }
}

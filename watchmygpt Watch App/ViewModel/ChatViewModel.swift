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
    
    // Diese Funktion teilt den Text in kleinere Segmente auf
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
    
    // Diese Funktion sendet die Segmente nacheinander
    func sendSegments(segments: [String]) {
        for segment in segments {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.chatOutput += "\nGPT: \(segment)"
            }
        }
    }

    
    func sendMessage() {
        
        isLoading = true // Start Loading Indicator

        let message = self.userInput
        
        func getAPIKey() -> String? {
            var apiKey: String?
            if let path = Bundle.main.path(forResource: "Config", ofType: "plist") {
                if let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
                    apiKey = dict["API_KEY"] as? String
                }
            }
            return apiKey
        }
        
        // Konfiguration für die OpenAI API
        let urlString = "https://api.openai.com/v1/chat/completions"
        let apiKey = getAPIKey() ?? ""
        
        // URLRequest konfigurieren
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Nachrichten für die Anfrage erstellen
        let messages = [
            ["role": "system", "content": "You are a helpful assistant."],
            ["role": "user", "content": message]
        ]
        
        // JSON-Body für die Anfrage erstellen
        let json: [String: Any] = ["model": "gpt-3.5-turbo", "messages": messages]
        
        // Ausgabe des Anfrage-Bodys
        if let jsonData = try? JSONSerialization.data(withJSONObject: json), let jsonString = String(data: jsonData, encoding: .utf8) {
            print("Anfrage-Body: \(jsonString)")
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            DispatchQueue.main.async { // Switch to main thread
                self?.isLoading = false // Stop Loading Indicator
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP-Statuscode: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    // Handle Fehlerantwort vom Server hier
                    // Zeige eine Fehlermeldung im UI oder protokolliere sie.
                    if let data = data {
                        let str = String(data: data, encoding: .utf8)
                        print("Fehlerantwort vom Server: \(str ?? "")")
                    }
                    return
                }
            }
            
            if let error = error {
                DispatchQueue.main.async { // Switch to main thread
                    self?.errorMessage = "Fehler beim Senden der Anfrage: \(error)"
                }
                return
            }
            
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
                    DispatchQueue.main.async { [weak self] in
                        if let strongSelf = self {
                            let content = decodedResponse.choices[0].message.content
                            let segments = strongSelf.splitTextIntoSegments(text: content, maxWords: 200) // Verwende "strongSelf" hier
                            
                            strongSelf.chatOutput += "\nYou: \(message)"
                            strongSelf.sendSegments(segments: segments)
                            
                            strongSelf.userInput = "" // Lösche die Eingabe, um Platz für eine neue Nachricht zu machen
                        }
                    }

                } catch {
                    // Fehlerbehandlung
                }
            }
        }.resume()
        
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
    
}


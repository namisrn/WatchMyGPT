//
//  NewChat.swift
//  watchmygpt Watch App
//
//  Created by Sasan Rafat Nami on 20.09.23.
//

import SwiftUI

struct NewChat: View {
    
    @State private var userInput: String = "" // Hier wird der Benutzereingabestring gespeichert
    @State private var chatOutput: String = "Welcome to WatchMyGPT How can i help you?" // Hier wird die Chat-Ausgabe gespeichert

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Spacer(minLength: 30) // Platz am oberen Rand
                    
                    ScrollView {
                        VStack(spacing: 10) { // Abstand zwischen den Nachrichten
                            ForEach(chatOutput.split(separator: "\n"), id: \.self) { message in
                                if message.hasPrefix("GPT:") { // Überprüfen, ob es sich um eine "Response"-Nachricht handelt
                                    Text(message)
                                        .padding(10) // Innenraum-Padding für die "Response"
                                        .background(Color.gray.opacity(0.2)) // Hintergrundfarbe für die "Response"
                                        .cornerRadius(10) // Ecken der "Response" abrunden
                                } else {
                                    Text(message)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding() // Abstand zu den Rändern der VStack
                    //.border(Color.red)
                    
                    HStack(spacing: 6) { // Abstand zwischen Textfeld und Button
                        TextField("Send a message...", text: $userInput)
                        //.border(Color.red)
                        Button(action: {
                            sendMessage(userInput)
                        }) {
                            Image(systemName: "paperplane.fill")
                                .font(Font.system(size: 25))
                            //.border(Color.red)
                            
                        }
                        .clipShape(Circle()) // Button in Kreisform
                        .frame(width: 55)
                        //.border(Color.orange)
                        
                    }
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 15, trailing: 10)) // Innenraum-Padding für HStack
                    //.background(Color.white.opacity(0.9)) // Hintergrundfarbe für den Innenraum der HStack
                    //.border(Color.green)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .edgesIgnoringSafeArea(.all)
            .containerBackground(.blue.gradient, for: .navigation)
            /*
             .toolbar{
             ToolbarItem(placement: .topBarTrailing){
             Button(action: {
             // Aktion für Detailansicht
             }) {
             Image(systemName: "ellipsis") // Beispiel für ein System-Icon
             }
             }
             }
             */
            
        }
        
    }
    

func sendMessage(_ message: String) {
    // Konfiguration für die OpenAI API
    let urlString = "https://api.openai.com/v1/chat/completions"
    let apiKey = "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"  // Deinen echten API-Schlüssel einfügen

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

    URLSession.shared.dataTask(with: request) { data, response, error in
        print("Task completed")

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
            // Handle Fehler beim Senden der Anfrage hier
            // Zeige eine Fehlermeldung im UI oder protokolliere sie.
            print("Fehler beim Senden der Anfrage: \(error)")
            return
        }

        if let data = data {
            do {
                let decodedResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
                DispatchQueue.main.async {
                    self.chatOutput += "\nYou: \(message)"
                    self.chatOutput += "\nGPT: \(decodedResponse.choices[0].message.content)"
                    self.userInput = "" // Lösche die Eingabe, um Platz für eine neue Nachricht zu machen
                }
            } catch DecodingError.keyNotFound(_, _) {
                // Handle Fehlerantwort zu dekodieren hier
                // Zeige eine Fehlermeldung im UI oder protokolliere sie.
                print("Fehler beim Dekodieren der Antwort")
            } catch {
                // Handle sonstige Dekodierungsfehler hier
                // Zeige eine Fehlermeldung im UI oder protokolliere sie.
                print("Sonstiger Fehler beim Dekodieren der Antwort: \(error)")
            }
        }
    }.resume()

    // Dein bestehendes ChatResponse-Modell
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

#Preview {
    NewChat()
}
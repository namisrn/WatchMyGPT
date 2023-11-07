//
//  NewChat.swift
//  WatchMyAI
//
//  Created by Sasan Rafat Nami on 20.09.23.
//
import SwiftUI

// NewChat: Struktur für die Hauptansicht des Chats
struct NewChat: View {
    
    // ViewModel für Datenbindung
    @ObservedObject var viewModel = ChatViewModel()

    // Hauptkörper der View
    var body: some View {
        
        // Navigationscontainer
        NavigationStack {
            ZStack {
                VStack {
                    // Spacer, der Platz am oberen Rand der Ansicht lässt
                    Spacer(minLength: 60)
                    
                    // ScrollView für den Chatverlauf
                    ScrollView {
                        
                        // Vertikaler Stapel mit Abstand von 2 zwischen den Elementen
                        LazyVStack(spacing: 2) {
                            
                            // Anfangsnachricht "How can I help you?"
                            Text("How can I help you?")
                                .padding(8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            
                            // Schleife durch die Chat-Ausgabe und zeige sie an
                            ForEach(viewModel.chatOutput.split(separator: "\n"), id: \.self) { message in
                                
                                // Wenn die Nachricht von GPT kommt
                                if message.hasPrefix("GPT:") {
                                    
                                    Text(message)
                                        .multilineTextAlignment(.leading)
                                        .padding(10)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                    
                                    // Wenn die Nachricht vom Benutzer kommt
                                } else if message.hasPrefix("You:") {
                                    
                                    Text(message)
                                        .multilineTextAlignment(.leading)
                                        .padding(10)
                                        .background(Color.blue.opacity(0.6))
                                        .cornerRadius(10)
                                }
                            }
                            
                            // Anzeige, wenn GPT tippt
                            if viewModel.isTyping {
                                Text("GPT is typing...")
                                    .multilineTextAlignment(.center)
                                    .padding(10)
                            }
                            
                            // Ladeanzeige, wenn eine Anfrage an die API gesendet wird
                            if viewModel.isLoading {
                                ProgressView()
                            }
                            
                            // Fehlermeldung, falls vorhanden
                            if let errorMessage = viewModel.errorMessage {
                                Text("Fehler: \(errorMessage)")
                                    .foregroundColor(.red)
                            }
                            
                            // Button für den Verbindungsfehler
                            if viewModel.connectionError && viewModel.messageSent {
                                Button("Try Again") {
                                    Task {
                                        await viewModel.retryMessage()
                                    }
                                }
                            }
                        }
                    }
                    .scenePadding()
                    
                    // Toolbar für das Textfeld und den Senden-Button
                    .toolbar{
                        ToolbarItem(placement: .bottomBar) {
                            Spacer()
                        }
                        ToolbarItem(placement: .bottomBar){
                            
                            // Eingabefeld für den Benutzer
                            //TextField("", text: $viewModel.userInput)
                            TextField("", text: $viewModel.userInput, prompt: Text("Start").foregroundColor(.blue))
                                .foregroundColor(Color.blue)
                                .frame(width: 60)
                                .background(.ultraThinMaterial)
                                .cornerRadius(20)
                                .multilineTextAlignment(.center)
                                .disabled(viewModel.isTyping) // Deaktiviere das TextField, wenn GPT tippt
                                .submitLabel(.send)
                            
                            // Aktion, die beim Senden ausgeführt wird
                                .onSubmit {
                                    if !viewModel.userInput.isEmpty {
                                        Task {
                                            await viewModel.sendMessage()
                                        }
                                    }
                                }
                        }
                    }
                }
                // Maximale Größe für den VStack
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }
            .edgesIgnoringSafeArea(.all)
            //.containerBackground(.blue.gradient, for: .navigation)

            .navigationTitle("New Chat")
        }.onAppear {
            viewModel.resetChat() // Setze den Chat zurück, wenn die Ansicht erscheint
        }
    }
}


#Preview {
    NewChat()
}

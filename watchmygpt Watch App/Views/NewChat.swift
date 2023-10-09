//
//  NewChat.swift
//  WatchMyAI
//
//  Created by Sasan Rafat Nami on 20.09.23.
//

import SwiftUI

// Die Hauptansicht für den Chat
struct NewChat: View {
    
    // Verwendung des ViewModel für die Datenbindung
    @ObservedObject var viewModel = ChatViewModel()
    // Der Body der View
    var body: some View {
        NavigationStack { // Navigationscontainer
            ZStack { // Stapel für Überlagerung von Views
                VStack { // Vertikaler Stapel für Anordnung der Unter-Views
                    
                    // Ein Spacer, der Platz am oberen Rand der Ansicht lässt
                    Spacer(minLength: 60)
                    
                    // ScrollView für den Chatverlauf
                    ScrollView {
                        VStack(spacing: 2) { // Vertikaler Stapel mit einem Abstand von 5 zwischen den Elementen
                            // Anfangsnachricht "How can I help you?"
                            Text("How can I help you?")
                                .padding(8) // Abstand um den Text
                                .background(Color.gray.opacity(0.2)) // Hintergrundfarbe
                                .cornerRadius(10) // Eckenradius für den Hintergrund

                            // Schleife durch die Chat-Ausgabe und zeige sie an
                            ForEach(viewModel.chatOutput.split(separator: "\n"), id: \.self) { message in
                                if message.hasPrefix("GPT:") { // Wenn die Nachricht von GPT kommt
                                    Text(message)
                                        .multilineTextAlignment(.leading) // Ausrichtung des Texts
                                        .padding(10) // Abstand um den Text
                                        .background(Color.gray.opacity(0.2)) // Hintergrundfarbe
                                        .cornerRadius(10) // Eckenradius
                                } else if message.hasPrefix("You:") { // Wenn die Nachricht vom Benutzer kommt
                                    Text(message)
                                        .multilineTextAlignment(.leading)
                                        .padding(10)
                                        .background(Color.blue.opacity(0.5))
                                        .cornerRadius(10)
                                }
                            }
                            
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
                                    .foregroundColor(.red) // Rote Textfarbe für Fehlermeldungen
                            }
                            
                            // Button für den Verbindungsfehler
                            if viewModel.connectionError && viewModel.messageSent {
                                Button("Try Again") {
                                    Task {
                                        await viewModel.sendMessage()
                                    }
                                }
                            }
                            

                            
                        }
                        //.frame(maxWidth: .infinity, alignment: .center) // Maximale Breite und Ausrichtung für den VStack
                        //.border(Color.red)

                    }
                    //.padding() // Abstand um die ScrollView
                    //.border(Color.cyan)
                    .scenePadding()
                    .toolbar{
                        ToolbarItem(placement: .bottomBar) {
                            Spacer()
                        }
                        ToolbarItem(placement: .bottomBar){
                            // Eingabefeld und Sende-Button
                            TextField("Start", text: $viewModel.userInput) // Eingabefeld für den Benutzer
                                .frame(width: 60)
                                .background(.ultraThinMaterial)
                                .cornerRadius(20)
                                .multilineTextAlignment(.center)
                                .disabled(viewModel.isTyping)  // Deaktiviere das TextField, wenn GPT tippt
                                .submitLabel(.send)
                                .onSubmit {  // Aktion, die beim Senden ausgeführt wird
                                    Task {
                                        await viewModel.sendMessage() // Aufruf der sendMessage Funktion im ViewModel
                                    }
                                }
                        }
                    }//toolbar
                }
                
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Maximale Größe für den VStack
                //.border(Color.red)

            }
            .edgesIgnoringSafeArea(.all) // Ignoriere den Safe Area für diese Ansicht
            .containerBackground(.blue.gradient, for: .navigation) // Hintergrundfarbe für die Navigationsleiste
            .navigationTitle("New Chat") // Titel der Navigationsleiste
            //.border(Color.green)
            

        }
        
    }
}



#Preview {
    NewChat()
}

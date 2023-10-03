//
//  NewChat.swift
//  WatchMyAI
//
//  Created by Sasan Rafat Nami on 20.09.23.
//

import SwiftUI

struct NewChat: View {
    
    @ObservedObject var viewModel = ChatViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Spacer(minLength: 40) // Platz am oberen Rand
                    
                    ScrollView {
                        VStack(spacing: 5) {

                            Text("How can I help you?")
                                .padding(10)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            
                            ForEach(viewModel.chatOutput.split(separator: "\n"), id: \.self) { message in
                                if message.hasPrefix("GPT:") {
                                    Text(message)
                                        .multilineTextAlignment(.leading)
                                        .padding(10)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                } else if message.hasPrefix("You:") {
                                    Text(message)
                                        .multilineTextAlignment(.leading)
                                        .padding(10)
                                        .background(Color.blue.opacity(0.5))
                                        .cornerRadius(10)
                                }
                            }
                            
                            
                            
                            
                            if viewModel.isLoading {
                                ProgressView()
                            }
                            
                            if let errorMessage = viewModel.errorMessage {
                                Text("Fehler: \(errorMessage)")
                                    .foregroundColor(.red)
                            }
                            
                            
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    
                    HStack(spacing: 6) {
                        TextField("Send a message...", text: $viewModel.userInput)
                        
                        Button(action: {
                            viewModel.sendMessage()
                        }) {
                            Image(systemName: "paperplane.fill")
                                .font(Font.system(size: 25))
                        }
                        .clipShape(Circle())
                        .frame(width: 55)

                        
                    }
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 8))
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .edgesIgnoringSafeArea(.all)
            .containerBackground(.blue.gradient, for: .navigation)
            .navigationTitle("New Chat")
        }
    }
}



#Preview {
    NewChat()
}

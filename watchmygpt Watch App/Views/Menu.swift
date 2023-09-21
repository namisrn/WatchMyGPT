//
//  Menu.swift
//  watchmygpt Watch App
//
//  Created by Sasan Rafat Nami on 20.09.23.
//

import SwiftUI

struct Menu: View {
    var body: some View {
        NavigationStack{
            List {
                NavigationLink(destination: NewChat()) {
                    VStack(alignment: .leading){
                        label:do {
                            Image(systemName: "plus.bubble")
                                .font(.system(size: 35))
                                .padding(.top)
                        }
                        Text("New Chat")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding()
                    }
                    

                }
                NavigationLink(destination: Archive()) {
                    VStack(alignment: .leading){
                        label:do {
                            Image(systemName: "archivebox")
                                .font(.system(size: 35))
                                .padding(.top)
                        }
                        Text("Archive")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding()
                        Text("no func")
                            .font(.subheadline)
                            .fontWeight(.light)
                            .padding(.leading)
                            .foregroundColor(Color.red)

                    }

                }
                NavigationLink(destination: Setting()) {
                    VStack(alignment: .leading){
                        label:do {
                            Image(systemName: "gear")
                                .font(.system(size: 35))
                                .padding(.top)
                        }
                        Text("Setting")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding()
                        Text("no func")
                            .font(.subheadline)
                            .fontWeight(.light)
                            .padding(.leading)
                            .foregroundColor(Color.red)
                    }

                }
            }
            .navigationTitle("WatchMyGPT")
            .containerBackground(.blue.gradient, for: .navigation)
            .listStyle(.carousel)

        }

    }

}


#Preview {
    Menu()
}

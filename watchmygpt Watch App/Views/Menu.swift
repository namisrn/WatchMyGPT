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
            List{
                Text("New Chat")
                Text("Archive")
                Text("Setting")
            }
        }
        //.containerBackground(.blue.gradient, for: .navigation)

    }
}

#Preview {
    Menu()
}

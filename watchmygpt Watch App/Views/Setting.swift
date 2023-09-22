//
//  Setting.swift
//  WatchMyAI
//
//  Created by Sasan Rafat Nami on 21.09.23.
//

import SwiftUI

struct Setting: View {
    var body: some View {
        NavigationStack{
            List{
                Text("setting 01")
                Text("setting 02")
            }
            .containerBackground(.blue.gradient, for: .navigation)
            .navigationTitle("Setting")
        }
    }
}

#Preview {
    Setting()
}

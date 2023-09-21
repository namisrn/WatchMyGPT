//
//  Archive.swift
//  watchmygpt Watch App
//
//  Created by Sasan Rafat Nami on 21.09.23.
//

import SwiftUI

struct Archive: View {
    var body: some View {
        NavigationStack{
            List{
                Text("msg 01")
                Text("msg 02")
            }
            .containerBackground(.blue.gradient, for: .navigation)

        }
        .navigationTitle("Archive")

    }
}

#Preview {
    Archive()
}

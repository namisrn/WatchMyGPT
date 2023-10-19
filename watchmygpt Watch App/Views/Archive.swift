//
//  Archive.swift
//  WatchMyAI
//
//  Created by Sasan Rafat Nami on 21.09.23.
//

import SwiftUI

struct Archive: View {
    var body: some View {
        NavigationStack{
            
            List{
                
                Text("Coming Soon")
            }
            .containerBackground(.blue.gradient, for: .navigation)
            .navigationTitle("Archive")
            
            
            //Text("Testing phase, limited functionality.")
            Text("Coming Soon!")
                .font(.footnote)
                .padding(5)
                .background(Color.gray.opacity(0.1))
                .foregroundColor(.white.opacity(0.4))
                .cornerRadius(5)
            
        }
        .listStyle(.plain)


    }
}


#Preview {
    Archive()
}

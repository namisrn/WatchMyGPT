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
        }
        
        
    }
}


#Preview {
    Archive()
}

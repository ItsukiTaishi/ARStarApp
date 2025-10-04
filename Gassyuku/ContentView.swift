//
//  ContentView.swift
//  Gassyuku
//
//  Created by hasegawa on 2025/09/20.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var loader = StarLoader()
    @StateObject private var gameCenterManager = GameCenterManager()
    
    
    var body: some View {
        VStack{
            
            StarGazingView(stars: $loader.stars)
                .environmentObject(gameCenterManager)
            
//                    Button{
//                        print(loader.stars[0],loader.stars[1],loader.stars[2])
//                    }label: {
//                        Text("プリント")
//                    }
            
            
        }
    }
}
#Preview {
    ContentView()
}

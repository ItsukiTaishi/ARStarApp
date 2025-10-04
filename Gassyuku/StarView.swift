//
//  StarView.swift
//  Gassyuku
//
//  Created by hasegawa on 2025/09/22.
//

import SwiftUI

struct StarView: View {
    var star: Star
    
    var body: some View {
        
        VStack{
            Image("star")
                .resizable()
                .scaledToFit()
                .frame(width: star.collectStar ? 50 : 25, height: star.collectStar ? 50 : 25)
             

            Text("\(star.name)")
                .foregroundColor(.white)
                .font(.caption)
                
        }
        
    }
}




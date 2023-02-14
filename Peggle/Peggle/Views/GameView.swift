//
//  GameView.swift
//  Peggle
//
//  Created by James Chiu on 13/2/23.
//

import SwiftUI

struct GameView: View {
    var body: some View {
        ZStack {
            GeometryReader { geo in
                generateGameArea(geo)
            }
        }
        .ignoresSafeArea()
    }

    func generateGameArea(_ geo: GeometryProxy) -> some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width)

            CannonView()
                .position(x: geo.size.width / 2, y: 60)
        }
    }
}

struct CannonView: View {
    var width: CGFloat = 150
    var body: some View {
        Image("cannon-static")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width)
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}

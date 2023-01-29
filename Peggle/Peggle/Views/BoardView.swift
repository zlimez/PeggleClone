//
//  BoardView.swift
//  Peggle
//
//  Created by James Chiu on 28/1/23.
//

import SwiftUI

struct BoardView: View {
    var body: some View {
        PegView(peg: Peg(pegVariant: "peg-orange", radius: 60))
    }
}

struct PegView: View {
    let peg: Peg
    var body: some View {
        Image(peg.pegVariant)
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView()
    }
}

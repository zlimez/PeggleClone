//
//  ControlPanelView.swift
//  Peggle
//
//  Created by James Chiu on 28/1/23.
//

import SwiftUI

struct ControlPanelView: View {
    @State private var levelName = ""
    @Binding var boardViewModel: BoardViewModel

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                PegButtonView(pegVariant: "peg-blue", action: {
                    boardViewModel.switchToAddPeg(pegVariant: ("peg-blue", 30))
                }, diameter: 60)
                .tint(boardViewModel.selectedAction == Action.add && boardViewModel.selectedPegVariant!.0 == "peg-blue" ? .cyan : .clear)
                PegButtonView(pegVariant: "peg-orange", action: {
                    boardViewModel.switchToAddPeg(pegVariant: ("peg-orange", 30))
                }, diameter: 60)
                .tint(boardViewModel.selectedAction == Action.add && boardViewModel.selectedPegVariant!.0 == "peg-orange" ? .cyan : .clear)
                Spacer()
                PegButtonView(pegVariant: "delete", action: {
                    boardViewModel.switchToDeletePeg()
                }, diameter: 60)
                .tint(boardViewModel.selectedAction == Action.delete ? .cyan : .clear)
            }
            .padding([.leading, .trailing], 20)
            HStack {
                Button("LOAD", action: {})
                Button("SAVE", action: {})
                Button("RESET", action: {})
                TextField("Level Name", text: $levelName)
                    .border(.gray)
                    .textFieldStyle(.roundedBorder)
                Button("START", action: {})
            }
            .padding([.leading, .trailing], 20)
        }
        .padding([.top, .bottom], 20)
    }
}

struct PegButtonView: View {
    let pegVariant: String
    let action: () -> Void
    let diameter: CGFloat
    var body: some View {
        Button(action: action) {
            Image(pegVariant)
                .resizable()
                .frame(width: diameter, height: diameter)
        }
    }
}

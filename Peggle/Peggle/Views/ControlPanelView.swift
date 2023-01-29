//
//  ControlPanelView.swift
//  Peggle
//
//  Created by James Chiu on 28/1/23.
//

import SwiftUI

struct ControlPanelView: View {
    @State private var levelName = ""
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                PegButtonView(pegVariant: "peg-blue", action: {}, diameter: 60)
                PegButtonView(pegVariant: "peg-orange", action: {}, diameter: 60)
                Spacer()
                PegButtonView(pegVariant: "delete", action: {}, diameter: 60)
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

struct ControlPanelView_Previews: PreviewProvider {
    static var previews: some View {
        ControlPanelView()
    }
}

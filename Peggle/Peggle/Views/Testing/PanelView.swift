//
//  PanelView.swift
//  Peggle
//
//  Created by James Chiu on 2/3/23.
//

import Foundation
import SwiftUI

struct PanelView: View {
    @State private var levelName = ""
    @State private var selectedMode = "Operation Strix"
    @State private var ballGiven = 0

    var body: some View {
        HStack {
            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                GridRow {
                    ActionButtonView(text: "LOAD") {
                        _ = ModeMapper.defaultMode
                    }
                    ActionButtonView(text: "SAVE") {

                    }
                }
                GridRow {
                    ActionButtonView(text: "RESET") { }
                    ActionButtonView(text: "MENU") { }
                }
            }
            Spacer()
            VStack(alignment: .leading, spacing: 10) {
                TextField("Level Name", text: $levelName)
                    .padding(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                    .foregroundColor(.white)

                ModeView(selectedMode: $selectedMode, ballGiven: $ballGiven, pickerColor: Color("dark green"))
            }
            .frame(width: 350)
            Spacer()
            createGameWorld(selectedMode)
        }
        .padding(.horizontal, 20)
        .padding(.top, 40)
        .padding(.bottom, 20)
        .background(Color("dark grey"))
    }

    func createGameWorld(_ gameMode: String) -> some View {
        NavigationLink(value: Page.playPage) {
            Button("GO!") {
            }
            .font(.title2)
            .fontDesign(.monospaced)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .background(Color("grey"))
            .cornerRadius(20)
        }
    }
}

struct ActionView: View {
    var text: String
    var color = Color("grey")

    var body: some View {
        Button(action: {}) {
            Text(text)
                .fontDesign(.monospaced)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .frame(width: 75)
        .padding(.vertical, 5)
        .background(color)
        .cornerRadius(5)
    }
}

struct Previews: PreviewProvider {
    static var previews: some View {
        PanelView()
    }
}

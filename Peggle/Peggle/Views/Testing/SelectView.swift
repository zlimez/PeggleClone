//
//  SelectionLayout.swift
//  Peggle
//
//  Created by James Chiu on 2/3/23.
//

import Foundation
import SwiftUI

struct SelectView: View {
    var levels: [String] = ["Start A Family", "Get Anya Into Eden", "Meet Desmond"]

    var body: some View {
        VStack {
            VStack {
                Text("Missions")
                    .fontWeight(.heavy)
                    .font(.title)
                    .fontDesign(.monospaced)
                ForEach(levels, id: \.self) { levelName in
                    RowView(levelName: levelName)
                }
            }
            .padding()
            .padding(.top, 25)

            Spacer()
        }
        .background(Color("dull green").opacity(0.8))
        .zIndex(10)
        .ignoresSafeArea()
    }
}

struct RowView: View {
    @State private var selectedMode = "Operation Strix"
    @State private var ballGiven = 0
    var levelName: String

    var body: some View {
        HStack {
            Text(levelName)
                .foregroundColor(.white)
                .fontWeight(.bold)
                .fontDesign(.monospaced)
            Spacer()
            ModeView(selectedMode: $selectedMode, ballGiven: $ballGiven, pickerColor: Color("dark green"))
            NavigationLink(value: Page.playPage) {
                Button(action: {
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
            }
        }
        .padding(10)
        .background(Color("dark grey"))
//        .background(Color("dark green"))
        .cornerRadius(5)
    }
}

struct ModeView: View {
    @Binding var selectedMode: String
    @Binding var ballGiven: Int
    var pickerColor: Color
    var codeNames: [String] = ["Operation Strix", "Operation Eden", "Operation Gigi"]

    var body: some View {
        HStack {
            Menu {
                Picker("Game Mode", selection: $selectedMode) {
                    ForEach(codeNames, id: \.self) { mode in
                        Text(mode)
                    }
                }
            } label: {
                Text(selectedMode)
                    .fontDesign(.monospaced)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(pickerColor)
                    .cornerRadius(10)
            }

            if selectedMode == "Operation Gigi"{
                BallEditorView(ballGiven: $ballGiven)
            }
        }
    }
}

struct BallEditorView: View {
    @Binding var ballGiven: Int

    var body: some View {
        HStack {
            Text("Ball Given: \(ballGiven)")
                .fontDesign(.monospaced)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Button(action: { ballGiven += 1 }) {
                Image(systemName: "plus")
                    .foregroundColor(.white)
            }
            .padding(.leading, 25)
            Button(action: { ballGiven -= 1 }) {
                Image(systemName: "minus")
                    .foregroundColor(.white)
            }
        }
    }
}

struct Select_Previews: PreviewProvider {
    static var previews: some View {
        SelectView()
    }
}

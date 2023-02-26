//
//  ControlPanelView.swift
//  Peggle
//
//  Created by James Chiu on 28/1/23.
//

import SwiftUI

struct PegPanelView: View {
    @ObservedObject var designBoardVM: DesignBoardVM

    var body: some View {
        HStack(spacing: 20) {
            /// Assumes palette is static upon loaded
            if designBoardVM.hasSelectedPeg {
                TransformView(designBoardVM: designBoardVM)
            } else {
                PaletteView(designBoardVM: designBoardVM)
                Spacer()
            }
            PegButtonView(pegVariant: "delete", action: {
                designBoardVM.switchToDeletePeg()
            }, diameter: 60)
            .opacity(designBoardVM.selectedAction == Action.delete ? 1 : 0.5)
        }
        .padding(.all, 20)
        .background(.white)
    }
}

struct ControlPanelView: View {
    @EnvironmentObject var levels: Levels
    @EnvironmentObject var renderAdaptor: RenderAdaptor
    @State private var levelName = ""
    @ObservedObject var designBoardVM: DesignBoardVM
    @Binding var path: [Mode]

    var body: some View {
        HStack {
            Button("LOAD") {
                if let loadedBoard = levels.loadLevel(levelName) {
                    designBoardVM.setNewBoard(DesignBoard(board: loadedBoard))
                } else {
                    designBoardVM.setNewBoard(DesignBoard.getEmptyBoard())
                }
            }
            Button("SAVE") { levels.saveLevel(levelName: levelName, updatedBoard: designBoardVM.designedBoard) }
            Button("RESET") { designBoardVM.removeAllPegs() }
            Button("DONE") { _ = path.popLast() }
            TextField("Level Name", text: $levelName)
                .textFieldStyle(.roundedBorder)
                .border(.gray)
            createGameWorld()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .padding(.top, 40)
        .background(.white)
    }

    func createGameWorld() -> some View {
        NavigationLink(value: Mode.playMode) {
            Button("START") {
                path.append(Mode.playMode)
                renderAdaptor.setBackBoard(designBoardVM.designedBoard)
            }
            .foregroundColor(Color.blue)
        }
    }
}

struct TransformView: View {
    @ObservedObject var designBoardVM: DesignBoardVM

    var body: some View {
        HStack(spacing: 40) {
            getScalableAxis()
            VStack {
                Text("Rotation")
                    .font(.headline)
                Slider(
                    value: $designBoardVM.selectedPeg.sliderRotation,
                    in: -180...180,
                    step: 0.01,
                    label: { Text("Rotation") },
                    minimumValueLabel: { Text("-180") },
                    maximumValueLabel: { Text("180") }
                )
            }
        }
    }

    func getScalableAxis() -> some View {
        return VStack {
            if designBoardVM.selectedPeg.isCircle {
                Text("Radius")
                    .font(.headline)
                Slider(
                    value: $designBoardVM.selectedPeg.sliderXScale,
                    in: 1...3,
                    step: 0.01,
                    label: { Text("Radius") },
                    minimumValueLabel: { Text("1") },
                    maximumValueLabel: { Text("3") }
                )
            } else {
                Text("Width")
                    .font(.headline)
                Slider(
                    value: $designBoardVM.selectedPeg.sliderXScale,
                    in: 1...3,
                    step: 0.01,
                    label: { Text("Width") },
                    minimumValueLabel: { Text("1") },
                    maximumValueLabel: { Text("3") }
                )
                Text("Height")
                    .font(.headline)
                Slider(
                    value: $designBoardVM.selectedPeg.sliderYScale,
                    in: 1...3,
                    step: 0.01,
                    label: { Text("Height") },
                    minimumValueLabel: { Text("1") },
                    maximumValueLabel: { Text("3") }
                )
            }
        }
    }
}

struct PaletteView: View {
    @ObservedObject var designBoardVM: DesignBoardVM
    let columns = [GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(adaptPalette(DesignBoard.palette), id: \.self) { variantGroup in
                HStack {
                    ForEach(variantGroup, id: \.self) { variant in
                        PegButtonView(
                            pegVariant: variant.pegSprite,
                            action: { designBoardVM.switchToAddPeg(variant) },
                            diameter: 60)
                        .opacity(designBoardVM.isVariantActive(variant) ? 1 : 0.5)
                    }
                }
            }
            .offset(x: -80)
        }
    }

    func adaptPalette(_ palette: [PegVariant]) -> [[PegVariant]] {
        var groupsOfThree: [[PegVariant]] = []
        var i = 0
        var currGroup: [PegVariant] = []
        while i < palette.count {
            currGroup.append(palette[i])
            i += 1
            if i.isMultiple(of: 3) || i == palette.count {
                groupsOfThree.append(currGroup)
                currGroup = []
            }
        }
        return groupsOfThree
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

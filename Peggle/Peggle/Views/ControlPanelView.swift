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
            }, unitSize: Vector2.one * 60)
            .opacity(designBoardVM.selectedAction == Action.delete ? 1 : 0.5)
        }
        .padding(.all, 20)
        .background(Color("dark grey"))
    }
}

struct ControlPanelView: View {
    @EnvironmentObject var levels: Levels
    @EnvironmentObject var renderAdaptor: RenderAdaptor
    @State private var levelName = ""
    @State private var selectedMode = ModeMapper.codeNames[0]
    @State private var ballGiven = 0
    @ObservedObject var designBoardVM: DesignBoardVM
    @Binding var path: [Page]

    var body: some View {
        HStack {
            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                GridRow {
                    ActionButtonView(text: "LOAD") {
                        if let loadedBoard = levels.loadLevel(levelName) {
                            designBoardVM.setNewBoard(DesignBoard(board: loadedBoard))
                        } else {
                            designBoardVM.setNewBoard(DesignBoard.getEmptyBoard())
                        }
                    }
                    ActionButtonView(text: "SAVE") {
                        levels.saveLevel(levelName: levelName, updatedBoard: designBoardVM.designedBoard)
                    }
                }
                GridRow {
                    ActionButtonView(text: "RESET") { designBoardVM.removeAllPegs() }
                    ActionButtonView(text: "MENU") {
                        path.removeAll()
                    }
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

                ModeSelectionView(selectedMode: $selectedMode, ballGiven: $ballGiven, pickerColor: Color("dark green"))
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
        Button("GO!") {
            path.append(Page.playPage)
            renderAdaptor.setBoardAndMode(
                board: designBoardVM.designedBoard,
                gameMode: selectedMode,
                ballCount: ballGiven
            )
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

struct ActionButtonView: View {
    var text: String
    var color = Color("grey")
    var action: () -> Void

    var body: some View {
        Button(action: action) {
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
                    label: { Text("Rotation").fontDesign(.monospaced).fontWeight(.semibold).foregroundColor(.white) },
                    minimumValueLabel: { Text("-180") },
                    maximumValueLabel: { Text("180") }
                )
            }
        }
    }

    func getScalableAxis() -> some View {
        VStack {
            if designBoardVM.selectedPeg.isCircle {
                Text("Radius")
                    .font(.headline)
                Slider(
                    value: $designBoardVM.selectedPeg.sliderXScale,
                    in: 1...3,
                    step: 0.01,
                    label: { Text("Radius").fontDesign(.monospaced).fontWeight(.semibold).foregroundColor(.white) },
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
                    label: { Text("Width").fontDesign(.monospaced).fontWeight(.semibold).foregroundColor(.white) },
                    minimumValueLabel: { Text("1") },
                    maximumValueLabel: { Text("3") }
                )
                Text("Height")
                    .font(.headline)
                Slider(
                    value: $designBoardVM.selectedPeg.sliderYScale,
                    in: 1...3,
                    step: 0.01,
                    label: { Text("Height").fontDesign(.monospaced).fontWeight(.semibold).foregroundColor(.white) },
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
        HStack {
            layoutPalette(PegMapper.palette)
            layoutPalette(PegMapper.blockPalette)
        }
        .frame(width: 300)
        .padding()
        .background(Color("grey"))
        .cornerRadius(5)
    }

    func layoutPalette(_ palette: [PegVariant]) -> some View {
        LazyVGrid(columns: columns) {
            ForEach(adaptPalette(palette: palette, groupSize: 3), id: \.self) { variantGroup in
                HStack {
                    ForEach(variantGroup, id: \.self) { variant in
                        PegButtonView(
                            pegVariant: variant.pegSprite,
                            action: { designBoardVM.switchToAddPeg(variant) },
                            unitSize: variant.size * 0.8)
                        .opacity(designBoardVM.isVariantActive(variant) ? 1 : 0.5)
                    }
                }
            }
        }
    }

    func adaptPalette(palette: [PegVariant], groupSize: Int) -> [[PegVariant]] {
        var groups: [[PegVariant]] = []
        var i = 0
        var currGroup: [PegVariant] = []
        while i < palette.count {
            currGroup.append(palette[i])
            i += 1
            if i.isMultiple(of: groupSize) || i == palette.count {
                groups.append(currGroup)
                currGroup = []
            }
        }
        return groups
    }
}

struct PegButtonView: View {
    let pegVariant: String
    let action: () -> Void
    let unitSize: Vector2
    var body: some View {
        Button(action: action) {
            Image(pegVariant)
                .resizable()
                .frame(width: unitSize.x, height: unitSize.y)
        }
    }
}

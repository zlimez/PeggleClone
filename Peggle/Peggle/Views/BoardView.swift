//
//  BoardView.swift
//  Peggle
//
//  Created by James Chiu on 28/1/23.
//

import SwiftUI
import Foundation

struct BoardView: View {
    @State private var boardViewModel = BoardViewModel(board: Board(allPegs: [
        Peg(pegColor: "peg-orange", radius: 30, x: 60, y: 60),
        Peg(pegColor: "peg-blue", radius: 30, x: 150, y: 150)
    ]), maxPegRadius: 30)

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                GeometryReader { geo in
                    fillPlayArea(geo)
                }
                ForEach($boardViewModel.allPegVMs) { pegVM in
                    PegView(pegVM: pegVM, parentBoardVM: $boardViewModel)
                }
            }
            .onTapGesture { location in
                boardViewModel.tryAddPegAt(x: location.x, y: location.y)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            ControlPanelView(boardViewModel: $boardViewModel)
        }
        .ignoresSafeArea()
//        .onAppear {
//            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
//        }
    }

    func fillPlayArea(_ geo: GeometryProxy) -> some View {
        if !boardViewModel.gridInitialized {
            DispatchQueue.main.async { boardViewModel.initEmptyGrid(geo.size) }
        }

        return Image("background")
            .resizable()
            .scaledToFill()
            .frame(width: geo.size.width)
    }
}

/// Each peg should detect a drag to move the peg around or a long tap to signal its deletion
struct PegView: View {
    @Binding var pegVM: PegViewModel
    @Binding var parentBoardVM: BoardViewModel
    @GestureState private var startLocation: CGPoint?
    let dragPressDistanceThreshold: CGFloat = 5

    var body: some View {
        Image(pegVM.color)
            .resizable()
            .frame(width: pegVM.diameter, height: pegVM.diameter)
            .position(x: pegVM.x, y: pegVM.y)
            .gesture(drag)
            .simultaneousGesture(tap)
            .simultaneousGesture(longPress)
    }

    var tap: some Gesture {
        TapGesture()
            .onEnded { _ in parentBoardVM.tryRemovePeg(isLongPress: false, targetPegVM: pegVM)
            }
    }

    var longPress: some Gesture {
        LongPressGesture(minimumDuration: 0.4, maximumDistance: dragPressDistanceThreshold)
            .onEnded { _ in
            parentBoardVM.tryRemovePeg(isLongPress: true, targetPegVM: pegVM)
            }
    }

    var drag: some Gesture {
        DragGesture(minimumDistance: dragPressDistanceThreshold)
            .onChanged { value in
                withAnimation(.linear) {
                    var destination = startLocation ?? CGPoint(x: pegVM.x, y: pegVM.y)
                    destination.x += value.translation.width
                    destination.y += value.translation.height
                    parentBoardVM.tryMovePeg(targetPegVM: pegVM, destination: destination)
                }
            }
            .updating($startLocation) { _, startLocation, _ in
                startLocation = startLocation ?? CGPoint(x: pegVM.x, y: pegVM.y)
            }
            .onEnded { _ in
                pegVM.completeDrag()
            }
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BoardView()
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (4th generation)"))
        }
    }
}

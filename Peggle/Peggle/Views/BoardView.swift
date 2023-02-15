//
//  BoardView.swift
//  Peggle
//
//  Created by James Chiu on 28/1/23.
//

import SwiftUI
import Foundation

struct BoardView: View {
    @State private var designBoardVM = DesignBoardVM.getEmptyBoard()
    @Binding var path: [Mode]

    var body: some View {
        VStack(spacing: 0) {
            ZStack { 
                GeometryReader { geo in
                    fillPlayArea(geo)
                }
                ForEach($designBoardVM.pegVMs) { pegVM in
                    PegView(pegVM: pegVM, parentBoardVM: $designBoardVM)
                }
            }
            .onTapGesture { location in
                designBoardVM.tryAddPegAt(x: location.x, y: location.y)
            }
            .ignoresSafeArea()

            ControlPanelView(designBoardVM: $designBoardVM, path: $path)
        }
    }

    func fillPlayArea(_ geo: GeometryProxy) -> some View {
        if !DesignBoard.dimInitialized {
            DispatchQueue.main.async { designBoardVM.initGrid(geo.size) }
        }

        return Image("background")
            .resizable()
            .scaledToFill()
            .frame(width: geo.size.width)
    }
}

/// Each peg should detect a drag to move the peg around or a long tap to signal its deletion
struct PegView: View {
    @Binding var pegVM: PegVM
    @Binding var parentBoardVM: DesignBoardVM
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
            .onEnded { _ in parentBoardVM.tryRemovePeg(isLongPress: false, targetPeg: pegVM.peg)
            }
    }

    var longPress: some Gesture {
        LongPressGesture(minimumDuration: 0.4, maximumDistance: dragPressDistanceThreshold)
            .onEnded { _ in
                parentBoardVM.tryRemovePeg(isLongPress: true, targetPeg: pegVM.peg)
            }
    }

    var drag: some Gesture {
        DragGesture(minimumDistance: dragPressDistanceThreshold)
            .onChanged { value in
                withAnimation(.linear) {
                    var destination = startLocation ?? CGPoint(x: pegVM.x, y: pegVM.y)
                    destination.x += value.translation.width
                    destination.y += value.translation.height
                    parentBoardVM.tryMovePeg(targetPeg: pegVM.peg, destination: destination)
                }
            }
            .updating($startLocation) { _, startLocation, _ in
                startLocation = startLocation ?? CGPoint(x: pegVM.x, y: pegVM.y)
            }
    }
}

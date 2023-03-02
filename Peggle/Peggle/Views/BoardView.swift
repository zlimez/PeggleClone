//
//  BoardView.swift
//  Peggle
//
//  Created by James Chiu on 28/1/23.
//

import SwiftUI
import Foundation

struct BoardView: View {
    @StateObject var designBoardVM = DesignBoardVM()
    @Binding var path: [Page]

    var body: some View {
        VStack(spacing: 0) {
            ControlPanelView(designBoardVM: designBoardVM, path: $path)

            ZStack {
                GeometryReader { geo in fillPlayArea(geo) }

                ForEach(designBoardVM.pegVMs) { pegVM in
                    PegView(pegVM: pegVM, parentBoardVM: designBoardVM)
                }
            }
            .onTapGesture { location in
                if !designBoardVM.tryAddPegAt(x: location.x, y: location.y) {
                    designBoardVM.deselectPeg()
                }
            }

            PegPanelView(designBoardVM: designBoardVM)
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
    }

    func fillPlayArea(_ geo: GeometryProxy) -> some View {
        if !DesignBoard.dimInitialized {
            DispatchQueue.main.async { designBoardVM.initDim(geo.size) }
        }

        return Image("poster")
            .resizable()
            .scaledToFill()
            .frame(width: geo.size.width)
    }
}

/// Each peg should detect a drag to move the peg around or a long tap to signal its deletion
struct PegView: View {
    var pegVM: PegVM
    @ObservedObject var parentBoardVM: DesignBoardVM
    @GestureState private var startLocation: CGPoint?
    let dragPressDistanceThreshold: CGFloat = 5

    var body: some View {
        Image(pegVM.pegSprite)
            .resizable()
            .frame(width: pegVM.width, height: pegVM.height)
            .rotationEffect(.degrees(pegVM.rotation))
            .position(x: pegVM.x, y: pegVM.y)
            .gesture(drag)
            .simultaneousGesture(tap)
            .simultaneousGesture(longPress)
    }

    var tap: some Gesture {
        TapGesture()
            .onEnded { _ in parentBoardVM.selectOrRemovePeg(isLongPress: false, targetPegVM: pegVM)
            }
    }

    var longPress: some Gesture {
        LongPressGesture(minimumDuration: 0.4, maximumDistance: dragPressDistanceThreshold)
            .onEnded { _ in
                parentBoardVM.selectOrRemovePeg(isLongPress: true, targetPegVM: pegVM)
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
    }
}

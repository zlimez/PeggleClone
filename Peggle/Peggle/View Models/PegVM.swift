//
//  PegViewModel.swift
//  Peggle
//
//  Created by James Chiu on 30/1/23.
//

import Foundation

class PegVM: Identifiable, Equatable {
    static let dummyPegVM = PegVM(designPeg: DesignPeg.dummyDesignPeg, parentBoard: DesignBoard.dummyBoard)
    let id: Int
    var parentBoard: DesignBoard
    var designPeg: DesignPeg
    var sliderXScale: CGFloat = 1 {
        willSet {
            fwdSliderScale()
        }
    }
    var sliderYScale: CGFloat = 1 {
        willSet {
            fwdSliderScale()
        }
    }
    var sliderRotation: CGFloat = 0 {
        willSet {
            fwdSliderRotation()
        }
    }
    var isCircle: Bool {
        designPeg.isCircle()
    }

    init(designPeg: DesignPeg, parentBoard: DesignBoard) {
        self.id = designPeg.id
        self.designPeg = designPeg
        self.parentBoard = parentBoard
    }

    var x: CGFloat { designPeg.x }
    var y: CGFloat { designPeg.y }
    var width: CGFloat { designPeg.width }
    var height: CGFloat { designPeg.height }
    var pegSprite: String { designPeg.pegSprite }
    var rotation: CGFloat { Math.rad2Deg(designPeg.rotation) }

    func fwdSliderScale() {
        parentBoard.tryScalePeg(
            targetPeg: designPeg,
            newScale: Vector2(x: sliderXScale, y: sliderYScale)
        )
    }

    func fwdSliderRotation() {
        let unsignedRotation = sliderRotation >= 0 ? 360 + sliderRotation : sliderRotation
        parentBoard.tryRotatePeg(targetPeg: designPeg, newRotation: Math.deg2Rad(unsignedRotation))
    }

    static func == (lhs: PegVM, rhs: PegVM) -> Bool {
        lhs.designPeg == rhs.designPeg
    }
}

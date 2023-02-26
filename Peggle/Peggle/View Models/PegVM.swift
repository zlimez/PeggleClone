//
//  PegViewModel.swift
//  Peggle
//
//  Created by James Chiu on 30/1/23.
//

import Foundation

class PegVM: Identifiable, Equatable {
    let id: Int
    // TODO: Generalize peg definition
    let isCircle = true
    var peg: Peg
    var sliderXScale: CGFloat = 1 {
        willSet {
            print(newValue)
            fwdSliderScale()
        }
    }
    var sliderYScale: CGFloat = 1 {
        willSet {
            print(newValue)
            fwdSliderScale()
        }
    }
    var sliderRotation: CGFloat = 0 {
        willSet {
            print(newValue)
            fwdSliderRotation()
        }
    }

    init(peg: Peg) {
        self.id = peg.id
        self.peg = peg
    }

    var x: CGFloat {
        peg.transform.position.x
    }

    var y: CGFloat {
        peg.transform.position.y
    }

    var diameter: CGFloat {
        peg.unitRadius * 2 * peg.transform.scale.x
    }

    var color: String {
        peg.pegColor
    }

    func fwdSliderScale() {
        // TODO: Move actual scaling and rotation to model
        if isCircle {
            peg.transform.scale = Vector2(x: sliderXScale, y: sliderXScale)
        } else {
            peg.transform.scale = Vector2(x: sliderXScale, y: sliderYScale)
        }
    }

    func fwdSliderRotation() {
        peg.transform.rotation = Math.deg2Rad(sliderRotation)
    }

    static func == (lhs: PegVM, rhs: PegVM) -> Bool {
        lhs.peg == rhs.peg
    }
}

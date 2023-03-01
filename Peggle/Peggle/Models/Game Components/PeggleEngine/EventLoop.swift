//
//  EventLoop.swift
//  Peggle
//
//  Created by James Chiu on 24/2/23.
//

import Foundation
import QuartzCore

final class EventLoop {
    let preferredFrameRate: Float
    var activeDisplayLink: CADisplayLink?
    var step: ((Double) -> Void)?
    var gameTime: Double {
        guard let displayLink = activeDisplayLink else {
            return 0
        }

        return displayLink.timestamp
    }

    init(preferredFrameRate: Float = 120) {
        self.preferredFrameRate = preferredFrameRate
    }

    func start(_ step: @escaping (Double) -> Void) {
        self.step = step
        activeDisplayLink?.invalidate()
        activeDisplayLink = CADisplayLink(target: self, selector: #selector(iterate))
        activeDisplayLink?.preferredFrameRateRange = CAFrameRateRange(
            minimum: 75, maximum: 150, __preferred: preferredFrameRate)

        activeDisplayLink?.add(to: .current, forMode: .default)
    }
    
    func stop() {
        activeDisplayLink?.invalidate()
    }

    @objc func iterate() {
        guard let displayLink = activeDisplayLink else {
            fatalError("Physics step invoked before display link is created")
        }
        let deltaTime = displayLink.targetTimestamp - displayLink.timestamp

        guard let step = step else {
            return
        }
        step(deltaTime)
    }
}

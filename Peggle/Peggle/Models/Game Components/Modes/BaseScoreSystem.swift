//
//  BaseScoreSystem.swift
//  Peggle
//
//  Created by James Chiu on 25/2/23.
//

import Foundation

class BaseScoreSystem: ScoreSystem {
    var score: Int = 0

    static let streakMultipliers = [1, 2, 3, 5, 10]

    private var currTally = 0
    private var arrestStreak = 0
    private var collateralStreak = 0

    func registerListeners(_ gameWorld: GameWorld) {
        gameWorld.onPegRemoved.append(baseScoreUpdater)
        gameWorld.onShotFinalized.append(scoreUpdater)
    }

    lazy var baseScoreUpdater: (PegRB) -> Void = { [weak self] (pegRemoved: PegRB) in
        guard let self = self else {
            print("Object have been destroyed before its coroutine")
            return
        }

        if let enemyPeg = pegRemoved as? HostilePeg {
            self.updateBaseScore(enemyPeg)
            return
        }

        if let civilian = pegRemoved as? CivilianPeg {
            self.updateBaseScore(civilian)
            return
        }
    }

    func updateBaseScore(_ hostilePeg: HostilePeg) {
        arrestStreak += 1
        currTally += hostilePeg.captureReward
    }

    func updateBaseScore(_ civilianPeg: CivilianPeg) {
        collateralStreak += 1
        currTally -= civilianPeg.deathPenalty
    }

    // Apply streak based multiplier
    lazy var scoreUpdater: () -> Void = { [unowned self] in
        let absNetStreak = abs(arrestStreak - collateralStreak)
        var multiplier = 1
        if absNetStreak <= 2 {
            multiplier = BaseScoreSystem.streakMultipliers[0]
        } else if absNetStreak <= 5 {
            multiplier = BaseScoreSystem.streakMultipliers[1]
        } else if absNetStreak <= 8 {
            multiplier = BaseScoreSystem.streakMultipliers[2]
        } else if  absNetStreak <= 15 {
            multiplier = BaseScoreSystem.streakMultipliers[3]
        } else {
            multiplier = BaseScoreSystem.streakMultipliers[4]
        }
        score += currTally * multiplier
        currTally = 0
        collateralStreak = 0
        arrestStreak = 0
    }

    func reset() {
        score = 0
        currTally = 0
        arrestStreak = 0
        collateralStreak = 0
    }
}

class CivilianScoreSystem: BaseScoreSystem {
    var civilianKilled: Int = 0
    var hostileKilled: Int = 0

    override func updateBaseScore(_ civilianPeg: CivilianPeg) {
        super.updateBaseScore(civilianPeg)
        civilianKilled += 1
    }

    override func updateBaseScore(_ hostilePeg: HostilePeg) {
        super.updateBaseScore(hostilePeg)
        hostileKilled += 1
    }
    
    override func reset() {
        super.reset()
        civilianKilled = 0
        hostileKilled = 0
    }
}

class NoScoreSystem: ScoreSystem {
    var score: Int = 0
    var hasHit = false
    var scoreUpdater: () -> Void = {}
    
    func registerListeners(_ gameWorld: GameWorld) {
        gameWorld.onBallHitPeg.append(loseOnCollision)
    }

    private lazy var loseOnCollision: (PegRB) -> Void = {
        [unowned self]
        _ in
        hasHit = true
    }

    func reset() {
        hasHit = false
    }
}

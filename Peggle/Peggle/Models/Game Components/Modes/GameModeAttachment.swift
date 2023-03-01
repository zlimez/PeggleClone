//
//  GameModeAttachment.swift
//  Peggle
//
//  Created by James Chiu on 27/2/23.
//

import Foundation

final class ModeMapper {
    static var codeNames: [String] = []
    static var modeToGameAttachmentTable: [String: any GameModeAttachment] = [:]
    static var defaultMode: any GameModeAttachment = {
        let standardMode = "Operation Strix"
        let beatScoreMode = "Operation Eden"
        let siamMode = "Operation Gigi"
        ModeMapper.codeNames.append(standardMode)
        ModeMapper.codeNames.append(beatScoreMode)
        ModeMapper.codeNames.append(siamMode)
        let defaultMode = StandardAttachment()
        modeToGameAttachmentTable[standardMode] = defaultMode
        modeToGameAttachmentTable[beatScoreMode] = TimedHighScoreAttachment()
        modeToGameAttachmentTable[siamMode] = SiamAttachment()
        return defaultMode
    }()
}

protocol GameModeAttachment {
    associatedtype Evaluator: WinLoseEvaluator
    var canEditBallCount: Bool { get }
    var scoreSystem: ScoreSystem { get }
    var winLoseEvaluator: Evaluator { get }
    var configurer: WorldConfig<Evaluator> { get }

    func setUpWorld(gameWorld: GameWorld, pegBodies: Set<PegRB>)

    func evaluate(gameWorld: GameWorld, playState: inout PlayState)
}

extension GameModeAttachment {
    var canEditBallCount: Bool {
        false
    }

    func reset() {
        winLoseEvaluator.reset()
        scoreSystem.reset()
    }

    func setUpWorld(gameWorld: GameWorld, pegBodies: Set<PegRB>) {
        configurer.configWorld(gameWorld, pegBodies, winLoseEvaluator)
        scoreSystem.registerListeners(gameWorld)
    }

    func evaluate(gameWorld: GameWorld, playState: inout PlayState) {
        guard let assignedScorer = scoreSystem as? Self.Evaluator.Scorer else {
            fatalError("Mismatch in score and evaluator pair")
        }
        playState = winLoseEvaluator.evaluateGameState(gameWorld: gameWorld, scoreSystem: assignedScorer)
    }
}

final class TimedHighScoreAttachment: GameModeAttachment {
    var scoreSystem: ScoreSystem
    var winLoseEvaluator: TimedHighScoreEvaluator
    var configurer = WorldConfig(
        configWorld: { (gameWorld: GameWorld, pegBodies: Set<PegRB>, evaluator: TimedHighScoreEvaluator) in
            var hostileCount = 0
            // Mid tier streak expected
            let midTierIndex = BaseScoreSystem.streakMultipliers.count / 2
            let expectedMultiplier = BaseScoreSystem.streakMultipliers[midTierIndex]
            var aggBaseScore = 0
            for pegBody in pegBodies {
                if let hostilePeg = pegBody as? HostilePeg {
                    aggBaseScore += hostilePeg.captureReward
                    hostileCount += 1
                }
            }

            let perBallDropTime: Double = 10
            let expectedHit: Double = 3.5
            let timeGiven = perBallDropTime * Double(hostileCount) / expectedHit
            evaluator.targetScore = aggBaseScore * expectedMultiplier
            gameWorld.timer.isActive = true
            gameWorld.timer.timeLeft = timeGiven
            gameWorld.ballCounter.isActive = false
            gameWorld.score.isActive = true
            gameWorld.targetScore.isActive = true
            gameWorld.civTally.isActive = false
        }
    )

    init(
        scoreSystem: ScoreSystem = CivilianScoreSystem(),
        winLoseEvaluator: TimedHighScoreEvaluator = TimedHighScoreEvaluator()
    ) {
        self.scoreSystem = scoreSystem
        self.winLoseEvaluator = winLoseEvaluator
    }
}

final class StandardAttachment: GameModeAttachment {
    var scoreSystem: ScoreSystem
    var winLoseEvaluator: StandardEvaluator
    var configurer = WorldConfig(
        configWorld: { (gameWorld: GameWorld, pegBodies: Set<PegRB>, evaluator: StandardEvaluator) in
            var civilianSurvivability: [CivilianPeg: CGFloat] = [:]
            var hostiles: [HostilePeg] = []
            var bombs: [BoomPeg] = []
            // for each civilian check the hostile pegs and bomb pegs near it
            for pegBody in pegBodies {
                if let civilian = pegBody as? CivilianPeg {
                    civilianSurvivability[civilian] = 0
                } else if let hostile = pegBody as? HostilePeg {
                    hostiles.append(hostile)
                } else if let bomb = pegBody as? BoomPeg {
                    bombs.append(bomb)
                }
            }

            let extendedRadius: CGFloat = 100
            let threatModifier: CGFloat = 0.1
            for civilian in civilianSurvivability.keys {
                var thisSurvivability: CGFloat = 1
                let avgRadius = (civilian.transform.scale.x * civilian.unitWidth
                                 + civilian.transform.scale.y * civilian.unitHeight) / 4
                let vulnerabilityRadius = avgRadius + extendedRadius
                for hostile in hostiles {
                    let proximity = Vector2.distance(a: hostile.transform.position, b: civilian.transform.position)
                    if proximity <= vulnerabilityRadius {
                        let threatPosed = threatModifier * extendedRadius / (proximity - avgRadius)
                        thisSurvivability = max(0, thisSurvivability - threatPosed)
                    }
                }
                civilianSurvivability[civilian] = thisSurvivability
            }

            let bombThreat: CGFloat = 0.1
            for bomb in bombs {
                let bombRadius = (bomb.transform.scale.x * bomb.unitWidth
                                  + bomb.transform.scale.y * bomb.unitHeight) / 4 * bomb.explosionScale
                for civilian in civilianSurvivability.keys {
                    let proximity = Vector2.distance(a: bomb.transform.position, b: civilian.transform.position)
                    if proximity <= bombRadius {
                        guard let thisSurvivability = civilianSurvivability[civilian] else {
                            fatalError("Something wrong with swift")
                        }
                        civilianSurvivability[civilian] = max(0, thisSurvivability - bombThreat)
                    }
                }
            }

            let totalSurvivability = civilianSurvivability.values.reduce(0, { result, survivability in
                result + survivability
            })
            let allowedKills = civilianSurvivability.count - Int(round(totalSurvivability))

            evaluator.allowedKills = allowedKills
            evaluator.hostileCount = hostiles.count
            // Expected to hit an average of 5 hostile balls per shot
            let ballGiven = Int(ceil(Float(hostiles.count) / 5))
            gameWorld.ballCounter.isActive = true
            gameWorld.ballCounter = BallCounter(ballCount: ballGiven)
            gameWorld.civTally.isActive = true
            gameWorld.score.isActive = true
            gameWorld.targetScore.isActive = false
            gameWorld.timer.isActive = false
        }
    )

    init(
        scoreSystem: ScoreSystem = CivilianScoreSystem(),
        winLoseEvaluator: StandardEvaluator = StandardEvaluator()
    ) {
        self.scoreSystem = scoreSystem
        self.winLoseEvaluator = winLoseEvaluator
    }
}

final class SiamAttachment: GameModeAttachment {
    var canEditBallCount: Bool {
        true
    }

    var scoreSystem: ScoreSystem
    var winLoseEvaluator: NoHitEvaluator
    var configurer = WorldConfig(
        configWorld: { (gameWorld: GameWorld, _: Set<PegRB>, _: NoHitEvaluator) in
            // Let player determine the number of balls to clear
            gameWorld.timer.isActive = false
            gameWorld.ballCounter.isActive = true
            gameWorld.score.isActive = false
            gameWorld.targetScore.isActive = false
            gameWorld.civTally.isActive = false
        }
    )

    init(
        scoreSystem: ScoreSystem = NoScoreSystem(),
        winLoseEvaluator: NoHitEvaluator = NoHitEvaluator()
    ) {
        self.scoreSystem = scoreSystem
        self.winLoseEvaluator = winLoseEvaluator
    }
}

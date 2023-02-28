//
//  GameModeAttachment.swift
//  Peggle
//
//  Created by James Chiu on 27/2/23.
//

import Foundation

final class ModeMapper {
    static var codeNames: [String] = []
    static var modeToGameAttachmentTable: [String: GameModeAttachment] = [:]
}

final class GameModeAttachment {
    static var defaultMode: GameModeAttachment = {
        let standardMode = "Operation Strix"
        let beatScoreMode = "Operation Eden"
        let siamMode = "Operation Gigi"
        let defaultMode = GameModeAttachment()
        ModeMapper.modeToGameAttachmentTable[standardMode] = defaultMode
        ModeMapper.modeToGameAttachmentTable[beatScoreMode] = GameModeAttachment(
            configurer: TimedBeatScoreConfig(),
            scoreSystem: BaseScoreSystem(),
            winLoseEvaluator: TimedHighScoreEvaluator()
        )
        ModeMapper.modeToGameAttachmentTable[siamMode] = GameModeAttachment(
            configurer: siamConfig(),
            scoreSystem: NoScoreSystem(),
            winLoseEvaluator: NoHitEvaluator(),
            canEditBallCount: true
        )
        ModeMapper.codeNames.append(standardMode)
        ModeMapper.codeNames.append(beatScoreMode)
        ModeMapper.codeNames.append(siamMode)
        return defaultMode
    }()

    let configurer: WorldConfig
    let scoreSystem: ScoreSystem
    let winLoseEvaluator: WinLoseEvaluator
    let canEditBallCount: Bool

    init(
        configurer: any WorldConfig = StandardConfig(),
        scoreSystem: any ScoreSystem = CivilianScoreSystem(),
        winLoseEvaluator: any WinLoseEvaluator = StandardEvaluator(),
        canEditBallCount: Bool = false
    ) {
        self.configurer = configurer
        self.scoreSystem = scoreSystem
        self.winLoseEvaluator = winLoseEvaluator
        self.canEditBallCount = canEditBallCount
    }

    func setUpWorld(gameWorld: GameWorld, pegBodies: [PegRB]) {
        /// Add a world configuration protocol, start timer, set highscore to beat etc add them to graphic objects
        configurer.configWorld(gameWorld: gameWorld, pegBodies: pegBodies, evaluator: winLoseEvaluator)
        scoreSystem.registerListeners(gameWorld)
    }

    func evaluate(gameWorld: GameWorld, playState: inout PlayState) {
        playState = winLoseEvaluator.evaluateGameState(gameWorld: gameWorld, scoreSystem: scoreSystem)
    }

    func reset() {
        scoreSystem.reset()
    }
}

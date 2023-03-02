//
//  Setup.swift
//  Peggle
//
//  Created by James Chiu on 27/2/23.
//

import Foundation

final class WorldConfig<T: WinLoseEvaluator> {
    var configWorld: (GameWorld, Set<PegRB>, T) -> Void

    init(configWorld: @escaping (GameWorld, Set<PegRB>, T) -> Void) {
        self.configWorld = configWorld
    }
}

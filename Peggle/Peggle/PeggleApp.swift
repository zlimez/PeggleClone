//
//  PeggleApp.swift
//  Peggle
//
//  Created by James Chiu on 25/1/23.
//

import SwiftUI

@main
struct PeggleApp: App {
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            MenuView()
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .active:
                break
            case .background:
                TrackPlayer.instance.stopBGM()
            case .inactive:
                break
            @unknown default:
                break
            }
        }
    }
}

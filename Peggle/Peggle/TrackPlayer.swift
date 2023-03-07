//
//  SoundPlayer.swift
//  Peggle
//
//  Created by James Chiu on 2/3/23.
//

import Foundation
import AVFoundation

final class TrackPlayer {
    static let instance = TrackPlayer()
    let audioEngine: AVAudioEngine
    let bgmPlayer: AVAudioPlayerNode
    var sfxPlayers: [AVAudioPlayerNode] = []
    var playerReadiness: [Bool] = []
    let trackNum: Int
    let defaultBgm = "bgm"
    private var currBgm: String = ""

    init(trackNum: Int = 10) {
        self.trackNum = trackNum
        self.audioEngine = AVAudioEngine()
        self.bgmPlayer = AVAudioPlayerNode()
        let mixer = audioEngine.mainMixerNode
        audioEngine.attach(bgmPlayer)
        audioEngine.connect(bgmPlayer, to: mixer, format: nil)

        for _ in 0..<trackNum {
            let sfxPlayer = AVAudioPlayerNode()
            audioEngine.attach(sfxPlayer)
            audioEngine.connect(sfxPlayer, to: mixer, format: nil)
            sfxPlayers.append(sfxPlayer)
            playerReadiness.append(true)
        }

        do {
            try audioEngine.start()
        } catch {
            print(error.localizedDescription)
        }
    }

    func playBGM(_ trackName: String) {
        guard let url = Bundle.main.url(forResource: trackName, withExtension: "mp3") else {
            return
        }

        if trackName == currBgm {
            return
        }

        do {
            if bgmPlayer.isPlaying {
                bgmPlayer.stop()
            }

            let audioFile = try AVAudioFile(forReading: url)
            let audioFormat = audioFile.processingFormat
            let audioFrameCount = UInt32(audioFile.length)
            let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)
            guard let avBuffer = audioFileBuffer else {
                return
            }
            try audioFile.read(into: audioFileBuffer!)

            bgmPlayer.volume = 0.8
            let mixer = audioEngine.mainMixerNode
            audioEngine.connect(bgmPlayer, to: mixer, format: avBuffer.format)
            bgmPlayer.scheduleBuffer(avBuffer, at: nil, options: .loops, completionHandler: nil)

            if !audioEngine.isRunning {
                try audioEngine.start()
            }
            bgmPlayer.play()
            currBgm = trackName
        } catch {
            print(error.localizedDescription)
        }
    }

    func stopBGM() {
        currBgm = ""
        bgmPlayer.stop()
        sfxPlayers.forEach { player in player.stop() }
        audioEngine.stop()
        audioEngine.reset()
    }

    func playSFX(_ trackName: String) {
        guard let url = Bundle.main.url(forResource: trackName, withExtension: "mp3") else {
            return
        }

        guard let playerIndex = playerReadiness.firstIndex(where: { $0 }) else {
            print("No available sfx players")
            return
        }
        let sfxPlayer = sfxPlayers[playerIndex]

        do {
            let audioFile = try AVAudioFile(forReading: url)
            let audioFormat = audioFile.processingFormat
            let audioFrameCount = UInt32(audioFile.length)
            let audioFileBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)
            guard let avBuffer = audioFileBuffer else {
                return
            }
            try audioFile.read(into: audioFileBuffer!)

            let mixer = audioEngine.mainMixerNode
            audioEngine.attach(sfxPlayer)
            audioEngine.connect(sfxPlayer, to: mixer, format: avBuffer.format)
            sfxPlayer.scheduleBuffer(avBuffer, at: nil, completionCallbackType: .dataPlayedBack) { [unowned self] _ in
                playerReadiness[playerIndex] = true
            }

            if !audioEngine.isRunning {
                try audioEngine.start()
            }
            sfxPlayer.play()
        } catch {
            print(error.localizedDescription)
        }
    }
}

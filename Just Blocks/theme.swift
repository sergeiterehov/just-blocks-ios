import Foundation
import SwiftUI
import AVKit

let blockSize = 20
let blockPadding = 2

let formater = NumberFormatter()
let mainFont = Font.system(size: 20, weight: .bold).monospaced()
let headerFont = Font.system(size: 40, weight: .bold).monospaced()
let smallFont = Font.system(size: 14, weight: .bold).monospaced()

func getColor(r: Int, g: Int, b: Int, a: Double = 1) -> UIColor {
    return UIColor(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, alpha: a)
}

let pallettes = [
    [getColor(r: 71, g: 134, b: 255), getColor(r: 244, g: 81, b: 93)],
    [getColor(r: 51, g: 141, b: 153), getColor(r: 76, g: 179, b: 115)],
    [getColor(r: 47, g: 115, b: 219), getColor(r: 90, g: 175, b: 216)],
    [getColor(r: 222, g: 117, b: 84), getColor(r: 221, g: 153, b: 85)],
    [getColor(r: 47, g: 115, b: 219), getColor(r: 140, g: 192, b: 148)],
    [getColor(r: 165, g: 90, b: 166), getColor(r: 90, g: 175, b: 216)],
    [getColor(r: 25, g: 169, b: 119), getColor(r: 195, g: 80, b: 81)],
    [getColor(r: 244, g: 81, b: 93), getColor(r: 245, g: 166, b: 35)],
]

struct Theme {
    static let success = getColor(r: 77, g: 202, b: 131)
    static let danger = getColor(r: 244, g: 81, b: 93)

    static let background = getColor(r: 25, g: 34, b: 40)
    static let border = getColor(r:255, g: 255, b: 255, a: 0.1)

    static let text = getColor(r: 255, g: 255, b: 255)
    static let textSecond = getColor(r: 124, g: 137, b: 171)
    static let textThird = getColor(r: 124, g: 137, b: 171, a: 0.5)
}

struct SoundPlayer {
    private var audioPlayer: AVAudioPlayer?

    init(name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch let error {
            print("Sound Error \(error.localizedDescription)")
        }
    }
    
    func play() {
        audioPlayer?.currentTime = 0.0
        audioPlayer?.play()
    }
}

let rotateSound = SoundPlayer(name: "rotate")
let moveSound = SoundPlayer(name: "move")
let dropSound = SoundPlayer(name: "drop")
let clearSound = SoundPlayer(name: "clear")
let tetrisSound = SoundPlayer(name: "tetris")
let levelUpSound = SoundPlayer(name: "level-up")
let gameOverSound = SoundPlayer(name: "game-over")

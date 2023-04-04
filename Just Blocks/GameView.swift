import SwiftUI
import AVFoundation

let debugAchievementsView = false

class GameState : ObservableObject {
    @Published var gameApprovedForCounter = false
}

struct GameView: View {
    @Environment(\.scenePhase) var scenePhase

    @ObservedObject private var model = GameModel()
    @ObservedObject private var state = GameState()
    
    @AppStorage("displayDotsField") private var displayDotsField = false
    
    @AppStorage("maxScore") private var maxScore = 0
    @AppStorage("gamesCounter") private var gamesCounter = 0
    
    @AppStorage("achievementTetris") private var achievementTetris = false
    @AppStorage("achievementLevel10") private var achievementLevel10 = false
    @AppStorage("achievement100000") private var achievement100000 = false
    @AppStorage("achievementGames1000") private var achievementGames1000 = false
    @AppStorage("achievementLevel18") private var achievementLevel18 = false
    
    @State var avoidTopOfScreen = false
    
    init() {
        // Configuring the audio session that does not stop other music and off when muted
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { print(error.localizedDescription) }

        model.onRun = { [self] in
            // reset local state
            state.gameApprovedForCounter = false
        }
        model.onRotate = {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            
            rotateSound.play()
        }
        model.onMove = {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            
            moveSound.play()
        }
        model.onDrop = {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            
            dropSound.play()
        }
        model.onClear = { [self] (y, lines) in
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
            state.gameApprovedForCounter = true
            
            clearSound.play()
            
            // TODO: clear animation
        }
        model.onTetris = { [self] (y, lines) in
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            
            state.gameApprovedForCounter = true
            
            if (!achievementTetris) {
                achievementTetris = true
                achievementSound.play()
            }

            tetrisSound.play()
            
            // TODO: clear animation
        }
        model.onLevelUp = { [self] in
            if (model.level > model.startLevel) {
                if (!achievementLevel10 && model.level == 10) {
                    achievementLevel10 = true
                    achievementSound.play()
                }
                
                if (!achievementLevel18 && model.level == 18) {
                    achievementLevel18 = true
                    achievementSound.play()
                }
            }

            levelUpSound.play()
        }
        model.onGameOver = { [self] in
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            
            if (state.gameApprovedForCounter) {
                gamesCounter += 1
            }
            
            if (model.score > maxScore) {
                maxScore = model.score
            }
            
            if (!achievement100000 && model.score >= 100000) {
                achievement100000 = true
                achievementSound.play()
            }
            
            if (!achievementGames1000 && gamesCounter >= 1000) {
                achievementGames1000 = true
                achievementSound.play()
            }
            
            gameOverSound.play()
        }
        
        // Random field
        for x in 0..<model.width {
            let height = Int.random(in: 1..<5)
            var cases = Block.allCases
            
            cases.removeFirst()

            for y in (model.height - height)..<model.height {
                model.field[y * model.width + x] = cases.randomElement()!
            }
        }
    }

    var body: some View {
        let inProgressColor = Color(model.inProgress ? Theme.success : model.inPause ? Theme.textThird : Theme.danger)
        let palletteIndex = model.level % pallettes.count

        GeometryReader { geometry in
            let smallScreen = geometry.size.height < 730
            let extraSmallScreen = geometry.size.width < 370
            
            let topOffset = avoidTopOfScreen
                ? max(5, geometry.size.height - (smallScreen ? 150 : 250) - 540)
                : 0
            
            let arrowButtonsSpace = extraSmallScreen ? 50.0 : 60.0

            Color(Theme.background).ignoresSafeArea()

            ZStack {
                ZStack {
                    GeometryReader { topGeometry in
                        ZStack {
                            if (model.inPause) {
                                Text("PAUSE")
                                    .padding(.bottom, 1)
                                    .font(mainFont)
                                    .foregroundColor(Color(Theme.text))
                                    .multilineTextAlignment(.center)
                                    .frame(width: 120, height: 60)
                                    .border(Color(Theme.background), width: 4)
                                    .background(Color(Theme.danger))
                            } else {
                                ZStack {
                                    Path()
                                        .background(Color(Theme.background))
                                        .onTapGesture {
                                            displayDotsField = !displayDotsField
                                        }
                                        .gesture(
                                            DragGesture()
                                                .onChanged { gesture in
                                                    if (gesture.translation.height > 100) {
                                                        avoidTopOfScreen = true
                                                    } else if (gesture.translation.height < -100) {
                                                        avoidTopOfScreen = false
                                                    }
                                                }
                                        )
                                    
                                    ZStack {
                                        ForEach(0..<model.height * model.width, id: \.self) { index in
                                            let y = index / model.width
                                            let x = index % model.width
                                            
                                            BlockView(
                                                block: model.field[index],
                                                palletteIndex: palletteIndex,
                                                dot: displayDotsField
                                            )
                                            .offset(x: CGFloat(x * blockSize), y: CGFloat(y * blockSize))
                                        }
                                    }
                                    
                                    TetrominoView(
                                        tetromino: model.current,
                                        offset: CGPoint(x: model.x, y: model.y),
                                        rotation: model.rotation,
                                        palletteIndex: palletteIndex
                                    )
                                }
                                .offset(x: 8, y: 8)
                                
                                if (!model.inProgress) {
                                    VStack {
                                        Text("TAP PLAY\nTO START")
                                            .padding(.bottom, 1)
                                            .font(mainFont)
                                            .foregroundColor(Color(Theme.text))
                                            .multilineTextAlignment(.center)
                                        Text("GAMES \(gamesCounter)")
                                            .font(smallFont)
                                            .foregroundColor(Color(Theme.text))
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(width: 150, height: 100)
                                    .border(Color(Theme.background), width: 4)
                                    .background(Color(Theme.danger))
                                }
                            }
                        }
                            .frame(width: 216, height: 416)
                            .border(inProgressColor, width: 6)
                            .position(x: 100, y: 200)
                            .offset(x: 26, y: 26)
                        
                        HUDView(model: model, maxScore: maxScore, inProgressColor: inProgressColor, palletteIndex: palletteIndex)
                            .offset(x: topGeometry.size.width - 100 - 23, y: 20)
                    }
                }
                    .frame(maxWidth: 440)
                    .offset(y: topOffset)
                
                DesignTetrominosView(palletteIndex: palletteIndex)
                    .offset(
                        x: geometry.size.width - (smallScreen ? 260 : 300),
                        y: geometry.size.height - 120
                    )
                    .opacity(0.7)
                
                ZStack {
                    if (achievementTetris || debugAchievementsView) {
                        TetrominoView(tetromino: Tetromino.I, palletteIndex: 3)
                            .frame(width: 80, height: 80)
                            .rotationEffect(Angle(degrees: 10))
                            .scaleEffect(0.3)
                            .position(x: 40, y: 40)
                    }
                    if (achievementLevel10 || debugAchievementsView) {
                        TetrominoView(tetromino: Tetromino.S, palletteIndex: 3)
                            .frame(width: 80, height: 80)
                            .rotationEffect(Angle(degrees: -5))
                            .scaleEffect(0.3)
                            .position(x: 40, y: 65)
                    }
                    if (achievement100000 || debugAchievementsView) {
                        TetrominoView(tetromino: Tetromino.L, palletteIndex: 3)
                            .frame(width: 80, height: 80)
                            .rotationEffect(Angle(degrees: -10))
                            .scaleEffect(0.3)
                            .position(x: 40, y: 90)
                    }
                    if (achievementGames1000 || debugAchievementsView) {
                        TetrominoView(tetromino: Tetromino.O, palletteIndex: 3)
                            .frame(width: 80, height: 80)
                            .rotationEffect(Angle(degrees: 10))
                            .scaleEffect(0.3)
                            .position(x: 65, y: 90)
                    }
                    if (achievementLevel18 || debugAchievementsView) {
                        TetrominoView(tetromino: Tetromino.T, palletteIndex: 3)
                            .frame(width: 80, height: 80)
                            .rotationEffect(Angle(degrees: -5))
                            .scaleEffect(0.3)
                            .position(x: 70, y: 65)
                    }
                }
                    .offset(
                        x: 0,
                        y: geometry.size.height - (smallScreen ? 120 : 100)
                    )
                    .blur(radius: 3)
                
                ZStack {
                    ZStack {
                        ControlButtonView(
                            icon: "arrow.left",
                            onTap: {
                                model.move(dx: -1)
                            },
                            extraSmallScreen: extraSmallScreen,
                            enableDas: true
                        )
                            .position(x: -arrowButtonsSpace, y: 0)
                        
                        ControlButtonView(
                            icon: "arrow.right",
                            onTap: {
                                model.move(dx: 1)
                            },
                            extraSmallScreen: extraSmallScreen,
                            enableDas: true
                        )
                            .position(x: arrowButtonsSpace, y: 0)
                        
                        ControlButtonView(
                            icon: "arrow.down",
                            onTap: {
                                model.softDrop = true
                            },
                            onUntap: {
                                model.softDrop = false
                            },
                            extraSmallScreen: extraSmallScreen
                        )
                            .position(x: 0, y: arrowButtonsSpace + 20)
                    }
                        .offset(x: 125, y: 0)
                        .opacity(model.inProgress ? 1 : 0.4)
                    
                    ControlButtonView(
                        icon: model.inProgress ? "arrow.clockwise" : "play.fill",
                        onTap: {
                            if (model.inProgress) {
                                model.rotate()
                            } else if (model.inPause) {
                                model.play()
                                
                                moveSound.play()
                            } else {
                                model.run()
                                
                                dropSound.play()
                            }
                        },
                        color: Color(model.inProgress ? Theme.textSecond : Theme.text),
                        padding: 34,
                        extraSmallScreen: extraSmallScreen
                    )
                        .font(.system(size: extraSmallScreen ? 24 : 30))
                        .position(x: geometry.size.width - 80, y: 0)
                }
                .offset(x: 0, y: geometry.size.height - (smallScreen ? 150 : 250))
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .inactive {
                model.pause()
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}

import SwiftUI
import AVFoundation

enum ScreenSize {
    case Normal
    case Small
    case ExtraSmall
}

var screenSize = ScreenSize.Normal

func updateScreenSize(size: CGSize) -> ScreenSize {
    if (size.height < 730) {
        screenSize = .Small
    } else if (size.width < 370) {
        screenSize = .ExtraSmall
    } else {
        screenSize = .Normal
    }
    
    return screenSize
}

struct GameView: View {
    @Environment(\.scenePhase) var scenePhase

    @ObservedObject private var model = GameModel()
    @ObservedObject private var state = globalGameState
    
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
            
            if (!state.achievementTetris) {
                state.achievementTetris = true
                achievementSound.play()
            }

            tetrisSound.play()
            
            // TODO: clear animation
        }
        model.onLevelUp = { [self] in
            if (model.level > model.startLevel) {
                if (!state.achievementLevel10 && model.level == 10) {
                    state.achievementLevel10 = true
                    achievementSound.play()
                }
                
                if (!state.achievementLevel18 && model.level == 18) {
                    state.achievementLevel18 = true
                    achievementSound.play()
                }
            }

            levelUpSound.play()
        }
        model.onGameOver = { [self] in
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            
            if (state.gameApprovedForCounter) {
                state.gamesCounter += 1
            }
            
            if (model.score > state.maxScore) {
                state.maxScore = model.score
            }
            
            if (!state.achievement100000 && model.score >= 100000) {
                state.achievement100000 = true
                achievementSound.play()
            }
            
            if (!state.achievementGames1000 && state.gamesCounter >= 1000) {
                state.achievementGames1000 = true
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
            // TODO: should use environment?
            let _ = updateScreenSize(size: geometry.size)

            let topOffset = avoidTopOfScreen
            ? max(5, geometry.size.height - (screenSize == .Small ? 150 : 250) - 540)
            : 0

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
                                            state.displayDotsField = !state.displayDotsField
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
                                                dot: state.displayDotsField
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
                                        Text("GAMES \(state.gamesCounter)")
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
                        
                        HUDView(model: model, maxScore: state.maxScore, inProgressColor: inProgressColor, palletteIndex: palletteIndex)
                            .offset(x: topGeometry.size.width - 100 - 23, y: 20)
                    }
                }
                    .frame(maxWidth: 440)
                    .offset(y: topOffset)
                
                DesignTetrominosView(palletteIndex: palletteIndex)
                    .offset(
                        x: geometry.size.width - (screenSize == .Small ? 260 : 300),
                        y: geometry.size.height - 120
                    )
                    .opacity(0.7)
                
                AchievementsView()
                    .offset(
                        x: 0,
                        y: geometry.size.height - (screenSize == .Small ? 120 : 100)
                    )
                    .blur(radius: 3)
                
                KeyboardView(size: geometry.size, model: model)
                    .offset(x: 0, y: geometry.size.height - (screenSize == .Small ? 150 : 250))
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

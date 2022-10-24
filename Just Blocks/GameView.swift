import SwiftUI

struct GameView: View {
    @ObservedObject private var model = GameModel()
    
    @AppStorage("maxScore") private var maxScore = 0
    
    @AppStorage("achievementTetris") private var achievementTetris = false
    @AppStorage("achievementLevel10") private var achievementLevel10 = false
    @AppStorage("achievement100000") private var achievement100000 = false

    @State private var downPressed = false
    @State private var leftPressed = false
    @State private var rightPressed = false
    @State private var rotatePressed = false
    
    init() {
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
        model.onClear = {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
            clearSound.play()
        }
        model.onTetris = { [self] in
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            
            achievementTetris = true

            tetrisSound.play()
        }
        model.onLevelUp = { [self] in
            if (model.level == 10) {
                achievementLevel10 = true
            }

            levelUpSound.play()
        }
        model.onGameOver = { [self] in
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            
            if (model.score > maxScore) {
                maxScore = model.score
            }
            
            if (model.score >= 100000) {
                achievement100000 = true
            }
            
            gameOverSound.play()
        }
    }

    var body: some View {
        let inProgressColor = model.inProgress ? Color(Theme.success) : Color(Theme.danger)
        let palletteIndex = model.level % pallettes.count

        GeometryReader { geometry in
            let smallScreen = geometry.size.height < 730

            Color(Theme.background).ignoresSafeArea()

            ZStack {
                ZStack {
                    Path(CGRect(x: -6, y: -6, width: 212, height: 412))
                        .stroke(inProgressColor, lineWidth: 6)
                    
                    ZStack {
                        ForEach(0..<model.height * model.width, id: \.self) { index in
                            let y = index / model.width
                            let x = index % model.width

                            BlockView(block: model.field[index], palletteIndex: palletteIndex)
                                .offset(x: CGFloat(x * blockSize), y: CGFloat(y * blockSize))
                        }
                    }
                    
                    TetrominoView(
                        tetromino: model.current,
                        offset: CGPoint(x: model.x, y: model.y),
                        rotation: model.rotation,
                        palletteIndex: palletteIndex
                    )
                    
                    if (!model.inProgress) {
                        Text("TAP PLAY TO PLAY")
                            .font(mainFont)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(Theme.text))
                            .frame(width: 180, height: 60)
                            .background(Color(Theme.danger))
                            .position(x: 100, y: 200)
                    }
                }
                    .offset(x: 26, y: 26)
                
                ZStack {
                    ZStack {
                        Path(CGRect(x: 0, y: 0, width: 100, height: 110))
                            .stroke(
                                Color(maxScore == model.score ? Theme.success : Theme.textThird),
                                lineWidth: 4
                            )
                        
                        Text("TOP\n\(formater.string(from: NSNumber(value: maxScore))!)")
                            .font(mainFont)
                            .foregroundColor(Color(Theme.textSecond))
                            .padding(.leading)
                            .frame(width: 100, alignment: .leading)
                            .position(x: 50, y: 30)
                        
                        Text("SCORE\n\(formater.string(from: NSNumber(value: model.score))!)")
                            .font(mainFont)
                            .foregroundColor(Color(Theme.text))
                            .padding(.leading)
                            .frame(width: 100, alignment: .leading)
                            .position(x: 50, y: 80)
                    }
                        .offset(x: 0, y: 0)
                    
                    ZStack {
                        Path(CGRect(x: 0, y: 0, width: 100, height: 60))
                            .stroke(Color(Theme.border), lineWidth: 3)
                        
                        Text("LINES\n\(model.lines)")
                            .font(mainFont)
                            .foregroundColor(Color(Theme.text))
                            .padding(.leading)
                            .frame(width: 100, alignment: .leading)
                            .position(x: 50, y: 30)
                    }
                        .offset(x: 0, y: 130)

                    ZStack {
                        Path(CGRect(x: 0, y: 0, width: 100, height: 100))
                            .stroke(inProgressColor, lineWidth: 4)
                        
                        Text("NEXT")
                            .font(mainFont)
                            .foregroundColor(Color(Theme.textSecond))
                            .frame(width: 100)
                            .position(x: 50, y: 20)
                        
                        if (model.inProgress) {
                            TetrominoView(
                                tetromino: model.next,
                                offset: CGPoint(x: 0, y: 0),
                                rotation: 0,
                                palletteIndex: palletteIndex,
                                center: true
                            )
                                .offset(x: 50, y: 62)
                        } else {
                            Text("?")
                                .font(headerFont)
                                .foregroundColor(Color(Theme.text))
                                .frame(width: 100)
                                .position(x: 50, y: 60)
                        }
                    }
                        .offset(x: 0, y: 210)
                    
                    ZStack {
                        Path(CGRect(x: 0, y: 0, width: 100, height: 60))
                            .stroke(Color(Theme.border), lineWidth: 3)
                        
                        Text("LEVEL\n\(model.level)")
                            .font(mainFont)
                            .foregroundColor(Color(Theme.text))
                            .padding(.leading)
                            .frame(width: 100, alignment: .leading)
                            .position(x: 50, y: 30)
                    }
                        .offset(x: 0, y: 330)
                }
                    .offset(x: geometry.size.width - 100 - 23, y: 20)
                
                ZStack {
                    TetrominoView(tetromino: Tetromino.S, palletteIndex: palletteIndex)
                        .frame(width: 80, height: 80)
                        .scaleEffect(2)
                        .rotationEffect(Angle(degrees: 10))
                        .position(x: 280, y: 40)
                    TetrominoView(tetromino: Tetromino.L, palletteIndex: palletteIndex)
                        .frame(width: 80, height: 80)
                        .scaleEffect(1.2)
                        .rotationEffect(Angle(degrees: -10))
                        .position(x: 270, y: 120)
                        .opacity(0.8)
                    TetrominoView(tetromino: Tetromino.T, palletteIndex: palletteIndex)
                        .frame(width: 80, height: 80)
                        .scaleEffect(1)
                        .rotationEffect(Angle(degrees: 20))
                        .position(x: 180, y: 110)
                        .opacity(0.7)
                    TetrominoView(tetromino: Tetromino.J, palletteIndex: palletteIndex)
                        .frame(width: 80, height: 80)
                        .scaleEffect(0.6)
                        .rotationEffect(Angle(degrees: -5))
                        .position(x: 120, y: 110)
                        .opacity(0.7)
                        .blur(radius: 2)
                    TetrominoView(tetromino: Tetromino.I, rotation: 1, palletteIndex: palletteIndex)
                        .frame(width: 80, height: 80)
                        .scaleEffect(0.5)
                        .rotationEffect(Angle(degrees: 10))
                        .position(x: 65, y: 135)
                        .opacity(0.5)
                        .blur(radius: 3)
                }
                    .offset(
                        x: geometry.size.width - (smallScreen ? 260 : 300),
                        y: geometry.size.height - (smallScreen ? 120 : 100)
                    )
                    .opacity(0.7)
                
                ZStack {
                    if (achievementTetris) {
                        TetrominoView(tetromino: Tetromino.I, palletteIndex: 3)
                            .frame(width: 80, height: 80)
                            .rotationEffect(Angle(degrees: 10))
                            .scaleEffect(0.3)
                            .position(x: 40, y: 40)
                    }
                    if (achievementLevel10) {
                        TetrominoView(tetromino: Tetromino.S, palletteIndex: 3)
                            .frame(width: 80, height: 80)
                            .rotationEffect(Angle(degrees: -5))
                            .scaleEffect(0.3)
                            .position(x: 40, y: 65)
                    }
                    if (achievement100000) {
                        TetrominoView(tetromino: Tetromino.L, palletteIndex: 3)
                            .frame(width: 80, height: 80)
                            .rotationEffect(Angle(degrees: -10))
                            .scaleEffect(0.3)
                            .position(x: 40, y: 90)
                    }
                }
                    .offset(
                        x: 0,
                        y: geometry.size.height - (smallScreen ? 120 : 100)
                    )
                    .blur(radius: 3)
                
                ZStack {
                    ZStack {
                        Image(systemName: "arrow.left")
                            .padding(30)
                            .foregroundColor(Color(Theme.textSecond))
                            .background(Circle().fill(Color(Theme.border)))
                            .position(x: 60, y: 0)
                            .gesture(
                                DragGesture(
                                    minimumDistance: 0,
                                    coordinateSpace: .local
                                ).onChanged { _ in
                                    if (!leftPressed) {
                                        leftPressed = true
                                        model.move(dx: -1)
                                    }
                                }.onEnded { _ in
                                    leftPressed = false
                                }
                            )
                        
                        Image(systemName: "arrow.right")
                            .padding(30)
                            .foregroundColor(Color(Theme.textSecond))
                            .background(Circle().fill(Color(Theme.border)))
                            .position(x: 180, y: 0)
                            .gesture(
                                DragGesture(
                                    minimumDistance: 0,
                                    coordinateSpace: .local
                                ).onChanged { _ in
                                    if (!rightPressed) {
                                        rightPressed = true
                                        model.move(dx: 1)
                                    }
                                }.onEnded { _ in
                                    rightPressed = false
                                }
                            )
                        
                        Image(systemName: "arrow.down")
                            .padding(30)
                            .foregroundColor(Color(Theme.textSecond))
                            .background(Circle().fill(Color(Theme.border)))
                            .position(x: 120, y: 80)
                            .gesture(
                                DragGesture(
                                    minimumDistance: 0,
                                    coordinateSpace: .local
                                ).onChanged { _ in
                                    if (!downPressed) {
                                        downPressed = true
                                        model.softDrop = true
                                    }
                                }.onEnded { _ in
                                    downPressed = false
                                    model.softDrop = false
                                }
                            )
                    }
                        .offset(x: 10, y: 0)
                        .opacity(model.inProgress ? 1 : 0.4)
                    
                    Image(systemName: model.inProgress ? "arrow.clockwise" : "play.fill")
                        .font(.system(size: 30))
                        .padding(34)
                        .foregroundColor(Color(model.inProgress ? Theme.textSecond : Theme.text))
                        .background(Circle().fill(Color(Theme.border)))
                        .position(x: geometry.size.width - 80, y: 0)
                        .gesture(
                            DragGesture(
                                minimumDistance: 0,
                                coordinateSpace: .local
                            ).onChanged { _ in
                                if (!rotatePressed) {
                                    rotatePressed = true
                                    
                                    print(geometry.size.height)
                                    
                                    if (model.inProgress) {
                                        model.rotate()
                                    } else {
                                        model.run()
                                        
                                        dropSound.play()
                                    }
                                }
                            }.onEnded { _ in
                                rotatePressed = false
                            }
                        )
                }
                .offset(x: 0, y: geometry.size.height - (smallScreen ? 150 : 250))
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}

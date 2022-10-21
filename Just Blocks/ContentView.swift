//
//  ContentView.swift
//  Just Blocks
//
//  Created by Сергей Терехов on 19.10.2022.
//

import SwiftUI

let blockSize = 20
let blockPadding = 2

let formater = NumberFormatter()

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

struct BlockView: View {
    var block: Block
    var palletteIndex: Int = 0

    var body: some View {
        if (block != .Empty) {
            Path(
                CGRect(
                    x: 0 + blockPadding,
                    y: 0 + blockPadding,
                    width: blockSize - blockPadding * 2,
                    height: blockSize - blockPadding * 2
                )
            ).fill(Color(block != .B ? pallettes[palletteIndex][0] : pallettes[palletteIndex][1]))

            if (block == .A || block == .B) {
                Path { path in
                    path.move(to: CGPoint(x: blockPadding * 4, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: blockPadding * 4))
                }
                    .offset(x: CGFloat(blockPadding * 2), y: CGFloat(blockPadding * 2))
                    .stroke(.white, lineWidth: CGFloat(blockPadding))
            } else {
                Path(
                    CGRect(
                        x: blockPadding * 2,
                        y: blockPadding * 2,
                        width: blockSize - blockPadding * 4,
                        height: blockSize - blockPadding * 4
                    )
                ).fill(.white)
            }
        }
    }
}

struct TetrominoView: View {
    var tetromino: Tetromino
    var offset: CGPoint
    var rotation: Int
    var palletteIndex: Int = 0
    var center = false

    var body: some View {
        let spriteVariants = tetrominoToSprite[tetromino]!
        let sprite = spriteVariants[rotation % spriteVariants.count]
        let size = sprite.count == 9 ? 3 : 4
        
        let centerOffset = center ? getCenterOffsetForTetromino(tetromino: tetromino) : CGPoint()

        ZStack {
            ForEach(0..<size * size, id: \.self) { index in
                let y = index / size
                let x = index % size

                if (y + Int(offset.y) >= 0) {
                    BlockView(block: sprite[index], palletteIndex: palletteIndex)
                        .offset(
                            x: CGFloat((x + Int(offset.x)) * blockSize),
                            y: CGFloat((y + Int(offset.y)) * blockSize)
                        )
                }
            }
        }.offset(
            x: centerOffset.x * CGFloat(blockSize),
            y: centerOffset.y * CGFloat(blockSize)
        )
    }
    
    func getCenterOffsetForTetromino(tetromino: Tetromino) -> CGPoint {
        switch (tetromino) {
        case .I:
            return CGPoint(x: -2, y: -2.5)
        case .O:
            return CGPoint(x: -2, y: -2)
        default:
            return CGPoint(x: -1.5, y: -2)
        }
    }
}

struct ContentView: View {
    @ObservedObject private var model = GameModel()
    
    @AppStorage("maxScore") private var maxScore = 0

    @State private var downPressed = false
    @State private var leftPressed = false
    @State private var rightPressed = false
    @State private var rotatePressed = false
    
    init() {
        model.onRotate = {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
        model.onMove = {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        model.onDrop = {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
        model.onClear = {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        model.onTetris = {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
        model.onLevelUp = {
            //
        }
        model.onGameOver = { [self] in
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            
            maxScore = model.score
        }
    }

    var body: some View {
        let font = Font.system(size: 20, weight: .bold).monospaced()
        let inProgressColor = model.inProgress ? Color(Theme.success) : Color(Theme.danger)
        let palletteIndex = model.level % pallettes.count

        GeometryReader { geometry in
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
                            .font(font)
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
                            .stroke(Color(Theme.textThird), lineWidth: 4)
                        
                        Text("TOP\n\(formater.string(from: NSNumber(value: maxScore))!)")
                            .font(font)
                            .foregroundColor(Color(Theme.textSecond))
                            .padding(.leading)
                            .frame(width: 100, alignment: .leading)
                            .position(x: 50, y: 30)
                        
                        Text("SCORE\n\(formater.string(from: NSNumber(value: model.score))!)")
                            .font(font)
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
                            .font(font)
                            .foregroundColor(Color(Theme.text))
                            .padding(.leading)
                            .frame(width: 100, alignment: .leading)
                            .position(x: 50, y: 30)
                    }
                        .offset(x: 0, y: 130)

                    ZStack {
                        Path(CGRect(x: 0, y: 0, width: 100, height: 100))
                            .stroke(inProgressColor, lineWidth: 4)
                        
                        TetrominoView(
                            tetromino: model.next,
                            offset: CGPoint(x: 0, y: 0),
                            rotation: 0,
                            palletteIndex: palletteIndex,
                            center: true
                        )
                            .offset(x: 50, y: 50)
                    }
                        .offset(x: 0, y: 210)
                    
                    ZStack {
                        Path(CGRect(x: 0, y: 0, width: 100, height: 60))
                            .stroke(Color(Theme.border), lineWidth: 3)
                        
                        Text("LEVEL\n\(model.level)")
                            .font(font)
                            .foregroundColor(Color(Theme.text))
                            .padding(.leading)
                            .frame(width: 100, alignment: .leading)
                            .position(x: 50, y: 30)
                    }
                        .offset(x: 0, y: 330)
                }
                    .offset(x: geometry.size.width - 100 - 23, y: 20)
                
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
                                    
                                    if (model.inProgress) {
                                        model.rotate()
                                    } else {
                                        model.run()
                                    }
                                }
                            }.onEnded { _ in
                                rotatePressed = false
                            }
                        )
                }
                .offset(x: 0, y: geometry.size.height - (geometry.size.height < 720 ? 150 : 250))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

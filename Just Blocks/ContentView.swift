//
//  ContentView.swift
//  Just Blocks
//
//  Created by Сергей Терехов on 19.10.2022.
//

import SwiftUI

let blockSize = 20
let blockPadding = 2

struct BlockView: View {
    var block: Block

    var body: some View {
        if (block != .Empty) {
            Path(CGRect(x: 0 + blockPadding, y: 0 + blockPadding, width: blockSize - blockPadding * 2, height: blockSize - blockPadding * 2))
                .fill(block == .A ? .red : .blue)

            if (block == .A || block == .B) {
                Path { path in
                    path.move(to: CGPoint(x: blockPadding * 4, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: blockPadding * 4))
                }
                    .offset(x: CGFloat(blockPadding * 2), y: CGFloat(blockPadding * 2))
                    .stroke(.white, lineWidth: CGFloat(blockPadding))
            } else {
                Path(CGRect(x: blockPadding * 2, y: blockPadding * 2, width: blockSize - blockPadding * 4, height: blockSize - blockPadding * 4))
                    .fill(.white)
            }
        }
    }
}

struct TetrominoView: View {
    var tetromino: Tetromino
    var offset: CGPoint
    var rotation: Int

    var body: some View {
        ZStack {
            let spriteVariants = tetrominoToSprite[tetromino]!
            let sprite = spriteVariants[rotation % spriteVariants.count]
            let size = sprite.count == 9 ? 3 : 4
            
            ForEach(0..<size * size, id: \.self) { index in
                let y = index / size
                let x = index % size

                if (y + Int(offset.y) >= 0) {
                    BlockView(block: sprite[index])
                        .offset(
                            x: CGFloat((x + Int(offset.x)) * blockSize),
                            y: CGFloat((y + Int(offset.y)) * blockSize)
                        )
                }
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject private var model = GameModel()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZStack {
                    Path(CGRect(x: 0, y: 0, width: 200, height: 400))
                        .stroke(model.inProgress ? .green : .red, lineWidth: 1)
                    
                    ZStack {
                        ForEach(0..<model.height * model.width, id: \.self) { index in
                            let y = index / model.width
                            let x = index % model.width

                            BlockView(block: model.field[index])
                                .offset(x: CGFloat(x * blockSize), y: CGFloat(y * blockSize))
                        }
                    }
                    
                    TetrominoView(tetromino: model.current, offset: CGPoint(x: model.x, y: model.y), rotation: model.rotation)
                }
                    .offset(x: 20, y: 20)
                
                ZStack {
                    ZStack {
                        Path(CGRect(x: 0, y: 0, width: 100, height: 110))
                            .stroke()
                        
                        Text("TOP\n???\nSCORE\n\(model.score)")
                            .position(x: 50, y: 55)
                    }
                        .offset(x: 0, y: 0)
                    
                    ZStack {
                        Path(CGRect(x: 0, y: 0, width: 100, height: 60))
                            .stroke()
                        
                        Text("LINES\n\(model.lines)")
                            .position(x: 50, y: 30)
                    }
                        .offset(x: 0, y: 130)

                    ZStack {
                        Path(CGRect(x: 0, y: 0, width: 100, height: 100))
                            .stroke(model.inProgress ? .green : .red, lineWidth: 1)
                        
                        TetrominoView(tetromino: model.next, offset: CGPoint(x: 0, y: 0), rotation: 0)
                    }
                        .offset(x: 0, y: 210)
                    
                    ZStack {
                        Path(CGRect(x: 0, y: 0, width: 100, height: 60))
                            .stroke()
                        
                        Text("LEVEL\n\(model.level)")
                            .position(x: 50, y: 30)
                    }
                        .offset(x: 0, y: 330)
                }
                    .offset(x: geometry.size.width - 100 - 20, y: 20)
                
                ZStack {
                    Text("<<<")
                        .position(x: 50, y: 0)
                        .onTapGesture {
                            model.move(dx: -1)
                        }
                    
                    Text(">>>")
                        .position(x: 150, y: 0)
                        .onTapGesture {
                            model.move(dx: 1)
                        }
                    
                    Text("DOWN")
                        .position(x: 100, y: 50)
                        .gesture(
                            DragGesture(
                                minimumDistance: 0,
                                coordinateSpace: .local
                            ).onChanged({ _ in
                                model.softDrop = true
                            }).onEnded({ _ in
                                model.softDrop = false
                            })
                        )
                    
                    Text("Rotate")
                        .position(x: geometry.size.width - 50, y: 0)
                        .onTapGesture {
                            if (model.inProgress) {
                                model.rotate()
                            } else {
                                model.run()
                            }
                        }
                }
                    .offset(x: 0, y: geometry.size.height - 200)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

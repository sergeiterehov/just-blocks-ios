//
//  GameModel.swift
//  Just Blocks
//
//  Created by Сергей Терехов on 19.10.2022.
//

import Foundation

enum Tetromino : CaseIterable {
  case O
  case S
  case Z
  case I
  case T
  case L
  case J
}

enum Block : CaseIterable {
  case Empty
  case A
  case B
  case C
}

func fillMap(type: Block, map: [Int]) -> [Block] {
    return map.map({bit in bit == 1 ? type : Block.Empty})
}

let tetrominoToSprite: [Tetromino:[[Block]]] = [
    .O: [
        fillMap(type: .C, map: [
            0, 0, 0, 0,
            0, 1, 1, 0,
            0, 1, 1, 0,
            0, 0, 0, 0
        ])
    ],
    .S: [
        fillMap(type: .A, map: [
            0, 0, 0,
            0, 1, 1,
            1, 1, 0
        ]),
        fillMap(type: .A, map: [
            0, 1, 0,
            0, 1, 1,
            0, 0, 1
        ])
    ],
    .Z: [
        fillMap(type: .B, map: [
            0, 0, 0,
            1, 1, 0,
            0, 1, 1
        ]),
        fillMap(type: .B, map: [
            0, 0, 1,
            0, 1, 1,
            0, 1, 0
        ])
    ],
    .I: [
        fillMap(type: .C, map: [
            0, 0, 0, 0,
            0, 0, 0, 0,
            1, 1, 1, 1,
            0, 0, 0, 0
        ]),
        fillMap(type: .C, map: [
            0, 0, 1, 0,
            0, 0, 1, 0,
            0, 0, 1, 0,
            0, 0, 1, 0
        ])
    ],
    .T: [
        fillMap(type: .C, map: [
            0, 0, 0,
            1, 1, 1,
            0, 1, 0
        ]),
        fillMap(type: .C, map: [
            0, 1, 0,
            1, 1, 0,
            0, 1, 0
        ]),
        fillMap(type: .C, map: [
            0, 1, 0,
            1, 1, 1,
            0, 0, 0
        ]),
        fillMap(type: .C, map: [
            0, 1, 0,
            0, 1, 1,
            0, 1, 0
        ]),
    ],
    .L: [
        fillMap(type: .B, map: [
            0, 0, 0,
            1, 1, 1,
            1, 0, 0
        ]),
        fillMap(type: .B, map: [
            1, 1, 0,
            0, 1, 0,
            0, 1, 0
        ]),
        fillMap(type: .B, map: [
            0, 0, 1,
            1, 1, 1,
            0, 0, 0
        ]),
        fillMap(type: .B, map: [
            0, 1, 0,
            0, 1, 0,
            0, 1, 1
        ]),
    ],
    .J: [
        fillMap(type: .A, map: [
            0, 0, 0,
            1, 1, 1,
            0, 0, 1
        ]),
        fillMap(type: .A, map: [
            0, 1, 0,
            0, 1, 0,
            1, 1, 0
        ]),
        fillMap(type: .A, map: [
            1, 0, 0,
            1, 1, 1,
            0, 0, 0
        ]),
        fillMap(type: .A, map: [
            0, 1, 1,
            0, 1, 0,
            0, 1, 0
        ]),
    ],
]

let levelToFramesPerRow: [Int] = [
    48, 43, 38, 33, 28, 23, 18, 13, 8, 6,
    5, 5, 5, 4, 4, 4, 3, 3, 3, 2,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 1,
]

class GameModel : ObservableObject {
    let width = 10
    let height = 20
    let fps = 50.0
    
    var clock: Timer?;
    
    @Published var level = 0
    @Published var lines = 0
    @Published var score = 0
    
    @Published var field: [Block] = []

    @Published var inProgress = false
    @Published var inPause = false
    @Published var softDrop = false
    
    var softDropRows = 0;

    @Published var current = Tetromino.S
    @Published var next = Tetromino.T
    
    @Published var x = 4
    @Published var y = 1
    @Published var rotation = 0
    
    var onRotate = {}
    var onMove = {}
    var onDrop = {}
    var onGameOver = {}
    var onLevelUp = {}
    var onClear = {}
    var onTetris = {}
    
    var framesToDrop = 0
    
    init() {
        reset()
        
        y = -10

        clock = Timer.scheduledTimer(
            withTimeInterval: 1.0 / fps,
            repeats: true
        ) { timer in self.frame() }
    }
    
    deinit {
        clock?.invalidate()
    }
    
    func reset() {
        field = Array(repeating: .Empty, count: width * height)
        x = 0
        y = 0
        rotation = 0
        softDrop = false
        level = 0
        lines = 0
        score = 0
        softDropRows = 0
        inPause = false
        framesToDrop = levelToFramesPerRow[level]
        
        generateNextTetromino()
        generateNextTetromino()
    }
    
    func run() {
        if (inProgress) {
            return
        }
        
        reset()

        inProgress = true
    }
    
    func stop() {
        inProgress = false
    }
    
    func pause() {
        if (inProgress) {
            inProgress = false
            inPause = true
        }
    }
    
    func play() {
        if (inPause) {
            inProgress = true
            inPause = false
        }
    }
    
    func move(dx: Int) {
        if (inProgress && testPosition(x: x + dx, y: y, rotation: rotation)) {
            x += dx
            
            onMove()
        }
    }
    
    func rotate() {
        if (inProgress && testPosition(x: x, y: y, rotation: rotation + 1)) {
            rotation += 1
            
            onRotate()
        }
    }
    
    private func frame() {
        if (!inProgress) {
            return
        }
        
        if (softDrop || framesToDrop <= 1) {
            if (fell()) {
                fix()
                
                if (gameOver()) {
                    stop()

                    onGameOver()
                } else {
                    score += softDropRows

                    clearLines()
                    generateNextTetromino()

                    onDrop()
                }
                
                softDrop = false
                softDropRows = 0
            } else {
                y += 1
                
                if (softDrop) {
                    softDropRows += 1
                }
            }
            
            // Level
            
            let prevLevel = level
            
            level = Int(lines / 10)
            
            if (level != prevLevel) {
                onLevelUp()
            }
            
            // Continue...
            
            framesToDrop = levelToFramesPerRow[level]
        } else {
            framesToDrop -= 1
        }
    }
    
    private func getHeight() -> Int {
        for y in 0..<height {
            for x in 0..<width {
                if (field[y * width + x] == .Empty) {
                    return height - y
                }
            }
        }
        
        return 0
    }
    
    private func gameOver() -> Bool {
        for x in 0..<width {
            if (field[x] != .Empty) {
                return true
            }
        }

        return false
    }
    
    private func fell() -> Bool {
        let spriteVariants = tetrominoToSprite[current]!
        let sprite = spriteVariants[rotation % spriteVariants.count]
        let size = sprite.count == 9 ? 3 : 4
        
        for dy in 0..<size {
            for dx in 0..<size {
                if (sprite[dy * size + dx] != .Empty && (
                    (
                        y + dy + 1 >= 0 && y + dy + 1 < height
                        && x + dx >= 0 && x + dx < width
                        && field[(y + dy + 1) * width + x + dx] != .Empty
                    )
                    || y + dy + 1 == height
                )) {
                    return true
                }
            }
        }

        return false
    }
    
    private func testPosition(x: Int, y: Int, rotation: Int) -> Bool {
        let spriteVariants = tetrominoToSprite[current]!
        let sprite = spriteVariants[rotation % spriteVariants.count]
        let size = sprite.count == 9 ? 3 : 4
        
        for dy in 0..<size {
            for dx in 0..<size {
                if (sprite[dy * size + dx] != .Empty && (
                    y + dy >= height
                    || x + dx < 0
                    || x + dx >= width
                    || (
                        y + dy >= 0 && y + dy < height
                        && x + dx >= 0 && x + dx < width
                        && field[(y + dy) * width + x + dx] != .Empty
                    )
                )) {
                    return false
                }
            }
        }

        return true
    }
    
    private func fix() {
        let spriteVariants = tetrominoToSprite[current]!
        let sprite = spriteVariants[rotation % spriteVariants.count]
        let size = sprite.count == 9 ? 3 : 4
        
        for dy in 0..<size {
            if (y + dy >= 0 && y + dy < height) {
                for dx in 0..<size {
                    if (x + dx >= 0 && x + dx < width) {
                        let block = sprite[dy * size + dx]
                        
                        if (block != .Empty) {
                            field[(y + dy) * width + x + dx] = block
                        }
                    }
                }
            }
        }
    }
    
    private func clearLines() {
        var cleared = 0

        for y in 0..<height {
            var filled = true
            
            for x in 0..<width {
                if (field[y * width + x] == .Empty) {
                    filled = false
                    break
                }
            }
            
            if (!filled) {
                continue
            }
            
            cleared += 1
            
            for t in (1...y).reversed() {
                for x in 0..<width {
                    field[t * width + x] = field[(t - 1) * width + x]
                }
            }
            
            for x in 0..<width {
                field[x] = .Empty
            }
        }
        
        lines += cleared
        
        if (cleared == 0) {
          // nop
        } else if (cleared == 1) {
          score += 40 * (level + 1)
            
          onClear()
        } else if (cleared == 2) {
          score += 100 * (level + 1)
            
            onClear()
        } else if (cleared == 3) {
          score += 300 * (level + 1)
            
            onClear()
        } else if (cleared >= 4) {
          score += 1200 * (level + 1)
            
            onTetris()
        }
    }
    
    private func generateNextTetromino() {
        current = next
        
        next = Tetromino.allCases.randomElement()!
        
        if (next == current) {
            next = Tetromino.allCases.randomElement()!
        }
        
        rotation = 0
        
        let sprite = tetrominoToSprite[current]![rotation]
        let size = sprite.count == 9 ? 3 : 4
        
        for dy in 0..<size {
            var found = false
            
            for dx in 0..<size {
                if (sprite[dy * size + dx] != .Empty) {
                    y = -dy
                    found = true
                    break
                }
            }
            
            if (found) {
                break
            }
        }
        
        x = Int((width - size) / 2)
    }
}

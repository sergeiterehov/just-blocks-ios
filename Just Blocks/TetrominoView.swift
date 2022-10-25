import Foundation
import SwiftUI

struct BlockView: View {
    var block: Block
    var palletteIndex: Int = 0
    var dot: Bool = false

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
        } else if (dot) {
            Path(CGRect(x: blockSize / 2, y: blockSize / 2, width: 2, height: 2)).fill(Color(Theme.border))
        }
    }
}

struct TetrominoView: View {
    var tetromino: Tetromino
    var offset: CGPoint = CGPoint(x: 0, y: 0)
    var rotation: Int = 0
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

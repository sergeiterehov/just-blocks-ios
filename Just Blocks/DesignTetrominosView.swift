import SwiftUI

struct DesignTetrominosView : View {
    var palletteIndex = 0

    var body: some View {
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
    }
}

struct DesignTetrominosView_Previews: PreviewProvider {
    static var previews: some View {
        DesignTetrominosView()
    }
}

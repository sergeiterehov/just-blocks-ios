import SwiftUI

struct AchievementsView: View {
    var debugAchievementsView = false

    @ObservedObject private var state = globalGameState

    var body: some View {
        ZStack {
            if (state.achievementTetris || debugAchievementsView) {
                TetrominoView(tetromino: Tetromino.I, palletteIndex: 3)
                    .frame(width: 80, height: 80)
                    .rotationEffect(Angle(degrees: 10))
                    .scaleEffect(0.3)
                    .position(x: 40, y: 40)
            }
            if (state.achievementLevel10 || debugAchievementsView) {
                TetrominoView(tetromino: Tetromino.S, palletteIndex: 3)
                    .frame(width: 80, height: 80)
                    .rotationEffect(Angle(degrees: -5))
                    .scaleEffect(0.3)
                    .position(x: 40, y: 65)
            }
            if (state.achievement100000 || debugAchievementsView) {
                TetrominoView(tetromino: Tetromino.L, palletteIndex: 3)
                    .frame(width: 80, height: 80)
                    .rotationEffect(Angle(degrees: -10))
                    .scaleEffect(0.3)
                    .position(x: 40, y: 90)
            }
            if (state.achievementGames1000 || debugAchievementsView) {
                TetrominoView(tetromino: Tetromino.O, palletteIndex: 3)
                    .frame(width: 80, height: 80)
                    .rotationEffect(Angle(degrees: 10))
                    .scaleEffect(0.3)
                    .position(x: 65, y: 90)
            }
            if (state.achievementLevel18 || debugAchievementsView) {
                TetrominoView(tetromino: Tetromino.T, palletteIndex: 3)
                    .frame(width: 80, height: 80)
                    .rotationEffect(Angle(degrees: -5))
                    .scaleEffect(0.3)
                    .position(x: 70, y: 65)
            }
        }
    }
}

struct AchievementsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(Theme.background).ignoresSafeArea()
            AchievementsView(debugAchievementsView: true)
                .blur(radius: 3)
        }
    }
}

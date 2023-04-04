import SwiftUI

struct HUDView: View {
    let padding: CGFloat = 10
    let width = 100.0

    @ObservedObject var model: GameModel
    var maxScore: Int
    var inProgressColor: Color
    var palletteIndex: Int
    
    @State var scoreMode = 0

    var body: some View {
        ZStack {
            // SCORE
            ZStack {
                Path(CGRect(x: 0, y: 0, width: width, height: 60))
                    .fill(.black.opacity(0))
                Path(CGRect(x: 0, y: 0, width: width, height: 60))
                    .stroke(
                        Color(model.score > 0 && maxScore == model.score ? Theme.success : Theme.border),
                        lineWidth: maxScore == model.score ? 4 : 3
                    )
                
                if (scoreMode == 0) {
                    Text("SCORE\n\(formater.string(from: NSNumber(value: model.score))!)")
                        .font(mainFont)
                        .foregroundColor(Color(Theme.text))
                        .padding(.leading, padding)
                        .frame(width: width, alignment: .leading)
                        .position(x: 50, y: 30)
                } else if (scoreMode == 1) {
                    Text("TOP\n\(formater.string(from: NSNumber(value: maxScore))!)")
                        .font(mainFont)
                        .foregroundColor(Color(Theme.textSecond))
                        .padding(.leading, padding)
                        .frame(width: width, alignment: .leading)
                        .position(x: 50, y: 30)
                } else {
                    let offset = model.score - maxScore

                    Text("DELTA\n\(offset > 0 ? "+" : "")\(formater.string(from: NSNumber(value: abs(offset)))!)")
                        .font(mainFont)
                        .foregroundColor(Color(model.score >= maxScore ? Theme.success : Theme.danger))
                        .padding(.leading, padding)
                        .frame(width: width, alignment: .leading)
                        .position(x: 50, y: 30)
                }
            }
                .offset(x: 0, y: 0)
                .onTapGesture {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    
                    scoreMode = (scoreMode + 1) % 3
                }
            
            // LINES AND LEVEL
            ZStack {
                Path(CGRect(x: 0, y: 0, width: width, height: 60))
                    .fill(.black.opacity(0))
                Path(CGRect(x: 0, y: 0, width: width, height: 60))
                    .stroke(Color(Theme.border), lineWidth: 3)
                
                if (model.startLevel > 0) {
                    Text("\(model.startLevel)")
                        .font(smallFont)
                        .foregroundColor(Color(Theme.textThird))
                        .padding(.trailing, padding)
                        .frame(width: width, alignment: .trailing)
                        .position(x: 50, y: 43)
                }
                
                (
                    Text("LINES\n")
                    + Text("\(Int(model.lines / 10))")
                    + Text("\(model.lines % 10)").foregroundColor(Color(Theme.textSecond))
                )
                    .font(mainFont)
                    .foregroundColor(Color(Theme.text))
                    .padding(.leading, padding)
                    .frame(width: width, alignment: .leading)
                    .position(x: 50, y: 30)
            }
                .offset(x: 0, y: 80)
                .onTapGesture {
                    if (!model.isGameOver) {
                        return
                    }

                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    
                    model.changeStartLevel()
                }

            // NEXT
            ZStack {
                Path(CGRect(x: 0, y: 0, width: width, height: 100))
                    .stroke(inProgressColor, lineWidth: 4)
                
                Text("NEXT")
                    .font(mainFont)
                    .foregroundColor(Color(Theme.textSecond))
                    .frame(width: width)
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
                        .frame(width: width)
                        .position(x: 50, y: 60)
                }
            }
                .offset(x: 0, y: 160)
        }
    }
}

struct HUDView_Previews: PreviewProvider {
    private static var model = GameModel().setTestState()

    static var previews: some View {
        ZStack {
            Color(Theme.background).ignoresSafeArea()
            HStack {
                HUDView(model: model, maxScore: 100500, inProgressColor: Color(Theme.danger), palletteIndex: 0)
                HUDView(model: model, maxScore: 999999, inProgressColor: Color(Theme.textThird), palletteIndex: 2)
                HUDView(model: model, maxScore: 0, inProgressColor: Color(Theme.success), palletteIndex: 3)
            }
            .padding(.horizontal, 20)
        }
    }
}

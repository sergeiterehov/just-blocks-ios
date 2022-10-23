import SwiftUI

struct FiguresGuideView: View {
    var body: some View {
        HStack {
            Spacer()
            VStack {
                HStack {
                    TetrominoView(tetromino: Tetromino.S)
                        .scaleEffect(1.5)
                        .rotationEffect(Angle(degrees: -20))
                    TetrominoView(tetromino: Tetromino.L)
                        .scaleEffect(0.9)
                        .rotationEffect(Angle(degrees: 5))
                    TetrominoView(tetromino: Tetromino.Z)
                        .scaleEffect(1.2)
                    TetrominoView(tetromino: Tetromino.T)
                        .scaleEffect(0.7)
                        .rotationEffect(Angle(degrees: 10))
                }
                    .offset(x: 10)
                HStack {
                    TetrominoView(tetromino: Tetromino.I)
                        .scaleEffect(1)
                    TetrominoView(tetromino: Tetromino.O)
                        .scaleEffect(1.2)
                        .rotationEffect(Angle(degrees: 20))
                    TetrominoView(tetromino: Tetromino.J)
                        .scaleEffect(1.5)
                        .rotationEffect(Angle(degrees: -5))
                }
                    .offset(x: 20)
            }.frame(width: 340,height: 150)
            Spacer()
        }
        
        Spacer()
        
        Text("Figures")
            .font(headerFont)
            .foregroundColor(Color(Theme.text))
            .padding()
        Text("There are 7 figures in the game world. They appear in a 10x20 field and fall down.")
            .font(mainFont)
            .foregroundColor(Color(Theme.text))
            .padding(.horizontal)
    }
}


struct ControlGuideView: View {
    var body: some View {
        Image(systemName: "arrow.clockwise")
            .font(Font.system(size: 48))
            .foregroundColor(Color(Theme.textThird))

        HStack {
            Spacer()

            Image(systemName: "chevron.left.2")
                .font(Font.system(size: 48))
                .foregroundColor(Color(Theme.textThird))
                .padding()

            ZStack {
                TetrominoView(tetromino: Tetromino.S, offset: CGPoint(x: 0, y: 0), rotation: 0, center: true)
                    .offset(x: 75, y: 60)
                    .scaleEffect(2)
            }.frame(width: 150, height: 120)
            
            Image(systemName: "chevron.right.2")
                .font(Font.system(size: 48))
                .foregroundColor(Color(Theme.textThird))
                .padding()

            Spacer()
        }
        
        Image(systemName: "arrow.down.to.line")
            .font(Font.system(size: 48))
            .foregroundColor(Color(Theme.textThird))
        
        Spacer()
        
        Text("Control")
            .font(headerFont)
            .foregroundColor(Color(Theme.text))
            .padding()
        Text("Figures can be moved, rotated and sent into free fall.")
            .font(mainFont)
            .foregroundColor(Color(Theme.text))
            .padding(.horizontal)
    }
}


struct RulesGuideView: View {
    @State private var field: [Block] = [
        .Empty, .Empty, .C, .Empty, .A, .Empty,
        .Empty, .C, .C, .C, .A, .Empty,
        .A, .B, .Empty, .A, .A, .C,
        .A, .B, .A, .B, .B, .C,
        .A, .B, .C, .C, .B, .C,
        .A, .A, .C, .C, .B, .C,
    ]

    var body: some View {
        ZStack {
            ForEach(0..<36, id: \.self) { index in
                let y = index / 6
                let x = index % 6

                BlockView(block: field[index])
                    .offset(x: CGFloat(x * blockSize), y: CGFloat(y * blockSize))
                    .offset(x: 150 - Double(3 * blockSize))
                    .opacity(y >= 3 ? 0.1 : 1)
            }
                .scaleEffect(1.5)
        }.frame(width: 300, height: 150)
        
        Spacer()
        
        Text("Rules")
            .font(headerFont)
            .foregroundColor(Color(Theme.text))
            .padding()
        Text("When the pieces line up, the line is cleared. The more lines cleared at a time, the more points. Points are also awarded for free fall. The game ends when the figure reaches the top of the screen.")
            .font(mainFont)
            .foregroundColor(Color(Theme.text))
            .padding(.horizontal)
    }
}

struct GuideView: View {
    var onClose = {}

    @State private var step = 1
    private let maxStep = 3

    var body: some View {
        ZStack {
            Color(Theme.background).ignoresSafeArea()

            VStack {
                HStack {
                    if (step > 1) {
                        Button("Back", action: {
                            if (step > 1) {
                                step -= 1
                            }
                        })
                            .font(mainFont)
                            .foregroundColor(Color(Theme.textSecond))
                            .padding()
                        
                    }

                    Spacer()
                    
                    if (step < maxStep) {
                        Button("Skip", action: {
                            onClose()
                        })
                            .font(mainFont)
                            .foregroundColor(Color(Theme.textThird))
                            .padding()
                    }
                }

                Spacer()

                switch (step) {
                case 1: FiguresGuideView()
                case 2: ControlGuideView()
                case 3: RulesGuideView()
                default: Text("Oops")
                }
                
                Spacer()
                
                if (step < maxStep) {
                    Button("Next \(step)/\(maxStep)", action: {
                        if (step < maxStep) {
                            step += 1
                        }
                    })
                        .padding()
                        .font(mainFont)
                        .background(RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)).fill(Color(Theme.textThird)))
                        .foregroundColor(Color(Theme.text))
                        .padding()
                } else {
                    Button("Play now!", action: {
                        onClose()
                    })
                        .padding()
                        .font(mainFont)
                        .background(RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)).fill(Color(Theme.success)))
                        .foregroundColor(Color(Theme.text))
                        .padding()
                }
            }
        }
    }
}

struct GuideView_Previews: PreviewProvider {
    static var previews: some View {
        GuideView()
    }
}

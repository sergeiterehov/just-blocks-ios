//
//  KeyboardView.swift
//  Just Brick
//
//  Created by Сергей Терехов on 04.04.2023.
//

import SwiftUI

struct KeyboardView: View {
    var size: CGSize

    @ObservedObject var model: GameModel
    @ObservedObject private var state = globalGameState

    var body: some View {
        let arrowButtonsSpace = screenSize == .ExtraSmall ? 50.0 : 60.0

        ZStack {
            ZStack {
                ControlButtonView(
                    icon: "arrow.left",
                    onTap: {
                        model.move(dx: -1)
                    },
                    extraSmallScreen: screenSize == .ExtraSmall,
                    enableDas: true,
                    disabled: !model.inProgress
                )
                    .position(x: -arrowButtonsSpace, y: 0)
                
                ControlButtonView(
                    icon: "arrow.right",
                    onTap: {
                        model.move(dx: 1)
                    },
                    extraSmallScreen: screenSize == .ExtraSmall,
                    enableDas: true,
                    disabled: !model.inProgress
                )
                    .position(x: arrowButtonsSpace, y: 0)
                
                ControlButtonView(
                    icon: "arrow.down",
                    onTap: {
                        model.softDrop = true
                    },
                    onUntap: {
                        model.softDrop = false
                    },
                    extraSmallScreen: screenSize == .ExtraSmall,
                    disabled: !model.inProgress
                )
                    .position(x: 0, y: arrowButtonsSpace + 20)
            }
                .offset(x: 125, y: 0)
            
            ControlButtonView(
                icon: model.inProgress ? "arrow.clockwise" : "play.fill",
                onTap: {
                    if (model.inProgress) {
                        model.rotate()
                    } else if (model.inPause) {
                        model.play()
                        
                        moveSound.play()
                    } else {
                        model.run()
                        
                        dropSound.play()
                    }
                },
                color: Color(model.inProgress ? Theme.textSecond : Theme.text),
                padding: 34,
                extraSmallScreen: screenSize == .ExtraSmall
            )
                .font(.system(size: screenSize == .ExtraSmall ? 24 : 30))
                .position(x: size.width - 80, y: 0)
        }
    }
}

struct KeyboardView_Previews: PreviewProvider {
    static private var model = GameModel()

    static var previews: some View {
        GeometryReader { geometry in
            KeyboardView(size: geometry.size, model: model)
        }
    }
}

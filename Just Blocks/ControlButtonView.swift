import SwiftUI

class DASModel : ObservableObject {
    private var enabled = false
    private var counter = 0
    private var clock: Timer?

    var handler = {}

    init() {
        clock = Timer.scheduledTimer(
            withTimeInterval: 1.0 / 60,
            repeats: true
        ) { timer in self.tick()}
    }
    
    deinit {
        clock?.invalidate()
    }
    
    public func begin() {
        counter = 16
        enabled = true
        
        handler()
    }
    
    public func end() {
        enabled = false
    }
    
    private func tick() {
        if (!enabled) {
            return
        }
        
        counter -= 1

        if (counter == 0) {
            handler()

            counter = 6
        }
    }
}

struct ControlButtonView : View {
    var icon = "arrow.left"
    var onTap = {}
    var onUntap = {}
    var color = Color(Theme.textSecond)
    var padding = 30.0
    var extraSmallScreen = false
    var enableDas = false
    var disabled = false
    
    @StateObject private var das = DASModel()
    @Environment(\.scenePhase) var scenePhase
    @State var isPressing = false
    
    var body: some View {
        
        Image(systemName: icon)
            .padding(extraSmallScreen ? 24 : self.padding)
            .foregroundColor(isPressing ? Color(Theme.text) : color)
            .background(Circle().fill(Color(isPressing ? Theme.highlightedColor : Theme.border)))
            .opacity(disabled ? 0.4 : 1)
            .animation(.easeOut(duration: 0.1), value: isPressing)
            .onLongPressGesture(
                minimumDuration: .infinity,
                perform: {},
                onPressingChanged: { isPressing in
                    if (disabled) {
                        self.isPressing = false

                        return
                    }

                    self.isPressing = isPressing

                    if isPressing {
                        if (enableDas) {
                            das.handler = onTap
                            das.begin()
                        } else {
                            onTap()
                        }
                    } else {
                        das.end()
                        onUntap()
                    }
                })
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .inactive || newPhase == .background {
                    das.end()
                    onUntap()
                }
            }
    }
}

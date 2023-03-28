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
        
        print(1)
    }
    
    deinit {
        clock?.invalidate()
        print(2)
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
    
    @StateObject private var das = DASModel()
    @Environment(\.scenePhase) var scenePhase
    @State var isDetectingLongPress = false
    
    var body: some View {
        
        Image(systemName: icon)
            .padding(extraSmallScreen ? 24 : self.padding)
            .foregroundColor(isDetectingLongPress ? .white : color)
            .background(Circle().fill(Color(isDetectingLongPress ? Theme.highlightedColor : Theme.border)))
            .onLongPressGesture(
                minimumDuration: .infinity,
                perform: {},
                onPressingChanged: { isPressing in
                    isDetectingLongPress = isPressing
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

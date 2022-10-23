import SwiftUI

struct MainView: View {
    @AppStorage("showGuide") private var showGuide = true

    var body: some View {
        if (showGuide) {
            GuideView(onClose: { [self] in
                showGuide = false
            })
        } else {
            GameView()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

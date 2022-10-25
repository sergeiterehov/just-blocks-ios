import SwiftUI

@main
struct Just_BlocksApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(.dark)
                .frame(minWidth: 356, minHeight: 640)
        }
    }
}

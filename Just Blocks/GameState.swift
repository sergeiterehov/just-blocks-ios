import Foundation
import Combine

class GameState : ObservableObject {
    @Published var gameApprovedForCounter = false
    
    @Published var displayDotsField = false
    
    @Published var maxScore = 0
    @Published var gamesCounter = 0
    
    @Published var achievementTetris = false
    @Published var achievementLevel10 = false
    @Published var achievement100000 = false
    @Published var achievementGames1000 = false
    @Published var achievementLevel18 = false
    
    private var cancellable: AnyCancellable?
    
    init() {
        restore()
        
        cancellable = objectWillChange.sink {[weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.store()
            }
        }
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    private func restore() {
        displayDotsField = UserDefaults.standard.bool(forKey: "displayDotsField")
        maxScore = UserDefaults.standard.integer(forKey: "maxScore")
        gamesCounter = UserDefaults.standard.integer(forKey: "gamesCounter")
        achievementTetris = UserDefaults.standard.bool(forKey: "achievementTetris")
        achievementLevel10 = UserDefaults.standard.bool(forKey: "achievementLevel10")
        achievement100000 = UserDefaults.standard.bool(forKey: "achievement100000")
        achievementGames1000 = UserDefaults.standard.bool(forKey: "achievementGames1000")
        achievementLevel18 = UserDefaults.standard.bool(forKey: "achievementLevel18")
    }
    
    private func store() {
        UserDefaults.standard.set(displayDotsField, forKey: "displayDotsField")
        UserDefaults.standard.set(maxScore, forKey: "maxScore")
        UserDefaults.standard.set(gamesCounter, forKey: "gamesCounter")
        UserDefaults.standard.set(achievementTetris, forKey: "achievementTetris")
        UserDefaults.standard.set(achievementLevel10, forKey: "achievementLevel10")
        UserDefaults.standard.set(achievement100000, forKey: "achievement100000")
        UserDefaults.standard.set(achievementGames1000, forKey: "achievementGames1000")
        UserDefaults.standard.set(achievementLevel18, forKey: "achievementLevel18")
    }
}

let globalGameState = GameState()

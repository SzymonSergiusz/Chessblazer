import SwiftUI

struct ContentView: View {
    
    @Bindable var gameState = GameState()
        
    var body: some View {
        
        Button("Start new game") {
            gameState.startNewGame()
        }
        
        ZStack {
            BoardView(gameState: gameState)
            PiecesBoardView(gameState: gameState)
        }
    }
}

#Preview {
    ContentView()
}

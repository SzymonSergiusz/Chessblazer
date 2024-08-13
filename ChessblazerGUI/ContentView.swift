import SwiftUI

struct ContentView: View {
    
    @Bindable var gameState = GameState()
    @State var fen = ""
    @State var vsEngine = false
    var body: some View {
        HStack {
            Toggle("Silnik", isOn: $vsEngine)
            Button("Start new game") {
                gameState.vsEngine = vsEngine
                gameState.startNewGame()
            }
            TextField(text: $fen) {
                Text("Input FEN here and submit (enter)")
            }.onSubmit {
                gameState.loadFenGame(fen: fen)
            }
        }

        Spacer()
        ZStack {
            BoardView(gameState: gameState)
            PiecesBoardView(gameState: gameState)
        }
    }
}

#Preview {
    ContentView()
}

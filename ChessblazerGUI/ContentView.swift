import SwiftUI

struct ContentView: View {
    
    #warning("zmienic game: Game() na jakis observable object")
    
    @State var squarePositions: [Int: CGPoint] = [:]
    
    var body: some View {
        
        
//        GeometryReader { geometry in
//            let squareSize = min(geometry.size.width, geometry.size.height - (geometry.size.height / 9)) / 8

            ZStack {
                BoardView()
                
                PiecesBoardView()
                    .onAppear {
                        CurrentState.createCurrentState(game: CurrentState.game)
                    }
//                ChessPieceLayer(squarePositions: squarePositions)
            }

            
            
            
//        }
        
        
        
    }
}



/*
 
 frame ma określony size
 więc gdyby użyć geometry readera aby obliczył obecny frame dla square
 to z square1 do square2 można obliczyć indexy przy użyciu dragAmount / offsetu
 i jeśli square by się zgadzał
 np. square ma frame = 50
 jeśli dragamount.height / 50 to o ile wierszy w góre
 to dragamount.width / 50 to o ile kolumn
 czy w góre czy w dół? jeśli pieceposition.x < drag.width to w lewo
 jeśli pieceposition.y < drag.height to w góre
 
 
 
 
 */

#Preview {
    ContentView()
}

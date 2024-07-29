import SwiftUI

struct ContentView: View {
    @State var game = Game()
    
    var body: some View {
        VStack {
            Chessboard(game: $game)
        }
        .padding()
    }
}

struct Square: View {
    var color: Color
    var pieceValue: Int
    
    let pieceImage: [Int: Image] = [
        18 : Image("blackpawn"),
        21 : Image("blackrook"),
        19 : Image("blackknight"),
        20 : Image("blackbishop"),
        22 : Image("blackqueen"),
        17 : Image("blackking"),
        10 : Image("whitepawn"),
        13 : Image("whiterook"),
        11 : Image("whiteknight"),
        12 : Image("whitebishop"),
        14 : Image("whitequeen"),
        9 : Image("whiteking"),
    ]
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(color)
                .frame(width: 50, height: 50)
            
            if pieceValue != 0 {
                pieceImage[pieceValue]?
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            }
        }
    }
}


struct Chessboard: View {
    @Binding var game: Game
    
    var body: some View {
        VStack(spacing: 0) {
            let lightBrown = Color(red: 245/255, green: 213/255, blue: 193/255)
            let brown = Color(red: 133/255, green: 75/255, blue: 40/255)
            let letters = ["a", "b", "c", "d","e","f","g","h"]

            VStack(spacing: 0) {
                HStack(spacing: 0) {

                    Text(" ")
                        .frame(width: 50, height: 50)
                        .background(.white)
                        .foregroundColor(.black)
                        .font(.headline)
                    ForEach(letters, id: \.self) { letter in
                        Text(letter)
                            .frame(width: 50, height: 50)
                            .background(.white)
                            .foregroundColor(.black)
                            .font(.headline)
                    }
                }
                ForEach(0..<8) { row in
                    HStack(spacing: 0) {

                        Text("\(8 - row)")
                            .frame(width: 50, height: 50)
                            .background(.white)
                            .foregroundColor(.black)
                            .font(.headline)
                        ForEach(0..<8) { column in
                            let index = (7 - row) * 8 + column
                            let pieceValue = game.board[index]
                            Square(color: (row + column).isMultiple(of: 2) ? lightBrown : brown, pieceValue: pieceValue)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

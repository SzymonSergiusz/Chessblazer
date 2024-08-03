//
//  SquareView.swift
//  ChessblazerGUI
//
//  Created by sergiusz on 01/08/2024.
//

import SwiftUI

struct SquareView: View {
    var color: Color
    var index: Int
    var size: CGFloat = 50
//    @Binding var piecePositions: [Int: CGPoint]
    
    var piece: Int
    var piecePosition: CGPoint = CGPoint(x: 25, y: 25)

    
    
    var body: some View {

        
        ZStack() {
            Rectangle()
                .fill(color)
                .frame(width: size, height: size)
                .onTapGesture {
                    let square = CurrentState.squareToNotation(square: index)
                    print("Square tapped: \(square)")
                }
                .overlay(alignment: .center, content: {
                    Text(String(index)).font(.title)
//                    if piece > 0 {
//                        ChessPieceView(pieceValue: piece, indexOfSquare: index,width: size, height: size, game: $game)
//                    }
                })
        }
    }
}

struct PieceView: View {
    var color: Color
    var index: Int
    var size: CGFloat = 50

    var game: Game
    var piece: Int
    var piecePosition: CGPoint = CGPoint(x: 25, y: 25)

    
    
    var body: some View {

        
        ZStack() {

            ChessPieceView(pieceValue: piece, indexOfSquare: index,width: size, height: size)

        }
    }
}

//#Preview {
//    VStack {
//        SquareView(color: Settings.whiteSquaresColor, index: 0, piece: 0, game: .constant(Game()))
//
//        SquareView(color: Settings.blackSquaresColor, index: 1, piece: 0, game: .constant(Game()))
//    }
//}

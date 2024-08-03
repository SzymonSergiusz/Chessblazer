//
//  ChessPiece.swift
//  ChessblazerGUI
//
//  Created by sergiusz on 01/08/2024.
//

import SwiftUI

struct ChessPieceView: View {
    
    
    let pieceValue: Int
    @State var indexOfSquare: Int
    var width: CGFloat = 50
    var height: CGFloat = 50
    
    @State var piecePosition: CGPoint = CGPoint(x: 50, y: 50)
    @State var dragAmount = CGSize()
    var body: some View {
        if let image = ChessPiece.pieceImage[pieceValue] {
            image
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)
                .position(piecePosition)
                .offset(dragAmount)
                .onTapGesture {
                    CurrentState.getMoves(square: indexOfSquare)
                }
            
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if Piece.checkColor(piece: pieceValue) == CurrentState.game.currentTurnColor {
                                dragAmount = value.translation
                            }
                        }
                        .onEnded { value in
                            
                            let columns = Int(((piecePosition.x-dragAmount.width) / width).rounded(.down))
                            let rows = Int(((piecePosition.y-dragAmount.height) / height).rounded(.down))
                            
                            
                            print("rows: \(rows), columns: \(columns)")
                            print("aktualne miejsce: \(CurrentState.squareToNotation(square: indexOfSquare))")
                            
                            
                            var newIndex = -1
                            newIndex = indexOfSquare + (rows*8)+(-columns)
                            
                            print("nowe miejsce: \(CurrentState.squareToNotation(square: newIndex)) \(newIndex)")
                            
                            if (0...63).contains(newIndex) {
                                let validTargetSquares = CurrentState.validTargetSquares(fromSquare: indexOfSquare)
                                
                                print(validTargetSquares)
                                if validTargetSquares.contains(newIndex) {
                                    // wykonac ruch
                                    print("poprawny ruch")
                                    
                                    #warning("poprawić")
                                    CurrentState.game.makeMove(pieceValue: pieceValue, move: Move(fromSquare: indexOfSquare, targetSquare: newIndex))
                                    indexOfSquare = newIndex
                                    
                                    CurrentState.afterMove(game: CurrentState.game)
                                    
                                    return
                                }
                                
                                
                                dragAmount = .zero
                                
                            }
                            
                            
                            
                        }
                )
        }
    }
}

//#Preview {
//
//    ChessPieceView(pieceValue: 18, indexOfSquare: 0, game: .constant(Game()))
//}

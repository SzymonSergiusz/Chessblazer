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
    
    @Bindable var gameState: GameState
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
                    
                    Task.init {
                        await gameState.onPieceTap(square: indexOfSquare)
                    }
                }
            
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if Piece.checkColor(piece: pieceValue) == gameState.currentColorToMove {
                                dragAmount = value.translation
                                Task.init {
                                    await gameState.onPieceTap(square: indexOfSquare)
                                    
                                }
                            }
                            
                        }
                        .onEnded { value in
                            
                            let columns = Int(((piecePosition.x-dragAmount.width) / width).rounded(.down))
                            let rows = Int(((piecePosition.y-dragAmount.height) / height).rounded(.down))
                            
                            
                            print("rows: \(rows), columns: \(columns)")
                            print("current square: \(BoardUtils.squareToNotation(square: indexOfSquare))")
                            
                            
                            var newIndex = -1
                            newIndex = indexOfSquare + (rows*8)+(-columns)
                            
                            print("new square: \(BoardUtils.squareToNotation(square: newIndex)) \(newIndex)")
                            
                            if (0...63).contains(newIndex) {
                                let validTargetSquares = gameState.validTargetSquares(fromSquare: indexOfSquare)
                                
                                print(validTargetSquares)
                                if validTargetSquares.contains(newIndex) {
                                    // make a move
                                    print("correct move")
                                    gameState.makeMove(indexOfSquare, newIndex)
                                    
                                    
                                    indexOfSquare = newIndex
                                    
                                    return
                                }
                                
                                
                                dragAmount = .zero
                                
                            }
                            
                            
                            
                        }
                )
        } else {
            Rectangle()
                .frame(width: width, height: height)
                .position(piecePosition)
                .hidden()
            
        }
    }
}

#Preview {
    ChessPieceView(pieceValue: 9, indexOfSquare: 0, width: 150, height: 150,gameState: GameState(), piecePosition: CGPoint(x: CGFloat(200), y: CGFloat(200)))
}

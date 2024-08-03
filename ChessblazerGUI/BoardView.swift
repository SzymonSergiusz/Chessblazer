//
//  BoardView.swift
//  ChessblazerGUI
//
//  Created by sergiusz on 01/08/2024.
//

import SwiftUI


struct BoardView: View {
    
//    @Binding var game: Game
    var body: some View {
        
        GeometryReader { geometry in
            
            let squareSize = min(geometry.size.width, geometry.size.height - (geometry.size.height / 9)) / 8
            
            VStack(spacing: 0) {
                
                
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text(" ")
                            .frame(width: squareSize, height: squareSize)
                            .background(.white)
                            .foregroundColor(.black)
                            .font(.headline)
                        ForEach(Settings.letters, id: \.self) { letter in
                            Text(letter)
                                .frame(width: squareSize, height:squareSize)
                                .background(.white)
                                .foregroundColor(.black)
                                .font(.title2)
                        }
                    }
                }
                
                
                ForEach(0..<8) { row in
                    HStack(spacing: 0) {
                        
                        Text("\(8 - row)")
                            .frame(width: squareSize, height: squareSize)
                            .background(.white)
                            .foregroundColor(.black)
                            .font(.title2)
                        
                        ForEach(0..<8) { column in
                            let index = (7 - row) * 8 + column
                            
                            SquareView(color: (row + column).isMultiple(of: 2) ? Settings.lightBrown : Settings.brown, index: index, size: squareSize, piece: CurrentState.game.toBoardArrayRepresentation()[index])
                                
                        }
                        
                    }
                    
                }
                
                
            }   .frame(width: min(geometry.size.width, geometry.size.height), height: min(geometry.size.width, geometry.size.height))
                .aspectRatio(1, contentMode: .fit)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
        }
    }
}

struct PiecesBoardView: View {
//    @Binding var game: Game
    var body: some View {

        
        GeometryReader { geometry in
            
            let squareSize = min(geometry.size.width, geometry.size.height - (geometry.size.height / 9)) / 8
            
            VStack(spacing: 0) {
                
                
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text(" ")
                            .frame(width: squareSize, height: squareSize)
                            .background(.white)
                            .foregroundColor(.black)
                            .font(.headline)
                        ForEach(Settings.letters, id: \.self) { letter in
                            Text(letter)
                                .frame(width: squareSize, height:squareSize)
                                .background(.white)
                                .foregroundColor(.black)
                                .font(.title2)
                        }
                    }
                }
                
                
                ForEach(0..<8) { row in
                    HStack(spacing: 0) {
                        
                        Text("\(8 - row)")
                            .frame(width: squareSize, height: squareSize)
                            .background(.white)
                            .foregroundColor(.black)
                            .font(.title2)
                            .hidden()
                        
                        ForEach(0..<8) { column in
                            let index = (7 - row) * 8 + column
                            
                            PieceView(color: (row + column).isMultiple(of: 2) ? Settings.white : Settings.black, index: index, size: squareSize, game: CurrentState.game, piece: CurrentState.game.toBoardArrayRepresentation()[index])
                        }
                        
                    }
                    
                }
                
                
            }   .frame(width: min(geometry.size.width, geometry.size.height), height: min(geometry.size.width, geometry.size.height))
                .aspectRatio(1, contentMode: .fit)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
        }
    }
}

/*
 
 
 ChessPieceView(pieceValue: CurrentState.game.toBoardArrayRepresentation()[index], indexOfSquare: index, width: squareSize, height: squareSize, game: CurrentState.game, piecePosition: squareSize)
 
 */

//#Preview {
////    BoardView(game: .constant(Game()))
//}

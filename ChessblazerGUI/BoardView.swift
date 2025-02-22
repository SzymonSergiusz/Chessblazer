//
//  BoardView.swift
//  ChessblazerGUI
//
//  Created by sergiusz on 01/08/2024.
//

import SwiftUI


struct BoardView: View {
    
    @Bindable var gameState: GameState
    @State var geometry: GeometryProxy
    var body: some View {
        
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
                        
                        SquareView(color: (row + column).isMultiple(of: 2) ? Settings.lightBrown : Settings.brown, index: index, size: squareSize, piece: gameState.boardArray[index], gameState: gameState)
                        
                    }
                    
                }
                
            }
            
            
        }   .frame(width: min(geometry.size.width, geometry.size.height), height: min(geometry.size.width, geometry.size.height))
            .aspectRatio(1, contentMode: .fit)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        
    }
}

//#Preview {
//    BoardView(gameState: GameState())
//}

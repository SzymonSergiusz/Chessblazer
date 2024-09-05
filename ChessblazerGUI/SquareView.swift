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
    var piece: Int
    @State var piecePosition: CGPoint = CGPoint(x: 25, y: 25)
    @Bindable var gameState: GameState
    
    var body: some View {
        ZStack() {
            Rectangle()
                
                .fill(gameState.tappedPieceTargets.contains(index) ? Color.green : color)
                .fill(Settings.attackDebugMode && gameState.attackTable.contains(index) ? Color.red.opacity(0.7) : Color.white.opacity(0))
                .frame(width: size, height: size)
                .overlay(alignment: .center, content: {
                    Text(String(index)).font(.title3)
                })
                .onTapGesture {
                    let square = BoardUtils.squareToNotation(square: index)
                    print("Square tapped: \(square)")
                    gameState.onPieceTap(square: index)
                }
                
        }
    }
}

#Preview {
    
    HStack {
        SquareView(color: Settings.lightBrown, index: 0, size: 150, piece: 0, piecePosition: CGPoint(x: CGFloat(25), y: CGFloat(25)), gameState: GameState())
        
        SquareView(color: Settings.brown, index: 0, size: 150, piece: 0, piecePosition: CGPoint(x: CGFloat(25), y: CGFloat(25)), gameState: GameState())
    }

}

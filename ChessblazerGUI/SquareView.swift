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
                .frame(width: size, height: size)
                .onTapGesture {
                    let square = BoardUtils.squareToNotation(square: index)
                    print("Square tapped: \(square)")
                    gameState.onPieceTap(square: index)
                }
                .overlay(alignment: .center, content: {
                    Text(String(index)).font(.title)
                })
        }
    }
}

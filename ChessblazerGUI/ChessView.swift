//
//  ChessView.swift
//  ChessblazerGUI
//
//  Created by sergiusz on 04/09/2024.
//

import SwiftUI

struct ChessView: View {
    @Bindable var gameState: GameState
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                BoardView(gameState: gameState, geometry: geometry)
                PiecesBoardView(gameState: gameState, geometry: geometry)
            }

        }

    }
}

#Preview {
    
    ChessView(gameState: GameState())
}

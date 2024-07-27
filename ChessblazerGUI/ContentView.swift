//
//  ContentView.swift
//  ChessblazerGUI
//
//  Created by sergiusz on 28/07/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Chessboard()
       
        }
        .padding()
    }
}

struct Square: View {
    var color: Color
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 50, height: 50)
    }
}

struct Chessboard: View {
    var body: some View {
        VStack(spacing: 0) {

            let lightBrown = Color(red: 245/255, green: 213/255, blue: 193/255)
            let brown = Color(red: 133/255, green: 75/255, blue: 40/255)
                
            ForEach(0..<8) { row in
                HStack(spacing: 0) {
                    ForEach(0..<8) { column in
                        Square(color: (row + column).isMultiple(of: 2) ? lightBrown : brown)
                    }
                }
            }
        }
    }
}

struct PieceImage: View {
    var body: some View {
        Image(.blackpawn)
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
    }
}


#Preview {
    ContentView()
}

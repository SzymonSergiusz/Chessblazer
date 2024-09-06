# UCI-compatible Chess Engine fully written in Swift with dedicated GUI in SwiftUI
# Engine
## Game logic
### Implemented
- generating moves using bitboard
- checks
- xrays
- castling
- pawn promotions
### Not implemented yet
- en passant
- hashing magic bitboards
## AI
- not implemented
## Perft test results
<table>
   <tr>
    <th>Depth</th>
    <th>Nodes</th>
    <th>Passed</th>
  </tr>
  <tr>
    <td>0</td>
    <td>1</td>
    <td>✅</td>
  </tr>
  <tr>
    <td>1</td>
    <td>20</td>
    <td>✅</td>
  </tr>
  <tr>
    <td>2</td>
    <td>400</td>
    <td>✅</td>
  </tr>
  <tr>
    <td>3</td>
    <td>8902</td>
    <td>✅</td>
  </tr>
  <tr>
    <td>4</td>
    <td>197281</td>
    <td>✅</td>
  </tr>
</table>

# GUI
## UI
### Implemented
- basic game (based on engine)
- starting new game
- playing against engine (random moves as the engine is not yet completed)
- loading game from fen notation
- undoing moves
- choosing piece for pawn's promotion
### Not yet implemented
- switching pov
- choosing player's color
- making custom positions
- and many more (right now I don't plan anything for GUI as I focus on engine) 

# UCI-compatible Chess Engine fully written in Swift with dedicated GUI in SwiftUI
# Engine
## Current state showcase (engine vs engine)
<img src = "https://raw.githubusercontent.com/SzymonSergiusz/Chessblazer/main/res/showcase.gif" alt="showcase">
<i>it's not really smart yet</i>

## Game logic
### Implemented
- generating moves using bitboard
- hashing magic bitboards
- checks
- xrays
- castling
- pawn promotions
- en passant

### Not implemented yet

## AI
- 
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
- engine vs engine [check engine in left corner]
- loading game from fen notation
- undoing moves
### Not yet implemented
- choosing piece for pawn's promotion
- switching pov
- choosing player's color
- making custom positions
- and many more (right now I don't plan anything for GUI as I focus on engine) 

# UCI-compatible Chess Engine fully written in Swift with dedicated GUI in SwiftUI
# Engine
## Current state showcase (me vs engine)
<img src = "https://raw.githubusercontent.com/SzymonSergiusz/Chessblazer/main/res/showcase2.gif" alt="showcase">
<i>it's little smarter now</i>

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
### Implemented
- Alpha-Beta Pruning
- Move Ordering
- Iterative deepening
### Not implemented yet
- Transposition Table
- Opening book

## Perft test results
<a href="https://www.chessprogramming.org/Perft_Results">I use this data to compare with my results</a>

### From Initial Position
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
    <tr>
    <td>5</td>
    <td>4865609</td>
    <td>✅</td>
  </tr>
    </tr>
    <tr>
    <td>6</td>
    <td>119060324</td>
    <td>✅</td>
  </tr>
</table>

### Position 2 (Kiwipete)
<table>
   <tr>
    <th>Depth</th>
    <th>Nodes</th>
    <th>Passed</th>
  </tr>
  <tr>
    <td>1</td>
    <td>48</td>
    <td>✅</td>
  </tr>
  <tr>
    <td>2</td>
    <td>2039</td>
    <td>✅</td>
  </tr>
  <tr>
    <td>3</td>
    <td>97862</td>
    <td>✅</td>
  </tr>
  <tr>
    <td>4</td>
    <td>4085603</td>
    <td>✅</td>
  </tr>
</table>

### Position 4
<table>
   <tr>
    <th>Depth</th>
    <th>Nodes</th>
    <th>Passed</th>
  </tr>
  <tr>
    <td>1</td>
    <td>6</td>
    <td>✅</td>
  </tr>
  <tr>
    <td>2</td>
    <td>264</td>
    <td>✅</td>
  </tr>
  <tr>
    <td>3</td>
    <td>9467</td>
    <td>✅</td>
  </tr>
  <tr>
    <td>4</td>
    <td>422333</td>
    <td>✅</td>
  </tr>
    <tr>
    <td>5</td>
    <td>15833292</td>
    <td>✅</td>
  </tr>
</table>


# GUI
## UI
### Implemented
- basic game (based on engine)
- starting new game
- player vs engine [check engine in left corner]
- loading game from fen notation
- undoing moves
### Not yet implemented
- choosing piece for pawn's promotion
- switching pov
- choosing player's color
- making custom positions
- and many more (right now I don't plan anything for GUI as I focus on engine) 

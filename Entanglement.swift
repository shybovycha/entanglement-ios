import Darwin

class Tile {
    var connections: [(Int, Int)] = []

    func output(input: Int) -> Int {
        for (inPin, outPin) in self.connections {
            if inPin == input {
                return outPin
            }

            if outPin == input {
                return inPin
            }
        }

        return -1
    }

    func outputFromNeighbourOutput(output: Int) -> Int {
        return self.output(self.input(output))
    }

    func input(output: Int) -> Int {
        if (output % 2) == 0 {
            return (output + 12 - 5) % 12
        } else {
            return (output + 12 + 5) % 12
        }
    }

    func rotate(direction: Int) {
        var res: [(Int, Int)] = []

        for (input, output) in self.connections {
            res.append(((input + (direction * 2)) % 12, (output + (direction * 2)) % 12))
        }

        self.connections = res
    }

    // ↻
    func rotateRight() {
        self.rotate(1)
    }

    // ↺
    func rotateLeft() {
        self.rotate(-1)
    }

    // draw connections
    func render() {
        print("*", terminator: "")
    }

    func toString() -> String {
        return "\(self.connections)"
    }
}

class ZeroTile : Tile {
    override init() {
        super.init()

        self.connections = [(0, 0)]
    }

    override func render() {
        print("0", terminator: "")
    }
}

class BorderTile : Tile {
    // draw wall
    override func render() {
        print("x", terminator: "")
    }
}

class NullTile : Tile {
    // draw an empty space
    override func render() {
        print("o", terminator: "")
    }
}

class NonEmptyTile : Tile {

}

class PathItem {
    var u: Int, v: Int
    var input: Int
    var output: Int

    init(u: Int, v: Int, input: Int, output: Int) {
        self.u = u
        self.v = v
        self.input = input
        self.output = output
    }
}

class Path {
    var items: [PathItem] = []

    init(centerU u: Int, centerV v: Int) {
        self.expand(u, v: v, input: 0, output: 0)
    }

    func expand(u: Int, v: Int, input: Int, output: Int) {
        self.items.append(PathItem(u: u, v: v, input: input, output: output))
    }

    func toString() -> String {
        var res = "x"

        for item in self.items {
            res += " -> [\(item.u), \(item.v)] \(item.input) -> \(item.output)"
        }

        return res
    }

    func lastOutput() -> Int {
        return self.items.last!.output
    }
}

class Field {
    var tiles: [[Tile]] = []
    var path: Path = Path(centerU: 4, centerV: 4)
    var nextPlace: (Int, Int) = (5, 5)
    var pathFinished: Bool = false

    init() {
        self.tiles = []

        for i in 0...8 {
            self.tiles.append([])

            for _ in 0...8 {
                self.tiles[i].append(NullTile())
            }
        }

        self.tiles[4][4] = ZeroTile()

        for i in 0...4 {
            self.tiles[0][i] = BorderTile()
            self.tiles[i][0] = BorderTile()
            self.tiles[8][i + 4] = BorderTile()
            self.tiles[i + 4][8] = BorderTile()
        }

        for i in 1...4 {
            self.tiles[i][i + 4] = BorderTile()
            self.tiles[i + 4][i] = BorderTile()
        }
    }

    func findNextPlace() -> (Int, Int) {
        var u: Int, v: Int
        (u, v) = self.nextPlace

        let output: Int = self.path.lastOutput()

        switch output {
        case 0, 1:
            return (u + 1, v + 1)
        case 2, 3:
            return (u + 1, v)
        case 4, 5:
            return (u, v - 1)
        case 6, 7:
            return (u - 1, v - 1)
        case 8, 9:
            return (u - 1, v)
        case 10, 11:
            return (u, v + 1)
        default:
            return (u, v)
        }
    }

    func isPathFinished() -> Bool {
        return self.pathFinished
    }

    func placeTile(tile: NonEmptyTile) {
        var u: Int, v: Int

        (u, v) = self.nextPlace
        self.tiles[u][v] = tile

        while self.tiles[u][v] is NonEmptyTile {
            let lastOutput: Int = self.path.lastOutput()

            self.path.expand(u, v: v, input: self.tiles[u][v].input(lastOutput), output: self.tiles[u][v].outputFromNeighbourOutput(lastOutput))

            self.nextPlace = self.findNextPlace()
            (u, v) = self.nextPlace
        }

        if self.tiles[u][v] is ZeroTile || self.tiles[u][v] is BorderTile {
            self.pathFinished = true
        }
    }

    func render() {
        for row in self.tiles {
            for tile in row {
                tile.render()
            }

            print("")
        }
    }
}

enum GameError : ErrorType {
    case GameOver
}

class Game {
    var field: Field = Field()
    var pocket: NonEmptyTile = NonEmptyTile()
    var nextTile: NonEmptyTile = NonEmptyTile()
    var state: String {
        return "Is over: \(self.isGameOver())\nNext tile: \(self.nextTile.toString())\nPocket: \(self.pocket.toString())\nPath: \(self.field.path.toString())"
    }

    init() {
        self.nextTile = self.generateTile()
        self.pocket = self.generateTile()
    }

    func isGameOver() -> Bool {
        return self.field.isPathFinished()
    }

    func usePocket() throws {
        if isGameOver() {
            throw GameError.GameOver
        }

        swap(&self.pocket, &self.nextTile)
    }

    func rotateTileRight() throws {
        if isGameOver() {
            throw GameError.GameOver
        }

        self.nextTile.rotateRight()
    }

    func rotateTileLeft() throws {
        if isGameOver() {
            throw GameError.GameOver
        }

        self.nextTile.rotateLeft()
    }

    func placeTile() throws {
        if isGameOver() {
            throw GameError.GameOver
        }

        self.field.placeTile(self.nextTile)
        self.nextTile = self.generateTile()
    }

    func generateTile() -> NonEmptyTile {
        let tile = NonEmptyTile()

        var pool = [Int](0...11)

        for _ in 0...5 {
            var i = Int(arc4random_uniform(UInt32(pool.count)))
            let a = pool[i]
            pool.removeAtIndex(i)
            i = Int(arc4random_uniform(UInt32(pool.count)))
            let b = pool[i]
            pool.removeAtIndex(i)

            tile.connections.append((a, b))
        }

        return tile
    }
}

do {
    var game = Game()

    print(game.state)

    try game.placeTile()

    print(game.state)

    try game.rotateTileRight()

    print(game.state)

    try game.placeTile()

    print(game.state)

    try game.usePocket()

    print(game.state)

    try game.placeTile()

    print(game.state)
} catch GameError.GameOver {
    print("Game over")
}

import Darwin

class Cell {
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

class ZeroCell : Cell {
    override init() {
        super.init()

        self.connections = [(0, 0)]
    }

    override func render() {
        print("0", terminator: "")
    }
}

class BorderCell : Cell {
    // draw wall
    override func render() {
        print("x", terminator: "")
    }
}

class NullCell : Cell {
    // draw an empty space
    override func render() {
        print("o", terminator: "")
    }
}

class NonEmptyCell : Cell {

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

class Field {
    var cells: [[Cell]] = []
    var path: [PathItem] = [PathItem(u: 4, v: 4, input: 0, output: 0)]
    var nextPlace: (Int, Int) = (5, 5)
    var pathFinished: Bool = false

    init() {
        self.cells = []

        for i in 0...8 {
            self.cells.append([])

            for _ in 0...8 {
                self.cells[i].append(NullCell())
            }
        }

        self.cells[4][4] = ZeroCell()

        for i in 0...4 {
            self.cells[0][i] = BorderCell()
            self.cells[i][0] = BorderCell()
            self.cells[8][i + 4] = BorderCell()
            self.cells[i + 4][8] = BorderCell()
        }

        for i in 1...4 {
            self.cells[i][i + 4] = BorderCell()
            self.cells[i + 4][i] = BorderCell()
        }
    }

    func findNextPlace() -> (Int, Int) {
        var u: Int, v: Int
        (u, v) = self.nextPlace

        let output: Int = self.path.last!.output

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

    func placeCell(cell: NonEmptyCell) {
        var u: Int, v: Int

        (u, v) = self.nextPlace
        self.cells[u][v] = cell

        while self.cells[u][v] is NonEmptyCell {
            let lastOutput: Int = self.path.last!.output

            self.path.append(PathItem(u: u, v: v, input: self.cells[u][v].input(lastOutput), output: self.cells[u][v].outputFromNeighbourOutput(lastOutput)))

            self.nextPlace = self.findNextPlace()
            (u, v) = self.nextPlace
        }

        if self.cells[u][v] is ZeroCell || self.cells[u][v] is BorderCell {
            self.pathFinished = true
        }
    }

    func render() {
        for row in self.cells {
            for cell in row {
                cell.render()
            }

            print("")
        }
    }

    func pathToString() -> String {
        var res = ""

        for item in self.path {
            res += " -> [\(item.u), \(item.v)] \(item.input) -> \(item.output)"
        }

        return res
    }
}

class Game {
    var field: Field = Field()
    var pocket: Cell = Cell()

    init() {
        self.pocket = self.generateCell()
    }

    func isGameEnded() -> Bool {
        return self.field.isPathFinished()
    }

    func generateCell() -> Cell {
        let cell = Cell()

        var pool = [Int](0...11)

        for _ in 0...5 {
            var i = Int(arc4random_uniform(UInt32(pool.count)))
            let a = pool[i]
            pool.removeAtIndex(i)
            i = Int(arc4random_uniform(UInt32(pool.count)))
            let b = pool[i]
            pool.removeAtIndex(i)

            cell.connections.append((a, b))
        }

        return cell
    }
}

// var field: Field = Field()
// field.render()

var game = Game()

var cell = NonEmptyCell() //game.generateCell()
cell.connections = [(11, 5), (4, 10), (2, 3), (7, 1), (0, 6), (9, 8)]
cell.output(cell.input(0))

print("Cell #1: \(cell.toString())")

game.field.placeCell(cell)

// cell = game.generateCell()
var cell2 = NonEmptyCell()
cell2.connections = [(3, 5), (6, 7), (10, 11), (0, 2), (8, 1), (9, 4)]

print("Cell #2: \(cell2.toString())")

game.field.placeCell(cell2)

print(game.field.pathToString()) // should be ({0} ->) {7 -> 1} -> {6 -> 7} -> {0 -> 6} -> {0}

print("Game ended? \(game.isGameEnded())")

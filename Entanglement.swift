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
        var res = ""

        for (a, b) in self.connections {
            res += "(\(a), \(b))"
        }

        return res
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

class PathItem {
    var cell: Cell
    var input: Int
    var output: Int

    init(cell: Cell, input: Int) {
        self.cell = cell
        self.input = cell.input(input)
        self.output = cell.output(self.input)
    }
}

class Field {
    var cells: [[Cell]] = []
    var path: [PathItem] = []
    var nextPlace: (Int, Int) = (5, 4)

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

    func placeCell(cell: Cell) {
        if self.path.count == 0 {
            self.path.append(PathItem(cell: cell, input: 0))
        } else {
            self.path.append(PathItem(cell: cell, input: self.path.last!.output))
        }

        var u: Int, v: Int

        (u, v) = self.nextPlace
        self.cells[u][v] = cell

        self.nextPlace = self.findNextPlace()
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
        if self.path.count < 1 {
            return ""
        }

        var res = "\(self.path.first!.input)"

        for item in self.path {
            res += " -> \(item.output)"
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

var cell = Cell() //game.generateCell()
cell.connections = [(11, 5), (4, 10), (2, 3), (7, 1), (0, 6), (9, 8)]
cell.output(cell.input(0))

print(cell.toString())

game.field.placeCell(cell)

// cell = game.generateCell()
cell.connections = [(3, 5), (6, 7), (10, 11), (0, 2), (8, 1), (9, 4)]

print(cell.toString())

game.field.placeCell(cell)

print(game.field.pathToString()) // should be ({0} ->) {7 -> 1} -> {6 -> 7} -> {0 -> 6} -> {0}

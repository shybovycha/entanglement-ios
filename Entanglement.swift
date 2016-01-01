import Darwin

class Cell {
    var connections: [(Int, Int)] = []

    func output(input: Int) -> Int {
        for (inPin, outPin) in self.connections {
            if inPin == input {
                return outPin
            }
        }

        return -1
    }

    func input(output: Int) -> Int {
        for (inPin, outPin) in self.connections {
            if outPin == output {
                return inPin
            }
        }

        return -1
    }

    func rotate(direction: Int) {
        var res: [(Int, Int)] = []

        for (_in, _out) in self.connections {
            res.append(((_in + (direction * 2)) % 12, (_out + (direction * 2)) % 12))
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
        self.input = input
        self.output = cell.output(input)
    }
}

class Field {
    var cells: [[Cell]] = []
    var path: [PathItem] = []

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

    func placeCell(cell: Cell) {
        if self.path.count == 0 {
            self.path.append(PathItem(cell: cell, input: 0))
        } else {
            self.path.append(PathItem(cell: cell, input: self.path.last!.output))
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

var cell = game.generateCell()

print(cell.toString())

game.field.placeCell(cell)

cell = game.generateCell()

print(cell.toString())

game.field.placeCell(cell)

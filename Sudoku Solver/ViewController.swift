//
//  ViewController.swift
//  Sudoku Solver
//
//  Created by Acoustictime on 4/4/19.
//  Copyright © 2019 Acoustictime. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var placed = 1
    
    var board : [[Int]] = [
        [9,4,0,0,0,0,8,0,7],
        [0,0,3,0,0,8,0,0,0],
        [0,0,2,4,0,0,9,0,0],
        [0,0,0,0,0,0,0,0,0],
        [6,2,0,0,3,0,0,0,1],
        [0,0,0,7,0,9,0,3,8],
        [3,0,8,2,4,0,0,0,0],
        [4,0,0,9,0,7,0,0,0],
        [0,9,0,0,0,1,0,0,0]
    ]
    
//    var board : [[Int]] = [
//        [0,0,0,0,0,0,0,0,0],
//        [0,0,0,0,0,0,0,0,0],
//        [0,0,0,0,0,0,0,0,0],
//        [0,0,0,0,0,0,0,0,0],
//        [0,0,0,0,0,0,0,0,0],
//        [0,0,0,0,0,0,0,0,0],
//        [0,0,0,0,0,0,0,0,0],
//        [0,0,0,0,0,0,0,0,0],
//        [0,0,0,0,0,0,0,0,0]
//    ]
    
    var actualBoard : [[Int]] = []
    
    var boardLabels : [[UILabel]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let button = UIButton(frame: CGRect(x: 125, y: 100, width: 100, height: 50))
        button.backgroundColor = .lightGray
        button.setTitle("Solve", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        view.addSubview(button)
        
        var baseX = 50
        var baseY = 200
        let rowLines = ["-","-","-","|","-","-","-","|","-","-","-"]
        
        for (index, row) in board.enumerated() {
            
            var rowLabels : [UILabel] = []
            
            if index != 0 && index % 3 == 0 {
                
                for value in rowLines {
                    let label2 = UILabel()
                    label2.frame = CGRect(x: baseX, y: baseY, width: 20, height: 20)
                    label2.text = value
                    label2.textColor = .lightGray
                    view.addSubview(label2)
                    baseX += 25
                }
                baseX = 50
                baseY += 25
            }
            
            for (index, column) in row.enumerated() {
                
                if index != 0 && index % 3 == 0 {
                    let label2 = UILabel()
                    label2.frame = CGRect(x: baseX, y: baseY, width: 20, height: 20)
                    label2.text = "|"
                    label2.textColor = .lightGray
                    view.addSubview(label2)
                    baseX += 25
                }
                
                
                let label = UILabel()
                label.frame = CGRect(x: baseX, y: baseY, width: 20, height: 20)
                label.text = column == 0 ? " " : String(column)
                label.textColor = column == 0 ? .red : .black
                rowLabels.append(label)
                view.addSubview(label)
                baseX += 25
            }
            baseY += 25
            baseX = 50
            boardLabels.append(rowLabels)
        }
        
        actualBoard = board
    }

    @objc func buttonAction(sender: UIButton!) {
        
        
        var openSpaces : [(Int,Int)] = []
        
        for (indexRow, row) in actualBoard.enumerated() {
            for (indexColumn, _) in row.enumerated() {
                if actualBoard[indexRow][indexColumn] == 0 {
                    // found blank spot
                    openSpaces.append((indexRow, indexColumn))
                    //boardLabels[indexRow][indexColumn].text = "x"
                }
            }
        }
        
        var index = 0
        
        DispatchQueue.global(qos: .background).async {
            
            while index < openSpaces.count {
                
                let row = openSpaces[index].0
                let column = openSpaces[index].1
                var currentValue = self.actualBoard[row][column]
                
                let possible = self.getPossibleForLocation(value: currentValue, row: row, column: column)
                
                if possible.count == 0 {
                    self.actualBoard[row][column] = 0
                    DispatchQueue.main.async {
                        self.boardLabels[row][column].text = " "
                    }
                    
                    index -= 1
                    continue
                }

                if currentValue == 0 {
                    currentValue = possible[0]
                } else {
                    
                    let possibleIndex = possible.firstIndex(of: currentValue)
                    
                    if let finalIndex = possibleIndex {
                        
                        if finalIndex + 1 == possible.count {
                            self.actualBoard[row][column] = 0
                            DispatchQueue.main.async {
                                self.boardLabels[row][column].text = " "
                            }
                            index -= 1
                            continue
                        } else {
                            currentValue = possible[finalIndex + 1]
                        }
                    }
                    
                }
                
                //currentValue += 1
                
                self.actualBoard[row][column] = currentValue
                
                DispatchQueue.main.async {
                    self.boardLabels[row][column].text = String(currentValue)
                }
                
                
                
                if self.checkIfErrorForPlacedValue(value: currentValue, row: row, column: column) {
                    
                    continue
                }
                index += 1
                print(self.placed)
                self.placed += 1
                
               
            }
            
        }
        
        
        
        
        
        
        
        
    }
    
    func getPossibleForLocation(value: Int, row: Int, column: Int) -> [Int] {
        
        let final : [Int] = [1,2,3,4,5,6,7,8,9]
        
        // row data
        let rowData = getRowData(row: row)
        
        
        

        // column data
        let columnData = getColumnData(column: column)
        // square data
        let squareData = getSquareData(row: row, column: column)
        
        let unique1 = Array(Set(rowData + columnData)).sorted()
        var unique2 = Array(Set(unique1 + squareData)).sorted()
        
        unique2.removeFirst()
        let indexOfCurrent = unique2.firstIndex(of: value)
        if let index = indexOfCurrent {
            unique2.remove(at: index)
        }
        
        let thisSet = Set(final)
        let otherSet = Set(unique2)
        
        return Array(thisSet.symmetricDifference(otherSet)).sorted()
    }
    
    func checkIfErrorForPlacedValue(value: Int, row : Int, column : Int) -> Bool {
        
        if checkIfRowHasError(value: value, row: row) || checkIfColumnHasError(value: value, column: column) || checkIfSquareHasError(value: value, row: row, column: column) {
            return true
        }
        
        return false
    }
    
    func getSquareData(row: Int, column: Int) -> [Int] {
        
        var squareData : [Int] = []
        
        switch column {
        case 0,1,2:
            switch row {
            case 0,1,2:
                for row in 0...2 {
                    for col in 0...2 {
                        squareData.append(actualBoard[row][col])
                    }
                }
            case 3,4,5:
                for row in 3...5 {
                    for col in 0...2 {
                        squareData.append(actualBoard[row][col])
                    }
                }
            case 6,7,8:
                for row in 6...8 {
                    for col in 0...2 {
                        squareData.append(actualBoard[row][col])
                    }
                }
            default:
                print("Problem")
            }
        case 3,4,5:
            switch row {
            case 0,1,2:
                for row in 0...2 {
                    for col in 3...5 {
                        squareData.append(actualBoard[row][col])
                    }
                }
            case 3,4,5:
                for row in 3...5 {
                    for col in 3...5 {
                        squareData.append(actualBoard[row][col])
                    }
                }
            case 6,7,8:
                for row in 6...8 {
                    for col in 3...5 {
                        squareData.append(actualBoard[row][col])
                    }
                }
            default:
                print("Problem")
            }
        case 6,7,8:
            switch row {
            case 0,1,2:
                for row in 0...2 {
                    for col in 6...8 {
                        squareData.append(actualBoard[row][col])
                    }
                }
            case 3,4,5:
                for row in 3...5 {
                    for col in 6...8 {
                        squareData.append(actualBoard[row][col])
                    }
                }
            case 6,7,8:
                for row in 6...8 {
                    for col in 6...8 {
                        squareData.append(actualBoard[row][col])
                    }
                }
            default:
                print("Problem")
            }
        default:
            print("Problem")
        }
        
        return squareData
    }
    
    
    func checkIfSquareHasError(value: Int, row : Int, column : Int) -> Bool {
        
        let squareData = getSquareData(row: row, column: column)
        
        let count = squareData.filter{$0 == value}.count
        
        if count > 1 {
            return true
        }
        
        return false
    }
    
    func getRowData(row: Int) -> [Int] {
        
        let rowData = actualBoard[row]
        
        return rowData
    }
    
    func checkIfRowHasError(value: Int, row : Int) -> Bool {
        
        let rowData = getRowData(row: row)
        let count = rowData.filter{$0 == value}.count
        
        if count > 1 {
            return true
            
        }
        
        return false
    }
    
    func getColumnData(column: Int) -> [Int] {
        
        var columnData : [Int] = []
        
        for row in actualBoard {
            columnData.append(row[column])
        }
        
        return columnData
    }
    
    func checkIfColumnHasError(value: Int, column : Int) -> Bool {
        
        let columnData = getColumnData(column: column)
        
        let count = columnData.filter{$0 == value}.count
        
        if count > 1 {
            return true
        }
        
        return false
    }
    
}


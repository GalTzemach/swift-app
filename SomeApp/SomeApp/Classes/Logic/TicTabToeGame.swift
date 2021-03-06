//
//  TicTabToe.swift
//  SomeApp
//
//  Created by Perry on 2/23/16.
//  Copyright © 2016 PerrchicK. All rights reserved.
//

import Foundation

protocol TicTabToeGameDelegate: class {
    func ticTabToeGame(game: TicTabToeGame, finishedWithWinner winner: TicTabToeGame.Player)
    func isGameEnabled(game: TicTabToeGame) -> Bool
}

class TicTabToeGame {

    weak var delegate: TicTabToeGameDelegate?

    struct Configuration {
        static let RowsCount = 3
        static let ColumnsCount = Configuration.RowsCount
        static let MaxMovesInSequence = Configuration.RowsCount
    }

    enum Player: String { // Enums don't must to inherit from anywhere, but it's helpful
        case X = "X"
        case O = "O"

        func intValue() -> Int {
            return Player.X == self ? 1 : -1
        }
    }

    // Computed property
    private var isGameEnabled: Bool {
        // Using 'guard' keyword to ensure that the delegate exists (not null):
        guard let delegate = delegate else { return false }
        // If exists: Make a new (and not optional!) object and continue
        // If it doesn't exist: do nothing and return 'false'

        return delegate.isGameEnabled(self)
    }

    private var matrix = Array<[Int?]>(count: Configuration.ColumnsCount, repeatedValue: Array<Int?>(count: Configuration.RowsCount, repeatedValue: nil))
    private(set) var currentPlayer: Player
    
    init() {
        currentPlayer = Player.X
    }
    
    func playerMadeMove(row: Int, column: Int) -> Bool {
        var didPlay = false
        // Using 'guard' keyword to ensure conditions
        guard isGameEnabled && matrix[row][column] == nil else { return didPlay }

        matrix[row][column] = currentPlayer.intValue()
        didPlay = true

        if let winner = checkWinner() {
            delegate?.ticTabToeGame(self, finishedWithWinner: winner)
        } else {
            switchTurns()
        }

        return didPlay
    }

    private func switchTurns() {
        currentPlayer = currentPlayer == Player.X ? Player.O : Player.X
    }

    private func checkWinner() -> Player? {
        var winner: Player? = nil
        var diagonalSequenceCounter = 0
        var reverseDiagonalSequenceCounter = 0

        var verticalSequenceCounter = Array<Int>(count: Configuration.MaxMovesInSequence, repeatedValue: 0)
//      Or: var verticalSequenceCounter = [0,0,0]
        for row in 0...Configuration.RowsCount - 1 {
            // Using 'guard' keyword for optimization in runtime, skips redundant loops
            guard winner == nil else { return winner }

            // Count \
            let diagonalIndex = row
            if let moveInDiagonalSequence = matrix[diagonalIndex][diagonalIndex] {
                if moveInDiagonalSequence == currentPlayer.intValue() {
                    // Removed on Swift 3.0:
//                    diagonalSequenceCounter++
                    diagonalSequenceCounter += 1
                }
            }

            // Count /
            let reverseDiagonalIndex = Configuration.RowsCount - row - 1
            if let moveInReverseDiagonalSequence = matrix[row][reverseDiagonalIndex] {
                if moveInReverseDiagonalSequence == currentPlayer.intValue() {
                    // Removed on Swift 3.0:
//                    reverseDiagonalSequenceCounter++
                    reverseDiagonalSequenceCounter += 1
                }
            }

            var horizontalSequenceCounter = 0
            for column in 0...Configuration.ColumnsCount - 1 {
                if let moveInRow = matrix[row][column] {
                    if moveInRow == currentPlayer.intValue() {
                        // Count -
                        horizontalSequenceCounter += 1
                        // Count |
                        verticalSequenceCounter[column] += currentPlayer.intValue()
                    }
                }
            }

            if [horizontalSequenceCounter, diagonalSequenceCounter, reverseDiagonalSequenceCounter].contains(Configuration.MaxMovesInSequence) {
                // 3 in an horozintal / diagonal row
                winner = currentPlayer
            } else if verticalSequenceCounter.contains(-Configuration.MaxMovesInSequence) || verticalSequenceCounter.contains(Configuration.MaxMovesInSequence) {
                // 3 in a vertical row
                winner = currentPlayer
            }
        }

        return winner
    }
}
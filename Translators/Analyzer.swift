//
//  Analyzer.swift
//  Translators
//
//  Created by Ruslan Serebryakov on 12/15/16.
//  Copyright © 2016 Ruslan Serebryakov. All rights reserved.
//

import Foundation

struct CompilerError {
    var description: String
}

typealias LexemDescription = (String, ID: Int, LexemType)

enum LexemType {
    case op
    case constant(Int)
    case identifier(Int)
}

class Analyzer {
    private let lexemsIDs: [String: Int] = [
        "program": 0,
        "var": 1,
        "mark": 2,
        "begin": 3,
        "end": 4,
        "int": 5,
        "read": 6,
        "write": 7,
        "repeat": 8,
        "until": 9,
        "if": 10,
        "then": 11,
        "goto": 12,
        "or": 13,
        "and": 14,
        "not": 15,
        "less": 16,
        "more": 17,
        "equals": 18,
        "\n": 19,
        ",": 20,
        ".": 21,
        "=": 22,
        "+": 23,
        "-": 24,
        "*": 25,
        "/": 26,
        "^": 27,
        "(": 28,
        ")": 29,
        "~": 30,
        ":": 31
    ]

    private let identifiersID = 24
    private let constantsID = 25

    private let limiters = ["\n", ".", "~", ":", "+", "*", ",", "=", "/", "-", "^", "(", ")"]
    private let whiteLimiters = [" ", "\t"]

    var lexems: [LexemDescription] = []
    var constants: [Int] = []
    var identifiers: [String] = []

    var errors: [CompilerError] = []

    // Syntax analyzer iterator
    private var i = 0

    // MARK: Lexical analyzer
    func lexicalAnalyzer(code: String) {
        lexems = []
        constants = []
        identifiers = []

        var i = 0
        while i < code.characters.count {
            // Search by the limiter
            var curr = ""
            while i < code.characters.count && !limiters.contains(code[i]) && !whiteLimiters.contains(code[i]) {
                curr += code[i]
                i += 1
            }

            // Checking lexems hash table
            if let id = lexemsIDs[curr] {
                lexems.append((curr, id, .op))
            } else { // let's see if it's a constant or identifier
                if let constant = Int(curr) {
                    if !constants.contains(constant) {
                        constants.append(constant)
                    }

                    let constantIndex = constants.index(of: constant)!
                    lexems.append((curr, constantsID, .constant(constantIndex)))
                } else if isWord(curr) {
                    if !identifiers.contains(curr) {
                        identifiers.append(curr)
                    }

                    let identifierIndex = identifiers.index(of: curr)!
                    lexems.append((curr, identifiersID, .identifier(identifierIndex)))
                } else {
                    if curr != "" {
                        errors.append(CompilerError(description: "Unknown lexem \(curr)"))
                    }
                }
            }

            if i < code.characters.count && !whiteLimiters.contains(code[i]) {
                if let id = lexemsIDs[code[i]] {
                    // Add limiters to the lexems list
                    lexems.append((code[i], id, .op))
                }
            }
            i += 1
        }
    }

    // MARK: Syntax analyzer
    func syntaxAnalyzer() {
        match("program")
        match(.identifier(-1))
        match("\n")

        match("var")
        checkVars()
        match("\n")

        match("mark")
        checkMarks()
        match("\n")

        match("begin")
        match("\n")
        checkStatements()
        match("end")

        i=0
    }

    // MARK: <statements>
    private func checkStatements() {
        while checkStatement() {
            match("\n")
        }
    }
    private func checkStatement() -> Bool {
        if check("read") {
            matchRead()
            return true
        } else if check("write") {
            matchWrite()
            return true
        } else if check(.identifier(-1)) { // mark or var
            if check("=") {
                matchExpression()
            } else {
                match(":")
            }
            return true
        } else if check("repeat") {
            match("\n")
            checkStatements()
            match("until")
            matchCondition()
            return true
        } else if check("if") {
            matchCondition()
            match("then")
            match("goto")
            match(.identifier(-1))
            return true
        }
        return false
    }

    // MARK: <vars>
    private func checkVars() {
        while check(.identifier(-1)) {
            match(".")
        }
    }

    // MARK: <marks>
    private func checkMarks() {
        while check(.identifier(-1)) {
            match("~")
        }
    }

    // MARK: <condition>
    private func matchCondition() {
        matchCT()
        while check("or") {
            matchCT()
        }
    }
    private func matchCT() {
        matchCM()
        while check("and") {
            matchCM()
        }
    }
    private func matchCM() {
        if check("not") {
            matchCM()
        } else {
            matchRatio()
        }
    }
    private func matchRatio() {
        matchExpression()
        if !check("less") && !check("more") && !check("equals") {
            errors.append(CompilerError(description: "Wrong ratio"))
        }
        matchExpression()
    }

    // MARK: <expression>
    private func matchExpression() {
        matchT()
        while check("+") || check("-") {
            matchT()
        }
    }
    private func matchT() {
        matchM()
        while check("*") || check("/") {
            matchM()
        }
    }
    private func matchM() {
        if !(check(.identifier(-1)) || check(.constant(-1))) {
            if (!check("(")) {
                errors.append(CompilerError(description: "Wrong assigning"))
            } else {
                matchExpression()
                match(")")
            }
        }
    }

    // MARK: <read>
    private func matchRead() {
        match("(")
        checkVars()
        match(")")
    }
    // MARK: <write>
    private func matchWrite() {
        match("(")
        checkVars()
        match(")")
    }

    // MARK: Common
    private func match(_ op: String) {
        if !check(op) {
            errors.append(CompilerError(description: "Error with matching \(lexems[i].0) to the pattern"))
            i += 1
        }
    }
    private func match(_ op: LexemType) {
        if !check(op) {
            errors.append(CompilerError(description: "Error with matching \(lexems[i].0) to the pattern"))
            i += 1
        }
    }
    private func check(_ op: String) -> Bool {
        if lexems[i].0 == op {
            i += 1
            return true
        }
        return false
    }
    private func check(_ type: LexemType) -> Bool {
        if lexems[i].2 == type {
            i += 1
            return true
        }
        return false
    }

    // MARK: Supporting functions
    private func isWord(_ c: String) -> Bool {
        let scalar = c.unicodeScalars[c.unicodeScalars.startIndex].value
        return ((scalar >= 65) && (scalar <= 90)) || ((scalar >= 97) && (scalar <= 122)) || scalar == 95
    }
}

func ==(lhs: LexemType, rhs: LexemType) -> Bool {
    switch (lhs, rhs) {
    case (.op, .op): return true
    case (.constant(_), .constant(_)): return true
    case (.identifier(_), .identifier(_)): return true
    default: return false
    }
}

extension String {
    subscript(i: Int) -> String {
        guard i >= 0 && i < characters.count else { return "" }
        return String(self[index(startIndex, offsetBy: i)])
    }
    subscript(range: CountableRange<Int>) -> String {
        let lowerIndex = index(startIndex, offsetBy: max(0,range.lowerBound), limitedBy: endIndex) ?? endIndex
        return self[lowerIndex..<(index(lowerIndex, offsetBy: range.upperBound - range.lowerBound, limitedBy: endIndex) ?? endIndex)]
    }
    subscript(range: ClosedRange<Int>) -> String {
        let lowerIndex = index(startIndex, offsetBy: max(0,range.lowerBound), limitedBy: endIndex) ?? endIndex
        return self[lowerIndex..<(index(lowerIndex, offsetBy: range.upperBound - range.lowerBound + 1, limitedBy: endIndex) ?? endIndex)]
    }
}

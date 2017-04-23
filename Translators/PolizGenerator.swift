//
//  PolizGenerator.swift
//  Translators
//
//  Created by Ruslan Serebryakov on 3/21/17.
//  Copyright © 2017 Ruslan Serebryakov. All rights reserved.
//

import Foundation

struct InternalMark {
    var name: String
    var index: Int
}

struct UPH {
    var mark: InternalMark
}

class PolizGenerator {
    private let expressionOperations: [String] = [
        "if",
        "repeat",
    ]
    private let UPHOperations: [String] = [
        "then",
        "until"
    ]

    private let operationsPriorities: [String: Int] = [
        "if": 0,
        "repeat": 0,
        "then": 1,
        "goto": 1,
        //"until": 1,
        "(": 0,
        ")": 1,
        "=": 4,
        "+": 5,
        "-": 5,
        "*": 6,
        "/": 6,
        "^": 7,
        "less": 8,
        "more": 8,
        "equals": 8,
        "or": 9,
        "and": 10,
        "not": 10,
        "until": 11,
        "write": 12,
        "read": 13
    ]

    var lexems: [LexemDescription] = [] {
        didSet {
            let filteredLexems = lexems
            lexems = []
            var flag = false

            for lexem in filteredLexems {
                if lexem.0 == "end" {
                    break
                }
                if flag {
                    lexems.append(lexem)
                }
                if lexem.0 == "begin" {
                    flag = true
                }
            }

            _ = lexems.removeFirst()
        }
    }
    var polizLexems: [Any] = []
    var out: [String] = []
    var marks: [InternalMark] = []

    var steps: [PolizStep] = []

    // MARK: Private stuff
    private var marksCount = 0
    private var stack: [(LexemDescription, [Any])] = []

    func generatePoliz() {
        var finishExpression = false
        var lexemsOffset = 0
        steps = []
        polizLexems = []
        out = []
        marks = []

        for (index, lexem) in lexems.enumerated() {
            if lexem.0 == "." {
                lexemsOffset += 1
                continue
            }
            if lexem.0 == ":" {
                lexemsOffset += 1
                let mark = InternalMark(name: lexems[index-1].0, index: index-lexemsOffset)
                polizLexems.append(mark)
                continue
            }

            var step: PolizStep = ([], [], lexem.0)

            if lexem.2 == .constant(-1) || lexem.2 == .identifier(-1) {
                polizLexems.append(lexem)

                step.out.append(lexem.0)
            } else {
                while !stack.isEmpty && (lexem.0 == "\n" || (operationsPriorities[lexem.0]! <= operationsPriorities[stack.last!.0.0]! && operationsPriorities[lexem.0]! > 0)) {
                    if expressionOperations.contains(stack.last!.0.0) {
                        if finishExpression {
                            for mark in marks.reversed() {
                                if stack.last!.0.0 == "repeat" {
                                    let uphOperation = UPH(mark: mark)
                                    polizLexems.append(uphOperation)

                                    step.out.append(mark.name + "UPH")

                                    // m2 creation
                                    let mark2 = InternalMark(name: "m\(marksCount)", index: polizLexems.count+2)
                                    let gotoOperation = ("goto", 12, LexemType.op)
                                    //polizLexems.append(mark2)
                                    //polizLexems.append(gotoOperation)

                                    //step.out.append("\(mark2.name)")
                                    //step.out.append("goto")

                                    _ = stack.removeLast()
                                } else if stack.last!.0.0 == "if" {
                                    var mark2 = mark
                                    mark2.index = polizLexems.count
                                    polizLexems.append(mark2)

                                    step.out.append(mark2.name)
                                    _ = stack.removeLast()
                                }
                            }
                            marks = []
                            finishExpression = false
                        }
                        break
                    } else {
                        let last = stack.removeLast()
                        if last.0.0 != "(" && last.0.0 != ")" {
                            polizLexems.append(last)
                            step.out.append(last.0.0)
                        }
                    }
                }
                // repeat until
                if lexem.0 == "repeat" {
                    let mark = InternalMark(name: "m\(marksCount)", index: polizLexems.count+1)
                    polizLexems.append(mark)
                    step.out.append(mark.name)

                    marks.append(mark)
                    marksCount += 1
                    stack.append((lexem, [mark]))
                } else if UPHOperations.contains(lexem.0) {
                    finishExpression = true

                    if lexem.0 == "then" {
                        let mark = InternalMark(name: "m\(marksCount)", index: polizLexems.count+3)
                        let uphOperation = UPH(mark: mark)
                        marks.append(mark)
                        marksCount += 1
                        polizLexems.append(uphOperation)

                        step.out.append("\(mark.name)UPH")
                    }
                } else if lexem.0 != "\n" {
                    stack.append((lexem, []))
                } else {
                    lexemsOffset += 1
                }
            }

            step.1 = stack.map({ $0.0.0 })
            steps.append(step)
            out += step.out
        }
    }
}

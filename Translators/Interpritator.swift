//
//  Interpritator.swift
//  Translators
//
//  Created by Ruslan Serebryakov on 3/23/17.
//  Copyright © 2017 Ruslan Serebryakov. All rights reserved.
//

import Foundation

class Interpritator {
    var lexems: [Any] = []
    var marks: [InternalMark] = []
    var input: [Int] = []
    var out: String = ""

    private var stack: [Any] = []
    private var identifiersMap: [String: Int] = [:]

    private func isTransitionOperation(_ lexem: LexemDescription) -> Bool {
        return !["+", "-", "*", "/", "^"].contains(lexem.0)
    }

    func interpritate() {
        out = ""
        var i = 0
        while i < lexems.count {
            let lexem = lexems[i]
            if let lexem = lexem as? LexemDescription {
                if lexem.2 == .constant(-1) || lexem.2 == .identifier(-1) {
                    stack.append(lexem)
                } else {
                    if !isTransitionOperation(lexem) {
                        let firstOperand = stack.removeLast() as! LexemDescription
                        let secondOperand = stack.removeLast() as! LexemDescription
                        var first: Int = Int.min
                        var second: Int = Int.min
                        var result: LexemDescription = ("", -1, .constant(-1))

                        if firstOperand.2 == .constant(-1) {
                            first = Int(firstOperand.0)!
                        } else if firstOperand.2 == .identifier(-1) {
                            if let value = identifiersMap[firstOperand.0] {
                                first = Int(value)
                            }
                        }
                        if secondOperand.2 == .constant(-1) {
                            //print(secondOperand)
                            second = Int(secondOperand.0)!
                        } else if secondOperand.2 == .identifier(-1) {
                            if let value = identifiersMap[secondOperand.0] {
                                second = Int(value)
                            }
                        }

                        switch lexem.0 {
                        case "+":
                            result.0 = "\(first + second)"
                        case "-":
                            result.0 = "\(first - second)"
                        case "*":
                            result.0 = "\(first * second)"
                        case "/":
                            result.0 = "\(first / second)"
                        case "^":
                            result.0 = "\(pow(Decimal(first), second))"
                        default:
                            break
                        }

                        stack.append(result)
                    } else {
                        switch lexem.0 {
                        case "=":
                            let firstOperand = stack.removeLast() as! LexemDescription
                            let secondOperand = stack.removeLast() as! LexemDescription
                            if secondOperand.2 == .identifier(-1) {
                                if let first = Int(firstOperand.0) {
                                    identifiersMap[secondOperand.0] = first
                                }
                            }
                        case "write":
                            if let l = stack.removeLast() as? LexemDescription {
                                if let value = identifiersMap[l.0] {
                                    out += "\(value)\n"
                                }
                            }
                        case "read":
                            if !input.isEmpty {
                                if let l = stack.removeLast() as? LexemDescription {
                                    let value = input.removeFirst()
                                    identifiersMap[l.0] = value
                                }
                            }
                        case "less", "equals", "more":
                            stack.append(lexem)
                        case "goto":

                            if let l = stack.removeLast() as? LexemDescription {
                                if let mark = marks.filter({ $0.name == l.0 }).first {
                                    i = mark.index

                                    continue
                                }
                            }
                        default:
                            break
                        }
                    }
                }
            } else if let uph = lexem as? UPH {
                let operation = stack.removeLast() as! LexemDescription
                if operation.2 == .op {
                    let firstOperand = stack.removeLast() as! LexemDescription
                    let secondOperand = stack.removeLast() as! LexemDescription
                    var first: Int = Int.min
                    var second: Int = Int.min

                    if firstOperand.2 == .constant(-1) {
                        first = Int(firstOperand.0)!
                    } else if firstOperand.2 == .identifier(-1) {
                        if let value = identifiersMap[firstOperand.0] {
                            first = Int(value)
                        }
                    }
                    if secondOperand.2 == .constant(-1) {
                        //print(secondOperand)
                        second = Int(secondOperand.0)!
                    } else if secondOperand.2 == .identifier(-1) {
                        if let value = identifiersMap[secondOperand.0] {
                            second = Int(value)
                        }
                    }

                    switch operation.0 {
                    case "less":
                        if second > first {
                            let mark = uph.mark
                            i = mark.index
                            print(lexems[i])
                            continue
                        }
                    case "equals":
                        if second != first {
                            let mark = uph.mark
                            i = mark.index
                            continue
                        }
                    case "more":
                        if second < first {
                            let mark = uph.mark
                            i = mark.index
                            continue
                        }
                    default:
                        break
                    }
                }
            } else if let mark = lexem as? InternalMark {
                //stack.append(mark)
            }
            i += 1
        }
    }
}

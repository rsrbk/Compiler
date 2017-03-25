//
//  ViewController.swift
//  Translators
//
//  Created by Ruslan Serebryakov on 12/15/16.
//  Copyright © 2016 Ruslan Serebryakov. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet var codeView: NSTextView!

    @IBOutlet weak var lexemsTableView: NSTableView!
    @IBOutlet weak var constantsTableView: NSTableView!
    @IBOutlet weak var identifiersTableView: NSTableView!
    @IBOutlet weak var polizStepsTableView: NSTableView!
    @IBOutlet weak var outTextField: NSTextField!

    @IBOutlet weak var marksLabel: NSTextField!
    @IBOutlet weak var polizLabel: NSTextField!

    private let analyzer = Analyzer()
    private let polizGenerator = PolizGenerator()
    private let interpritator = Interpritator()

    private let lexemsTableViewExtension = LexemsTableViewExtension()
    private let constantsTableViewExtension = ConstantsTableViewExtension()
    private let identifiersTableViewExtension = IdentifiersTableViewExtension()
    private let polizStepsTableViewExtension = PolizStepsTableViewExtension()

    override func viewDidLoad() {
        super.viewDidLoad()

        lexemsTableView.delegate = lexemsTableViewExtension
        lexemsTableView.dataSource = lexemsTableViewExtension

        constantsTableView.delegate = constantsTableViewExtension
        constantsTableView.dataSource = constantsTableViewExtension

        identifiersTableView.delegate = identifiersTableViewExtension
        identifiersTableView.dataSource = identifiersTableViewExtension

        polizStepsTableView.delegate = polizStepsTableViewExtension
        polizStepsTableView.dataSource = polizStepsTableViewExtension
    }

    @IBAction func compileAction(_ sender: NSButton) {
        if let code = codeView.textStorage?.string {
            analyzer.lexicalAnalyzer(code: code)
            analyzer.syntaxAnalyzer()

            if !analyzer.errors.isEmpty {
                let alert = NSAlert()
                alert.messageText = "Lexical error"
                alert.informativeText = analyzer.errors[0].description
                alert.addButton(withTitle: "OK")
                alert.runModal()
                analyzer.errors = []
            } else {
                lexemsTableViewExtension.rows = analyzer.lexems
                constantsTableViewExtension.rows = Array(analyzer.constants)
                identifiersTableViewExtension.rows = Array(analyzer.identifiers)

                constantsTableView.reloadData()
                lexemsTableView.reloadData()
                identifiersTableView.reloadData()
            }

            // MARK: Poliz Generator
            polizGenerator.lexems = analyzer.lexems
            polizGenerator.generatePoliz()

            polizStepsTableViewExtension.rows = polizGenerator.steps
            polizStepsTableView.reloadData()

            let polizString = polizGenerator.out.reduce("", { $0 + $1 + " " })
            polizLabel.stringValue = polizString

            let marksString = polizGenerator.polizLexems.flatMap({ lexem -> String? in
                if let mark = lexem as? InternalMark {
                    return "Mark: \(mark.name), index: \(mark.index)"
                }
                return nil
            }).reduce("", { $0 + $1 + " | " })
            marksLabel.stringValue = marksString

            // MARK: Interpritator
            interpritator.lexems = polizGenerator.polizLexems.flatMap({ lexem in
                if let lexem = lexem as? (LexemDescription, [Any]) {
                    return lexem.0
                } else if let lexem = lexem as? LexemDescription {
                    return lexem
                } else if let uph = lexem as? UPH {
                    return uph
                } else if let mark = lexem as? InternalMark {
                    return mark
                }
                return nil
            })
            interpritator.marks = polizGenerator.polizLexems.flatMap({ lexem -> InternalMark? in
                if let mark = lexem as? InternalMark {
                    return mark
                }
                return nil
            })
            //print(polizGenerator.polizLexems)
            //print(interpritator.lexems)
            interpritator.interpritate()
            outTextField.stringValue = interpritator.out
        }
    }
}

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

    @IBOutlet weak var errorsLabel: NSTextField!

    private let analyzer = Analyzer()

    private let lexemsTableViewExtension = LexemsTableViewExtension()
    private let constantsTableViewExtension = ConstantsTableViewExtension()
    private let identifiersTableViewExtension = IdentifiersTableViewExtension()

    override func viewDidLoad() {
        super.viewDidLoad()

        lexemsTableView.delegate = lexemsTableViewExtension
        lexemsTableView.dataSource = lexemsTableViewExtension

        constantsTableView.delegate = constantsTableViewExtension
        constantsTableView.dataSource = constantsTableViewExtension

        identifiersTableView.delegate = identifiersTableViewExtension
        identifiersTableView.dataSource = identifiersTableViewExtension
    }

    @IBAction func compileAction(_ sender: NSButton) {
        if let code = codeView.textStorage?.string {
            analyzer.lexicalAnalyzer(code: code)
            analyzer.syntaxAnalyzer()
            print(analyzer.errors.map({ $0.description }))
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
        }
    }
}

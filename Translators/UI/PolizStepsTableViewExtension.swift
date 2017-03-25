//
//  PolizStepsTableViewExtension.swift
//  Translators
//
//  Created by Ruslan Serebryakov on 3/22/17.
//  Copyright © 2017 Ruslan Serebryakov. All rights reserved.
//

import Cocoa

typealias PolizStep = (out: [String], stack: [String], input: String)

class PolizStepsTableViewExtension: NSObject {
    var rows: [PolizStep] = []
}

extension PolizStepsTableViewExtension: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 3
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // Determining the text for the cell
        guard let tableColumn = tableColumn else { return nil }
        guard let index = tableView.tableColumns.index(of: tableColumn) else { return nil }
        guard rows.count > index else { return nil }

        var text = ""
        let cellID = "\(index)"

        switch row {
        case 0:
            text = rows[index].out.reduce("", { $0 + $1 + " " })
        case 1:
            text = rows[index].stack.reduce("", { $0 + $1 + " " })
        case 2:
            text = rows[index].input
        default:
            break
        }

        if index == 20 {
            print("")
        }

        if let cell = tableView.make(withIdentifier: cellID, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}

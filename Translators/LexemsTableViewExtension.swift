//
//  LexemsTableViewExtension.swift
//  Translators
//
//  Created by Ruslan Serebryakov on 12/19/16.
//  Copyright © 2016 Ruslan Serebryakov. All rights reserved.
//

import Cocoa

class LexemsTableViewExtension: NSObject {
    var rows: [LexemDescription] = []

    fileprivate enum CellIdentifiers {
        static let TitleCell = "TitleCellID"
        static let IDCell = "IDCellID"
        static let ConstantIDCell = "ConstantCellID"
        static let IdentifierIDCell = "IdentifierCellID"
    }
}

extension LexemsTableViewExtension: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return rows.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // Determining the text for the cell
        var text = ""
        var cellID = ""

        if tableColumn == tableView.tableColumns[0] {
            text = rows[row].0
            cellID = CellIdentifiers.TitleCell
        } else if tableColumn == tableView.tableColumns[1] {
            text = "\(rows[row].ID)"
            cellID = CellIdentifiers.IDCell
        } else if tableColumn == tableView.tableColumns[2] {
            if case .constant(let id) = rows[row].2 {
                text = "\(id)"
            } else {
                text = "N/A"
            }
            cellID = CellIdentifiers.ConstantIDCell
        } else if tableColumn == tableView.tableColumns[3] {
            if case .identifier(let id) = rows[row].2 {
                text = "\(id)"
            } else {
                text = "N/A"
            }
            cellID = CellIdentifiers.IdentifierIDCell
        }

        if let cell = tableView.make(withIdentifier: cellID, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}

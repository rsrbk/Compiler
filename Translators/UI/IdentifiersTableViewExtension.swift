//
//  IdentifiersTableViewExtension.swift
//  Translators
//
//  Created by Ruslan Serebryakov on 12/19/16.
//  Copyright © 2016 Ruslan Serebryakov. All rights reserved.
//

import Cocoa

class IdentifiersTableViewExtension: NSObject {
    var rows: [String] = []

    fileprivate enum CellIdentifiers {
        static let IDCell = "IDCell"
        static let ValueCell = "ValueCell"
    }
}

extension IdentifiersTableViewExtension: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return rows.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // Determining the text for the cell
        var text = ""
        var cellID = ""

        if tableColumn == tableView.tableColumns[0] {
            text = "\(row)"
            cellID = CellIdentifiers.IDCell
        } else if tableColumn == tableView.tableColumns[1] {
            text = rows[row]
            cellID = CellIdentifiers.ValueCell
        }

        if let cell = tableView.make(withIdentifier: cellID, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}

//
//  MenuTableViewController.swift
//  EdgyCollectionView
//
//  Created by Alex Du Bois on 3/27/17.
//  Copyright © 2017 yfujiki. All rights reserved.
//

import UIKit

typealias Visibility = Bool

class MenuTableViewController: UITableViewController {

    fileprivate var sectionTitles: [String] = [
        "Visible",
        "Not Visible"
    ]

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return DataSource.shared.visibleCells.count
        } else {
            return DataSource.shared.invisibleCells.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        switch indexPath.section {
        case 0: cell.textLabel?.text = DataSource.shared.visibleCells[indexPath.row].0
        case 1: cell.textLabel?.text = DataSource.shared.invisibleCells[indexPath.row].0
        default: break
        }

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        guard let key = cell?.textLabel?.text,
            let index = DataSource.shared.baseData.index(where: { $0.0 == key }) else {
            return tableView.deselectRow(at: indexPath, animated: false)
        }

        DataSource.shared.baseData[index].2 = !DataSource.shared.baseData[index].2

        var newPath = indexPath
        newPath.section = DataSource.shared.baseData[index].2 ? 0 : 1
        newPath.row = 0

        tableView.moveRow(at: indexPath, to: newPath)
    }
}

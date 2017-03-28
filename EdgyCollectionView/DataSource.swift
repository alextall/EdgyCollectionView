//
//  DataSource.swift
//  EdgyCollectionView
//
//  Created by Alex Du Bois on 3/28/17.
//  Copyright © 2017 yfujiki. All rights reserved.
//

import Foundation

protocol DataSourceDelegate {
    func didUpdateBaseData()
}

class DataSource {

    public static var shared = DataSource()

    public var delegate: DataSourceDelegate?

    public var baseData: [(String, CellMode, Visibility)] = [
        ("NewYork", .photo, true),
        ("Texas", .photo, true),
        ("Illinois", .photo, true),
        ("Montana", .photo, true),
        ("California", .photo, true),
        ("Oregon", .photo, true),
        ("Florida", .photo, true)
        ] {
        didSet {
            delegate?.didUpdateBaseData()
        }
    }

    public var virtualBaseData: [(String, CellMode, Visibility)]!

    public var visibleCells: [(String, CellMode, Visibility)] {
        get {
            return baseData.filter { $0.2 == true }
        }

        set {
            for cell in visibleCells {
                guard let index = baseData.index(where: { $0.0 == cell.0 }) else { continue }
                baseData[index] = cell
            }
        }
    }

    public var invisibleCells: [(String, CellMode, Visibility)] {
        return baseData.filter { $0.2 == false }
    }

    private init() { }
}

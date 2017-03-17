//
//  ViewController.swift
//  EdgyCollectionView
//
//  Created by Yuichi Fujiki on 3/16/17.
//  Copyright © 2017 yfujiki. All rights reserved.
//

import UIKit

enum CellMode {
    case logo
    case photo
}

class ViewController: UIViewController {

    fileprivate var baseData: [(String, CellMode)] = [
        ("NewYork", .logo),
        ("Texas", .logo),
        ("Illinois", .photo),
        ("Montana", .photo),
        ("California", .photo),
        ("Oregon", .photo),
        ("Florida", .photo)
    ]

    fileprivate var virtualBaseData: [(String, CellMode)]!

    fileprivate var currentTargetIndexPath: IndexPath?

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        virtualBaseData = baseData

        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var baseName = baseData[indexPath.item].0
        var cellMode = baseData[indexPath.item].1

        if currentTargetIndexPath != nil {
            baseName = virtualBaseData[indexPath.item].0
            cellMode = virtualBaseData[indexPath.item].1
        }

        switch  cellMode {
        case .logo:
            let width = collectionView.bounds.width / 2 - collectionView.layoutMargins.left - collectionView.layoutMargins.right
            let height = width * 3 / 8
            return CGSize(width: width, height: height)
        default: // photo
            let photo = UIImage(named: "\(baseName)_Photo")!
            let width = collectionView.bounds.width
            let height = photo.size.height / photo.size.width * width // keep proportion
            return CGSize(width: width, height: height)
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return baseData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var baseName = baseData[indexPath.item].0
        var cellMode = baseData[indexPath.item].1

        if currentTargetIndexPath != nil {
            baseName = virtualBaseData[indexPath.item].0
            cellMode = virtualBaseData[indexPath.item].1
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCell
        cell.setCellMode(cellMode)
        cell.setBaseName(baseName)
        cell.delegate = self

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let data = baseData[sourceIndexPath.item]
        baseData.remove(at: sourceIndexPath.item)
        baseData.insert(data, at: destinationIndexPath.item)

        virtualBaseData = baseData

        collectionView.reloadItems(at: [sourceIndexPath, destinationIndexPath])
    }
}

extension ViewController: PhotoCellDelegate {
    func cell(_ cell: UICollectionViewCell, modeChangedTo cellMode: CellMode) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }

        baseData[indexPath.item].1 = cellMode
    }

    func cell(_ cell: UICollectionViewCell, didStartLongPressAt position: CGPoint) {
        let convertedPosition = cell.convert(position, to: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: convertedPosition) {
            let success = collectionView.beginInteractiveMovementForItem(at: indexPath)
            print("Begin interactive movement for \(indexPath.item) is \(success) ")
            currentTargetIndexPath = indexPath
        }
    }

    func cell(_ cell: UICollectionViewCell, didUpdateLongPressAt position: CGPoint) {
        let convertedPosition = cell.convert(position, to: collectionView)
        collectionView.updateInteractiveMovementTargetPosition(convertedPosition)

        if let indexPath = collectionView.indexPathForItem(at: convertedPosition) {
            if let currentTargetIndexPath = currentTargetIndexPath {
                if indexPath != currentTargetIndexPath {
                    let from = currentTargetIndexPath.item
                    let to = indexPath.item

                    if from > to {
                        let data = virtualBaseData.remove(at: from)
                        virtualBaseData.insert(data, at: to)
                    } else if from < to {
                        let data = virtualBaseData.remove(at: from)
                        virtualBaseData.insert(data, at: to)
                    }

                    self.currentTargetIndexPath = indexPath
                }
            }
        }
    }

    func cell(_ cell: UICollectionViewCell, didEndLongPressAt position: CGPoint) {
        collectionView.endInteractiveMovement()
        currentTargetIndexPath = nil
    }

    func cell(_ cell: UICollectionViewCell, didCancelLongPressAt position: CGPoint) {
        collectionView.cancelInteractiveMovement()
        currentTargetIndexPath = nil
    }
}

//
//  ViewController.swift
//  EdgyCollectionView
//
//  Created by Yuichi Fujiki on 3/16/17.
//  Copyright © 2017 yfujiki. All rights reserved.
//

import UIKit
import UICollectionViewLeftAlignedLayout

class ViewController: UIViewController {

    fileprivate var baseData: [(String, CellMode, Visibility)] = DataSource.shared.baseData

    fileprivate var virtualBaseData: [(String, CellMode, Visibility)]! = DataSource.shared.virtualBaseData

    fileprivate var currentTargetIndexPath: IndexPath?

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var menuButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        virtualBaseData = baseData

        collectionView.collectionViewLayout = UICollectionViewLeftAlignedLayout()
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "Cell")

        if let revealViewController = revealViewController() {
            menuButton.target = revealViewController
            menuButton.action = #selector(revealViewController.revealToggle(_:))
            view.addGestureRecognizer(revealViewController.panGestureRecognizer())
        }

        DataSource.shared.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var baseName = baseData[indexPath.item].0
        var cellMode = baseData[indexPath.item].1

        if currentTargetIndexPath != nil {
            baseName = virtualBaseData[indexPath.item].0
            cellMode = virtualBaseData[indexPath.item].1
        }

        switch  cellMode {
        case .logo:
            let width = collectionView.bounds.width / 2 - 2
            let height = width * 3 / 4
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
        return DataSource.shared.visibleCells.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var baseName = DataSource.shared.visibleCells[indexPath.item].0
        var cellMode = DataSource.shared.visibleCells[indexPath.item].1

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
        let data = DataSource.shared.visibleCells[sourceIndexPath.item]
        DataSource.shared.visibleCells.remove(at: sourceIndexPath.item)
        DataSource.shared.visibleCells.insert(data, at: destinationIndexPath.item)

        virtualBaseData = DataSource.shared.visibleCells

        collectionView.reloadItems(at: [sourceIndexPath, destinationIndexPath])
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") else { return }
        present(viewController, animated: true, completion: nil)
    }
}

extension ViewController: PhotoCellDelegate {

    func didStartZoomInForCell(_ cell: UICollectionViewCell) {
        collectionView.bringSubview(toFront: cell)
    }

    func didStartZoomOutForCell(_ cell: UICollectionViewCell) {
        collectionView.bringSubview(toFront: cell)
    }

    func cell(_ cell: UICollectionViewCell, modeChangedTo cellMode: CellMode) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }

        baseData[indexPath.item].1 = cellMode
        virtualBaseData = baseData

        collectionView.reloadItems(at: [indexPath])
    }

    func cell(_ cell: UICollectionViewCell, didStartLongPressAt position: CGPoint) {
        let convertedPosition = cell.convert(position, to: collectionView)

        if let indexPath = collectionView.indexPathForItem(at: convertedPosition) {
            let success = collectionView.beginInteractiveMovementForItem(at: indexPath)
            print("Begin interactive movement for \(indexPath.item) is \(success) ")
            currentTargetIndexPath = indexPath
        }
        setAlpha(0.7, toCellAt: convertedPosition)
    }

    func cell(_ cell: UICollectionViewCell, didUpdateLongPressAt position: CGPoint) {
        let convertedPosition = cell.convert(position, to: collectionView)

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

        collectionView.updateInteractiveMovementTargetPosition(convertedPosition)

        if let indexPath = currentTargetIndexPath,
            let cell = collectionView.cellForItem(at: indexPath) {
            cell.alpha = 0.7
        }
    }

    func cell(_ cell: UICollectionViewCell, didEndLongPressAt position: CGPoint) {
        let convertedPosition = cell.convert(position, to: collectionView)
        setAlpha(1.0, toCellAt: convertedPosition)

        collectionView.endInteractiveMovement()
        currentTargetIndexPath = nil
    }

    func cell(_ cell: UICollectionViewCell, didCancelLongPressAt position: CGPoint) {
        let convertedPosition = cell.convert(position, to: collectionView)
        setAlpha(1.0, toCellAt: convertedPosition)

        collectionView.cancelInteractiveMovement()
        currentTargetIndexPath = nil
    }

    func setAlpha(_ alpha: CGFloat, toCellAt position: CGPoint) {
        if let indexPath = collectionView.indexPathForItem(at: position),
            let cell = collectionView.cellForItem(at: indexPath) {
            cell.alpha = alpha
        }
    }
}

extension ViewController: DataSourceDelegate {
    func didUpdateBaseData() {
        collectionView.reloadData()
    }
}

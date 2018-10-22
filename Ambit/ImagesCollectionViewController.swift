//
//  ImagesCollectionViewController.swift
//  Ambit
//
//  Created by Ryan Thomas on 10/21/18.
//  Copyright © 2018 ryanphillipthomas. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MediaCollectionViewCell"

class ImagesCollectionViewController: UICollectionViewController {
    weak var settingsPageViewController: SettingsPageViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        self.collectionView.allowsMultipleSelection = true
        
        if (!UIAccessibility.isReduceTransparencyEnabled) {
            collectionView.backgroundColor = UIColor.clear
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            collectionView.backgroundView = blurEffectView

            //if inside a popover
            if let popover = navigationController?.popoverPresentationController {
                popover.backgroundColor = UIColor.clear
            }
        }
        self.collectionView.allowsSelection = true;
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 36
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MediaCollectionViewCell
        let imageTitle = UserDefaults.standard.string(forKey: AmbitConstants.BackroundImageTitle)

        let imageName = "\(indexPath.row + 1)"
        let image = UIImage(named: imageName)
        if let image = image {
            cell.configure(with: image)
        }
        
        cell.imageView.alpha = 0.60
        if imageTitle == imageName {
            cell.imageView.alpha = 1
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //
        let imageName = "\(indexPath.row + 1)"
        UserDefaults.standard.set(imageName, forKey: AmbitConstants.BackroundImageTitle) //setObject
        self.collectionView.reloadData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:AmbitConstants.UpdateBackround), object: nil)
    }
}



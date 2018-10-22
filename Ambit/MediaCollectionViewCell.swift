//
//  MediaCollectionViewCell.swift
//  Ambit
//
//  Created by Ryan Thomas on 10/21/18.
//  Copyright © 2018 ryanphillipthomas. All rights reserved.
//

import UIKit

class MediaCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public func configure(with image: UIImage) {
        imageView.image = image
    }
}

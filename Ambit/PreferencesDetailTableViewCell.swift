//
//  PreferencesDetailTableViewCell.swift
//  Ambit
//
//  Created by Ryan Thomas on 1/7/18.
//  Copyright © 2018 ryanphillipthomas. All rights reserved.
//

import Foundation

class PreferencesDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureWith(titleString : String, detailString : String) {
        title.text = titleString
        detail.text = detailString
    }
}

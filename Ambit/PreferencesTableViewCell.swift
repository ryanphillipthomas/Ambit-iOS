//
//  PreferencesTableViewCell.swift
//  Ambit
//
//  Created by Ryan Thomas on 1/6/18.
//  Copyright © 2018 ryanphillipthomas. All rights reserved.
//

import Foundation

class PreferencesTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureWith(titleString : String) {
        title.text = titleString
    }
}

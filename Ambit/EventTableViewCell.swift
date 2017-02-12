//
//  EventTableViewCell.swift
//  Ambit
//
//  Created by Ryan Phillip Thomas on 2/11/17.
//  Copyright © 2017 ryanphillipthomas. All rights reserved.
//

import UIKit
import GLTimeline

class EventTableViewCell: UITableViewCell {
    @IBOutlet weak var timeLineView: GLTimelineView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWith(eventIndex:Int, numberOfItems:Int, event : Event) {
        title.text = event.title
        startTime.text = StringHelper.hourMinuteStringFor(date: event.startTime)
        endTime.text = StringHelper.hourMinuteStringFor(date: event.endTime)

        timeLineView.lineType = GLTimelineView.getTimeLineType(eventIndex, items: numberOfItems)
        timeLineView.lineColor  = UIColor.white
        timeLineView.pointRadius = 5.0
        timeLineView.lineWidth = 1.0
    }
}

//
//  DimView.swift
//  Ambit
//
//  Created by Ryan Phillip Thomas on 2/9/17.
//  Copyright © 2017 ryanphillipthomas. All rights reserved.
//

import UIKit

class DimView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if !subview.isHidden && subview.alpha > 0 && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                print("true")
                return true
            }
        }
        print("false")
        return true
    }
}

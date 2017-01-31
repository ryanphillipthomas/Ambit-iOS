//
//  CALayer+Extension.swift
//  GradientAnimate
//
//  Created by Sujan Vaidya on 8/9/16.
//  Copyright © 2016 Sujan Vaidya. All rights reserved.
//

import UIKit

public extension CALayer {
    public class func animateWithDuration(_ duration: TimeInterval, animation: () -> Void, completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setCompletionBlock(completion)
        animation()
        CATransaction.commit()
    }
}


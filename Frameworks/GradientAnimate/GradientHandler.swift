//
//  GradientHandler.swift
//  GradientAnimate
//
//  Created by Sujan Vaidya on 8/9/16.
//  Copyright © 2016 Sujan Vaidya. All rights reserved.
//

import UIKit

struct GradientHandler {
    
    // MARK: - Properties for gradient layer
    
    static var gradientLayer = CAGradientLayer()
    static var bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
    static var location = [0.5, 1]
    static var startPosition = CGPoint(x: 0, y: 0)
    static var endPosition = CGPoint(x: 1, y: 1)
    static var colors = [CGColor]()
    
    static var animation = CABasicAnimation()
    static var fromColors: [AnyObject]!
    static var toColors: [AnyObject]!
    static var duration: Double = 1.5
    static var tempColors: [CGColor] = Colors.Gradient.blueGradient
    static var indexToRemove = 0
    static var indexToAdd = 5
    
    static func addGradientLayer() -> CAGradientLayer {
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        gradientLayer.locations = location as [NSNumber]?
        gradientLayer.startPoint = startPosition
        gradientLayer.endPoint = endPosition
        return gradientLayer
    }
    
    static func animateLayerWithColor() {
        
        fromColors = self.gradientLayer.colors as [AnyObject]!
        gradientLayer.colors = toColors
        
        CALayer.animateWithDuration(duration,
                                    animation: {
                                        animation = CABasicAnimation(keyPath: "colors")
                                        animation.fromValue = fromColors
                                        animation.toValue = toColors
                                        animation.duration = duration
                                        animation.fillMode = kCAFillModeForwards
                                        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                                        gradientLayer.add(animation, forKey:"animateGradientColor")
            },
                                    completion: { isCompleted in
                                        if indexToAdd == Colors.Gradient.animationColors.count - 1 {
                                            indexToAdd = 0
                                        } else {
                                            indexToAdd += 1
                                        }
                                        tempColors.remove(at: indexToRemove)
                                        tempColors.append(Colors.Gradient.animationColors[indexToAdd])
                                        toColors = tempColors
                                        
                                        animateLayerWithColor()
            }
        )
    }
    
}


//
//  SupportCode.h
//  SupportCode
//
//  Created by Ryan Thomas on 11/20/17.
//  Copyright © 2017 Wheels Up. All rights reserved.
//

import UIKit

@IBDesignable class UILabelWithMargins: UILabel {
     var topInset: CGFloat = 0.0
     var leftInset: CGFloat = 0.0
     var bottomInset: CGFloat = 0.0
     var rightInset: CGFloat = 0.0
    
    var insets: UIEdgeInsets {
        get {
            return UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        }
        set {
            topInset = newValue.top
            leftInset = newValue.left
            bottomInset = newValue.bottom
            rightInset = newValue.right
        }
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var adjSize = super.sizeThatFits(size)
        adjSize.width += leftInset + rightInset
        adjSize.height += topInset + bottomInset
        
        return adjSize
    }
    
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.width += leftInset + rightInset
        contentSize.height += topInset + bottomInset
        
        return contentSize
    }
}

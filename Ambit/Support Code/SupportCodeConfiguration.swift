//
//  SupportCode.h
//  SupportCode
//
//  Created by Ryan Thomas on 11/20/17.
//  Copyright © 2017 Wheels Up. All rights reserved.
//

import Foundation
import UIKit

public class SupportCodeConfiguration: NSObject {
    
    public static let sharedConfiguration = SupportCodeConfiguration()
    
    public var currentCodes = [String]()
    public var defaultCode = String()

    @objc public final class func setup(codes : [String]) {
        sharedConfiguration.currentCodes = [""] + codes
    }
    
    @objc public final class func setup(defaultCode : String) {
        sharedConfiguration.defaultCode = defaultCode
    }
    
    @objc public final class func supportCodeConfigurationDefaults(defaults : NSMutableDictionary) -> NSMutableDictionary  {
        if sharedConfiguration.defaultCode.count > 0 {
            defaults.setValue(sharedConfiguration.defaultCode, forKey: "SupportCode")
        }
        
        return defaults;
    }
}

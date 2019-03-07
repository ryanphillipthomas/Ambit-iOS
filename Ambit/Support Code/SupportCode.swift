//
//  SupportCode.h
//  SupportCode
//
//  Created by Ryan Thomas on 11/20/17.
//  Copyright © 2017 Wheels Up. All rights reserved.
//

import Foundation
import UIKit

public protocol SupportCodeDelegate: class {
    func supportCodeEnteredSuccessfully()
}

import Foundation

public class SupportCode: NSObject {
    
    weak public static var delegate:SupportCodeDelegate?
    
    private class func savedCode() -> String {
        
        let prefs = UserDefaults.standard
        guard let savedCode = prefs.string(forKey:"SupportCode")
            else {
                return ""
        }
        
        return savedCode
    }
    
    @objc public final class func process(url:URL) {
        if url.host?.caseInsensitiveCompare("SupportCode") == .orderedSame {
            displaySupportCodeAlertView(url: url)
        }
    }
    
    @objc public final class func matches(code:String) -> Bool {
        let savedCode = self.savedCode()
        return code.caseInsensitiveCompare(savedCode) == .orderedSame
    }
    
    @objc public final class func hasSavedCode() -> Bool {
        let savedCode = self.savedCode()
        return savedCode.count > 0
    }
    
    
   @objc public final class func displaySupportCodeAlertView(url:URL? = nil) {

    let alertController = UIAlertController(title: "Support Code", message: "", preferredStyle: .alert)
    
    alertController.addAction(UIAlertAction(title: "Apply", style: .default, handler: {
        alert -> Void in
        for code in SupportCodeConfiguration.sharedConfiguration.currentCodes
            {
                if let textField = alertController.textFields![0] as UITextField?
                {
                    if textField.text == code {
                        setCode(enteredCode: code)
                        self.delegate?.supportCodeEnteredSuccessfully()
                        displayRestartView()
                    }
                }
            }
    }))
    
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
        let textField = alertController.textFields![0] as UITextField
        
        
        var preEnteredCode = ""
        
        if let url = url {
            preEnteredCode = url.lastPathComponent
        }
        
        preEnteredCode = stripSingleTrailingSlash(code: preEnteredCode)
        
        if preEnteredCode.count > 0 {
            textField.text = preEnteredCode
        } else {
            let savedCode = self.savedCode()
            if savedCode.count > 0 {
                textField.text = savedCode
            } else {
                textField.placeholder = "Enter your support code"
            }
        }
        
    })
    let rootViewController = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController
    rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    private class func stripSingleTrailingSlash(code:String!) -> String {
        if let code = code {
            if code == "/" {
                return ""
            }
        }
        
        return code
    }
    
    private class func setCode(enteredCode:String) {
        let prefs = UserDefaults.standard
        prefs.setValue(enteredCode, forKey: "SupportCode")
    }
    
    private class func displayRestartView() {
        let vc = SupportCodeRestartViewController()
        vc.enteredCode = savedCode()
        
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController
        rootViewController?.present(vc, animated: true, completion: nil)
    }
}

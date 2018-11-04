//
//  Helpers.swift
//  Ambit
//
//  Created by Ryan Phillip Thomas on 10/7/16.
//  Copyright © 2016 ryanphillipthomas. All rights reserved.
//

import UIKit
import CoreData

class AppearanceHelper {
    
    class func addTransparentNavigationBar () {
        //setups a clear / invisible navigation bar
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    }
    
    class func removeTransparentNavigationBar () {
        //resets the navigation bar to defaults
        UINavigationBar.appearance().setBackgroundImage(nil, for: .default)
    }
    
    class func enableDarkKeyboard() {
        UITextField.appearance().keyboardAppearance = .dark
    }
    
    class func enableLightKeyboard() {
        UITextField.appearance().keyboardAppearance = .light
    }
}

class RoundingHelper {
    class func roundAndBorderImageView(imageView : UIImageView?){
        if let imageView = imageView {
            imageView.layer.cornerRadius = imageView.frame.size.width / 2;
            imageView.clipsToBounds = true;
            imageView.layer.borderWidth = 2.0;
            imageView.layer.borderColor = UIColor.white.cgColor;
        }
    }
    
    class func roundAndBorderButton(button : UIButton?){
        if let button = button {
            button.layer.cornerRadius = button.frame.size.width / 2
            button.clipsToBounds = true
            button.layer.borderWidth = 2.0
            button.layer.borderColor = UIColor.white.cgColor
        }
    }
}

// MARK: - Alert helper
class AlertHelper{
    // Show native ios alert
    class func showAlert(title: String, msg: String? = nil, controller: UIViewController) {
        DispatchQueue.main.async(execute: {
            let alertController = UIAlertController(title: title, message:
                msg, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            controller.present(alertController, animated: true, completion: nil)
        })
    }
    
    // Format error msgs
    class func formatErrorMsg(_ error: String) -> String{
        return StringHelper.capitalizedSentence(error) + "."
    }
    
    // alert with handler
    class func showAlertWithHandler(title: String, msg: String? = nil, controller: UIViewController, handler: @escaping (UIAlertAction) -> Void) {
        let alertController = UIAlertController(title: title, message:
            msg, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: handler))
        controller.present(alertController, animated: true, completion: nil)
    }
    
    // alert with custom handler
    class func showAlertWithCustomButtonHandler(title: String, msg: String? = nil, buttonTitle : String, controller: UIViewController, handler: @escaping (UIAlertAction) -> Void) {
        let alertController = UIAlertController(title: title, message:
            msg, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: buttonTitle, style: UIAlertAction.Style.default, handler: handler))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        controller.present(alertController, animated: true, completion: nil)
    }
}


// MARK: - String helper
class StringHelper{
    class func capitalizedSentence(_ string: String) -> String{
        var formatted = string
        formatted.replaceSubrange(formatted.startIndex...formatted.startIndex, with: String(formatted[formatted.startIndex]).capitalized)
        return formatted
    }
    
    // Returns a valid string to represent the time interval since the post was modified. i.e "10 days ago"
    class func pastTimeString(for date:Date) -> String {
        let diff = date.timeIntervalSinceNow
        let dateDifference = abs(diff / 60.0) // minutes
        var timeString = ""
        if Int(dateDifference) >= (60 * 24 * 2) {
            timeString = String(format:"%i", Int(dateDifference / (60 * 24))) + " days ago"
        } else if Int(dateDifference) >= (60 * 24) {
            timeString = String(format:"%i", Int(dateDifference / (60 * 24))) + " day ago"
        } else if Int(dateDifference) >= 120 {
            timeString = String(format:"%i", Int(dateDifference / 60.0)) + " hrs ago"
        } else if Int(dateDifference) >= 60 {
            timeString = String(format:"%i", Int(dateDifference / 60.0)) + " hr ago"
        } else if Int(dateDifference) >= 1 {
            timeString = String(format:"%i", Int(dateDifference)) + " min ago"
        } else {
            timeString = String(format:"%i", Int(dateDifference * 60.0)) + " sec ago"
        }
        return timeString
    }
    
    // Returns a valid string to represent the time interval since the post was modified. i.e "10 days left"
    class func futureTimeString(for date:Date) -> String {
        let diff = date.timeIntervalSinceNow
        let dateDifference = abs(diff / 60.0) // minutes
        var timeString = ""
        if Int(dateDifference) >= (60 * 24 * 2) {
            timeString = String(format:"%i", Int(dateDifference / (60 * 24))) + " days left"
        } else if Int(dateDifference) >= (60 * 24) {
            timeString = String(format:"%i", Int(dateDifference / (60 * 24))) + " day left"
        } else if Int(dateDifference) >= 120 {
            timeString = String(format:"%i", Int(dateDifference / 60.0)) + " hrs left"
        } else if Int(dateDifference) >= 60 {
            timeString = String(format:"%i", Int(dateDifference / 60.0)) + " hr left"
        } else if Int(dateDifference) >= 1 {
            timeString = String(format:"%i", Int(dateDifference)) + " min left"
        } else {
            timeString = String(format:"%i", Int(dateDifference * 60.0)) + " sec left"
        }
        return timeString
    }
    
    // Returns a valid string to represent the distance handed in (distance in is in form of FEET). i.e "25 ft away"
    class func distanceString(for distance:Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        var distString = ""
        if Int(distance) >= (5280 * 2) {
            distString = numberFormatter.string(from: NSNumber(value: Int(distance / 5280)))! + " miles away"
        } else if Int(distance) >= 5280 {
            distString = numberFormatter.string(from: NSNumber(value: Int(distance / 5280)))! + " mile away"
        } else if Int(distance) >= 100 {
            distString = numberFormatter.string(from: NSNumber(value: Int(100.0 * round(distance / 100.0))))! + " ft away"
        } else {
            distString = "<100 ft away"
        }
        return distString
    }
    
    class func secondsToHoursMinutesSecondsString (seconds : Int) -> String {
        var sec = seconds
        if sec <= 0 { sec = 0 }
        
        let hours = sec / 3600
        let minutes = (sec % 3600) / 60
        let seconds = (sec % 3600) % 60
        
        return String(format:"%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    class func hourMinuteStringForNow() -> String {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: date)

        let hour = components.hour
        let minutes = components.minute
        
        return String(format:"%02d:%02d", hour!, minutes!)
    }
    
    class func hourMinuteStringFor(date:Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: date)
        
        let hour = components.hour
        let minutes = components.minute
        
        return String(format:"%02d:%02d", hour!, minutes!)
    }
    
    class func timeLeftUntilAlarm(alarmDate : Date) -> String {
        let currentDate = Date()
        let min = DateHelper.minBetweenDates(startDate: currentDate, endDate: alarmDate)
        let hour = DateHelper.hoursBetweenDates(startDate: currentDate, endDate: alarmDate)
        var ago_left = "left"
        
        if currentDate > alarmDate {
            //flip text if alarm is in the past
            ago_left = "ago"
        }
        
        return String("\(hour) hrs \(min) mins \(ago_left)")
    }
    
    class func soundFileForName(string : String) -> String? {
        if string == "Bell" {
            return "bell.mp3"
        } else if string == "Party" {
            return "party.mp3"
        } else if string == "Tickle" {
            return "tickle.mp3"
        } else if string == "Thunderstorm" {
            return "thunderstorm.mp3"
        } else if string == "Thunderstorm Fireplace" {
            return "thunderstorm_fireplace.mp3"
        }
        return nil
    }
    
    class func nextAlarmString(alarmDate : Date) -> String {
        let alarmHour = StringHelper.hour(date: alarmDate)
        let alarmMinute = StringHelper.minute(date: alarmDate)
        let alarm_am_pm = StringHelper.am_pm(date: alarmDate).uppercased()
        
//      let calendar = Calendar.current
//      let endDate = calendar.date(byAdding: .minute, value: 15, to: alarmDate)
//      let endHour = StringHelper.hour(date: endDate!)
//      let endMinute = StringHelper.minute(date: endDate!)
//      let end_am_pm = StringHelper.am_pm(date: endDate!)
        
//      return "\(alarmHour):\(alarmMinute) \(alarm_am_pm) - \(endHour):\(endMinute) \(end_am_pm)"
        
        return "\(alarmHour):\(alarmMinute) \(alarm_am_pm)"
    }
    
    class func day(date : Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: date)
    }
    
    class func minute(date : Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm"
        return dateFormatter.string(from: date)
    }
    
    class func hour(date : Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h"
        return dateFormatter.string(from: date)
    }
    
    class func am_pm(date : Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        dateFormatter.dateFormat = "a"
        return dateFormatter.string(from: date)
    }
    
    class func randomQuote() -> String {
        let randomIndex = Int(arc4random_uniform(UInt32(AmbitConstants.quotes.quotesArray.count)))
        let quote = AmbitConstants.quotes.quotesArray[randomIndex]
        return quote
    }
}

class DateHelper {
    
    class func daysBetweenDates(startDate: Date, endDate: Date) -> Int {
        var days = 0
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.day], from: startDate, to: endDate)
        
        if (components.day != nil) {
            days = components.day!
        }
        
        return days
    }
    
    class func hoursBetweenDates(startDate: Date, endDate: Date) -> Int {
        var hour = 0
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.hour], from: startDate, to: endDate)
        
        if (components.hour != nil) {
            hour = components.hour!
        }
        return hour
    }
    
    class func minBetweenDates(startDate: Date, endDate: Date) -> Int {
        var min = 0
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.minute], from: startDate, to: endDate)
       
        if (components.minute != nil) {
            min = components.minute!
        }
        
        return min
    }
}

// MARK: - Root helper
class RootHelper{
    // Set root to a navigation controller. Usually use when login in or login out
    class func setRootController(window: UIWindow?, storyboardName: String, viewControllerID: String, moc: NSManagedObjectContext){
        let storyBoard = UIStoryboard(name: storyboardName, bundle: nil)
        window?.rootViewController = storyBoard.instantiateViewController(withIdentifier: viewControllerID)
        setMOCController(window: window, moc: moc)
    }
    
    class func setMOCController(window: UIWindow?, moc: NSManagedObjectContext){
        // Navigations Controller
        if let vc = window?.rootViewController as? ManagedObjectContextSettable { // Controller
            vc.managedObjectContext = moc
        } else if let rootController = window?.rootViewController as? UINavigationController, let vc = rootController.viewControllers.first as? ManagedObjectContextSettable {
            vc.managedObjectContext = moc
        }
    }
}

class GradientViewHelper {
    class func addGradientColorsToView(view : UIView, gradientLayer : CAGradientLayer) {
        GradientHandler.bounds = view.bounds
        GradientHandler.colors = Colors.Gradient.animationColors
        GradientHandler.location = [0.10, 0.30, 0.45, 0.60, 0.75, 0.9]
        GradientHandler.startPosition = CGPoint(x: 0, y: 1)
        GradientHandler.endPosition = CGPoint(x: 1, y: 0)
        
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        GradientHandler.toColors = GradientHandler.colors
        GradientHandler.animateLayerWithColor()
    }
}

// MARK: - UIApplication helper extension
extension UIApplication {
    class func returnToRootViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) {
        
        if let nav = base as? UINavigationController {
            returnToRootViewController(base: nav.visibleViewController)
            nav.popToRootViewController(animated: false)
        }
        
        if let presented = base?.presentedViewController {
            returnToRootViewController(base: presented)
            presented.dismiss(animated: false, completion: nil)
        }
        
    }
}

// MARK: - Color helper extension
extension UIColor {
    //    Swift 3.0
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    var hexString:String {
        let colorRef = self.cgColor.components
        
        var r, b, g: CGFloat
        
        if colorRef?.count == 2 {
            r = colorRef![0]
            g = colorRef![0]
            b = colorRef![0]
        } else {
            r = colorRef![0]
            g = colorRef![1]
            b = colorRef![2]
        }
        return NSString(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255))) as String
    }
}

// MARK: - Loader helper
class LoaderHelper {
    static let activityIndicator = UIActivityIndicatorView(frame: CGRect.zero)
    class func showLoader(inView: UIView, userInteractionEnabled: Bool, style: UIActivityIndicatorView.Style){
        activityIndicator.center = inView.center
        activityIndicator.style = style
        activityIndicator.startAnimating()
        inView.addSubview(activityIndicator)
        inView.isUserInteractionEnabled = userInteractionEnabled
    }
    
    class func hideLoader(inView: UIView){
        DispatchQueue.main.async {
            activityIndicator.removeFromSuperview()
            inView.isUserInteractionEnabled = true
        }
    }
}

// String helper
extension String {
    func toBool() -> Bool? {
        switch self {
        case "TRUE", "True", "true", "YES", "Yes", "yes", "1":
            return true
        case "FALSE", "False", "false", "NO", "No", "no", "0":
            return false
        default:
            return nil
        }
    }
}

class LightsHelper {
    class func saveLightSettings(selections : NSMutableArray, lights : NSArray) {
        var counter = 0
        let uniqueIDs : NSMutableArray = []
        for selection in selections {
            let shouldUse = selection as! Bool
            if shouldUse {
                let light = lights[counter] as! PHLight
                uniqueIDs.add(light.uniqueId)
            }
            counter += 1
        }
        
        UserDefaults.standard.set(uniqueIDs, forKey: AmbitConstants.ActiveLightGroupingSettings) //setObject
    }
    
    class func lightGroupingAllowsLight(string : String) -> Bool {
        let activeLights = UserDefaults.standard.mutableArrayValue(forKey: AmbitConstants.ActiveLightGroupingSettings)
        for idValue in activeLights {
            if let id = idValue as? String {
                if id == string {
                    return true
                }
            }
        }
        
        return false
    }
}

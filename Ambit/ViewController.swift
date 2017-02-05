//
//  ViewController.swift
//  template
//
//  Created by Ryan Phillip Thomas on 12/9/16.
//  Copyright © 2016 ryanphillipthomas. All rights reserved.
//

import UIKit
import Spring
import CoreData
import RTCoreData
import UserNotifications

class ViewController: UIViewController, ManagedObjectContextSettable {
    fileprivate let food = ["🍦", "🍮", "🍤","🍉", "🍨", "🍏", "🍌", "🍰", "🍚", "🍓", "🍪", "🍕"]
    
    @IBOutlet var timeLabel:SBTimeLabel!
    @IBOutlet var timePicker:UIDatePicker!
    @IBOutlet var settingsButton:UIButton!
    
    @IBOutlet weak var fullScreenBlackoutView: SpringView!
    @IBOutlet weak var timeLabelAnimationView: SpringView!
    @IBOutlet weak var settingsButtonAnimationView: SpringView!
    @IBOutlet weak var timePickerAnimationView: SpringView!
    @IBOutlet weak var nextAlarmAnimationView: SpringView!
    @IBOutlet weak var stopAnimationView: SpringView!

    @IBOutlet weak var timeButton: UIButton!
    
    var backroundAnimation = CAGradientLayer()
    var managedObjectContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        timeLabel.updateText()
        timeLabel.start()
        timeLabel.delegate = self
        HueConnectionManager.sharedManager.delegate = self
        
        backroundAnimation = GradientHandler.addGradientLayer()
        GradientViewHelper.addGradientColorsToView(view: self.view, gradientLayer: backroundAnimation)
        
        timeLabelAnimationView.isHidden = true
        nextAlarmAnimationView.isHidden = true
        stopAnimationView.isHidden = true
        
        setNeedsStatusBarAppearanceUpdate()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.toggleStatusBar(notification:)), name: NSNotification.Name(rawValue:"didToggleStatusBar"), object: nil)
        
        timePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //updateRunningAlarmUI()
    }
    
    override func viewDidLayoutSubviews() {
        backroundAnimation.frame = self.view.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateRunningAlarmUI() {
//DEV TODO        Alarm.fetchInContext(context: managedObjectContext)
    }
    
    func animateInTimeDisplayLayers() {
        timeLabelAnimationView.isHidden = false
        nextAlarmAnimationView.isHidden = false
        stopAnimationView.isHidden = false

        nextAlarmAnimationView.animation = "fadeInDown"
        nextAlarmAnimationView.curve = "linear"
        nextAlarmAnimationView.duration = 2.0
        nextAlarmAnimationView.animate()
        
        timeLabelAnimationView.animation = "fadeInDown"
        timeLabelAnimationView.curve = "linear"
        timeLabelAnimationView.duration = 2.0
        timeLabelAnimationView.animate()
        
        stopAnimationView.animation = "fadeInUp"
        stopAnimationView.curve = "linear"
        stopAnimationView.duration = 2.0
        stopAnimationView.animate()
    }
    
    func animateOutTimeDisplayLayers() {
        nextAlarmAnimationView.animation = "fadeOutDown"
        nextAlarmAnimationView.curve = "linear"
        nextAlarmAnimationView.duration = 2.0
        nextAlarmAnimationView.animate()
        
        timeLabelAnimationView.animation = "fadeOutDown"
        timeLabelAnimationView.curve = "linear"
        timeLabelAnimationView.duration = 2.0
        timeLabelAnimationView.animate()
        
        stopAnimationView.animation = "fadeOutUp"
        stopAnimationView.curve = "linear"
        stopAnimationView.duration = 2.0
        stopAnimationView.animate()
        
        timeLabelAnimationView.isHidden = true
        nextAlarmAnimationView.isHidden = true
        stopAnimationView.isHidden = true
        
        animateInTimePickerLayers()
    }
    
    func animateInTimePickerLayers() {
        timePickerAnimationView.isHidden = false
        settingsButtonAnimationView.isHidden = false
        
        timePickerAnimationView.animation = "fadeInDown"
        timePickerAnimationView.curve = "linear"
        timePickerAnimationView.duration = 2.0
        timePickerAnimationView.animate()
        
        settingsButtonAnimationView.animation = "fadeInUp"
        settingsButtonAnimationView.curve = "linear"
        settingsButtonAnimationView.duration = 2.0
        settingsButtonAnimationView.animate()
    }
    
    func animateOutTimePickerLayers() {
        timePickerAnimationView.animation = "fadeOut"
        timePickerAnimationView.curve = "linear"
        timePickerAnimationView.duration = 1.0
        timePickerAnimationView.animate()
        
        settingsButtonAnimationView.animation = "fadeOut"
        settingsButtonAnimationView.curve = "linear"
        settingsButtonAnimationView.duration = 1.0
        settingsButtonAnimationView.animate()
        
        timePickerAnimationView.isHidden = true
        settingsButtonAnimationView.isHidden = true

        
        animateInTimeDisplayLayers()
    }
    
    func configurePickerView() {
//        timePicker.date = UIDatePickerMode.Time // 4- use time only
//        let currentDate = NSDate()  //5 -  get the current date
//        myDatePicker.minimumDate = currentDate  //6- set the current date/time as a minimum
//        myDatePicker.date = currentDate //7 - defa
    }
    
    func vibrateWatch() {
        let randomItem = food[Int(arc4random_uniform(UInt32(food.count)))]
        do {
            try WatchSessionManager.sharedManager.updateApplicationContext(["food" : randomItem as AnyObject])
            
            AlertHelper.showAlert(title: "Did Send Ping", controller: self)
        } catch {
            AlertHelper.showAlert(title: "Error Could Not Send Ping", controller: self)
        }
    }
    
    @IBAction func pingWatch(_ sender: Any) {
        vibrateWatch()
        self.scheduleAlarmNotification(event: "test", interval: 10)
    }
    
    @IBAction func stopAlarm(_ sender: Any) {
        self.animateOutTimeDisplayLayers()
    }
    
    func scheduleAlarmNotification(event : String, interval: TimeInterval) {
        let content = UNMutableNotificationContent()
        
        content.title = event
        content.body = "body"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "CALLINNOTIFICATION"
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: interval, repeats: false)
        let id = UUID.init().uuidString
        let request = UNNotificationRequest.init(identifier: "CALLINNOTIFICATION", content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            
        }
    }
    
    @IBAction func randomizeLights(_ sender: Any) {
        randomize()
    }
    
    @IBAction func toggleSettings(_ sender: Any) {
        performSegue(withIdentifier: "alarmOptions", sender: nil)
//        HueConnectionManager.sharedManager.searchForBridgeLocal()
    }
    
    @IBAction func startClock(_ sender: Any) {
        let id = UUID().uuidString //create new alarm
        let alarmDictionary:[String : Any] = ["id": id, "fireDate": timePicker.date, "name": "unnamed"]
       _ = Alarm.insertIntoContext(moc: managedObjectContext, alarmDictionary: alarmDictionary as NSDictionary)
        animateOutTimePickerLayers()
        
        updateRunningAlarmUI()
    }
    
    fileprivate func randomize() {
        let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
        let bridgeSendAPI = PHBridgeSendAPI()
        
        if let lights = cache?.lights {
            let lightsData = NSMutableDictionary()
            lightsData.addEntries(from: lights)
            
            for light in lightsData.allValues {
                let newLight = light as! PHLight
                let lightState = PHLightState()
                
                let colors = Colors.Gradient.blueGradient
                let randomIndex = Int(arc4random_uniform(UInt32(colors.count)))
                let color = colors[randomIndex]
                let xy = Utilities.calculateXY(cgColor: color, forModel: newLight.modelNumber)
                
                lightState.x = xy.x as NSNumber!
                lightState.y = xy.y as NSNumber!

                lightState.brightness = Int(1) as NSNumber!
                lightState.saturation = Int(245) as NSNumber!
                
                bridgeSendAPI.updateLightState(forId: newLight.identifier, with: lightState, completionHandler: { (errors : [Any]?) in
                    
                })
            }
        }
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bridgeSelection", let nav = segue.destination as? UINavigationController, let bridgesTableViewController =  nav.viewControllers.first as? HueBridgeSelectionTableViewController, let bridgesFound = sender as? [AnyHashable : Any] {
            let bridgesData = NSMutableDictionary()
            bridgesData.addEntries(from: bridgesFound)
            bridgesTableViewController.bridgesFound = bridgesData
            bridgesTableViewController.delegate = HueConnectionManager.sharedManager
        } else if segue.identifier == "bridgeAuthentication", let nav = segue.destination as? UINavigationController, let authViewController =  nav.viewControllers.first as? HueBridgeAuthenticationViewController {
            authViewController.delegate = HueConnectionManager.sharedManager
            authViewController.startPushLinking()
        } else if segue.identifier == "alarmOptions", let alarmOptions = segue.destination as? AlarmOptionsTableViewController {
            ///
        }
    }
    
    // MARK - Status Bar
    var statusBarHidden : Bool = false
    func toggleStatusBar(notification : NSNotification) {
        if let isHidden = notification.object as? Bool {
            animateStatusBars(isHidden: isHidden)
        }
    }
    
    func animateStatusBars(isHidden : Bool) {
        self.statusBarHidden = isHidden
        UIView.animate(withDuration: 0.70) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return self.statusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
}

extension ViewController: SBTimeLabelDelegate {
    func didUpdateText(_ label: SBTimeLabel) {
//        NSLog("clock: \(timeLabel.text)")
    }
}

extension ViewController : HueConnectionManagerDelegate {
    internal func didStartConnecting() {
        AlertHelper.showAlert(title: "Did Start Connecting", controller: self)
    }
    
    internal func didStartSearching() {
        AlertHelper.showAlert(title: "Did Start Searching", controller: self)
    }
    
    internal func didFindBridges(bridgesFound: [AnyHashable : Any]?) {
        AlertHelper.showAlert(title: "Did Find Bridges", controller: self)
        performSegue(withIdentifier: "bridgeSelection", sender: bridgesFound)
    }
    
    internal func didFailToFindBridges() {
        AlertHelper.showAlert(title: "Did Fail To Find Bridges", controller: self)
    }
    
    internal func showPushButtonAuthentication() {
        AlertHelper.showAlert(title: "Should Show Push Button", controller: self)
        performSegue(withIdentifier: "bridgeAuthentication", sender: nil)
    }
    
    //MARK - Date Picker
    func dateChanged(_ sender: UIDatePicker) {
        let componenets = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: sender.date)
        if let day = componenets.day, let month = componenets.month, let year = componenets.year, let hour = componenets.hour, let minute = componenets.minute, let second = componenets.second {
            print("\(day) \(month) \(year),  \(hour),  \(minute),  \(second)")
        }
    }
    
    
}


//extension ViewController : UIPickerViewDataSource {
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 3
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        var numberOfRows = 0
//        switch component {
//        case 0:
//            numberOfRows = AmbitConstants.time.hoursArray.count
//        case 1:
//            numberOfRows = AmbitConstants.time.minutesArray.count
//        case 2:
//            numberOfRows = AmbitConstants.time.ampmArray.count
//        default:
//            break
//        }
//        
//        return numberOfRows
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        
//        var titleForRow = ""
//        switch component {
//        case 0:
//            titleForRow = AmbitConstants.time.hoursArray[row]
//        case 1:
//            titleForRow = AmbitConstants.time.minutesArray[row]
//        case 2:
//            titleForRow = AmbitConstants.time.ampmArray[row]
//        default:
//            break
//        }
//        
//        return titleForRow
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        /// get date and save it to 
//        
//        // First we need to create a new instance of the NSDateFormatter
//        let dateFormatter = DateFormatter()
//        // Now we specify the display format, e.g. "27-08-2015
//        dateFormatter.dateFormat = "dd-MM-YYYY"
//        // Now we get the date from the UIDatePicker and convert it to a string
//        let strDate = dateFormatter.stringFromDate(timePicker.date)
//        
//        
//        let alarmDictionary:[String : Any] = ["id": "Juris", "fireDate": "Prudence", "name": "Test Alarm"]
//        Alarm.insertIntoContext(moc: managedObjectContext, alarmDictionary: alarmDictionary as NSDictionary)
//    }
//}


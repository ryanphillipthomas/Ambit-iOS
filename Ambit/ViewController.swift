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
import EventKit

class ViewController: UIViewController, ManagedObjectContextSettable {
    fileprivate let food = ["🍦", "🍮", "🍤","🍉", "🍨", "🍏", "🍌", "🍰", "🍚", "🍓", "🍪", "🍕"]
    
    @IBOutlet var timeLabel:SBTimeLabel!
    @IBOutlet var timeLeftLabel:UILabel!
    @IBOutlet var timeUpcomingLabel: UILabel!

    @IBOutlet var timePicker:UIDatePicker!
    @IBOutlet var settingsButton:UIButton!
    
    @IBOutlet weak var fullScreenBlackoutView: SpringView!
    @IBOutlet weak var timeLabelAnimationView: SpringView!
    @IBOutlet weak var settingsButtonAnimationView: SpringView!
    @IBOutlet weak var timePickerAnimationView: SpringView!
    @IBOutlet weak var nextAlarmAnimationView: SpringView!
    @IBOutlet weak var stopAnimationView: SpringView!
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var snoozeView: SpringView!
    
    @IBOutlet weak var containerView: UIView!
    weak var tableViewController:UITableViewController!
    weak var tableView: UITableView!

    var backroundAnimation = CAGradientLayer()
    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeLabel.updateText()
        timeLabel.start()
        timeLabel.delegate = self
        
        HueConnectionManager.sharedManager.delegate = self
        
        EventManager.sharedManager.delegate = self
        EventManager.sharedManager.checkCalendarAuthorizationStatus()

        backroundAnimation = GradientHandler.addGradientLayer()
        GradientViewHelper.addGradientColorsToView(view: self.view, gradientLayer: backroundAnimation)
        
        timeLabelAnimationView.isHidden = true
        nextAlarmAnimationView.isHidden = true
        stopAnimationView.isHidden = true
        snoozeView.isHidden = true
//        dimView.isHidden = true
        
        setNeedsStatusBarAppearanceUpdate()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.toggleStatusBar(notification:)), name: NSNotification.Name(rawValue:"didToggleStatusBar"), object: nil)
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(didSnooze(gesture:)))
//        snoozeView.addGestureRecognizer(tap)
//        snoozeView.isUserInteractionEnabled = true

        timePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        loadEvents()
        
//        dimView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.dimViewFadeGesture(gesture:))))

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateRunningAlarmUI()
    }
    
    override func viewDidLayoutSubviews() {
        backroundAnimation.frame = self.view.bounds
    }
    
    func handleRefresh() {
        loadFutureEvents()
        
        fetch()
        self.tableView.reloadData()
        self.tableViewController.refreshControl?.endRefreshing()
    }
    
    // MARK - Load Events
    func loadEvents() {
        fetch()
        self.tableView.reloadData()
        //        updateView()
        loadFutureEvents()
    }
    
    func loadFutureEvents() {
        Event.allUpcoming(moc: managedObjectContext) { (events) in
            //print(events)
            self.tableViewController.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: -fetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController<Event> = {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<Event>(entityName: "Event")
        
        // Configure Fetch Request
        let sortDescriptor = NSSortDescriptor(key: "startTime", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = 100
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    func fetch () {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   @IBAction func dimViewFadeGesture(gesture: UIPanGestureRecognizer) {
        print("Pan Dim The View")
        
        var lastPosition : CGPoint = CGPoint(x: 0, y: 0)
        var nowPosition : CGPoint = CGPoint(x: 0, y: 0)
        var alpha : CGFloat = 0.0
        var new_alpha : CGFloat = 0.0
        
        nowPosition = gesture.translation(in: self.view)
        alpha = self.dimView.alpha
        
        if (nowPosition.y > lastPosition.y) {
            new_alpha = min(alpha + 0.02,1.0)
            if new_alpha == 1 {new_alpha = 0.99}
            print("\(new_alpha)")
            self.dimView.alpha = new_alpha
        }
        else if (nowPosition.y < lastPosition.y) {
            new_alpha = max(alpha - 0.02,0)
            if new_alpha == 0 {new_alpha = 0.01}
            print("\(new_alpha)")
            self.dimView.alpha = new_alpha
        }
        else {
            print("Neither")
        }

        lastPosition = nowPosition
    }
    
    func fadeToBlack() {
        //fade out lights
        self.blackOut()
       
        //show the stop button
        self.animateInStopButton()
        
        //timeLabel to white
        UIView.transition(with: self.timeLabel, duration: 3.0, options: .transitionCrossDissolve, animations: {
            self.timeUpcomingLabel.textColor = UIColor.white
            self.timeLabel.textColor = UIColor.white
        }) { (finished) in

            //timeLabel to grey
            UIView.transition(with: self.timeLabel, duration: 3.0, options: .transitionCrossDissolve, animations: {
                self.timeUpcomingLabel.textColor = UIColor.darkGray
                self.timeLabel.textColor = UIColor.darkGray
            }, completion: nil)
        }

        blackoutFullscreenView()
    }
    
    func blackoutFullscreenView() {
        //fullScreenBlackoutView to black
        UIView.animate(withDuration: 3.0, animations: {
            self.fullScreenBlackoutView.backgroundColor = UIColor.black
        }) { (finished) in
            
            //remove back animation view
            self.removeAnimation()
        }
    }
    
    func removeAnimation() {
        self.view.layer.sublayers?.remove(at: 0)
    }
    
    func fadeToClear() {
        //fade to clear
        self.view.layer.insertSublayer(backroundAnimation, at: 0)
        
        UIView.transition(with: self.timeLabel, duration: 1.0, options: .transitionCrossDissolve, animations: {
            self.timeUpcomingLabel.textColor = UIColor.black
            self.timeLabel.textColor = UIColor.black
        }, completion: nil)

        UIView.animate(withDuration: 1.0) {
            self.fullScreenBlackoutView.backgroundColor = UIColor.clear
        }
        
        //fullScreenBlackoutView to black
        UIView.animate(withDuration: 1.0, animations: {
            self.fullScreenBlackoutView.backgroundColor = UIColor.clear
        }) { (finished) in
            self.lightsOn()
        }
    }
    
    func updateRunningAlarmUI() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let alarm = Alarm.fetchCurrentAlarm(moc: managedObjectContext)
        guard let scheduleAlarm = alarm else {return}
        //let timeRemaining = StringHelper.timeLeftUntilAlarm(alarmDate: scheduleAlarm.fireDate)
        let currentDate = Date()
        var hour_min_string = ""
        if currentDate > scheduleAlarm.fireDate {
            hour_min_string = StringHelper.pastTimeString(for: scheduleAlarm.fireDate)
        } else {
            hour_min_string = StringHelper.futureTimeString(for: scheduleAlarm.fireDate)
        }
        
        NSLog("fire date: \(hour_min_string)")

        timeUpcomingLabel.text = hour_min_string
        
        let next_alarm_string = StringHelper.nextAlarmString(alarmDate: scheduleAlarm.fireDate)
        timeLeftLabel.text = next_alarm_string
        
        if appDelegate.isPlayingSound() {
            animateOutTimeDisplayLayers()
            animateInSnoozeButton() //show the snooze button
            self.perform(#selector(self.fadeToClear), with: nil, afterDelay: 0.4) //fade in the color backround in 0.4 secs
        }
    }
    
    func animateInTimeDisplayLayers() {
        timeLabelAnimationView.isHidden = false
        nextAlarmAnimationView.isHidden = false

        nextAlarmAnimationView.animation = "fadeInDown"
        nextAlarmAnimationView.curve = "linear"
        nextAlarmAnimationView.duration = 2.0
        nextAlarmAnimationView.animate()
        
        timeLabelAnimationView.animation = "fadeInDown"
        timeLabelAnimationView.curve = "linear"
        timeLabelAnimationView.duration = 2.0
        timeLabelAnimationView.animate()
    }
    
    func animateInSnoozeButton () {
        if snoozeView.isHidden == true {
            snoozeView.isHidden = false
            snoozeView.animation = "zoomIn"
            snoozeView.curve = "easeIn"
            snoozeView.duration = 1.0
            snoozeView.animate()
        }
    }
    
    func animateOutSnoozeButton () {
        snoozeView.isHidden = true

        snoozeView.animation = "zoomOut"
        snoozeView.curve = "easeIn"
        snoozeView.duration = 1.0
        snoozeView.animate()
    }
    
    func animateInStopButton () {
        if stopAnimationView.isHidden == true {
            stopAnimationView.isHidden = false
    //        dimView.isHidden = false

            stopAnimationView.animation = "fadeInUp"
            stopAnimationView.curve = "linear"
            stopAnimationView.duration = 2.0
            stopAnimationView.animate()
        }
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
        
        timeLabelAnimationView.isHidden = true
        nextAlarmAnimationView.isHidden = true
//        dimView.isHidden = true
    }
    
    func animateOutStopButton() {
        
        stopAnimationView.animation = "fadeOutUp"
        stopAnimationView.curve = "linear"
        stopAnimationView.duration = 2.0
        stopAnimationView.animate()
        
        stopAnimationView.isHidden = true
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
    }
    
    @IBAction func stopAlarm(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.stopCurrentSound()
        
        self.fadeToClear()
        self.animateOutTimeDisplayLayers()
        self.animateOutStopButton()
        self.animateInTimePickerLayers()
        self.animateOutSnoozeButton()
    }
    
    @IBAction func didSnooze(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.stopCurrentSound()
        
        //start fading black frame
        self.perform(#selector(self.fadeToBlack), with: nil, afterDelay: 3.0)
        
        //generate date in 1 min
        let now = Date()
        let dateInFifteenMinutes = now.addingTimeInterval(60*1)
        addAlarmFromTimePicker(date:dateInFifteenMinutes)
        
        animateOutSnoozeButton()
        animateInTimeDisplayLayers()
    }
    

    
    @IBAction func randomizeLights(_ sender: Any) {
        randomize()
    }
    
    @IBAction func toggleSettings(_ sender: Any) {
        performSegue(withIdentifier: "alarmOptions", sender: nil)
//        HueConnectionManager.sharedManager.searchForBridgeLocal()
    }
    
    @IBAction func toggleUpcoming(_ sender: Any) {
        performSegue(withIdentifier: "upcomingEvents", sender: nil)
    }

    func addAlarmFromTimePicker(date:Date? = nil) {
        //create new alarm attributes
        let id = UUID().uuidString
        var fireDate = timePicker.date
        fireDate = Date.init(timeInterval: 0, since: fireDate) //alarms go off at the top of the hour

        if (date != nil) { fireDate = date! }
        let alarmDictionary:[String : Any] = ["id": id,
                                              "fireDate": fireDate,
                                              "name": "unnamed",
                                              "enabled" : true,
                                              "mediaID" : "",
                                              "mediaLabel" : "tickle.mp3",
                                              "snoozeEnabled" : true]
        
        //create the alarm
        _ = Alarm.insertIntoContext(moc: managedObjectContext, alarmDictionary: alarmDictionary as NSDictionary)
        
        //get the alarm and provide it to our sceduler
        let alarm = Alarm.fetchCurrentAlarm(moc: managedObjectContext)
        guard let scheduleAlarm = alarm else {return}
        print(scheduleAlarm.fireDate)
        
        RecorderManager.sharedManager.startRecording()

        //get the apple watch to vibrate
        scheduleLocalNotifications(scheduleAlarm: scheduleAlarm)
    }
    
    func scheduleLocalNotifications(scheduleAlarm : Alarm) {
        //get the apple watch to vibrate
        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 0)
        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 5)
        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 10)
        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 15)
        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 20)
        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 25)
        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 30)
        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 35)
        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 40)
        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 45)
        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 50)
        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 55)
        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 60)
        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 65)
        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 70)
        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 75)
        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 80)
        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 85)
        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 90)
        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 95)
        AlarmScheduleManager.sharedManager.scheduleAlarmNotification(alarm: scheduleAlarm, interval : 100)
    }
    
    @IBAction func startClock(_ sender: Any) {

        //create new alarm from time picker
        addAlarmFromTimePicker()
        
        //animaite out time picker
        self.animateOutTimePickerLayers()
        
        //animaite out time picker
        animateInTimeDisplayLayers()

        //update label with alarm
        updateRunningAlarmUI()
        
        //start fading black frame
        self.perform(#selector(self.fadeToBlack), with: nil, afterDelay: 3.0)
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
    
    fileprivate func blackOut() {
        let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
        let bridgeSendAPI = PHBridgeSendAPI()
        
        if let lights = cache?.lights {
            let lightsData = NSMutableDictionary()
            lightsData.addEntries(from: lights)
            
            for light in lightsData.allValues {
                let newLight = light as! PHLight
                let lightState = PHLightState()
                
                lightState.brightness = 0
                lightState.setOn(false)
    
                bridgeSendAPI.updateLightState(forId: newLight.identifier, with: lightState, completionHandler: { (errors : [Any]?) in
                    
                })
            }
        }
    }
    
    fileprivate func lightsOn() {
        let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
        let bridgeSendAPI = PHBridgeSendAPI()
        
        if let lights = cache?.lights {
            let lightsData = NSMutableDictionary()
            lightsData.addEntries(from: lights)
            
            for light in lightsData.allValues {
                let newLight = light as! PHLight
                let lightState = PHLightState()
                
                lightState.brightness = 100
                lightState.setOn(true)
                
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
        } else if segue.identifier == "upcomingEvents", let nav = segue.destination as? UINavigationController, let upcomingEvents = nav.viewControllers.first as? EventOptionsViewController {
            upcomingEvents.managedObjectContext = managedObjectContext
        } else if segue.identifier == "containerSegue", let tableVC = segue.destination as? UITableViewController {
            let refreshControl = UIRefreshControl()
            refreshControl.tintColor = UIColor.white
            refreshControl.addTarget(self, action: #selector(ViewController.handleRefresh), for: UIControlEvents.valueChanged)
            tableVC.refreshControl = refreshControl
            self.tableView = tableVC.tableView
            self.tableViewController = tableVC
            
            self.tableView.delegate = self
            self.tableView.dataSource = self
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
        updateRunningAlarmUI()
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


extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let count = fetchedResultsController.fetchedObjects?.count
        
        var cell:UITableViewCell
        
        let event = fetchedResultsController.object(at:indexPath)
        cell = tableView.dequeueReusableCell(withIdentifier: "eventTableViewCell", for: indexPath)
        
        // Configure Cell
        configure(cell as! EventTableViewCell, at: indexPath)
        return cell
    }
    
    func configure(_ cell: EventTableViewCell, at indexPath: IndexPath) {
        let row = indexPath.row
        let count = fetchedResultsController.fetchedObjects?.count
        let event = fetchedResultsController.object(at: indexPath)
        cell.configureWith(eventIndex: Int(row), numberOfItems: Int(count!), event:event)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let event = fetchedResultsController.object(at: indexPath)
    }
}

extension ViewController: UITableViewDataSource {
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let events = fetchedResultsController.fetchedObjects else { return 0 }
        return events.count
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        //        updateView()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? EventTableViewCell {
                configure(cell, at: indexPath)
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        }
    }
}

extension ViewController: EventManagerDelegate {
    func needPermissionToCalendar() {
        //Display alert that we need the users calendar permission
    }
    func loadCalendars() {
        self.loadEvents()
    }
    func requestAccessToCalendar() {
        EKEventStore().requestAccess(to: .event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {
                DispatchQueue.main.async(execute: {
                    self.loadCalendars()
                    self.tableView.reloadData()
                })
            } else {
                //Display alert that we need the users calendar permission
            }
        })
    }
}




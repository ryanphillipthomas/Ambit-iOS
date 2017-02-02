//
//  ViewController.swift
//  template
//
//  Created by Ryan Phillip Thomas on 12/9/16.
//  Copyright © 2016 ryanphillipthomas. All rights reserved.
//

import UIKit
import Spring

class ViewController: UIViewController {
    @IBOutlet var timeLabel:SBTimeLabel!
    @IBOutlet var settingsButton:UIButton!

    @IBOutlet weak var timeLabelAnimationView: SpringView!
    @IBOutlet weak var settingsButtonAnimationView: SpringView!


    @IBOutlet weak var timeButton: UIButton!
    var backroundAnimation = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeLabel.updateText()
        timeLabel.start()
        timeLabel.delegate = self
        HueConnectionManager.sharedManager.delegate = self
        addGradientToView()
        animateLayers()
        
        setNeedsStatusBarAppearanceUpdate()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.toggleStatusBar(notification:)), name: NSNotification.Name(rawValue:"didToggleStatusBar"), object: nil)

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidLayoutSubviews() {
        backroundAnimation.frame = self.view.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animateLayers() {
        timeLabelAnimationView.animation = "fadeInDown"
        timeLabelAnimationView.curve = "linear"
        timeLabelAnimationView.duration = 2.0
        timeLabelAnimationView.animate()
        
        settingsButtonAnimationView.animation = "fadeInUp"
        settingsButtonAnimationView.curve = "linear"
        settingsButtonAnimationView.duration = 2.0
        settingsButtonAnimationView.animate()
    }
    
    @IBAction func randomizeLights(_ sender: Any) {
        randomize()
    }
    
    @IBAction func toggleSettings(_ sender: Any) {
        performSegue(withIdentifier: "alarmOptions", sender: nil)

//        HueConnectionManager.sharedManager.searchForBridgeLocal()
    }
    
    fileprivate func addGradientToView() {
        GradientHandler.bounds = self.view.bounds
        GradientHandler.colors = Colors.Gradient.blueGradient
        GradientHandler.location = [0.10, 0.30, 0.45, 0.60, 0.75, 0.9]
        GradientHandler.startPosition = CGPoint(x: 0, y: 1)
        GradientHandler.endPosition = CGPoint(x: 1, y: 0)
        
        backroundAnimation = GradientHandler.addGradientLayer()
        self.view.layer.insertSublayer(backroundAnimation, at: 0)
        
        GradientHandler.toColors = GradientHandler.colors
        GradientHandler.animateLayerWithColor()
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
}


//
//  HueBridgeAuthenticationViewController.swift
//  Sheet
//
//  Created by Ryan Phillip Thomas on 1/30/17.
//  Copyright © 2017 ryanphillipthomas. All rights reserved.
//

import UIKit

protocol HueBridgeAuthenticationViewControllerDelegate: class {
    func pushlinkSuccess()
    func pushlinkFailed(error:PHError)
}


class HueBridgeAuthenticationViewController: UIViewController {
    weak var delegate:HueBridgeAuthenticationViewControllerDelegate?
    var notificationManager : PHNotificationManager?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func done(sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func startPushLinking() {
        self.notificationManager = PHNotificationManager.default()
        
        self.notificationManager?.register(self, with: #selector(self.authenticationSuccess(_:)), forNotification: PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION)
        self.notificationManager?.register(self, with: #selector(self.authenticationFailed(_:)), forNotification: PUSHLINK_LOCAL_AUTHENTICATION_FAILED_NOTIFICATION)
        self.notificationManager?.register(self, with: #selector(self.noLocalConnection(_:)), forNotification: PUSHLINK_NO_LOCAL_CONNECTION_NOTIFICATION)
        self.notificationManager?.register(self, with: #selector(self.noLocalBridge(_:)), forNotification: PUSHLINK_NO_LOCAL_BRIDGE_KNOWN_NOTIFICATION)
        self.notificationManager?.register(self, with: #selector(self.buttonNotPressed(_:)), forNotification: PUSHLINK_BUTTON_NOT_PRESSED_NOTIFICATION)
        
        // Call to the hue SDK to start pushlinking process
        /***************************************************
         Call the SDK to start Push linking.
         The notifications sent by the SDK will confirm success
         or failure of push linking
         *****************************************************/
        
        HueConnectionManager.sharedManager.client?.startPushlinkAuthentication()
    }
    
    //MARK: Notification
    func authenticationSuccess(_ notification : Notification) {
        /***************************************************
         The notification PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION
         was received. We have confirmed the bridge.
         De-register for notifications and call
         pushLinkSuccess on the delegate
         *****************************************************/
        // Deregister for all notifications
        self.notificationManager?.deregisterObject(forAllNotifications: self)
        
        // Inform delegate
        self.dismiss(animated: true) { 
            self.delegate?.pushlinkSuccess()
        }
    }
    
    func authenticationFailed(_ notification : Notification) {
        // Deregister for all notifications
        self.notificationManager?.deregisterObject(forAllNotifications: self)
        
        print("Error")
    }
    
    func noLocalConnection(_ notification : Notification) {
        // Deregister for all notifications
        self.notificationManager?.deregisterObject(forAllNotifications: self)
        
        print("Error")
    }
    
    func noLocalBridge(_ notification : Notification) {
        // Deregister for all notifications
        self.notificationManager?.deregisterObject(forAllNotifications: self)
        
        print("Error")
    }
    
    func buttonNotPressed(_ notification : Notification) {
        print("Button Not Pressed")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

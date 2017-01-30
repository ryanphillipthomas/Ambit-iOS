//
//  HueConnectionManager.swift
//  Sheet
//
//  Created by Ryan Phillip Thomas on 1/29/17.
//  Copyright © 2017 ryanphillipthomas. All rights reserved.
//

import UIKit

protocol HueConnectionManagerDelegate: class {
    func didStartConnecting()
    func didStartSearching()
    func didFindBridges(bridgesFound:[AnyHashable : Any]?)
    func didFailToFindBridges()
    func showPushButtonAuthentication()
}

class HueConnectionManager: NSObject {
    static let sharedManager = HueConnectionManager()
    var client : PHHueSDK?
    var notificationManager : PHNotificationManager?
    var bridgeSearch : PHBridgeSearching?

    weak var delegate:HueConnectionManagerDelegate?
    
    func startUp() {
        self.client = PHHueSDK()
        self.client?.startUp()
        self.client?.enableLogging(true)
        self.notificationManager = PHNotificationManager.default()
        
        /***************************************************
         The SDK will send the following notifications in response to events:
         
         - LOCAL_CONNECTION_NOTIFICATION
         This notification will notify that the bridge heartbeat occurred and the bridge resources cache data has been updated
         
         - NO_LOCAL_CONNECTION_NOTIFICATION
         This notification will notify that there is no connection with the bridge
         
         - NO_LOCAL_AUTHENTICATION_NOTIFICATION
         This notification will notify that there is no authentication against the bridge
         *****************************************************/

        self.notificationManager?.register(self, with: #selector(self.localConnectionNotification(_:)), forNotification: LOCAL_CONNECTION_NOTIFICATION)
        self.notificationManager?.register(self, with: #selector(self.noLocalConnectionNotification(_:)), forNotification: NO_LOCAL_CONNECTION_NOTIFICATION)
        self.notificationManager?.register(self, with: #selector(self.notAuthenticatedNotification(_:)), forNotification: NO_LOCAL_AUTHENTICATION_NOTIFICATION)
        
        enableLocalHeartbeat()
    }
    
    func enableLocalHeartbeat() {
        /***************************************************
         The heartbeat processing collects data from the bridge
         so now try to see if we have a bridge already connected
         *****************************************************/
        
        let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
        if let cache = cache {
            if (cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil) {
                print("Connecting to Philips HUE Bridge...")
                self.delegate?.didStartConnecting()
                
                // Enable heartbeat with interval of 10 seconds
                self.client?.enableLocalConnection()
            } else {
                // Automaticly start searching for bridges
                searchForBridgeLocal()
            }
        }
        
    }
    
    func disableLocalHeartbeat() {
        self.client?.disableLocalConnection()
    }
    
    func searchForBridgeLocal() {
        // Stop heartbeats
        self.disableLocalHeartbeat()
        
        // Show search screen
        print("Searching...")
        self.delegate?.didStartSearching()

        /***************************************************
         A bridge search is started using UPnP to find local bridges
         *****************************************************/
        
        // Start search
        self.bridgeSearch = PHBridgeSearching.init(upnpSearch: true, andPortalSearch: true, andIpAddressSearch: true)
        self.bridgeSearch?.startSearch(completionHandler: { (bridgesFound: [AnyHashable : Any]?) in
            // Done with search, remove loading view
            // [remove loading view]
            /***************************************************
             The search is complete, check whether we found a bridge
             *****************************************************/
            
            // Check for results
            if let bridgesFound = bridgesFound {
                if (bridgesFound.count > 0) {
                    
                    /***************************************************
                     Use the list of bridges, present them to the user, so one can be selected.
                     *****************************************************/
                    
                    print("Found Bridges...")
                    self.delegate?.didFindBridges(bridgesFound:bridgesFound)

                } else {
                    /***************************************************
                     No bridge was found was found. Tell the user and offer to retry..
                     *****************************************************/
                    
                    // No bridges were found, show this to the user
                    
                    print("No Bridges Found...")
                    self.delegate?.didFailToFindBridges()

                }
            }

        })
    }

    func bridgeSelectedWithIpAddress(ipAddress : String, bridgeID : String) {
        /***************************************************
         Removing the selection view controller takes us to
         the 'normal' UI view
         *****************************************************/
        
        // Remove the selection view controller
        print("Connecting to Philips HUE Bridge...")
        self.delegate?.didStartConnecting()
        
        // Set SDK to use bridge and our default username (which should be the same across all apps, so pushlinking is only required once)
        //NSString *username = [PHUtilities whitelistIdentifier];
        
        /***************************************************
         Set the ipaddress and bridge id,
         as the bridge properties that the SDK framework will use
         *****************************************************/
        self.client?.setBridgeToUseWithId(bridgeID, ipAddress: ipAddress)
        /***************************************************
         Setting the hearbeat running will cause the SDK
         to regularly update the cache with the status of the
         bridge resources
         *****************************************************/
        
        // Start local heartbeat again
        self.perform( #selector(self.enableLocalHeartbeat), with: nil, afterDelay: 1)
    }
    
    //MARK: Bridge authentication
    func doAuthentication() {
        // Disable heartbeats
        self.disableLocalHeartbeat()
        
        /***************************************************
         To be certain that we own this bridge we must manually
         push link it. Here we display the view to do this.
         *****************************************************/
        
        // Create an interface for the pushlinking
        self.delegate?.showPushButtonAuthentication()

        /***************************************************
         Start the push linking process.
         *****************************************************/
        
        // Start pushlinking when the interface is shown

    }
    
    func pushLinkSuccess() {
        /***************************************************
         Push linking succeeded we are authenticated against
         the chosen bridge.
         *****************************************************/
        
        // Remove pushlink view controller

        // Start local heartbeat again
        self.perform( #selector(self.enableLocalHeartbeat), with: nil, afterDelay: 1)
    }
    
    func pushLinkFailed(error:PHError) {
        // Remove pushlink view controller
        
    }
    
    //MARK: Notification
    func localConnectionNotification(_ notification : Notification) {
        // Check current connection state
        checkConnectionState()
    }
    
    func noLocalConnectionNotification(_ notification : Notification) {
        checkConnectionState()

    }
    
    func notAuthenticatedNotification(_ notification : Notification) {
        // Start local heartbeat again
        self.perform( #selector(self.doAuthentication), with: nil, afterDelay: 1)
    }
    
    func checkConnectionState() {
        if ((self.client?.localConnected) != nil) {
        
        }
    }
    
}


//
//  Thunderstorm_Fireplace.swift
//  Ambit
//
//  Created by Ryan Thomas on 1/1/18.
//  Copyright © 2018 ryanphillipthomas. All rights reserved.
//

import Foundation
import AudioPlayer
import AVFoundation
import MediaPlayer

private enum FlashType {
    case Default
    case Sharp
    case Trailing
    case All
}

class Thunderstorm_Fireplace: NSObject {
    static let sharedManager = Thunderstorm_Fireplace()
    var currentSound: AudioPlayer?
    var audioPlayer : AVAudioPlayer!
    var audioPlayerVolume : Float!
    var lightBrightnessLevel : Float!
    var isPlayingOverride : Bool = false
    var isTransitioning : Bool = false

    
    func isPlayingSound() -> Bool {
        if isPlayingOverride { return true }
        
        guard let currentSound = self.currentSound else { return false }
        return currentSound.isPlaying
    }
    
    func startStorm() {
        //play()
        largeFlashAll()
    }
    
    func play() {
        
        if isPlayingSound() { return }
        
        //get sound file name and load it up
        do {
            currentSound = try AudioPlayer(fileName: "thunderstorm_fireplace.mp3")
        }
        catch _ {
            // Error handling
            print("Sound initialization failed")
        }
        
        //initalize volume
        audioPlayerVolume = 0.1
        lightBrightnessLevel = 10.0
        (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(audioPlayerVolume, animated: false)
        
        //start playing sound
        playCurrentSound()
    }
    
    func playCurrentSound() {
        currentSound?.numberOfLoops = 10
        currentSound?.currentTime = 0
        currentSound?.fadeIn()
        currentSound?.volume = 100.0
        currentSound?.play()
        
        isPlayingOverride = true
    }
    
    fileprivate func resetToLightBrightnessLevel() {
        let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
        let bridgeSendAPI = PHBridgeSendAPI()
        
        if let lights = cache?.lights {
            let lightsData = NSMutableDictionary()
            lightsData.addEntries(from: lights)
            
            for light in lightsData.allValues {
                let newLight = light as! PHLight
                let lightState = PHLightState()
                
                lightState.brightness = lightBrightnessLevel! as NSNumber
                lightState.setOn(false)
                
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
    
    fileprivate func largeFlashAll() {
        let index = Int(arc4random_uniform(UInt32(5)))
        if index == 0 {
            lightsWhiteBright(FlashType.Sharp)
        } else if index == 1 {
            lightsWhiteBright(FlashType.All)
        } else if index == 2 {
            lightsWhiteBright(FlashType.Default)
        } else if index == 3 {
            lightsWhiteBright(FlashType.Sharp)
        } else if index == 4 {
            lightsWhiteBright(FlashType.Trailing)
        }

    }
    
    fileprivate func lightsBright() {
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
    
    
    
    //grab a random light, grab a random brightness (dev todo add brighness levels), grab the color value before the update and set it back to it after...
    fileprivate func lightsWhiteBright(_ type: FlashType) {
        if self.isTransitioning {
            return
        }
        
        self.isTransitioning = true
        let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
        let bridgeSendAPI = PHBridgeSendAPI()
        if let lights = cache?.lights {
            switch type {
            case .Default:
                let lightsData = NSMutableDictionary()
                let randomLightIndex = Int(arc4random_uniform(UInt32(lights.count)))
                lightsData.addEntries(from: lights)
                
                let randomLight = lightsData.allValues[randomLightIndex]
                let newLight = randomLight as! PHLight
                let newLightX = newLight.lightState.value(forKey: "x")
                let newLightY = newLight.lightState.value(forKey: "y")
                let newLightBrightness = newLight.lightState.value(forKey: "brightness")
                var newLightXY = CGPoint(x:0, y:0)
                
                if (newLightY != nil) && (newLightX != nil) {
                    newLightXY = CGPoint(x:newLightX as! CGFloat, y:newLightY as! CGFloat)
                }
                
                let lightState = PHLightState()
                
                let xy = Utilities.calculateXY(cgColor: UIColor.white.cgColor, forModel: newLight.modelNumber)
                
                lightState.x = xy.x as NSNumber!
                lightState.y = xy.y as NSNumber!
                
                lightState.brightness = 254 //0-254
                lightState.setOn(true)
                
                bridgeSendAPI.updateLightState(forId: newLight.identifier, with: lightState, completionHandler: { (errors : [Any]?) in
                    let lightState = PHLightState()
                    
                    let xy = newLightXY
                    lightState.brightness = newLightBrightness as! NSNumber //0-254
                    lightState.x = xy.x as NSNumber!
                    lightState.y = xy.y as NSNumber!
                    
                    lightState.setOn(true)
                    bridgeSendAPI.updateLightState(forId: newLight.identifier, with: lightState, completionHandler: { (errors : [Any]?) in
                        //
                        print("stoped transitiong default")
                        self.isTransitioning = false;
                    })
                })
            case .Sharp:
                print("sharp")
                let lightsData = NSMutableDictionary()
                let randomLightIndex = Int(arc4random_uniform(UInt32(lights.count)))
                lightsData.addEntries(from: lights)
                
                let randomLight = lightsData.allValues[randomLightIndex]
                let newLight = randomLight as! PHLight
                let newLightX = newLight.lightState.value(forKey: "x")
                let newLightY = newLight.lightState.value(forKey: "y")
                let newLightBrightness = newLight.lightState.value(forKey: "brightness")
                var newLightXY = CGPoint(x:0, y:0)
                
                if (newLightY != nil) && (newLightX != nil) {
                    newLightXY = CGPoint(x:newLightX as! CGFloat, y:newLightY as! CGFloat)
                }
                
                let lightState = PHLightState()
                
                let xy = Utilities.calculateXY(cgColor: UIColor.white.cgColor, forModel: newLight.modelNumber)
                
                lightState.x = xy.x as NSNumber!
                lightState.y = xy.y as NSNumber!
                
                lightState.brightness = 254 //0-254
                lightState.setOn(true)
                
                bridgeSendAPI.updateLightState(forId: newLight.identifier, with: lightState, completionHandler: { (errors : [Any]?) in
                })
                let newLightState = PHLightState()
                newLightState.brightness = newLightBrightness as! NSNumber //0-254

                let new_xy = newLightXY
                newLightState.x = new_xy.x as NSNumber!
                newLightState.y = new_xy.y as NSNumber!
                
                newLightState.setOn(true)
                bridgeSendAPI.updateLightState(forId: newLight.identifier, with: newLightState, completionHandler: { (errors : [Any]?) in
                    //
                    print("stoped transitiong sharp")
                    self.isTransitioning = false;
                })
            case .Trailing:
                let lightsData = NSMutableDictionary()
                let lightsValueArray = NSMutableArray()

                lightsData.addEntries(from: lights)
 
                //make light count dynamic
                for _ in 0 ..< 3 {
                    let randomIndex = Int(arc4random_uniform(UInt32(lightsData.allValues.count)))
                    let randomItem = lightsData.allValues[randomIndex]
                    lightsValueArray.add(randomItem)
                }
                
                var count = 0
                for light in lightsValueArray {
                    let newLight = light as! PHLight
                    let newLightX = newLight.lightState.value(forKey: "x")
                    let newLightY = newLight.lightState.value(forKey: "y")
                    let newLightBrightness = newLight.lightState.value(forKey: "brightness")
                    var newLightXY = CGPoint(x:0, y:0)
                    
                    if (newLightY != nil) && (newLightX != nil) {
                        newLightXY = CGPoint(x:newLightX as! CGFloat, y:newLightY as! CGFloat)
                    }
                    
                    let lightState = PHLightState()
                    
                    let xy = Utilities.calculateXY(cgColor: UIColor.white.cgColor, forModel: newLight.modelNumber)
                    
                    lightState.x = xy.x as NSNumber!
                    lightState.y = xy.y as NSNumber!
                    
                    lightState.brightness = 254 //0-254
                    lightState.setOn(true)
                    
                    bridgeSendAPI.updateLightState(forId: newLight.identifier, with: lightState, completionHandler: { (errors : [Any]?) in
                        let lightState = PHLightState()
                        lightState.brightness = newLightBrightness as! NSNumber //0-254
                        
                        let xy = newLightXY
                        lightState.x = xy.x as NSNumber!
                        lightState.y = xy.y as NSNumber!
                        
                        lightState.setOn(true)
                        bridgeSendAPI.updateLightState(forId: newLight.identifier, with: lightState, completionHandler: { (errors : [Any]?) in
                            count += 1
                            print(count)
                            if count == lightsValueArray.count {
                                print("stoped transitiong trailing")
                                self.isTransitioning = false;
                            }
                        })
                    })
                    
                }
            case .All:
                let lightsData = NSMutableDictionary()
                lightsData.addEntries(from: lights)
                var count = 0
                for light in lightsData.allValues {
                    let newLight = light as! PHLight
                    let newLightX = newLight.lightState.value(forKey: "x")
                    let newLightY = newLight.lightState.value(forKey: "y")
                    let newLightBrightness = newLight.lightState.value(forKey: "brightness")
                    var newLightXY = CGPoint(x:0, y:0)
                    
                    if (newLightY != nil) && (newLightX != nil) {
                        newLightXY = CGPoint(x:newLightX as! CGFloat, y:newLightY as! CGFloat)
                    }
                    
                    let lightState = PHLightState()
                    
                    let xy = Utilities.calculateXY(cgColor: UIColor.white.cgColor, forModel: newLight.modelNumber)
                    
                    lightState.x = xy.x as NSNumber!
                    lightState.y = xy.y as NSNumber!
                    
                    lightState.brightness = 254 //0-254
                    lightState.setOn(true)
                    
                    bridgeSendAPI.updateLightState(forId: newLight.identifier, with: lightState, completionHandler: { (errors : [Any]?) in
                        let lightState = PHLightState()
                        lightState.brightness = newLightBrightness as! NSNumber //0-254

                        let xy = newLightXY
                        lightState.x = xy.x as NSNumber!
                        lightState.y = xy.y as NSNumber!
                        
                        lightState.setOn(true)
                        bridgeSendAPI.updateLightState(forId: newLight.identifier, with: lightState, completionHandler: { (errors : [Any]?) in
                            count += 1
                            print(count)
                            if count == lightsData.allValues.count {
                                print("stoped transitiong all")
                                self.isTransitioning = false;
                            }
                        })
                    })
                    
                }
            }
        }
    }
}

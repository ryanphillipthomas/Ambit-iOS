//
//  LightsOptionsViewController.swift
//  Ambit
//
//  Created by Ryan Thomas on 2/19/17.
//  Copyright © 2017 ryanphillipthomas. All rights reserved.
//

import UIKit

class LightsOptionsViewController: UIViewController {
    
    var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didSelectDoneOptionButton(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:"didToggleStatusBar"), object: false)
        })
    }
    
    @IBAction func didSelectNightActionButton(_ sender: Any) {
        Thunderstorm_Fireplace.sharedManager.startStorm()
    }
    
    @IBAction func didSelectPixelActionButton(_ sender: Any) {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true);
        setToCurrentPixel() //todo add timer
    }
    
    // must be internal or public.
    func update() {
        setToCurrentPixel()
    }
    
    @IBAction func didSelectBlackoutActionButton(_ sender: Any) {
        blackOut()
    }
    
    @IBAction func didSelectResetToCurrentActionButton(_ sender: Any) {
        lightsOn()
    }
    
    fileprivate func setToBlueGradientColor() {
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
    
    
    fileprivate func setToWhiteColor() {
        let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
        let bridgeSendAPI = PHBridgeSendAPI()
        
        if let lights = cache?.lights {
            let lightsData = NSMutableDictionary()
            lightsData.addEntries(from: lights)
            
            for light in lightsData.allValues {
                let newLight = light as! PHLight
                let lightState = PHLightState()
                
                let xy = Utilities.calculateXY(cgColor: UIColor.white as! CGColor, forModel: newLight.modelNumber)
                
                lightState.x = xy.x as NSNumber!
                lightState.y = xy.y as NSNumber!
                
                lightState.brightness = Int(1) as NSNumber!
                lightState.saturation = Int(245) as NSNumber!
                
                bridgeSendAPI.updateLightState(forId: newLight.identifier, with: lightState, completionHandler: { (errors : [Any]?) in
                    
                })
            }
       }
    }
    
    fileprivate func setToCurrentPixel() {
        let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
        let bridgeSendAPI = PHBridgeSendAPI()
        
        if let lights = cache?.lights {
            let lightsData = NSMutableDictionary()
            lightsData.addEntries(from: lights)
            
            for light in lightsData.allValues {
                let newLight = light as! PHLight
                let lightState = PHLightState()

                let appDelegate  = UIApplication.shared.delegate as! AppDelegate
                let viewController = appDelegate.window!.rootViewController as! ViewController
                
                let layers = viewController.view.layer.sublayers
                let layer = layers?[0]
                if let bkdLayer = layer as? CAGradientLayer {
                    if let color = bkdLayer.colors?.first {
                        let xy = Utilities.calculateXY(cgColor: color as! CGColor, forModel: newLight.modelNumber)
                        
                        lightState.x = xy.x as NSNumber!
                        lightState.y = xy.y as NSNumber!
                        
                        lightState.brightness = Int(1) as NSNumber!
                        lightState.saturation = Int(245) as NSNumber!
                        
                        bridgeSendAPI.updateLightState(forId: newLight.identifier, with: lightState, completionHandler: { (errors : [Any]?) in
                            
                        })
                    }
                }
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
    
    fileprivate func flashAll() {
        blackOut()
        lightsOn()
        blackOut()
        lightsOn()
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
}


extension CALayer {
    
    func colorOfPoint(point:CGPoint) -> CGColor {
        
        var pixel: [CUnsignedChar] = [0, 0, 0, 0]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context!.translateBy(x: -point.x, y: -point.y)
        
        self.render(in: context!)
        
        let red: CGFloat   = CGFloat(pixel[0]) / 255.0
        let green: CGFloat = CGFloat(pixel[1]) / 255.0
        let blue: CGFloat  = CGFloat(pixel[2]) / 255.0
        let alpha: CGFloat = CGFloat(pixel[3]) / 255.0
        
        let color = UIColor(red:red, green: green, blue:blue, alpha:alpha)
        
        return color.cgColor
    }
}

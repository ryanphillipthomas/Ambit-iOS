//
//  AmbitConstants.swift
//  Ambit
//
//  Created by Ryan Phillip Thomas on 10/20/16.
//  Copyright © 2016 ryanphillipthomas. All rights reserved.
//

import Foundation
import UIKit

struct AmbitConstants {
    
    struct time {
        static let hoursArray = ["1","2","3","4","5","6","7","8","9","10","11","12"]
        static let minutesArray = ["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35", "36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59"]
        static let ampmArray = ["AM","PM"]
    }
    
    static let CurrentVolumeLevelName = "CurrentVolumeLevelName" // current setting for volume level
    static let CurrentLightSceneName = "CurrentLightSceneName" //current running light scene name
    static let CurrentHueBridgeName = "CurrentHueBridgeName" //hue bridgh ip address
    
    static let DefaultSnoozeLength = "DefaultSnoozeLength" //length of time for snoozing
    static let DefaultSleepSoundsLength = "DefaultSleepSoundsLength" //length of time for sleep sounds & lighting
    
    static let VibrateWithAlarmSetting = "VibrateWithAlarmSetting" //true or false for should vibrate device
    static let ProgressiveAlarmVolumeSetting = "ProgressiveAlarmVolumeSetting" //true or false for should fade in volume
    
    static let CurrentSleepSoundName = "CurrentSleepSoundName" // current setting for sleep sound
    static let SleepSoundsLightingSetting = "SleepSoundsLightingSetting" //true or false for should run sleep lighting
    static let SleepSoundsLightingSettingSceneName = "SleepSoundsLightingSettingSceneName" //Scene Name for Sleep Sounds
    
    static let AlarmSoundsLightingSetting = "AlarmSoundsLightingSetting" //true or false for should run alarm lighting
    static let AlarmSoundsLightingSettingSceneName = "AlarmSoundsLightingSettingSceneName" //Scene Name for Alarm Sounds
    static let CurrentAlarmSoundName = "CurrentAlarmSoundName" // current setting for alarm sound







}

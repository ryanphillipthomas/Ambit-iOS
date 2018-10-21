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
    
    static let ToggleStatusBar = "didToggleStatusBar" // toggle status bar
    
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
    static let RecorderActiveSetting = "RecorderActiveSetting" //true or false for should run recorder

    static let WeatherActiveSetting = "WeatherActiveSetting" //true or false for should run weather
    static let HealthActiveSetting = "HealthActiveSetting" //true or false for should run health

    
    static let AlarmSoundsLightingSetting = "AlarmSoundsLightingSetting" //true or false for should run alarm lighting
    static let AlarmSoundsLightingSettingSceneName = "AlarmSoundsLightingSettingSceneName" //Scene Name for Alarm Sounds
    static let CurrentAlarmSoundName = "CurrentAlarmSoundName" // current setting for alarm sound

    
    static let CurrentCustomMediaAlarmSoundName = "CurrentCustomMediaAlarmSoundName" // current setting for custom media sound
    static let CurrentCustomMediaAlarmSoundURL = "CurrentCustomMediaAlarmSoundURL" // current setting for custom media url
    static let CurrentCustomMediaAlarmSoundID = "CurrentCustomMediaAlarmSoundID" // current setting for custom media id

    static let CurrentCustomMediaSleepSoundName = "CurrentCustomMediaSleepSoundName" // current setting for custom media sound
    static let CurrentCustomMediaSleepSoundURL = "CurrentCustomMediaSleepSoundURL" // current setting for custom media url
    static let CurrentCustomMediaSleepSoundID = "CurrentCustomMediaSleepSoundID" // current setting for custom media id

    static let ActiveLightGroupingSettings = "ActiveLightGroupingSettings" //lights we can alter with effects
    
    static let BackroundType = "BackroundType"
    
    struct quotes {
        static let quote_1 = "Set a goal that makes you want to jump out of bed in the morning."
        static let quote_2 = "Yesterday is gone, tomorrow is a mystery, today is a blessing."
        static let quote_3 = "Everyday may not be good, but there is something good in every day"
        static let quote_4 = "You don’t have to be great to start, but you have to start to be great"
        static let quote_5 = "You will never have this day again so make it count!"
        static let quotesArray = [quote_1, quote_2, quote_3, quote_4, quote_5]
    }

}

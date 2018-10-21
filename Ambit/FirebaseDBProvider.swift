//
//  FirebaseDBProvider.swift
//  Weather Today
//
//  Created by Sebastián  Lara on 5/10/17.
//  Copyright © 2017 Sebastián  Lara. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class FirebaseDBProvider {
    private static let _instance = FirebaseDBProvider()
    
    static var Instance: FirebaseDBProvider {
        return _instance
    }
    
    var dbRef: DatabaseReference {
        return Database.database().reference()
    }
    
    var weatherRef: DatabaseReference {
        return dbRef.child(Constants.WEATHER)
    }
    
    // save current weather
    func saveCurrentWeather(currentWeather: CurrentWeatherViewModel) {
        let uuid = UUID().uuidString
        
        let data: Dictionary<String, Any> = [
            Constants.WEATHER_CITY: currentWeather.cityName!,
            Constants.WEATHER_TEMP: currentWeather.temperature!,
            Constants.WEATHER_CONDITION: currentWeather.weatherCondition!,
            Constants.DATE: self.getCurrentDate(),
            Constants.LATITUDE: String(Coordinate.sharedInstance.latitude),
            Constants.LONGITUDE: String(Coordinate.sharedInstance.longitude)
        ]
        
        weatherRef.child(uuid).setValue(data)
    }
    
    func getCurrentDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let currentDate = formatter.string(from: date)
        
        return currentDate
    }
}


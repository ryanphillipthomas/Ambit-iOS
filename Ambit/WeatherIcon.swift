//
//  WeatherIcon.swift
//  Weather Today
//
//  Created by Sebastián  Lara on 5/6/17.
//  Copyright © 2017 Sebastián  Lara. All rights reserved.
//

import Foundation
import UIKit

enum WeatherIcon {
    case clearSky
    case fewClouds
    case scatteredClouds
    case brokenClouds
    case showerRain
    case rain
    case thunderstorm
    case snow
    case mist
    case `default`
    
    init(iconString: String) {
        switch iconString {
        case "01n": self = .clearSky
        case "02n": self = .fewClouds
        case "03n": self = .scatteredClouds
        case "04n": self = .brokenClouds
        case "09n": self = .showerRain
        case "10n": self = .rain
        case "11n": self = .thunderstorm
        case "13n": self = .snow
        case "50n": self = .mist
        default: self = .default
        }
    }
}

extension WeatherIcon {
    var image: UIImage {
        switch self {
        case .clearSky: return #imageLiteral(resourceName: "ClearSkyIcon")
        case .fewClouds: return #imageLiteral(resourceName: "FewCloudsIcon")
        case .scatteredClouds: return #imageLiteral(resourceName: "ScatteredCloudsIcon")
        case .brokenClouds: return #imageLiteral(resourceName: "BrokenCloudsIcon")
        case .showerRain: return #imageLiteral(resourceName: "ShowerRainIcon")
        case .rain: return #imageLiteral(resourceName: "RainIcon")
        case .thunderstorm: return #imageLiteral(resourceName: "ThunderstormIcon")
        case .snow: return #imageLiteral(resourceName: "SnowIcon")
        case .mist: return #imageLiteral(resourceName: "CloudFogIcon")
        case .default: return #imageLiteral(resourceName: "ClearSkyIcon")
        }
    }
    
}

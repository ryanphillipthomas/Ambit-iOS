//
//  OpenWeatherMapError.swift
//  Weather Today
//
//  Created by Sebastián  Lara on 5/8/17.
//  Copyright © 2017 Sebastián  Lara. All rights reserved.
//

import Foundation

enum OpenWeatherMapError: Error {
    case requestFailed
    case responseUnsuccessful
    case invalidaData
    case jsonConversionFailure
    case invalidUrl
    case jsonParsingFailure
}

//
//  WeatherTodayViewController.swift
//  Weather Today
//
//  Created by Sebastián  Lara on 5/7/17.
//  Copyright © 2017 Sebastián  Lara. All rights reserved.
//

import UIKit
import CoreLocation

var currentWeatherViewModel: CurrentWeatherViewModel!

class WeatherTodayViewController: UIViewController {
    // MARK: - Properties
    
    @IBOutlet var weatherImageView: UIImageView!
    @IBOutlet var cityNameLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var weatherConditionLabel: UILabel!
    @IBOutlet var humidityLabel: UILabel!
    @IBOutlet var precipitationLabel: UILabel!
    @IBOutlet var pressureLabel: UILabel!
    @IBOutlet var windSpeedLabel: UILabel!
    @IBOutlet var windDirectionLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Today"
        
        // location manager setup
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
        setupActivityIndicator()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkPermissions()
    }
    
    // MARK: - View Methods
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        let sharedText = "\(currentWeatherViewModel.cityName!.uppercased())'s temperature ---> \(currentWeatherViewModel.temperature!)"
        let activityController = UIActivityViewController(activityItems: [sharedText, currentWeatherViewModel.icon!], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
    func checkPermissions() {
        Coordinate.checkForGrantedLocationPermissions() { [unowned self] allowed in
            if allowed {
                self.locationManager.requestLocation()
                self.getCurrentWeather()
            } else {
                self.showPermissionsScreen()
            }
        }
    }
    
    func showPermissionsScreen() {
        //DEV TODO
    }
    
    func getCurrentWeather() {
        //DEV TODO MAKE CALL AN BACKROUND QUE INSTEAD OF MAIN
        toggleRefreshAnimation(on: true)
        DispatchQueue.main.async {
            OpenWeatherMapAPIClient.client.getCurrentWeather(at: Coordinate.sharedInstance) {
                [unowned self] currentWeather, error in
                if let currentWeather = currentWeather {
                    currentWeatherViewModel = CurrentWeatherViewModel(model: currentWeather)
                    // update UI
                    self.displayWeather(using: currentWeatherViewModel)
                    // save weather
                    FirebaseDBProvider.Instance.saveCurrentWeather(currentWeather: currentWeatherViewModel)
                    self.toggleRefreshAnimation(on: false)
                }
            }
        }
    }
    
    func displayWeather(using viewModel: CurrentWeatherViewModel) {
        self.cityNameLabel.text = viewModel.cityName
        self.temperatureLabel.text = viewModel.temperature
        self.weatherConditionLabel.text = viewModel.weatherCondition
        self.humidityLabel.text = viewModel.humidity
        self.precipitationLabel.text = viewModel.precipitationProbability
        self.pressureLabel.text = viewModel.pressure
        self.windSpeedLabel.text = viewModel.windSpeed
        self.windDirectionLabel.text = viewModel.windDirection
        self.weatherImageView.image = viewModel.icon
    }
    
    func setupActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        view.addSubview(activityIndicator)
    }
    
    func toggleRefreshAnimation(on: Bool) {
        if on {
            activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
        } else {
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
}

extension WeatherTodayViewController: CLLocationManagerDelegate {
    // new location data is available
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        // update shaped instance
        Coordinate.sharedInstance.latitude = (manager.location?.coordinate.latitude)!
        Coordinate.sharedInstance.longitude = (manager.location?.coordinate.longitude)!
        // request current weather
        self.getCurrentWeather()
    }
    
    // the location manager was unable to retrieve a location value
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        Coordinate.checkForGrantedLocationPermissions() { allowed in
            if !allowed {
                self.showPermissionsScreen()
            }
        }
    }
}

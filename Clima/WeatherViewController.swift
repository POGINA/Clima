//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController,CLLocationManagerDelegate, changeCityDelegate{
    
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    //    my appid: 76a6e2b7d8d6aa9fca892689198fffb6
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherDescriptionTextField: UILabel!
    @IBOutlet weak var humidity: UIImageView!
    @IBOutlet weak var humidityTextField: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO:Set up the location manager here.
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url: String, parameters: [String : String]){
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
//                print("Success. Got the weather location")
                let json: JSON = JSON(response.result.value!)
                self.updateWeatherData(json:json)
                print(json)
            } else {
//                print("ERROR: \(String(describing: response.result.error))")
                debugPrint(response)
            }
            
        }
    }
    

    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json: JSON){
        
            if let tempResult = json["main"]["temp"].double {
//            weatherDataModel.temperature = Int(tempResult - 273.15)  // Celsius
            weatherDataModel.temperature = Int((tempResult - 273.15) * 9/5 + 32) //fahrenheit
                
            weatherDataModel.city = json["name"].stringValue
                
            weatherDataModel.condition = json["weather"][0]["id"].intValue
                
            weatherDataModel.weatherDescription = json["weather"][0]["description"].stringValue
                
            weatherDataModel.humidity = json["main"]["humidity"].intValue
            
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
                
            updateUIWithWeatherData()
                
            } else {
                cityLabel.text = "Weather Unavailable!"
        }
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData () {
        cityLabel.text = weatherDataModel.city
//        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        weatherDescriptionTextField.text = weatherDataModel.weatherDescription
        humidityTextField.text = "Humidity: \(weatherDataModel.humidity)"
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            print("Logitude \(location.coordinate.longitude)\n Latitude \(location.coordinate.latitude) ")
            
            let latilatude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let perams : [String : String] = ["lat":latilatude, "lon":longitude, "appid":APP_ID]
            getWeatherData(url: WEATHER_URL, parameters: perams)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        let params : [String:String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    
    //Write the PrepareForSegue Method here
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
    @IBAction func weatherSwitchButton(_ sender: UISwitch) {
        if(sender.isOn){
            temperatureLabel.text = "\(weatherDataModel.temperature)°"
        }
            
        else{
            let temperatureInCelsius = Double(weatherDataModel.temperature)
            let temperatureInFah : Int = Int((temperatureInCelsius - 32) / 1.8 )
            temperatureLabel.text = "\(temperatureInFah)°"
        }
        
    }
    
    
}



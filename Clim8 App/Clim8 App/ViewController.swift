//
//  ViewController.swift
//  Clim8 App
//
//  Created by Mohammed Azeem Azeez on 06/09/2018.
//  Copyright © 2018 Mohammed Azeem Azeez. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import KCFloatingActionButton
import SVProgressHUD
import Reachability

class ViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate, KCFloatingActionButtonDelegate {
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "49ce97bb1c064c0aae3a96edff6e2d00"
    //TODO: Declare instance variables here
    
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
  let reachability = Reachability()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.show()
        reachability.whenReachable = { reachability in
       
            if reachability.connection == .wifi {
               SVProgressHUD.dismiss()
                self.view.makeToast(message: "Internet Connected", duration: 3.0, position: HRToastPositionCenter as AnyObject, title: "Checking Internet Connection..")
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        }
        reachability.whenUnreachable = { _ in
            SVProgressHUD.dismiss()
            self.view.makeToast(message: "Something went wrong, please try again.", duration: 3.0, position: HRToastPositionCenter as AnyObject, title: "Checking Internet Connection..")
            print("Not reachable")
        }
        
        do {
            SVProgressHUD.dismiss()
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        //TODO:Set up the location manager here.
        
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url : String, parameters : [String : String]){
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                print("Success!!, Got Weather Data")
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
                print(weatherJSON)
            }
            else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Error"
            }
        }
    }
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json: JSON) {
        if  let tempResult = json["main"]["temp"].double {
            weatherDataModel.temperature = Int(tempResult - 273.15)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWithWeatherData()
        }
        else {
            cityLabel.text = "Weather Unavailable"
        }
    }
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData () {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named : weatherDataModel.weatherIconName)
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy  > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            print ("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            let longitude = String(location.coordinate.longitude)
            let latitude = String(location.coordinate.latitude)
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            getWeatherData(url : WEATHER_URL, parameters: params)
        }
        
    }
    
    
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        layoutFAB()
        
        
    }
    
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        //print(city)
        
        
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
            
        }
    }
    func layoutFAB() {
        let fab = KCFloatingActionButton()
        let item = KCFloatingActionButtonItem()
        item.buttonColor = UIColor(red: 188/255, green: 46/255, blue: 35/255, alpha: 1)
        item.circleShadowColor = UIColor.red
        item.titleShadowColor = UIColor(red: 188/255, green: 46/255, blue: 35/255, alpha: 0.5)
        item.title = "Custom item"
        item.handler = { item in
            
        }
        
        //fab.addItem(title: "I got a title")
        
        fab.addItem("Check City Clim8", icon: UIImage(named: "city.png")) { item in
            let ViewController:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let desVC = ViewController.instantiateViewController(withIdentifier: "ChangeCityViewController") as! ChangeCityViewController
            desVC.delegate = self
            SVProgressHUD.dismiss()
            self.present(desVC, animated: false, completion: nil)
            /* let alert = UIAlertController(title: "Become an Admin", message: "Send a request to be an admin and be able to write notices", preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "Send Request", style: .default, handler: nil))
             self.present(alert, animated: true, completion: nil)*/
        }
        fab.addItem("Share Clim8", icon: UIImage(named: "share.png")) { item in
            let shareText = "Clim8 App!"
            let loc = self.cityLabel.text!
            let temp = self.temperatureLabel.text!
            let clim = self.weatherIcon.image!
         let img = UIImage(named: "city")
            let activityViewController:UIActivityViewController = UIActivityViewController(activityItems:  [img!, shareText, loc, temp, clim], applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
            self.present(activityViewController, animated: true, completion: nil)
            SVProgressHUD.dismiss()
           /* let alert = UIAlertController(title: "Become an Admin", message: "Send a request to be an admin and be able to write notices", preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "Send Request", style: .default, handler: nil))
             self.present(alert, animated: true, completion: nil)*/
        }
        
       
        
        fab.fabDelegate = self
        
        self.view.addSubview(fab)
    }

}


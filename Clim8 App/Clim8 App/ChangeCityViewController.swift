//
//  ChangeCityViewController.swift
//  Clim8 App
//
//  Created by Mohammed Azeem Azeez on 06/09/2018.
//  Copyright © 2018 Mohammed Azeem Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD
import Reachability
protocol ChangeCityDelegate {
    func userEnteredANewCityName (city: String)
}

class ChangeCityViewController: UIViewController, UITextFieldDelegate {
let reachability = Reachability()!
 var delegate : ChangeCityDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.changeCityTextField.layer.borderColor = UIColor(red: 181.0 / 255.0, green: 181.0 / 255.0, blue: 181.0 / 255.0, alpha: 1.0).cgColor
        self.changeCityTextField.layer.borderWidth = 1.0
        self.changeCityTextField.layer.cornerRadius = 10.0
        self.changeCityTextField.borderStyle = UITextBorderStyle.roundedRect
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
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        // Do any additional setup after loading the view.
    }

    //This is the pre-linked IBOutlets to the text field:
    @IBOutlet weak var changeCityTextField: UITextField!
    
    
    //This is the IBAction that gets called when the user taps on the "Get Weather" button:
    @IBAction func getWeatherPressed(_ sender: AnyObject) {
        //1 Get the city name the user entered in the text field
        SVProgressHUD.show()
        let CityName = changeCityTextField.text!
        //2 If we have a delegate set, call the method userEnteredANewCityName
        
        delegate?.userEnteredANewCityName(city: CityName)
        //3 dismiss the Change City View Controller to go back to the WeatherViewController
        self.dismiss(animated: true, completion: nil)
        SVProgressHUD.dismiss()
    }
    

    @IBAction func backMain(_ sender: Any) {
        SVProgressHUD.show()
        self.dismiss(animated: true, completion: nil)
        SVProgressHUD.dismiss()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      changeCityTextField.resignFirstResponder()
       
        return (true)
    }
    

}

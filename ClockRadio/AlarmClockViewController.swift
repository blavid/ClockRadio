

import UIKit
import SwiftyJSON
import Alamofire
import CoreLocation

class AlarmClockViewController: UIViewController, WeatherModelDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var backgroundImageView: UIImageView!
    
    // Current Time and Date
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var amPmLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // Current Weather Conditions
    @IBOutlet weak var currentDescription: UILabel!
    @IBOutlet weak var currentBasics: UILabel!
    @IBOutlet weak var currentVisibility: UILabel!
    @IBOutlet weak var currentHumidity: UILabel!
    
    // Weather Forecast
    @IBOutlet weak var forecastBasics: UILabel!
    @IBOutlet weak var forecastName: UILabel!
    @IBOutlet weak var shortForecast: UILabel!
    @IBOutlet weak var detailedForecast: UILabel!
    
    @IBAction func playButton(_ button: UIButton) {
        if radio.isPlaying {
            radio.pause()
            button.setImage(#imageLiteral(resourceName: "play-button"), for: .normal)
        } else {
            radio.play()
            button.setImage(#imageLiteral(resourceName: "pause-button"), for: .normal)
        }
    }
    
    let model = WeatherModel.sharedInstance
    let locationManager = CLLocationManager()
    let radio = Radio.sharedInstance
    
    func dataIsReady() {
        updateCurrentConditionsUI()
        updateForecastUI()
        updateBackgroundImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        model.delegate = self
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        
        let weatherUpdateTimer = Timer.scheduledTimer(withTimeInterval: kWeatherRequestIntervalSeconds, repeats: true) { (_) in
            self.locationManager.startUpdatingLocation()
            self.model.fetchAllWeather()
        }
        weatherUpdateTimer.fire()
        
        let clockUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (_) in
            self.updateClockUI()
        }
        clockUpdateTimer.fire()
    }
    
    
    func updateClockUI() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US")
        let dateString = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "h:mm"
        let timeString = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "ss"
        let secondsString = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "a"
        let amPm = dateFormatter.string(from: date)
        
        timeLabel.text = timeString
        secondsLabel.text = secondsString
        amPmLabel.text = amPm
        dateLabel.text = dateString
    }
    
    func updateCurrentConditionsUI() {
        let shortDescription = model.currentConditions.description ?? ""
        currentDescription.text = shortDescription
//        let currentTemp = model.currentConditions.temperature?.description ?? ""
//        let windDir = model.currentConditions.windDirection ?? ""
//        let windSpeed = model.currentConditions.windSpeed?.description ?? ""
//        let basics = currentTemp + "° Wind: " + windDir + " " + windSpeed + " mph"
        currentBasics.text = model.currentConditions.shortDescription
        currentVisibility.text = model.currentConditions.visibility?.description ?? ""
        currentHumidity.text = model.currentConditions.relativeHumidity?.description ?? ""
    }
    
    func updateForecastUI() {
        forecastName.text = model.forecast.name ?? ""
        detailedForecast.text = model.forecast.detailedForecast ?? ""
        shortForecast.text = model.forecast.shortForecast ?? ""
        
//        let currentTemp = model.forecast.temperature?.description ?? ""
//        let windDir = model.forecast.windDirection ?? ""
//        let windSpeed = model.forecast.windSpeed?.description ?? ""
//        let basics = currentTemp + "° Wind: " + windDir + windSpeed
        forecastBasics.text = model.forecast.shortDescription
    }
    

    func updateBackgroundImage() {
        if let shortDescription = model.currentConditions.description?.lowercased() {
            let isDayTime = model.forecast.isDayTime ?? true
            
            
            switch (shortDescription, isDayTime) {
            case let (sd, daytime) where sd.contains("rain") && daytime:
                backgroundImageView.image = #imageLiteral(resourceName: "bg_rainyDay")
            case let (sd, daytime) where sd.contains("rain") && !daytime:
                backgroundImageView.image = #imageLiteral(resourceName: "bg_lightRain")
                
            case let (sd, daytime) where sd.contains("clear") && daytime:
                backgroundImageView.image = #imageLiteral(resourceName: "bg_clearDay")
            case let (sd, daytime) where sd.contains("clear") && !daytime:
                backgroundImageView.image = #imageLiteral(resourceName: "bg_clearNight")
                
            case let (sd, daytime) where sd.contains("snow") && daytime:
                backgroundImageView.image = #imageLiteral(resourceName: "bg_snowyDay")
            case let (sd, daytime) where sd.contains("snow") && !daytime:
                backgroundImageView.image = #imageLiteral(resourceName: "bg_snowyNight")
                
            case let (sd, daytime) where sd.contains("cloud") && daytime:
                backgroundImageView.image = #imageLiteral(resourceName: "bg_partlyCloudy")
            case let (sd, daytime) where sd.contains("cloud") && !daytime:
                backgroundImageView.image = #imageLiteral(resourceName: "bg_partlyCloudyNight")
                
            case let (sd, daytime) where sd.contains("thunder") && daytime:
                backgroundImageView.image = #imageLiteral(resourceName: "bg_lightningDay")
            case let (sd, daytime) where sd.contains("thunder") && !daytime:
                backgroundImageView.image = #imageLiteral(resourceName: "bg_lightningNight")
                
            case let (sd, daytime) where sd.contains("ice") && daytime:
                backgroundImageView.image = #imageLiteral(resourceName: "bg_snowyDay")
            case let (sd, daytime) where sd.contains("ice") && !daytime:
                backgroundImageView.image = #imageLiteral(resourceName: "bg_snowyNight")
                
            default:
                backgroundImageView.image = #imageLiteral(resourceName: "bg_clearDay")
            }
        }
    }
    
    // Core Location Stuff
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last
        model.latitude = currentLocation!.coordinate.latitude
        model.longitude = currentLocation!.coordinate.longitude
        model.fetchAllWeather()
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: Unable to determine location")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManager.startUpdatingLocation()
    }
    
}




import UIKit
import SwiftyJSON
import Alamofire

class AlarmClockViewController: UIViewController, WeatherModelDelegate {

    // Current Time and Date
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var amPmLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // Current Weather Conditions
    @IBOutlet weak var currentDescription: UILabel!
    @IBOutlet weak var currentTemp: UILabel!
    @IBOutlet weak var currentWindSpeed: UILabel!
    @IBOutlet weak var currentWindDirection: UILabel!
    @IBOutlet weak var currentWindGusts: UILabel!
    @IBOutlet weak var currentVisibility: UILabel!
    @IBOutlet weak var currentHumidity: UILabel!
    
    // Weather Forecast
    @IBOutlet weak var forecastTemperature: UILabel!
    @IBOutlet weak var forecastName: UILabel!
    @IBOutlet weak var forecastWindSpeed: UILabel!
    @IBOutlet weak var forecastWindDirection: UILabel!
    @IBOutlet weak var shortForecast: UILabel!
    @IBOutlet weak var detailedForecast: UILabel!
    
    
    let baseURL = "https://api.weather.gov/"
    let latitude = 45.522
    let longitude = -122.676
    let stationID = "KPDX"
    let model = WeatherModel.sharedInstance
    
 
    
    func dataIsReady() {
        updateCurrentConditionsUI()
        updateForecastUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.model.delegate = self
        model.fetchForecast()
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (_) in
            self.updateTimerUI()
        }
        timer.fire()
    }
    
    
    func updateTimerUI() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US")
        let dateString = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "h:mm:ss"
        let timeString = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "a"
        let amPm = dateFormatter.string(from: date)
        
        timeLabel.text = timeString
        amPmLabel.text = amPm
        dateLabel.text = dateString
    }
    
    func updateCurrentConditionsUI() {
        currentDescription.text = model.currentConditioins.description ?? ""
    }
    
    func updateForecastUI() {
        forecastName.text = model.forecast.name ?? ""
        forecastTemperature.text = model.forecast.temperature?.description
        forecastWindSpeed.text = model.forecast.windSpeed?.description
        forecastWindDirection.text = model.forecast.windDirection ?? ""
        detailedForecast.text = model.forecast.detailedForecast ?? ""
        shortForecast.text = model.forecast.shortForecast ?? ""
        
        let currentTemp = model.forecast.temperature?.description ?? ""
        let windDir = model.forecast.windDirection ?? ""
        let windSpeed = model.forecast.windSpeed?.description ?? ""
        let basics = currentTemp + "° Wind: " + windDir + windSpeed
        forecastTemperature.text = basics
    }
}


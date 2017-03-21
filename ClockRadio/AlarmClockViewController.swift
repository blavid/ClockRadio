

import UIKit

class AlarmClockViewController: UIViewController {
    
    // Current Time and Date
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var amPmLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // Current Weather Conditions
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
    
    
    var localWeatherStation: String? {
        willSet {
            getCurrentConditionsFromStation(newValue!)
            getForecastFromStation()
        }
    }
    var currentConditions = CurrentConditions()
    
    var forecast = Forecast()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (_) in
            self.updateUI()
        }
        timer.fire()
        fetchClosestWeatherStation()
    }
    
    
    func updateUI() {
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
    
    func fetchClosestWeatherStation() {
        guard let weatherStationsURL = URL(string: "\(baseURL)/points/\(latitude),\(longitude)/stations") else {
            print("Unable to build weather station URL")
            return
        }
        
        let forecastTask = URLSession.shared.dataTask(with: weatherStationsURL) { (data, response, error) in
            if error != nil {
                print("Error fetching weather data")
                return
            }
            do {
                if let dictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject] {
                    if let weatherStations = dictionary["observationStations"] as? [String] {
                        self.localWeatherStation = weatherStations[0]
                    }
                }
            } catch {
                print("Error parsing JSON")
                return
            }
        }
        forecastTask.resume()
    }
    
    func getForecastFromStation() {
        let forecastURL = URL(string: "\(baseURL)/points/\(latitude),\(longitude)/forecast")!

        let forecastTask = URLSession.shared.dataTask(with: forecastURL) { (data, response, error) in
            if error != nil {
                print("Error fetching weather data")
                return
            }
            do {
                if let dictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject] {
                    // Create the Forecast object
                    var currentForecast = Forecast()
                    if let forecastPeriods = dictionary["properties"]?["periods"] as? [[String:AnyObject]] {
                        if let nextForecast = forecastPeriods[0] as [String:AnyObject]? {
                            currentForecast.name = nextForecast["name"] as? String
                            currentForecast.number = nextForecast["number"] as? Int
                            currentForecast.windSpeed = nextForecast["windSpeed"] as? String
                            currentForecast.windDirection = nextForecast["windDirection"] as? String
                            currentForecast.shortForecast = nextForecast["shortForecast"] as? String
                            currentForecast.detailedForecast = nextForecast["detailedForecast"] as? String
                            currentForecast.isDayTime = nextForecast["isDayTime"] as? Bool
                            currentForecast.temperature = nextForecast["temperature"] as? Int
                        }
                    }
                    self.forecast = currentForecast
                }
            } catch {
                print("Error parsing JSON")
                return
            }
        }
        forecastTask.resume()
    }
    
    func getCurrentConditionsFromStation(_ station: String) {
        let currentConditionsURL = URL(string: "\(station)/observations/current")!
        let currentConditionsTask = URLSession.shared.dataTask(with: currentConditionsURL) { (data, response, error) in
            if error != nil {
                print("Error fetching weather data")
                return
            }
            do {
                if let dictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject] {
                    // Create the CurrentConditions object
                    self.currentConditions = CurrentConditions()
                    if let stationProperties = dictionary["properties"] as? [String:AnyObject] {
                        self.currentConditions.description = stationProperties["textDescription"] as! String?
                        self.currentConditions.temperature = stationProperties["temperature"]?["value"] as? Float
                        self.currentConditions.relativeHumidity = stationProperties["relativeHumidity"]?["value"] as? Float
                        self.currentConditions.windSpeed = stationProperties["windSpeed"]?["value"] as? Float
                        self.currentConditions.windGust = stationProperties["windGust"]?["value"] as? Float
                        self.currentConditions.windDirection = stationProperties["windDirection"]?["value"] as? Int
                        self.currentConditions.visibility = stationProperties["visibility"]?["value"] as? Int
                        
                        print("\(self.currentConditions)")
                        DispatchQueue.main.async {
                            self.updateWeatherConditions()
                        }
                    }
                }
            } catch {
                print("Error parsing JSON")
                return
            }
        }
        currentConditionsTask.resume()
        
    }
    
    func updateWeatherConditions() {
        let temp = currentConditions.temperature ?? 0
        currentTemp.text = "\(temp)"
    }
    
}


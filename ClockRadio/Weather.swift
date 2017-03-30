
struct CurrentConditions {
    var temperature: Int?
    var description: String?
    var windDirection: String?
    var windSpeed: Int?
    var windGust: Int?
    var visibility: Int?
    var relativeHumidity: Double?
    
    var shortDescription: String {
        get {
            // Either: 78° Wind: NNE 5 mph
            // or
            // 78° no wind
            // or
            // no data
            var desc = ""
            if let temp = temperature {
                desc = temp.description + "°"
            }
            if let windspd = windSpeed {
                if windspd < 2 {
                    desc = desc + " light winds"
                } else {
                    desc = desc + " \(windspd) mph"
                }
                
                if let winddir = windDirection {
                    desc = desc + " \(winddir)"
                }
            }
            
            //            currentTemp + "° Wind: " + windDir + " " + windSpeed + " mph"
            return desc
        }
    }
}

struct Forecast {
    var name: String?
    var isDayTime: Bool?
    var temperatureLabel: String?
    var temperature: String?
    var windSpeed: String?
    var windDirection: String?
    var hazard: String?
    var shortForecast: String?
    var detailedForecast: String?
    
    var shortDescription: String {
        get {
            // Either: 78° Wind: NNE 5 mph
            // or
            // 78° no wind
            // or
            // no data
            var desc = ""
            if let temp = temperature {
                desc = temp.description + "°"
            }
            desc = desc + (windSpeed ?? "No wind")
            
            if let winddir = windDirection {
                desc = desc + " \(winddir)"
            }
            return desc
        }
        set {
            
        }
    }
    
}

struct Weather {
    var currentBriefDescription: String?
    var currentTemperature: String?
    var currentRelativeHumidity: String?
    var currentWindSpeed: String?
    var currentWindGust: String?
    var currentWindDirection: String?
    var currentVisibility: String?
    var currentWindChill: String?
    var forecasts: [Forecast]?
    
    var shortDescription: String? {
        get {
            return "A short description of the current weather"
        }
    }
}

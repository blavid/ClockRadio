
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
                
            }
//            currentTemp + "° Wind: " + windDir + " " + windSpeed + " mph"
            return "Hello. I am a CurrentCondition"
        }
    }
}

struct Forecast {
    var name: String?
    var isDayTime: Bool?
    var temperature: Int?
    var windSpeed: String?
    var windDirection: String?
    var shortForecast: String?
    var detailedForecast: String?
    
    var shortDescription: String {
        get {
            return "Hello. I am a Forecast"
        }
    }

}

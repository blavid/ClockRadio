import Alamofire
import SwiftyJSON

protocol WeatherModelDelegate {
    func dataIsReady()
}

class WeatherModel {
    // prevent others from initing this class outside of the singlton
    private init() {}
    
    // The one-line singlton
    static let sharedInstance = WeatherModel()
    
    let baseWeatherUrl = "https://api.weather.gov/"
    let latitude = 45.522
    let longitude = -122.676
    let stationID = "KPDX"
    
    var closestWeatherStation = ""
    var currentConditioins = CurrentConditions()
    var forecast = Forecast()
    var delegate: WeatherModelDelegate?
    
    func fetchLocalWeatherStation() {
        
        let weatherStationsUrl = "\(baseWeatherUrl)/points/\(latitude),\(longitude)/stations"
        Alamofire.request(weatherStationsUrl)
        .responseJSON { response in
            if let responseValue = response.result.value {
                let json = JSON(responseValue)
                let closestWeatherStation = json["observationStations"][0].string ?? ""
                print(closestWeatherStation)
                self.closestWeatherStation = closestWeatherStation
            }
            
        }
    }
    
    func fetchCurrentConditionsFromStationUrl(_ stationURL: String) {
        let stationConditionsUrl = stationURL + "/observations/current"
        Alamofire.request(stationConditionsUrl)
        .responseJSON { (response) in
            var currentConditions = CurrentConditions()
            if let responseValue = response.result.value {
                let json = JSON(responseValue)
                currentConditions.temperature = json["properties"]["temperature"]["value"].float
                currentConditions.description = json["properties"]["textDescription"].string
                currentConditions.windDirection = json["properties"]["temperature"]["value"].int
                currentConditions.windSpeed = json["properties"]["windSpeed"]["value"].float
                currentConditions.windGust = json["properties"]["windGust"]["value"].float
                currentConditions.visibility = json["properties"]["visibility"]["value"].int
                currentConditions.relativeHumidity = json["properties"]["relativeHumidity"]["value"].float
                self.currentConditioins = currentConditions
                self.delegate?.dataIsReady()
            }
        }
    }
    
    func fetchForecast() {
        let forecastUrl = "\(baseWeatherUrl)/points/\(latitude),\(longitude)/forecast"
        Alamofire.request(forecastUrl)
            .responseJSON { (response) in
                var forecast = Forecast()
                if let responseValue = response.result.value {
                    let json = JSON(responseValue)
                    forecast.name = json["properties"]["periods"][0]["name"].string
                    forecast.temperature = json["properties"]["periods"][0]["temperature"].int
                    forecast.detailedForecast = json["properties"]["periods"][0]["detailedForecast"].string
                    forecast.windDirection = json["properties"]["periods"][0]["windDirection"].string
                    forecast.windSpeed = json["properties"]["periods"][0]["windSpeed"].string
                    forecast.shortForecast = json["properties"]["periods"][0]["shortForecast"].string
                    forecast.isDayTime = json["properties"]["periods"][0]["isDayTime"].bool
                    self.forecast = forecast
                    self.delegate?.dataIsReady()
                }
        }
    }
}

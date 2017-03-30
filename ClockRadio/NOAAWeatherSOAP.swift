import SwiftyJSON
import Alamofire
import CoreLocation


class NOAAWeatherSoap: NSObject {
    // prevent others from initing this class outside of the singlton
    private override init() {
        super.init()
    }
    
    // The one-line singlton
    static let sharedInstance = NOAAWeatherSoap()
    
    var weather = Weather()
    var delegate: WeatherModelDelegate?
    var geoManager = GeoManager.sharedInstance
    
    func fetchWeather() {
        // Truncate the latitude and longitude so that NWS doesn't choke on the long values
        let shortLatitude = String(format: "%.3f", geoManager.latitude!)
        let shortLongitude = String(format: "%.3f", geoManager.longitude!)
        let weatherStationsUrl = "\(kBaseWeatherUrlSOAP)lat=\(shortLatitude)&lon=\(shortLongitude)&FcstType=json"
        Alamofire.request(weatherStationsUrl)
            .responseJSON { response in
                if let responseValue = response.result.value {
                    let json = JSON(responseValue)
                    self.weather.currentTemperature = json["currentobservation"]["Temp"].string
                    self.weather.currentBriefDescription = json["currentobservation"]["Weather"].string
                    self.weather.currentVisibility = json["currentobservation"]["Visibility"].string
                    self.weather.currentWindDirection = json["currentobservation"]["Windd"].string
                    self.weather.currentWindSpeed = json["currentobservation"]["Winds"].string
                    self.weather.currentWindGust = json["currentobservation"]["Gust"].string
                    self.weather.currentWindChill = json["currentobservation"]["Windchill"].string
                    self.weather.currentRelativeHumidity = json["currentobservation"]["Relh"].string
                    let forecastNameArray = json["time"]["startPeriodName"].arrayValue
                    let forecastTempLabelArray = json["time"]["tempLabel"].arrayValue
                    let forecastTemperatureArray = json["data"]["temperature"].arrayValue
                    let forecastShortDescriptionArray = json["data"]["weather"].arrayValue
//                    let forecastHazardArray = json["data"]["hazard"].arrayValue
                    let forecastLongDescriptionArray = json["data"]["text"].arrayValue
                    
                    // Combine the arrays into a single array of Forecast
                    var forecastArray = [Forecast]()
                    for index in 0..<forecastNameArray.count {
                        var forecast = Forecast()
                        forecast.name = JSON(forecastNameArray).arrayObject?[index] as? String
                        forecast.shortForecast = JSON(forecastShortDescriptionArray).arrayObject?[index] as? String
                        forecast.temperatureLabel = JSON(forecastTempLabelArray).arrayObject?[index] as? String
                        forecast.temperature = JSON(forecastTemperatureArray).arrayObject?[index] as? String
                        forecast.detailedForecast = JSON(forecastLongDescriptionArray).arrayObject?[index] as? String
//                        forecast.hazard = JSON(forecastHazardArray).arrayObject?[index] as? String
                        forecastArray.append(forecast)
                    
                    }
                    self.weather.forecasts = forecastArray
                    self.delegate?.didRecieveForecast()
                }
        }

    }

}

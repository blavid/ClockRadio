import Alamofire
import SwiftyJSON
import CoreLocation

protocol WeatherModelDelegate {
    func didRecieveForecast()
    func didRecieveCurrentConditions()
}

class WeatherModel: NSObject {
    // prevent others from initing this class outside of the singlton
    private override init() {
        super.init()
    }
    
    // The one-line singlton
    static let sharedInstance = WeatherModel()
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    var closestWeatherStation = ""
    var currentConditions = CurrentConditions()
    var forecast = Forecast()
    var delegate: WeatherModelDelegate?
    var geoManager = GeoManager.sharedInstance
    
    func fetchAllWeatherForLatitude(_ latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        fetchLocalWeatherConditions()
    }
    
    private func fetchLocalWeatherConditions() {
        
        // Truncate the latitude and longitude so that NWS doesn't choke on the long values
        let shortLatitude = String(format: "%.3f", latitude)
        let shortLongitude = String(format: "%.3f", longitude)
        let weatherStationsUrl = "\(kBaseWeatherUrl)/points/\(shortLatitude),\(shortLongitude)/stations"
        Alamofire.request(weatherStationsUrl)
        .responseJSON { response in
            if let responseValue = response.result.value {
                let json = JSON(responseValue)
                let closestWeatherStation = json["observationStations"][0].string ?? ""
                self.closestWeatherStation = closestWeatherStation
                self.fetchCurrentConditionsFromStationUrl(closestWeatherStation)
                self.delegate?.didRecieveForecast()
                self.fetchForecast()

            }
            
        }
    }
    
    private func fetchCurrentConditionsFromStationUrl(_ stationURL: String) {
        let stationConditionsUrl = stationURL + "/observations/current"
        Alamofire.request(stationConditionsUrl)
        .responseJSON { (response) in
            var currentConditions = CurrentConditions()
            if let responseValue = response.result.value {
                let json = JSON(responseValue)
                let tempC = json["properties"]["temperature"]["value"].double ?? 0
                currentConditions.temperature = self.convertCtoF(tempC)
                currentConditions.description = json["properties"]["textDescription"].string
                let windDirectionDegrees = json["properties"]["windDirection"]["value"].double ?? 0
                currentConditions.windDirection = self.cardinalDirectionFromDegree(windDirectionDegrees)
                let windSpeedMeters = json["properties"]["windSpeed"]["value"].double ?? 0
                currentConditions.windSpeed = self.convertKilometerstoMiles(windSpeedMeters)
                let windGustMeters = json["properties"]["windGust"]["value"].double ?? 0
                currentConditions.windGust = self.convertKilometerstoMiles(windGustMeters)
                let visibilityMeters = json["properties"]["visibility"]["value"].int ?? 0
                currentConditions.visibility = self.convertKilometerstoMiles(Double(visibilityMeters))
                currentConditions.relativeHumidity = json["properties"]["relativeHumidity"]["value"].double
                self.currentConditions = currentConditions
                self.delegate?.didRecieveCurrentConditions()
            }
        }
    }
    
    private func fetchForecast() {
        
        // Truncate the latitude and longitude so that NWS doesn't choke on the long values
        let shortLatitude = String(format: "%.3f", latitude)
        let shortLongitude = String(format: "%.3f", longitude)
        let forecastUrl = "\(kBaseWeatherUrl)points/\(shortLatitude),\(shortLongitude)/forecast"
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
                    self.delegate?.didRecieveForecast()
                }
        }
    }
    
    private func cardinalDirectionFromDegree(_ degree: Double) -> String {
        // How many degrees contained in each cardinal direction
        let inc = 22.5
        
        // Where to start counting
        let base = 11.25
        
        switch degree {
        case let x where ( x > 360 - base && x <= 360 ) || (x >= 0 && x <= base ):
            return "N"
        case let x where x > base && x <= base + (inc * 1):
            return "NNE"
        case let x where x > base + (inc * 1) && x <= base + (inc * 2):
            return "NE"
        case let x where x > base + (inc * 2) && x <= base + (inc * 3):
            return "ENE"
        case let x where x > base + (inc * 3) && x <= base + (inc * 4):
            return "E"
        case let x where x > base + (inc * 4) && x <= base + (inc * 5):
            return "ESE"
        case let x where x > base + (inc * 5) && x <= base + (inc * 6):
            return "SE"
        case let x where x > base + (inc * 6) && x <= base + (inc * 7):
            return "SSE"
        case let x where x > base + (inc * 7) && x <= base + (inc * 8):
            return "S"
        case let x where x > base + (inc * 8) && x <= base + (inc * 9):
            return "SSW"
        case let x where x > base + (inc * 9) && x <= base + (inc * 10):
            return "SW"
        case let x where x > base + (inc * 10) && x <= base + (inc * 11):
            return "WSW"
        case let x where x > base + (inc * 11) && x <= base + (inc * 12):
            return "W"
        case let x where x > base + (inc * 12) && x <= base + (inc * 13):
            return "WNW"
        case let x where x > base + (inc * 13) && x <= base + (inc * 14):
            return "NW"
        case let x where x > base + (inc * 14) && x <= base + (inc * 15):
            return "NNW"
        default:
            return "Unknown"
        }
    }
    
    private func convertFtoC(_ degreesF: Double) -> Int {
        return Int((degreesF - 32) * 5 / 9)
    }
    
    private func convertCtoF(_ degreesC: Double) -> Int {
        return Int((degreesC * 9 / 5) + 32)
    }
    
    private func convertKilometerstoMiles(_ kilometers: Double) -> Int {
        return Int(kilometers * 0.621371)
    }
    
    private func convertMilestoKilometers(_ miles: Double) -> Int {
        return Int(miles * 1.60934)
    }

}

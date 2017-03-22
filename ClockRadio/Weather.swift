
struct CurrentConditions {
    var temperature: Int?
    var description: String?
    var windDirection: String?
    var windSpeed: Int?
    var windGust: Int?
    var visibility: Int?
    var relativeHumidity: Double?
}

struct Forecast {
    var name: String?
    var isDayTime: Bool?
    var temperature: Int?
    var windSpeed: String?
    var windDirection: String?
    var shortForecast: String?
    var detailedForecast: String?

}

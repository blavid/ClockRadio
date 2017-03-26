// GeoManager class
//
// Gets location from CoreLocation
// Identifies city, state, zip, etc.
import CoreLocation

protocol GeoManagerDelegate {
    func didUpdateLocation()
}

class GeoManager: NSObject, CLLocationManagerDelegate {
    
    var latitude: Double?
    var longitude: Double?
    var name: String?
    var addressDictionary: String?
    var isoCountryCode: String?
    var country: String?
    var postalCode: String?
    var administrativeArea: String?
    var subAdministrativeArea: String?
    var locality: String?
    var subLocality: String?
    var thoroughfare: String?
    var subThoroughfare: String?
    var region: String?
    var timeZone: String?
    let locationManager = CLLocationManager()
    var delegate: GeoManagerDelegate?
    let geoCoder = CLGeocoder()
    
    // prevent others from initing this class outside of the singlton
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // The one-line singlton
    static let sharedInstance = GeoManager()
    
    func locate() {
        locationManager.startUpdatingLocation()
    }
    
    // CLLocation Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last
        geoCoder.reverseGeocodeLocation(currentLocation!) { (placemarks: [CLPlacemark]?, error:Error?) in
            if error != nil {
                print("Error looking up address of geo location.")
                return
            } else {
                if (placemarks?.count)! > 0 {
                    let placemark = placemarks?.last
                    self.name = placemark?.name?.description
                    self.addressDictionary = placemark?.addressDictionary?.description
                    self.isoCountryCode = placemark?.isoCountryCode?.description
                    self.country = placemark?.country?.description
                    self.postalCode = placemark?.postalCode?.description
                    self.administrativeArea = placemark?.administrativeArea?.description
                    self.subAdministrativeArea = placemark?.subAdministrativeArea?.description
                    self.locality = placemark?.locality?.description
                    self.subLocality = placemark?.subLocality?.description
                    self.thoroughfare = placemark?.thoroughfare?.description
                    self.subThoroughfare = placemark?.subThoroughfare?.description
                    self.region = placemark?.region?.description
                    self.timeZone = placemark?.timeZone?.description
                    self.latitude = currentLocation?.coordinate.latitude
                    self.longitude = currentLocation?.coordinate.longitude
                    self.delegate?.didUpdateLocation()
                }
            }
        }
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: Unable to determine location")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManager.startUpdatingLocation()
    }
    
    
    
}

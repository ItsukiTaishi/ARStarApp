import SwiftUI
import CoreLocation
import SwiftAA

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var latitude: Double?
    @Published var longitude: Double?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let loc = locations.last else { return }
//        latitude = loc.coordinate.latitude
//        longitude = loc.coordinate.longitude
//    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        
        DispatchQueue.main.async {
            self.latitude = loc.coordinate.latitude
            self.longitude = loc.coordinate.longitude
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置情報取得失敗: \(error.localizedDescription)")
    }
    
    // SwiftAA の計算
    func moonPosition() -> (altitude: Double, azimuthSouth: Double, azimuthNorth: Double)? {
        guard let lat = latitude, let lon = longitude else { return nil }
        let geo = GeographicCoordinates(
            positivelyWestwardLongitude: -(lon).degrees,
            latitude: (lat).degrees
        )
        let now = Date()
        let jd = now.julianDay
        let moon = Moon(julianDay: jd)
        let horizontal = moon.apparentEquatorialCoordinates.makeHorizontalCoordinates(for: geo, at: jd)
        return (horizontal.altitude.value, horizontal.azimuth.value, horizontal.northBasedAzimuth.value)
    }
    
    func starPosition(ra: String, dec: String) -> (altitude: Double, azimuthSouth: Double, azimuthNorth: Double)? {
        guard let lat = latitude, let lon = longitude else { return nil }
        
        let userLocation = GeographicCoordinates(
            positivelyWestwardLongitude: -lon.degrees,
            latitude: lat.degrees
        )
        
        guard let raHour = ra.toHour(), let decDeg = dec.toDegree() else { return nil }
        
        let starCoordinates = EquatorialCoordinates(rightAscension: raHour, declination: decDeg)
        
        let now = Date()
        let jd = now.julianDay
        
//        let star = Object(
//            name: "Star",
//            coordinates: starCoordinates,
//            julianDay: jd
//        )
        
        let horizontal = starCoordinates.makeHorizontalCoordinates(for: userLocation, at: jd)
        return (horizontal.altitude.value, horizontal.azimuth.value, horizontal.northBasedAzimuth.value)
    }

    
}

extension String {
    // "±dd:mm:ss" → Degree
    func toDegree() -> Degree? {
        let parts = self.split(separator: " ").compactMap { Double($0) }
        guard parts.count == 3 else { return nil }
        
        let sign: FloatingPointSign = self.first == "-" ? .minus : .plus
        
        // parts[0]が負の値を持つ場合を考慮し、絶対値(abs)を取る
        let degrees = Int(abs(parts[0]))
        let minutes = Int(parts[1])
        let seconds = parts[2]
        
        return Degree(sign, degrees, minutes, seconds)
    }

    // "hh:mm:ss" → Hour
    func toHour() -> Hour? {
        let parts = self.split(separator: " ").compactMap { Double($0) }
        guard parts.count == 3 else { return nil }
        
        let sign: FloatingPointSign = self.first == "-" ? .minus : .plus
        // 赤経(RA)は常に正の値なので、符号は不要
        let hours = Int(parts[0])
        let minutes = Int(parts[1])
        let seconds = parts[2]
        
        // Hourのイニシャライザは (時間, 分, 秒) の3つの引数を取る
        return Hour(sign,hours, minutes, seconds)
    }
}


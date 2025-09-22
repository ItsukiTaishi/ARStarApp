import Foundation
import CoreMotion

class CoreMotionModel: ObservableObject {
    let motionManager: CMMotionManager!
    
    // attitudeの値を格納するプロパティ
    
    @Published var pitch: Double = 0.0
    
//    @Published var verticalAngle: Double = 0.0
    @Published var signedVerticalAngle: Double = 0.0
    
    init() {
        motionManager = CMMotionManager()
        if motionManager.isDeviceMotionAvailable {
                motionManager.showsDeviceMovementDisplay = true // キャリブレーションUIを有効化
            }
    }

    func start() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.005
            motionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical, to: .main) { data, error in
                guard let data else { return }
                
                
                self.pitch = data.attitude.pitch
                
                // 重力ベクトルを使った角度の計算
                let gravity = data.gravity
                // デバイスの上部(Y軸)と重力ベクトルのなす角度を計算
                let angle = atan2(gravity.y, gravity.z) // 戻り値はラジアン
                let angleDeg = angle * 180 / .pi
                self.signedVerticalAngle = angleDeg + 90 // ラジアンを度に変換
            }
        }
    }
    func reset() {
        self.stop()
        // 0.1秒後に再度開始する
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.start()
        }
    }

    func stop() {
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
    }
}


//磁場から取得した方位
class HeadingManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var heading: Double = 0.0

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // 真北基準の方位（度）
        heading = newHeading.trueHeading
    }
}


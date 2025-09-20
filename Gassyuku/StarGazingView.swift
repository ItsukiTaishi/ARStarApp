import SwiftUI

struct StarGazingView: View {
    // 3つのViewModelをインスタンス化
    @StateObject private var motionModel = CoreMotionModel()
    @StateObject private var headingManager = HeadingManager()
    @StateObject private var locationViewModel = LocationViewModel()

    // 表示したい天体の赤経・赤緯（例：おおいぬ座のシリウス）
    let targetStarRA = "06:45:08.9"
    let targetStarDEC = "-16:42:58"
    
    // デバイスの視野角（仮）
    let horizontalFOV: Double = 60.0 // 水平視野角を60度と仮定

    var body: some View {
        GeometryReader { geometry in
            
            ZStack {
                
                    
                // ここにカメラのプレビュー画面などを背景として表示すると、よりARらしくなります
                 Color.black.edgesIgnoringSafeArea(.all)
                    

                // 位置情報が取得できたら星を表示
                if let starPosition = locationViewModel.starPosition(ra: targetStarRA, dec: targetStarDEC) {
                    
                    // 1. 天体とデバイスの向きの差を計算
                    //    正規化して-180° ~ +180°の範囲に収める
                    let azimuthDifference = normalizeAngle(starPosition.azimuthNorth - headingManager.heading)
                    let altitudeDifference = starPosition.altitude - motionModel.signedVerticalAngle
                    
                    // 2. 差分を画面上のオフセットに変換
                    //    水平方向：視野角と画面幅を使って計算
                    let screenX = geometry.size.width / 2 + CGFloat(azimuthDifference / (horizontalFOV / 2)) * (geometry.size.width / 2)
                    
                    //    垂直方向：Y軸は上がマイナスなので符号を反転
                    let screenY = geometry.size.height / 2 - CGFloat(altitudeDifference / (horizontalFOV / 2)) * (geometry.size.width / 2)
                    
                    // 画面内に収まっているかチェック
                    if abs(azimuthDifference) < horizontalFOV / 2 {
                        // 3. 計算した位置に天体を描画
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 15, height: 15)
                            .position(x: screenX, y: screenY)

                        Text("シリウス")
                            .foregroundColor(.white)
                            .font(.caption)
                            .position(x: screenX, y: screenY + 20)
                    }
                } else {
                    Text("位置情報を取得中...")
                        .foregroundColor(.black)
                }
            }
        }
        .onAppear {
            // センサーの更新を開始
            motionModel.start()
        }
        .onDisappear {
            // センサーを停止
            motionModel.stop()
        }
    }
    
    // 角度を-180°から+180°の間に正規化する関数
    private func normalizeAngle(_ angle: Double) -> Double {
        var result = angle.truncatingRemainder(dividingBy: 360)
        if result < -180 {
            result += 360
        } else if result > 180 {
            result -= 360
        }
        return result
    }
}

#Preview {
    StarGazingView()
}


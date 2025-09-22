import SwiftUI

struct StarGazingView: View {
    // 3つのViewModelをインスタンス化
    @StateObject private var motionModel = CoreMotionModel()
    @StateObject private var headingManager = HeadingManager()
    @StateObject private var locationViewModel = LocationViewModel()
    @EnvironmentObject var gameCenterManager: GameCenterManager
    @State private var opponentSelectedIndex: Int?
    @State private var ArrowAngle = Angle(degrees: 0.0)
    
    @Binding var stars: [Star]
    
    // デバイスの視野角（仮）
    let horizontalFOV: Double = 60.0 // 水平視野角を60度と仮定
    let verticalFOV: Double = 45.0
    
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                
                
                
                ZStack(alignment: .topTrailing){
                    VStack{
                        NavigationLink{MatchmakingView()}label:{
                            // リンクの見た目（テキストやアイコン）
                            Image(systemName: "person.line.dotted.person.fill")
                            
                        }
                        .font(.system(size: 25))
                        .frame(width: 50, height: 30)
                        .foregroundStyle(.white)
                        
                        Spacer()
                        
                        Image(systemName: "arrowshape.up.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(Circle().foregroundStyle(.yellow)
                            )
                            .padding(20)
                            .rotationEffect(ArrowAngle)
                            
                    }
                    .zIndex(2)
//
//                    VStack{
//                        Text("\(motionModel.signedVerticalAngle)")
//                        Text("\(motionModel.pitch)")
//                        Text("\(headingManager.heading)")
//                    }
//                    .foregroundStyle(.white)
//                    .zIndex(1)
                    // ここにカメラのプレビュー画面などを背景として表示すると、よりARらしくなります
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    ForEach(Array(stars.enumerated()), id: \.offset){index ,star in
                        if let starPosition = locationViewModel.starPosition(ra: star.ra, dec: star.dec) {
                            
                            
                            
                            // 1. 天体とデバイスの向きの差を計算
                            //    正規化して-180° ~ +180°の範囲に収める
                            let azimuthDifference = normalizeAngle(starPosition.azimuthNorth - headingManager.heading)
                            let altitudeDifference = starPosition.altitude - motionModel.signedVerticalAngle
                            
                            // 2. 差分を画面上のオフセットに変換
                            
                            //    水平方向：視野角と画面幅を使って計算
                            let screenX = geometry.size.width / 2 + CGFloat(azimuthDifference / (horizontalFOV / 2)) * (geometry.size.width / 2)
                            
                            //    垂直方向：Y軸は上がマイナスなので符号を反転
                            let screenY = geometry.size.height / 2 - CGFloat(altitudeDifference / (verticalFOV / 2)) * (geometry.size.height / 2)
                            
                            // 画面内に収まっているかチェック
                            if abs(azimuthDifference) < horizontalFOV / 2 && abs(altitudeDifference) < verticalFOV / 2 {
                                // 3. 計算した位置に天体を描画
                                Button{
                                    stars[index].collectStar = true
                                    gameCenterManager.sendIndex(index)
                                }label:{
                                    StarView(star: star)
                                        
                                }
                                .position(x:screenX, y:screenY)
                                
                            }
                        } else {
                            Text("位置情報を取得中...")
                                .foregroundColor(.black)
                        }
                        
                        
                    }
                    // 位置情報が取得できたら星を表示
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
            .onReceive(gameCenterManager.$lastReceivedAction) { receivedAction in
                        // 受け取ったアクションがインデックス選択の場合、UIを更新
                        if let action = receivedAction, action.action == .selectIndex {
                            self.opponentSelectedIndex = action.selectedIndex
                        }
                    }
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
    // プレビュー用のコンテナView
   ContentView()
}

import SwiftUI
import GameKit

struct MatchmakingView: View {
    // GameCenterManagerをビューの状態として管理
    @EnvironmentObject var gameCenterManager: GameCenterManager
    
    // UIの状態を管理するためのローカル変数
    @State private var isMatchmaking = false // マッチング検索中かどうか
    

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 1. ログイン状態の表示
                Text(gameCenterManager.isAuthenticated ? "ログイン済み" : "未ログイン")
                    .font(.headline)
                    .foregroundColor(gameCenterManager.isAuthenticated ? .green : .red)
                
                Spacer()
                
                // 2. 状況に応じたUIの切り替え
                if gameCenterManager.currentMatch != nil {
                    // --- ケースA: マッチが成立している場合 ---
                    inGameView
                    
                } else if isMatchmaking {
                    // --- ケースB: マッチング検索中の場合 ---
                    matchmakingInProgressView
                    
                } else if !gameCenterManager.isAuthenticated{
                    Button("Game Centerにログイン") {
                        gameCenterManager.authenticatePlayer()
                    }
                    
                }else  {
                    
                    idleView
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Game Center対戦")
            .onAppear {
                // 画面が表示されたら、自動で認証処理を試みる
                gameCenterManager.authenticatePlayer()
            }
            // gameCenterManagerの状態変更を監視
            .onReceive(gameCenterManager.$currentMatch) { match in
                // マッチが成立 or 解消されたら、検索中フラグをリセット
                if match != nil || isMatchmaking {
                    isMatchmaking = false
                }
            }
            
        }
    }

    // MARK: - Subviews

    /// ケースA: マッチが成立している（ゲーム中）のビュー
    private var inGameView: some View {
        VStack(spacing: 20) {
            Image(systemName: "gamecontroller.fill")
                .font(.largeTitle)
                .foregroundColor(.blue)
            
            Text("対戦が成立しました！")
                .font(.title2)
            
            // 接続しているプレイヤー名を表示
            Text("相手: \(gameCenterManager.currentMatch?.players.first?.displayName ?? "不明なプレイヤー")")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // 【要件】マッチ解消ボタン
            Button(action: {
                gameCenterManager.disconnectFromMatch()
            }) {
                Text("マッチを解消する")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
    
    /// ケースB: マッチング検索中のビュー
    private var matchmakingInProgressView: some View {
        VStack(spacing: 20) {
            Text("対戦相手を探しています...")
                .font(.title2)
            
            ProgressView() // くるくるインジケーター
                .scaleEffect(1.5)
            
            // 【要件】マッチングキャンセルボタン
            Button(action: {
//                gameCenterManager.cancelMatchmaking()
                isMatchmaking = false // UIの状態を即時更新
            }) {
                Text("キャンセル")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
    
    /// ケースC: アイドル状態のビュー
    private var idleView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.wave.2.fill")
                .font(.largeTitle)
                .foregroundColor(.indigo)
            
            Text("対戦相手を探しましょう")
                .font(.title2)
            
            if gameCenterManager.isAuthenticated {
                // 【要件】マッチング開始ボタン
                Button(action: {
                    gameCenterManager.startMatchmaking()
                    isMatchmaking = true // UIを検索中状態に切り替え
                }) {
                    Text("ランダムマッチを開始")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                // (オプション) フレンド招待ボタン
                Button(action: {
                    // gameCenterManager.startFriendMatch() を呼び出す
                }) {
                    Text("フレンドを招待")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            } else {
                // 未ログイン時の表示
                Text("Game Centerにログインしてください。")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Preview
struct MatchmakingView_Previews: PreviewProvider {
    
    static var previews: some View {
        MatchmakingView()
    }
}

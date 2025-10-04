import GameKit
import SwiftUI

// NSObjectを継承してObservableObjectに準拠
class GameCenterManager: NSObject, ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentMatch: GKMatch?
    @Published var lastReceivedAction: PlayerAction?
    
    func authenticatePlayer() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if viewController != nil {
                // 認証画面を表示
                return
            }
            if error != nil {
                print("認証エラー: \(error?.localizedDescription ?? "")")
                return
            }
            self.isAuthenticated = GKLocalPlayer.local.isAuthenticated
        }
    }
}

extension GameCenterManager {
    func startMatchmaking() {
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        request.playerGroup = 4130
        
        GKMatchmaker.shared().findMatch(for: request) { match, error in
            if let error = error {
                print("マッチメイキングエラー: \(error.localizedDescription)")
                return
            }
            self.currentMatch = match
            self.setupMatchHandlers()
        }
    }
}
extension GameCenterManager {
    /// 現在の対戦から切断する関数
        func disconnectFromMatch() {
            // currentMatchが存在するか安全に確認
            guard let match = currentMatch else { return }
            
            // 1. マッチから切断する
            match.disconnect()
            
            // 2. 自分の状態をリセットする
            // これにより、UIが自動的に待機画面に戻る
            DispatchQueue.main.async {
                self.currentMatch = nil
            }
            
            print("マッチから切断しました。")
        }
}



extension GameCenterManager {
    func setupMatchHandlers() {
        currentMatch?.delegate = self
    }
    
    func sendData<T: Codable>(_ data: T) {
        guard let match = currentMatch else {
            print("マッチしているユーザーが存在しません")
            return
        
        }
        
        do {
            let jsonData = try JSONEncoder().encode(data)
            try match.sendData(toAllPlayers: jsonData, with: .reliable)
        } catch {
            print("データ送信エラー: \(error)")
        }
    }
}

// NSObjectを継承しているためGKMatchDelegateに準拠可能
extension GameCenterManager: GKMatchDelegate {
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        // 受信したデータを処理
        handleReceivedData(data)
    }
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        // プレイヤー接続状態の変更を処理
        print("プレイヤー \(player.displayName) の状態が変更されました: \(state.rawValue)")
    }
}

extension GameCenterManager {
    
    func sendIndex(_ index: Int) {
        let playerId = GKLocalPlayer.local.gamePlayerID
        
        let action = PlayerAction(
            playerId: playerId, action: .selectIndex, position: nil, selectedIndex: index
        )
        broadcastPlayerAction(action)
        print("インデックス \(index) を送信しました。")
    }
    
    func broadcastPlayerAction(_ action: PlayerAction) {
        sendData(action)
    }
    
    private func handleReceivedData(_ data: Data) {
        do {
            let action = try JSONDecoder().decode(PlayerAction.self, from: data)
            DispatchQueue.main.async {
                self.processPlayerAction(action)
            }
        } catch {
            print("データデコードエラー: \(error)")
        }
    }
    
    private func processPlayerAction(_ action: PlayerAction) {
            // UIを更新するためにPublishedプロパティを変更
            self.lastReceivedAction = action
            
            // switch文でアクションの種類によって処理を分岐
            switch action.action {
            case .selectIndex:
                if let index = action.selectedIndex {
                    print("プレイヤー \(action.playerId) がインデックス \(index) を選択しました。")
                    // ここで、相手がインデックスを選択した時のゲームロジックを実行する
                }
            case .move:
                print("プレイヤーが移動しました。")
                // 移動処理
            default:
                print("その他のアクションを受信しました。")
            }
        }
}



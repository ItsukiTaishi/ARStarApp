import Foundation

struct GameData: Codable {
    var playerPositions: [String: CGPoint] = [:]
    var gameState: GameState = .waiting
    var timestamp: Date = Date()
}

enum GameState: String, Codable {
    case waiting, playing, finished
}

struct PlayerAction: Codable {
    let playerId: String
    let action: ActionType
    let position: CGPoint?
    let selectedIndex: Int?
    var timestamp: Date = Date()
}

enum ActionType: String, Codable {
    case move, shoot, jump
    case selectIndex
}

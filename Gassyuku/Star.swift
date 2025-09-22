import Foundation

struct Star: Identifiable, Decodable , Hashable{
    // Identifiableに準拠させるため、ユニークなIDプロパティを用意します。
    // この場合、星の名前(name)がユニークであると仮定します。
    var id: String { name }

    let name: String
    let ra: String
    let dec: String
    let vmag: Double
    var collectStar : Bool = false

    // CSVのヘッダーとプロパティ名をマッピングします。
    private enum CodingKeys: String, CodingKey {
        case name
        case ra
        case dec
        case vmag
    }
}



import Foundation

class StarLoader: ObservableObject {
    @Published var stars = [Star]()

    init() {
        load()
    }

    func load() {
        // 1. ファイルのURLを取得
        guard let url = Bundle.main.url(forResource: "hipos", withExtension: "csv") else {
            fatalError("CSVファイルが見つかりません。")
        }

        do {
            // 2. ファイルの内容を文字列として読み込み
            let data = try Data(contentsOf: url)
            let csvString = String(data: data, encoding: .utf8)!

            // 3. 行ごとに分割し、ヘッダー行をスキップ
            let lines = csvString.components(separatedBy: .newlines)
            let dataRows = lines.dropFirst().filter { !$0.isEmpty } // ヘッダー行を削除し、空行も無視

            var tempStars = [Star]()
            for row in dataRows {
                let columns = row.components(separatedBy: ",")
                if columns.count == 4 {
                    // 4. 各行のデータをStarオブジェクトに変換
                    let name = columns[0]
                    let ra = columns[1]
                    let dec = columns[2]
                    let vmag = Double(columns[3]) ?? 0.0

                    let star = Star(name: name, ra: ra, dec: dec, vmag: vmag)
                    tempStars.append(star)
                }
            }
            // 5. データを@Publishedプロパティにセット
            self.stars = tempStars

        } catch {
            fatalError("CSVファイルの読み込みに失敗しました: \(error)")
        }
    }
}

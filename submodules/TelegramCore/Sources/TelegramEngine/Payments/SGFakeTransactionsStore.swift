import Foundation

public struct SGFakeTransaction: Codable {
    public let id: String
    public let amount: Int64
    public let date: Int32
    public let isTon: Bool
    public let isGift: Bool
    public let title: String?

    public init(id: String, amount: Int64, date: Int32, isTon: Bool, isGift: Bool, title: String?) {
        self.id = id
        self.amount = amount
        self.date = date
        self.isTon = isTon
        self.isGift = isGift
        self.title = title
    }
}

public final class SGFakeTransactionsStore {
    private static let defaultsKey = "sgFakeTransactionsV1"

    private static var defaults: UserDefaults {
        return UserDefaults.standard
    }

    public static func transactions(isTon: Bool) -> [SGFakeTransaction] {
        guard let data = defaults.data(forKey: defaultsKey) else {
            return []
        }
        guard let all = try? JSONDecoder().decode([SGFakeTransaction].self, from: data) else {
            return []
        }
        return all.filter { $0.isTon == isTon }
    }

    public static func add(_ transaction: SGFakeTransaction) {
        var all: [SGFakeTransaction] = []
        if let data = defaults.data(forKey: defaultsKey), let decoded = try? JSONDecoder().decode([SGFakeTransaction].self, from: data) {
            all = decoded
        }
        all.insert(transaction, at: 0)
        if let encoded = try? JSONEncoder().encode(all) {
            defaults.set(encoded, forKey: defaultsKey)
        }
    }

    public static func removeAll() {
        defaults.removeObject(forKey: defaultsKey)
    }
}

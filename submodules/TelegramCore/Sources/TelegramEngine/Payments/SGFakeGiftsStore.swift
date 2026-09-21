import Foundation
import Postbox

public final class SGFakeGiftsStore {
    private static let defaultsKey = "sgFakeSentGiftsV1"

    private static var defaults: UserDefaults {
        return UserDefaults.standard
    }

    public static func hasGifts(forPeerId peerId: Int64) -> Bool {
        guard let map = defaults.dictionary(forKey: defaultsKey) as? [String: String] else {
            return false
        }
        return map["\(peerId)"] != nil
    }

    static func gifts(forPeerId peerId: Int64) -> [ProfileGiftsContext.State.StarGift] {
        guard let map = defaults.dictionary(forKey: defaultsKey) as? [String: String] else {
            return []
        }
        guard let base64 = map["\(peerId)"], let data = Data(base64Encoded: base64) else {
            return []
        }
        return CodableEntry(data: data).get([ProfileGiftsContext.State.StarGift].self) ?? []
    }

    static func add(gift: ProfileGiftsContext.State.StarGift, forPeerId peerId: Int64) {
        var current = self.gifts(forPeerId: peerId)
        current.insert(gift, at: 0)
        self.store(current, forPeerId: peerId)
    }

    static func removeAll(forPeerId peerId: Int64) {
        var map = (defaults.dictionary(forKey: defaultsKey) as? [String: String]) ?? [:]
        map["\(peerId)"] = nil
        defaults.set(map, forKey: defaultsKey)
    }

    private static func store(_ gifts: [ProfileGiftsContext.State.StarGift], forPeerId peerId: Int64) {
        var map = (defaults.dictionary(forKey: defaultsKey) as? [String: String]) ?? [:]
        if let entry = CodableEntry(gifts) {
            map["\(peerId)"] = entry.data.base64EncodedString()
        }
        defaults.set(map, forKey: defaultsKey)
    }
}

import Foundation
import Postbox

public class SGDeletedMessageAttribute: MessageAttribute {
    public let deletionTimestamp: Int32
    public let wasOutgoing: Bool

    public init(deletionTimestamp: Int32, wasOutgoing: Bool) {
        self.deletionTimestamp = deletionTimestamp
        self.wasOutgoing = wasOutgoing
    }

    required public init(decoder: PostboxDecoder) {
        self.deletionTimestamp = decoder.decodeInt32ForKey("dt", orElse: 0)
        self.wasOutgoing = decoder.decodeBoolForKey("wo", orElse: false)
    }

    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeInt32(self.deletionTimestamp, forKey: "dt")
        encoder.encodeBool(self.wasOutgoing, forKey: "wo")
    }
}

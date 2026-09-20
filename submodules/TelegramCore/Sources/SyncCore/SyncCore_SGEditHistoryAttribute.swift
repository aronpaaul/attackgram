import Foundation
import Postbox

public class SGEditHistoryAttribute: MessageAttribute {
    public let texts: [String]
    public let timestamps: [Int32]

    public init(texts: [String], timestamps: [Int32]) {
        self.texts = texts
        self.timestamps = timestamps
    }

    required public init(decoder: PostboxDecoder) {
        self.texts = decoder.decodeStringArrayForKey("t")
        self.timestamps = decoder.decodeInt32ArrayForKey("ts")
    }

    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeStringArray(self.texts, forKey: "t")
        encoder.encodeInt32Array(self.timestamps, forKey: "ts")
    }
}

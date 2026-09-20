import Foundation
import UIKit
import ImageIO

enum SGGifLoader {
    static func load(name: String, bundles: [Bundle]) -> (images: [UIImage], duration: Double)? {
        for bundle in bundles {
            guard let asset = NSDataAsset(name: name, bundle: bundle), let source = CGImageSourceCreateWithData(asset.data as CFData, nil) else {
                continue
            }
            let count = CGImageSourceGetCount(source)
            var images: [UIImage] = []
            var duration: Double = 0.0
            for index in 0 ..< count {
                if let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) {
                    images.append(UIImage(cgImage: cgImage))
                    duration += frameDuration(source: source, index: index)
                }
            }
            if !images.isEmpty {
                return (images, duration > 0.0 ? duration : Double(images.count) / 20.0)
            }
        }
        return nil
    }

    private static func frameDuration(source: CGImageSource, index: Int) -> Double {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any], let gifProperties = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] else {
            return 0.1
        }
        if let unclamped = gifProperties[kCGImagePropertyGIFUnclampedDelayTime] as? Double, unclamped > 0.0 {
            return unclamped
        }
        if let delay = gifProperties[kCGImagePropertyGIFDelayTime] as? Double, delay > 0.0 {
            return delay
        }
        return 0.1
    }
}

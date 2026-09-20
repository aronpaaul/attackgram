import Foundation
import UIKit
import AsyncDisplayKit
import Display
import TelegramPresentationData
import ItemListUI

final class SGExtendedEmptyStateItemNode: ItemListControllerEmptyStateItemNode {
    private let imageView: UIImageView
    private let fallbackNode: ImmediateTextNode
    private let textNode: ImmediateTextNode
    private var hasAnimation = false

    override init() {
        self.imageView = UIImageView()
        self.imageView.contentMode = .scaleAspectFit
        self.fallbackNode = ImmediateTextNode()
        self.fallbackNode.textAlignment = .center
        self.textNode = ImmediateTextNode()
        self.textNode.maximumNumberOfLines = 0
        self.textNode.textAlignment = .center

        super.init()

        self.view.addSubview(self.imageView)
        self.addSubnode(self.fallbackNode)
        self.addSubnode(self.textNode)

        if let loaded = SGGifLoader.load(name: "UtyaWave", bundles: [Bundle(for: SGExtendedEmptyStateItemNode.self), Bundle.main]), !loaded.images.isEmpty {
            self.imageView.animationImages = loaded.images
            self.imageView.animationDuration = loaded.duration
            self.imageView.animationRepeatCount = 0
            self.imageView.image = loaded.images.first
            self.hasAnimation = true
        } else {
            self.fallbackNode.attributedText = NSAttributedString(string: "🦆", font: Font.regular(120.0), textColor: .black, paragraphAlignment: .center)
        }
    }

    func update(theme: PresentationTheme, text: String) {
        self.textNode.attributedText = NSAttributedString(string: text, font: Font.regular(16.0), textColor: theme.list.freeTextColor, paragraphAlignment: .center)
    }

    override func updateLayout(layout: ContainerViewLayout, navigationBarHeight: CGFloat, transition: ContainedViewLayoutTransition) {
        let duckSize = CGSize(width: 170.0, height: 170.0)
        let contentWidth = layout.size.width - 60.0
        let textSize = self.textNode.updateLayout(CGSize(width: contentWidth, height: .greatestFiniteMagnitude))
        let spacing: CGFloat = 22.0
        let totalHeight = duckSize.height + spacing + textSize.height
        let originY = navigationBarHeight + floor((layout.size.height - navigationBarHeight - totalHeight) / 2.0)

        let duckFrame = CGRect(origin: CGPoint(x: floor((layout.size.width - duckSize.width) / 2.0), y: originY), size: duckSize)
        if self.hasAnimation {
            self.imageView.frame = duckFrame
            if !self.imageView.isAnimating {
                self.imageView.startAnimating()
            }
        } else {
            let fallbackSize = self.fallbackNode.updateLayout(CGSize(width: contentWidth, height: 200.0))
            self.fallbackNode.frame = CGRect(origin: CGPoint(x: floor((layout.size.width - fallbackSize.width) / 2.0), y: originY + floor((duckSize.height - fallbackSize.height) / 2.0)), size: fallbackSize)
        }

        let textFrame = CGRect(origin: CGPoint(x: floor((layout.size.width - textSize.width) / 2.0), y: duckFrame.maxY + spacing), size: textSize)
        transition.updateFrame(node: self.textNode, frame: textFrame)
    }
}

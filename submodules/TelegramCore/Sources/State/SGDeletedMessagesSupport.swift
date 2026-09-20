import Foundation
import Postbox
import SGSimpleSettings

func sgKeepDeletedMessage(transaction: Transaction, message: Message, accountPeerId: PeerId) -> Bool {
    guard SGSimpleSettings.shared.saveDeletedMessages else {
        return false
    }
    if message.id.namespace != Namespaces.Message.Cloud {
        return false
    }
    let isOutgoing = !message.effectivelyIncoming(accountPeerId)
    if isOutgoing && !SGSimpleSettings.shared.saveDeletedFromSelf {
        return false
    }
    if let user = transaction.getPeer(message.id.peerId) as? TelegramUser, user.botInfo != nil, !SGSimpleSettings.shared.saveDeletedFromBots {
        return false
    }
    return true
}

func sgMarkMessageDeleted(transaction: Transaction, message: Message, accountPeerId: PeerId) {
    let isOutgoing = !message.effectivelyIncoming(accountPeerId)
    transaction.updateMessage(message.id, update: { currentMessage in
        if currentMessage.attributes.contains(where: { $0 is SGDeletedMessageAttribute }) {
            return .skip
        }
        var attributes = currentMessage.attributes
        attributes.append(SGDeletedMessageAttribute(deletionTimestamp: Int32(Date().timeIntervalSince1970), wasOutgoing: isOutgoing))
        var storeForwardInfo: StoreMessageForwardInfo?
        if let forwardInfo = currentMessage.forwardInfo {
            storeForwardInfo = StoreMessageForwardInfo(authorId: forwardInfo.author?.id, sourceId: forwardInfo.source?.id, sourceMessageId: forwardInfo.sourceMessageId, date: forwardInfo.date, authorSignature: forwardInfo.authorSignature, psaType: forwardInfo.psaType, flags: forwardInfo.flags)
        }
        return .update(StoreMessage(id: currentMessage.id, customStableId: nil, globallyUniqueId: currentMessage.globallyUniqueId, groupingKey: currentMessage.groupingKey, threadId: currentMessage.threadId, timestamp: currentMessage.timestamp, flags: StoreMessageFlags(currentMessage.flags), tags: currentMessage.tags, globalTags: currentMessage.globalTags, localTags: currentMessage.localTags, forwardInfo: storeForwardInfo, authorId: currentMessage.author?.id, text: currentMessage.text, attributes: attributes, media: currentMessage.media))
    })
}

func sgIsDeletedMessage(transaction: Transaction, id: MessageId) -> Bool {
    return transaction.getMessage(id)?.attributes.contains(where: { $0 is SGDeletedMessageAttribute }) ?? false
}

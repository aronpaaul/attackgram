import Foundation
import Postbox
import SwiftSignalKit
import SGSimpleSettings

public func sgClearDeletedMessages(account: Account) -> Signal<Void, NoError> {
    let ids = SGSimpleSettings.shared.deletedMessageKeys.compactMap { sgMessageIdFromKey($0) }
    return account.postbox.transaction { transaction in
        for id in ids {
            transaction.deleteMessages([id], forEachMedia: { _ in })
        }
        SGSimpleSettings.shared.deletedMessageKeys = []
    }
}

public func sgClearEditHistory(account: Account) -> Signal<Void, NoError> {
    let ids = SGSimpleSettings.shared.editedMessageKeys.compactMap { sgMessageIdFromKey($0) }
    return account.postbox.transaction { transaction in
        for id in ids {
            transaction.updateMessage(id, update: { currentMessage in
                if !currentMessage.attributes.contains(where: { $0 is SGEditHistoryAttribute }) {
                    return .skip
                }
                var attributes = currentMessage.attributes
                attributes.removeAll(where: { $0 is SGEditHistoryAttribute })
                var storeForwardInfo: StoreMessageForwardInfo?
                if let forwardInfo = currentMessage.forwardInfo {
                    storeForwardInfo = StoreMessageForwardInfo(authorId: forwardInfo.author?.id, sourceId: forwardInfo.source?.id, sourceMessageId: forwardInfo.sourceMessageId, date: forwardInfo.date, authorSignature: forwardInfo.authorSignature, psaType: forwardInfo.psaType, flags: forwardInfo.flags)
                }
                return .update(StoreMessage(id: currentMessage.id, customStableId: nil, globallyUniqueId: currentMessage.globallyUniqueId, groupingKey: currentMessage.groupingKey, threadId: currentMessage.threadId, timestamp: currentMessage.timestamp, flags: StoreMessageFlags(currentMessage.flags), tags: currentMessage.tags, globalTags: currentMessage.globalTags, localTags: currentMessage.localTags, forwardInfo: storeForwardInfo, authorId: currentMessage.author?.id, text: currentMessage.text, attributes: attributes, media: currentMessage.media))
            })
        }
        SGSimpleSettings.shared.editedMessageKeys = []
    }
}

public func sgMessageKey(_ id: MessageId) -> String {
    return "\(id.peerId.toInt64())_\(id.namespace)_\(id.id)"
}

public func sgMessageIdFromKey(_ key: String) -> MessageId? {
    let parts = key.split(separator: "_")
    guard parts.count == 3, let peerValue = Int64(parts[0]), let namespace = Int32(parts[1]), let messageValue = Int32(parts[2]) else {
        return nil
    }
    return MessageId(peerId: PeerId(peerValue), namespace: namespace, id: messageValue)
}

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
    let alreadyMarked = message.attributes.contains(where: { $0 is SGDeletedMessageAttribute })
    let isOutgoing = !message.effectivelyIncoming(accountPeerId)
    if !alreadyMarked {
        var keys = SGSimpleSettings.shared.deletedMessageKeys
        keys.append(sgMessageKey(message.id))
        SGSimpleSettings.shared.deletedMessageKeys = keys
    }
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

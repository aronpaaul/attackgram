import Foundation
import Display
import ItemListUI
import TelegramPresentationData

enum SGExtendedSection: Int32 {
    case chats
    case privacy
    case deleted
}

final class SGExtendedArguments {
    let toggleUnlimitedPins: (Bool) -> Void
    let toggleInvisibleMode: (Bool) -> Void
    let toggleHideOnline: (Bool) -> Void
    let toggleHideTyping: (Bool) -> Void
    let toggleDontSendRead: (Bool) -> Void
    let toggleVoiceVideoReceipts: (Bool) -> Void
    let toggleSaveDeleted: (Bool) -> Void
    let toggleSaveDeletedBots: (Bool) -> Void
    let toggleSaveDeletedSelf: (Bool) -> Void

    init(toggleUnlimitedPins: @escaping (Bool) -> Void, toggleInvisibleMode: @escaping (Bool) -> Void, toggleHideOnline: @escaping (Bool) -> Void, toggleHideTyping: @escaping (Bool) -> Void, toggleDontSendRead: @escaping (Bool) -> Void, toggleVoiceVideoReceipts: @escaping (Bool) -> Void, toggleSaveDeleted: @escaping (Bool) -> Void, toggleSaveDeletedBots: @escaping (Bool) -> Void, toggleSaveDeletedSelf: @escaping (Bool) -> Void) {
        self.toggleUnlimitedPins = toggleUnlimitedPins
        self.toggleInvisibleMode = toggleInvisibleMode
        self.toggleHideOnline = toggleHideOnline
        self.toggleHideTyping = toggleHideTyping
        self.toggleDontSendRead = toggleDontSendRead
        self.toggleVoiceVideoReceipts = toggleVoiceVideoReceipts
        self.toggleSaveDeleted = toggleSaveDeleted
        self.toggleSaveDeletedBots = toggleSaveDeletedBots
        self.toggleSaveDeletedSelf = toggleSaveDeletedSelf
    }
}

enum SGExtendedEntry: ItemListNodeEntry {
    case unlimitedPins(Bool)
    case invisibleMode(Bool)
    case hideOnline(Bool)
    case hideTyping(Bool)
    case dontSendRead(Bool)
    case voiceVideoReceipts(Bool)
    case saveDeleted(Bool)
    case saveDeletedBots(Bool)
    case saveDeletedSelf(Bool)

    var section: ItemListSectionId {
        switch self {
        case .unlimitedPins:
            return SGExtendedSection.chats.rawValue
        case .invisibleMode, .hideOnline, .hideTyping, .dontSendRead, .voiceVideoReceipts:
            return SGExtendedSection.privacy.rawValue
        case .saveDeleted, .saveDeletedBots, .saveDeletedSelf:
            return SGExtendedSection.deleted.rawValue
        }
    }

    var stableId: Int32 {
        switch self {
        case .unlimitedPins: return 0
        case .invisibleMode: return 1
        case .hideOnline: return 2
        case .hideTyping: return 3
        case .dontSendRead: return 4
        case .voiceVideoReceipts: return 5
        case .saveDeleted: return 6
        case .saveDeletedBots: return 7
        case .saveDeletedSelf: return 8
        }
    }

    static func <(lhs: SGExtendedEntry, rhs: SGExtendedEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! SGExtendedArguments
        switch self {
        case let .unlimitedPins(value):
            return ItemListSwitchItem(presentationData: presentationData, title: "Безлимитный закреп чатов", value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleUnlimitedPins($0) })
        case let .invisibleMode(value):
            return ItemListSwitchItem(presentationData: presentationData, title: "Невидимый режим", value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleInvisibleMode($0) })
        case let .hideOnline(value):
            return ItemListSwitchItem(presentationData: presentationData, title: "Скрывать статус «в сети»", value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleHideOnline($0) })
        case let .hideTyping(value):
            return ItemListSwitchItem(presentationData: presentationData, title: "Скрывать «печатает…»", value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleHideTyping($0) })
        case let .dontSendRead(value):
            return ItemListSwitchItem(presentationData: presentationData, title: "Не отправлять прочтение", value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleDontSendRead($0) })
        case let .voiceVideoReceipts(value):
            return ItemListSwitchItem(presentationData: presentationData, title: "Не отправлять «прослушано/просмотрено»", value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleVoiceVideoReceipts($0) })
        case let .saveDeleted(value):
            return ItemListSwitchItem(presentationData: presentationData, title: "Сохранять удалённые сообщения", value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleSaveDeleted($0) })
        case let .saveDeletedBots(value):
            return ItemListSwitchItem(presentationData: presentationData, title: "Удалённые в ботах", value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleSaveDeletedBots($0) })
        case let .saveDeletedSelf(value):
            return ItemListSwitchItem(presentationData: presentationData, title: "Удалённые от себя", value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleSaveDeletedSelf($0) })
        }
    }
}

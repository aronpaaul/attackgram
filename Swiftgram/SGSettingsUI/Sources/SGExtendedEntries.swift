import Foundation
import Display
import ItemListUI
import TelegramPresentationData

enum SGExtendedSection: Int32 {
    case chats
    case themes
    case privacy
    case deleted
    case maintenance
}

final class SGExtendedArguments {
    let toggleUnlimitedPins: (Bool) -> Void
    let openThemes: () -> Void
    let toggleInvisibleMode: (Bool) -> Void
    let toggleHideOnline: (Bool) -> Void
    let toggleHideTyping: (Bool) -> Void
    let toggleDontSendRead: (Bool) -> Void
    let toggleVoiceVideoReceipts: (Bool) -> Void
    let toggleSaveEditHistory: (Bool) -> Void
    let toggleSaveDeleted: (Bool) -> Void
    let toggleSaveDeletedBots: (Bool) -> Void
    let toggleSaveDeletedSelf: (Bool) -> Void
    let clearDeleted: () -> Void
    let clearEdited: () -> Void

    init(toggleUnlimitedPins: @escaping (Bool) -> Void, openThemes: @escaping () -> Void, toggleInvisibleMode: @escaping (Bool) -> Void, toggleHideOnline: @escaping (Bool) -> Void, toggleHideTyping: @escaping (Bool) -> Void, toggleDontSendRead: @escaping (Bool) -> Void, toggleVoiceVideoReceipts: @escaping (Bool) -> Void, toggleSaveEditHistory: @escaping (Bool) -> Void, toggleSaveDeleted: @escaping (Bool) -> Void, toggleSaveDeletedBots: @escaping (Bool) -> Void, toggleSaveDeletedSelf: @escaping (Bool) -> Void, clearDeleted: @escaping () -> Void, clearEdited: @escaping () -> Void) {
        self.toggleUnlimitedPins = toggleUnlimitedPins
        self.openThemes = openThemes
        self.toggleInvisibleMode = toggleInvisibleMode
        self.toggleHideOnline = toggleHideOnline
        self.toggleHideTyping = toggleHideTyping
        self.toggleDontSendRead = toggleDontSendRead
        self.toggleVoiceVideoReceipts = toggleVoiceVideoReceipts
        self.toggleSaveEditHistory = toggleSaveEditHistory
        self.toggleSaveDeleted = toggleSaveDeleted
        self.toggleSaveDeletedBots = toggleSaveDeletedBots
        self.toggleSaveDeletedSelf = toggleSaveDeletedSelf
        self.clearDeleted = clearDeleted
        self.clearEdited = clearEdited
    }
}

enum SGExtendedEntry: ItemListNodeEntry {
    case unlimitedPins(Bool)
    case themes
    case invisibleMode(Bool)
    case hideOnline(Bool)
    case hideTyping(Bool)
    case dontSendRead(Bool)
    case voiceVideoReceipts(Bool)
    case saveEditHistory(Bool)
    case saveDeleted(Bool)
    case saveDeletedBots(Bool)
    case saveDeletedSelf(Bool)
    case clearDeleted
    case clearEdited

    var section: ItemListSectionId {
        switch self {
        case .unlimitedPins:
            return SGExtendedSection.chats.rawValue
        case .themes:
            return SGExtendedSection.themes.rawValue
        case .invisibleMode, .hideOnline, .hideTyping, .dontSendRead, .voiceVideoReceipts:
            return SGExtendedSection.privacy.rawValue
        case .saveEditHistory, .saveDeleted, .saveDeletedBots, .saveDeletedSelf:
            return SGExtendedSection.deleted.rawValue
        case .clearDeleted, .clearEdited:
            return SGExtendedSection.maintenance.rawValue
        }
    }

    var stableId: Int32 {
        switch self {
        case .unlimitedPins: return 0
        case .themes: return 1
        case .invisibleMode: return 2
        case .hideOnline: return 3
        case .hideTyping: return 4
        case .dontSendRead: return 5
        case .voiceVideoReceipts: return 6
        case .saveEditHistory: return 7
        case .saveDeleted: return 8
        case .saveDeletedBots: return 9
        case .saveDeletedSelf: return 10
        case .clearDeleted: return 11
        case .clearEdited: return 12
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
        case .themes:
            return ItemListDisclosureItem(presentationData: presentationData, title: "Готовые темы", label: "", sectionId: self.section, style: .blocks, action: { arguments.openThemes() })
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
        case let .saveEditHistory(value):
            return ItemListSwitchItem(presentationData: presentationData, title: "Сохранять историю правок", value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleSaveEditHistory($0) })
        case let .saveDeleted(value):
            return ItemListSwitchItem(presentationData: presentationData, title: "Сохранять удалённые сообщения", value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleSaveDeleted($0) })
        case let .saveDeletedBots(value):
            return ItemListSwitchItem(presentationData: presentationData, title: "Удалённые в ботах", value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleSaveDeletedBots($0) })
        case let .saveDeletedSelf(value):
            return ItemListSwitchItem(presentationData: presentationData, title: "Удалённые от себя", value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleSaveDeletedSelf($0) })
        case .clearDeleted:
            return ItemListActionItem(presentationData: presentationData, title: "Очистить историю удалённых", kind: .destructive, alignment: .natural, sectionId: self.section, style: .blocks, action: { arguments.clearDeleted() })
        case .clearEdited:
            return ItemListActionItem(presentationData: presentationData, title: "Очистить историю правок", kind: .destructive, alignment: .natural, sectionId: self.section, style: .blocks, action: { arguments.clearEdited() })
        }
    }
}

import Foundation
import Display
import ItemListUI
import TelegramPresentationData

enum SGExtendedSection: Int32 {
    case search
    case chats
    case themes
    case privacy
    case deleted
    case fakeBalance
    case maintenance
}

final class SGFakeStarsInputTag: ItemListItemTag {
    func isEqual(to other: ItemListItemTag) -> Bool {
        return other is SGFakeStarsInputTag
    }
}

final class SGFakeTonInputTag: ItemListItemTag {
    func isEqual(to other: ItemListItemTag) -> Bool {
        return other is SGFakeTonInputTag
    }
}

final class SGExtendedSearchTag: ItemListItemTag {
    func isEqual(to other: ItemListItemTag) -> Bool {
        return other is SGExtendedSearchTag
    }
}

final class SGExtendedArguments {
    let updateSearch: (String) -> Void
    let toggleUnlimitedPins: (Bool) -> Void
    let openThemes: () -> Void
    let openIgnored: () -> Void
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
    let toggleFakeBalance: (Bool) -> Void
    let updateFakeStars: (String) -> Void
    let updateFakeTon: (String) -> Void
    let toggleFakeGifts: (Bool) -> Void

    init(updateSearch: @escaping (String) -> Void, toggleUnlimitedPins: @escaping (Bool) -> Void, openThemes: @escaping () -> Void, openIgnored: @escaping () -> Void, toggleInvisibleMode: @escaping (Bool) -> Void, toggleHideOnline: @escaping (Bool) -> Void, toggleHideTyping: @escaping (Bool) -> Void, toggleDontSendRead: @escaping (Bool) -> Void, toggleVoiceVideoReceipts: @escaping (Bool) -> Void, toggleSaveEditHistory: @escaping (Bool) -> Void, toggleSaveDeleted: @escaping (Bool) -> Void, toggleSaveDeletedBots: @escaping (Bool) -> Void, toggleSaveDeletedSelf: @escaping (Bool) -> Void, clearDeleted: @escaping () -> Void, clearEdited: @escaping () -> Void, toggleFakeBalance: @escaping (Bool) -> Void, updateFakeStars: @escaping (String) -> Void, updateFakeTon: @escaping (String) -> Void, toggleFakeGifts: @escaping (Bool) -> Void) {
        self.updateSearch = updateSearch
        self.toggleUnlimitedPins = toggleUnlimitedPins
        self.openThemes = openThemes
        self.openIgnored = openIgnored
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
        self.toggleFakeBalance = toggleFakeBalance
        self.updateFakeStars = updateFakeStars
        self.updateFakeTon = updateFakeTon
        self.toggleFakeGifts = toggleFakeGifts
    }
}

enum SGExtendedEntry: ItemListNodeEntry {
    case search(String, String)
    case unlimitedPins(String, Bool)
    case themes(String)
    case invisibleMode(String, Bool)
    case hideOnline(String, Bool)
    case hideTyping(String, Bool)
    case dontSendRead(String, Bool)
    case voiceVideoReceipts(String, Bool)
    case ignoredList(String)
    case saveEditHistory(String, Bool)
    case saveDeleted(String, Bool)
    case saveDeletedBots(String, Bool)
    case saveDeletedSelf(String, Bool)
    case clearDeleted(String)
    case clearEdited(String)
    case fakeBalance(String, Bool)
    case fakeStars(String, String)
    case fakeTon(String, String)
    case fakeGifts(String, Bool)

    var section: ItemListSectionId {
        switch self {
        case .search:
            return SGExtendedSection.search.rawValue
        case .unlimitedPins:
            return SGExtendedSection.chats.rawValue
        case .themes:
            return SGExtendedSection.themes.rawValue
        case .invisibleMode, .hideOnline, .hideTyping, .dontSendRead, .voiceVideoReceipts, .ignoredList:
            return SGExtendedSection.privacy.rawValue
        case .saveEditHistory, .saveDeleted, .saveDeletedBots, .saveDeletedSelf:
            return SGExtendedSection.deleted.rawValue
        case .clearDeleted, .clearEdited:
            return SGExtendedSection.maintenance.rawValue
        case .fakeBalance, .fakeStars, .fakeTon, .fakeGifts:
            return SGExtendedSection.fakeBalance.rawValue
        }
    }

    var stableId: Int32 {
        switch self {
        case .search: return 0
        case .unlimitedPins: return 1
        case .themes: return 2
        case .invisibleMode: return 3
        case .hideOnline: return 4
        case .hideTyping: return 5
        case .dontSendRead: return 6
        case .voiceVideoReceipts: return 7
        case .ignoredList: return 8
        case .saveEditHistory: return 9
        case .saveDeleted: return 10
        case .saveDeletedBots: return 11
        case .saveDeletedSelf: return 12
        case .clearDeleted: return 13
        case .clearEdited: return 14
        case .fakeBalance: return 15
        case .fakeStars: return 16
        case .fakeTon: return 17
        case .fakeGifts: return 18
        }
    }

    var searchableTitle: String {
        switch self {
        case .search: return ""
        case let .unlimitedPins(title, _), let .themes(title), let .ignoredList(title), let .invisibleMode(title, _), let .hideOnline(title, _), let .hideTyping(title, _), let .dontSendRead(title, _), let .voiceVideoReceipts(title, _), let .saveEditHistory(title, _), let .saveDeleted(title, _), let .saveDeletedBots(title, _), let .saveDeletedSelf(title, _), let .clearDeleted(title), let .clearEdited(title), let .fakeBalance(title, _), let .fakeStars(title, _), let .fakeTon(title, _), let .fakeGifts(title, _):
            return title
        }
    }

    static func <(lhs: SGExtendedEntry, rhs: SGExtendedEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! SGExtendedArguments
        switch self {
        case let .search(placeholder, query):
            return ItemListSingleLineInputItem(presentationData: presentationData, title: NSAttributedString(string: ""), text: query, placeholder: placeholder, type: .regular(capitalization: false, autocorrection: false), clearType: .always, tag: SGExtendedSearchTag(), sectionId: self.section, textUpdated: { value in
                arguments.updateSearch(value)
            }, action: {})
        case let .unlimitedPins(title, value):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleUnlimitedPins($0) })
        case let .themes(title):
            return ItemListDisclosureItem(presentationData: presentationData, title: title, label: "", sectionId: self.section, style: .blocks, action: { arguments.openThemes() })
        case let .invisibleMode(title, value):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleInvisibleMode($0) })
        case let .hideOnline(title, value):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleHideOnline($0) })
        case let .hideTyping(title, value):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleHideTyping($0) })
        case let .dontSendRead(title, value):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleDontSendRead($0) })
        case let .voiceVideoReceipts(title, value):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleVoiceVideoReceipts($0) })
        case let .ignoredList(title):
            return ItemListDisclosureItem(presentationData: presentationData, title: title, label: "", sectionId: self.section, style: .blocks, action: { arguments.openIgnored() })
        case let .saveEditHistory(title, value):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleSaveEditHistory($0) })
        case let .saveDeleted(title, value):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleSaveDeleted($0) })
        case let .saveDeletedBots(title, value):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleSaveDeletedBots($0) })
        case let .saveDeletedSelf(title, value):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleSaveDeletedSelf($0) })
        case let .clearDeleted(title):
            return ItemListActionItem(presentationData: presentationData, title: title, kind: .destructive, alignment: .natural, sectionId: self.section, style: .blocks, action: { arguments.clearDeleted() })
        case let .clearEdited(title):
            return ItemListActionItem(presentationData: presentationData, title: title, kind: .destructive, alignment: .natural, sectionId: self.section, style: .blocks, action: { arguments.clearEdited() })
        case let .fakeBalance(title, value):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleFakeBalance($0) })
        case let .fakeStars(placeholder, value):
            return ItemListSingleLineInputItem(presentationData: presentationData, title: NSAttributedString(string: "★"), text: value, placeholder: placeholder, type: .regular(capitalization: false, autocorrection: false), clearType: .always, tag: SGFakeStarsInputTag(), sectionId: self.section, textUpdated: { arguments.updateFakeStars($0) }, action: {})
        case let .fakeTon(placeholder, value):
            return ItemListSingleLineInputItem(presentationData: presentationData, title: NSAttributedString(string: "TON"), text: value, placeholder: placeholder, type: .regular(capitalization: false, autocorrection: false), clearType: .always, tag: SGFakeTonInputTag(), sectionId: self.section, textUpdated: { arguments.updateFakeTon($0) }, action: {})
        case let .fakeGifts(title, value):
            return ItemListSwitchItem(presentationData: presentationData, title: title, value: value, sectionId: self.section, style: .blocks, updated: { arguments.toggleFakeGifts($0) })
        }
    }
}

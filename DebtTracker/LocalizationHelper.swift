import Foundation

class LocalizationHelper: ObservableObject {
    static let shared = LocalizationHelper()
    
    private init() {}
    
    func localizedString(_ key: String, language: UserSettings.AppLanguage) -> String {
        // First, try to fetch from .strings file inside the corresponding .lproj bundle
        if let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            let localized = NSLocalizedString(key, tableName: nil, bundle: bundle, value: key, comment: "")
            if localized != key { // Found a translation in bundle
                return localized
            }
        }
        // Fallback to in-memory dictionaries
        switch language {
        case .english:
            return englishStrings[key] ?? key
        case .russian:
            return russianStrings[key] ?? key
        case .chinese:
            return chineseStrings[key] ?? key
        }
    }
    
    private let englishStrings: [String: String] = [
        // Tab Items
        "debts": "Debts",
        "statistics": "Statistics",
        "settings": "Settings",
        
        // Main Navigation
        "debt_tracker": "Debt Tracker",
        "add_debt": "Add Debt",
        
        // Settings
        "theme": "Theme",
        "language": "Language",
        "appearance": "Appearance",
        "general": "General",
        
        // Privacy
        "hide_total_amounts": "Hide Total Amounts",
        
        // Statistics
        "owed_to_me": "Owed to Me",
        "i_owe": "I Owe",
        "net_balance": "Net Balance",
        "overdue_debts": "Overdue Debts",
        "quick_stats": "Quick Stats",
        "total_debts": "Total Debts",
        "unpaid": "Unpaid",
        "paid": "Paid",
        
        // Filters
        "all": "All",
        "owed_to_me_filter": "Owed to Me",
        "i_owe_filter": "I Owe",
        "unpaid_filter": "Unpaid",
        "paid_filter": "Paid",
        "overdue_filter": "Overdue",
        
        // Sort Options
        "date_created": "Date Created",
        "amount": "Amount",
        "due_date": "Due Date",
        "title": "Title",
        
        // Common
        "filter": "Filter",
        "sort": "Sort",
        "search_debts": "Search debts...",
        "from": "From",
        "to": "To",
        "overdue": "(Overdue)",
        "days_overdue": "days overdue",
        
        // Empty States
        "no_debts_found": "No debts found.\nTap + to add your first debt.",
        "no_one_owes_you": "No one owes you money.\nLucky you!",
        "you_dont_owe": "You don't owe anyone money.\nGreat job!",
        "no_unpaid_debts": "No unpaid debts found.",
        "no_paid_debts": "No paid debts found.",
        "no_overdue_debts": "No overdue debts.\nEverything is on track!",
        "debt_details": "Debt Details",
        "title_field": "Title",
        "type": "Type",
        "someone_owes_me": "Someone owes me",
        "i_owe_someone": "I owe someone",
        "people": "People",
        "who_owes_you": "Who owes you?",
        "your_name": "Your Name",
        "who_do_you_owe": "Who do you owe?",
        "set_due_date": "Set Due Date",
        "additional_details": "Additional Details",
        "interest_rate_percent": "Interest Rate (%)",
        "amount_with_interest": "Amount with Interest",
        "notes_optional": "Notes (optional)",
        "cancel": "Cancel",
        "save": "Save",
        "edit": "Edit",
        "delete_debt": "Delete Debt",
        "delete_debt_title": "Delete Debt",
        "delete_debt_message": "Are you sure you want to delete this debt?",
        "mark_as_paid": "Mark as Paid",
        "mark_as_unpaid": "Mark as Unpaid",
        "creditor_you": "Creditor (You)",
        "creditor": "Creditor",
        "debtor_you": "Debtor (You)",
        "debtor": "Debtor",
        "created": "Created",
        "days_remaining": "days remaining"
    ]
    
    private let russianStrings: [String: String] = [
        // Tab Items
        "debts": "Долги",
        "statistics": "Статистика",
        "settings": "Настройки",
        
        // Main Navigation
        "debt_tracker": "Учёт Долгов",
        "add_debt": "Добавить Долг",
        
        // Settings
        "theme": "Тема",
        "language": "Язык",
        "appearance": "Внешний вид",
        "general": "Общие",
        
        // Privacy
        "hide_total_amounts": "Скрыть итоговые суммы",
        
        // Statistics
        "owed_to_me": "Мне должны",
        "i_owe": "Я должен",
        "net_balance": "Чистый баланс",
        "overdue_debts": "Просроченные долги",
        "quick_stats": "Быстрая статистика",
        "total_debts": "Всего долгов",
        "unpaid": "Неоплачено",
        "paid": "Оплачено",
        
        // Filters
        "all": "Все",
        "owed_to_me_filter": "Мне должны",
        "i_owe_filter": "Я должен",
        "unpaid_filter": "Неоплачено",
        "paid_filter": "Оплачено",
        "overdue_filter": "Просрочено",
        
        // Sort Options
        "date_created": "Дата начала",
        "amount": "Сумма",
        "due_date": "Срок оплаты",
        "title": "Название",
        
        // Common
        "filter": "Фильтр",
        "sort": "Сортировка",
        "search_debts": "Поиск долгов...",
        "from": "От",
        "to": "Кому",
        "overdue": "(Просрочено)",
        "days_overdue": "дней просрочки",
        
        // Empty States
        "no_debts_found": "Долги не найдены.\nНажмите + чтобы добавить первый долг.",
        "no_one_owes_you": "Никто вам не должен.\nВезёт!",
        "you_dont_owe": "Вы никому не должны.\nОтличная работа!",
        "no_unpaid_debts": "Неоплаченные долги не найдены.",
        "no_paid_debts": "Оплаченные долги не найдены.",
        "no_overdue_debts": "Нет просроченных долгов.\nВсё идёт по плану!",
        "debt_details": "Debt Details",
        "title_field": "Title",
        "type": "Type",
        "someone_owes_me": "Someone owes me",
        "i_owe_someone": "I owe someone",
        "people": "People",
        "who_owes_you": "Who owes you?",
        "your_name": "Your Name",
        "who_do_you_owe": "Who do you owe?",
        "set_due_date": "Set Due Date",
        "additional_details": "Additional Details",
        "interest_rate_percent": "Interest Rate (%)",
        "amount_with_interest": "Сумма с процентами",
        "notes_optional": "Заметки (необязательно)",
        "cancel": "Отмена",
        "save": "Сохранить",
        "edit": "Редактировать",
        "delete_debt": "Удалить долг",
        "delete_debt_title": "Удалить долг",
        "delete_debt_message": "Вы уверены, что хотите удалить этот долг?",
        "mark_as_paid": "Отметить как оплаченный",
        "mark_as_unpaid": "Отметить как неоплаченный",
        "creditor_you": "Кредитор (Вы)",
        "creditor": "Кредитор",
        "debtor_you": "Должник (Вы)",
        "debtor": "Должник",
        "created": "Создано",
        "days_remaining": "дней осталось"
    ]
    
    private let chineseStrings: [String: String] = [
        // TODO: Provide proper Simplified Chinese translations. Currently placeholders equal English.
        // Tab Items
        "debts": "债务",
        "statistics": "统计",
        "settings": "设置",
        
        // Main Navigation
        "debt_tracker": "债务跟踪",
        "add_debt": "添加债务",
        
        // Settings
        "theme": "主题",
        "language": "语言",
        "appearance": "外观",
        "general": "常规",
        
        // Privacy
        "hide_total_amounts": "隐藏总金额",
        
        // Statistics
        "owed_to_me": "别人欠我的",
        "i_owe": "我欠别人的",
        "net_balance": "净余额",
        "overdue_debts": "逾期债务",
        "quick_stats": "快速统计",
        "total_debts": "总债务",
        "unpaid": "未支付",
        "paid": "已支付",
        
        // Filters
        "all": "全部",
        "owed_to_me_filter": "别人欠我的",
        "i_owe_filter": "我欠别人的",
        "unpaid_filter": "未支付",
        "paid_filter": "已支付",
        "overdue_filter": "逾期",
        
        // Sort Options
        "date_created": "创建日期",
        "amount": "金额",
        "due_date": "到期日",
        "title": "标题",
        
        // Common
        "filter": "筛选",
        "sort": "排序",
        "search_debts": "搜索债务...",
        "from": "来自",
        "to": "到",
        "overdue": "(逾期)",
        "days_overdue": "天逾期",
        
        // Empty States
        "no_debts_found": "未找到债务。\n点击 + 添加第一笔债务。",
        "no_one_owes_you": "没有人欠你钱。\n恭喜！",
        "you_dont_owe": "你不欠任何人钱。\n干得好！",
        "no_unpaid_debts": "未找到未支付债务。",
        "no_paid_debts": "未找到已支付债务。",
        "no_overdue_debts": "没有逾期债务。\n一切进展顺利！",
        "debt_details": "Debt Details",
        "title_field": "Title",
        "type": "Type",
        "someone_owes_me": "Someone owes me",
        "i_owe_someone": "I owe someone",
        "people": "People",
        "who_owes_you": "Who owes you?",
        "your_name": "Your Name",
        "who_do_you_owe": "Who do you owe?",
        "set_due_date": "Set Due Date",
        "additional_details": "Additional Details",
        "interest_rate_percent": "Interest Rate (%)",
        "amount_with_interest": "含利息金额",
        "notes_optional": "Notes (optional)",
        "cancel": "Cancel",
        "save": "Save",
        "edit": "Edit",
        "delete_debt": "Delete Debt",
        "delete_debt_title": "Delete Debt",
        "delete_debt_message": "Are you sure you want to delete this debt?",
        "mark_as_paid": "Mark as Paid",
        "mark_as_unpaid": "Mark as Unpaid",
        "creditor_you": "Creditor (You)",
        "creditor": "Creditor",
        "debtor_you": "Debtor (You)",
        "debtor": "Debtor",
        "created": "Created",
        "days_remaining": "days remaining"
    ]
}

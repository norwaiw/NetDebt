import Foundation

class LocalizationHelper: ObservableObject {
    static let shared = LocalizationHelper()
    
    private init() {}
    
    func localizedString(_ key: String, language: UserSettings.AppLanguage) -> String {
        switch language {
        case .english:
            return englishStrings[key] ?? key
        case .russian:
            return russianStrings[key] ?? key
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
        "no_overdue_debts": "No overdue debts.\nEverything is on track!"
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
        "date_created": "Дата созд",
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
        "no_overdue_debts": "Нет просроченных долгов.\nВсё идёт по плану!"
    ]
}

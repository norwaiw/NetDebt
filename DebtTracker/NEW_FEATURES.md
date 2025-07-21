# New Features Added to DebtTracker

## 1. Partial Payment Progress Bar

The app now supports tracking partial payments for debts:

### Features:
- **Visual Progress Bar**: Shows payment progress as a percentage with color coding
  - Red: 0-50% paid
  - Orange: 50-75% paid
  - Blue: 75-99% paid
  - Green: 100% paid

- **Partial Payment Tracking**: 
  - Add multiple partial payments to any debt
  - Each payment includes amount, date, and optional note
  - View all partial payments in the debt detail view
  - Delete individual partial payments if needed

- **Automatic Updates**:
  - Total amounts in statistics reflect remaining balances
  - Debts automatically marked as paid when fully paid off
  - Progress shown in both list and detail views

### How to Use:
1. Open any unpaid debt
2. Look for the "Payment Progress" section
3. Tap "Add Payment" to record a partial payment
4. Enter amount and optional note
5. The progress bar updates immediately

## 2. Urgency Indicator

Debts with due dates now show urgency indicators that change color as the date approaches:

### Urgency Levels:
- **🟢 Normal (Green)**: More than 14 days remaining
- **🟡 Medium (Yellow)**: 8-14 days remaining
- **🟠 High (Orange)**: 4-7 days remaining
- **🔴 Critical (Red)**: 1-3 days remaining
- **🟣 Overdue (Purple)**: Past due date

### Visual Indicators:
- **List View**: Icon next to debt title changes based on urgency
- **Detail View**: Urgency badge in payment progress section
- **Days Remaining**: Shows exact days left with appropriate color

### Icons Used:
- Normal: Clock (clock)
- Medium: Clock with exclamation (clock.badge.exclamationmark)
- High: Warning triangle (exclamationmark.triangle)
- Critical: Double exclamation (exclamationmark.2)
- Overdue: Exclamation octagon (exclamationmark.octagon)

## Implementation Details

### Modified Files:
1. **Debt.swift**: Added partial payments support and urgency calculations
2. **DebtStore.swift**: Added methods for managing partial payments
3. **PaymentProgressBar.swift**: New component for progress visualization
4. **DebtListView.swift**: Updated to show progress bars and urgency indicators
5. **DebtDetailView.swift**: Added payment management interface
6. **Localizable.strings**: Added new localization strings

### Data Model Changes:
- Added `partialPayments: [PartialPayment]` to Debt struct
- Added computed properties: `totalPaid`, `remainingAmount`, `paymentProgress`
- Added `urgencyLevel` enum with color and icon properties

### Key Methods:
- `addPartialPayment(to:amount:note:)`: Add a payment
- `deletePartialPayment(from:paymentId:)`: Remove a payment
- `urgencyLevel`: Computed property for urgency status

## Toggle Debt Status (Переключение статуса долга)

Добавлена новая функциональность для переключения состояния долга между "оплачен" и "активен":

### Изменения:
1. **Новая функция в DebtStore**: `togglePaidStatus(_ debt: Debt)` - переключает состояние долга
2. **Обновленный UI в DebtDetailView**: Кнопка теперь работает в обе стороны:
   - Если долг активен - показывает "Отметить как оплаченный" (зеленая кнопка)
   - Если долг оплачен - показывает "Отметить как неоплаченный" (оранжевая кнопка)
3. **Обновленный swipe action в DebtListView**: Свайп влево теперь также переключает состояние
4. **Обновленная кнопка в DebtRowView**: Круглая кнопка теперь переключает состояние при нажатии

### Преимущества:
- Защита от случайных нажатий - можно легко вернуть долг в активное состояние
- Более гибкое управление долгами
- При возврате долга в активное состояние автоматически восстанавливаются уведомления

### Локализация:
Добавлены новые строки локализации:
- Английский: "Mark as Unpaid"
- Русский: "Отметить как неоплаченный"
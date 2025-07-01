# DebtTracker - iOS App

A comprehensive iOS application built with Swift and SwiftUI for tracking personal debts and money owed. This app helps you manage both money you owe to others and money others owe to you, with features for organizing, filtering, and monitoring debt statuses.

## Features

### Core Functionality
- **Debt Management**: Add, edit, and delete debt records
- **Dual Tracking**: Track both money you owe and money owed to you
- **Payment Status**: Mark debts as paid with visual indicators
- **Due Date Tracking**: Set due dates and monitor overdue debts
- **Notes & Interest**: Add notes and interest rates to debt records

### User Interface
- **Modern SwiftUI Design**: Clean, intuitive interface following iOS design principles
- **Tab Navigation**: Organized into Debts and Statistics tabs
- **Search & Filter**: Search debts by title, creditor, or debtor
- **Multiple Filters**: All, Owed to Me, I Owe, Unpaid, Paid, Overdue
- **Sorting Options**: Sort by date created, amount, due date, or title
- **Dark Mode Support**: Automatic dark/light mode compatibility

### Statistics & Analytics
- **Financial Overview**: Summary cards showing total amounts
- **Net Balance**: Calculate your overall financial position
- **Overdue Alerts**: Highlighted overdue debts with day counts
- **Quick Stats**: Total, unpaid, and paid debt counts
- **Visual Indicators**: Color-coded amounts (green for money owed to you, red for money you owe)

### Data Management
- **Local Persistence**: Data stored securely using UserDefaults with JSON encoding
- **Data Validation**: Form validation to ensure data integrity
- **CRUD Operations**: Full Create, Read, Update, Delete functionality
- **Auto-save**: Changes are automatically saved

## Technical Implementation

### Architecture
- **MVVM Pattern**: Clean separation of concerns using SwiftUI and ObservableObject
- **Single Source of Truth**: Centralized data management with `DebtStore`
- **Reactive UI**: SwiftUI's declarative syntax with automatic UI updates

### Key Components

#### Data Model (`Debt.swift`)
- Identifiable struct with UUID
- Codable for JSON persistence
- Computed properties for formatting and status
- Date calculations for overdue detection

#### Data Store (`DebtStore.swift`)
- ObservableObject for reactive updates
- UserDefaults persistence layer
- Computed properties for statistics
- CRUD operation methods

#### Views
- **ContentView**: Main tab container
- **DebtListView**: Debt listing with filtering and sorting
- **AddDebtView**: Form for creating new debts
- **DebtDetailView**: Detailed view with editing capabilities
- **StatisticsView**: Analytics and summary dashboard

### Dependencies
- **iOS 17.0+**: Minimum deployment target
- **SwiftUI**: User interface framework
- **Foundation**: Core data types and utilities

## Project Structure

```
DebtTracker/
├── DebtTracker.xcodeproj/
│   └── project.pbxproj
└── DebtTracker/
    ├── DebtTrackerApp.swift      # App entry point
    ├── ContentView.swift         # Main tab view
    ├── Models/
    │   ├── Debt.swift           # Debt data model
    │   └── DebtStore.swift      # Data management
    ├── Views/
    │   ├── DebtListView.swift   # Debt listing
    │   ├── AddDebtView.swift    # Add debt form
    │   └── DebtDetailView.swift # Debt details/editing
    ├── Assets.xcassets/         # App icons and colors
    └── Preview Content/         # SwiftUI preview assets
```

## Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later for deployment
- macOS Ventura or later for development

### Installation
1. Clone or download the project
2. Open `DebtTracker.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run the project (⌘+R)

### Usage

#### Adding a Debt
1. Tap the "+" button in the Debts tab
2. Fill in the debt details:
   - Title (e.g., "Lunch money", "Car loan")
   - Amount in dollars
   - Select type: "Someone owes me" or "I owe someone"
   - Enter creditor and debtor names
   - Optionally set a due date
   - Add interest rate and notes if needed
3. Tap "Save" to create the debt

#### Managing Debts
- **View Details**: Tap any debt in the list to see full details
- **Mark as Paid**: Tap the circle icon next to unpaid debts
- **Edit**: Use the "Edit" button in debt details
- **Delete**: Use the "Delete" button or swipe to delete from the list
- **Search**: Use the search bar to find specific debts
- **Filter**: Use the filter dropdown to show specific categories
- **Sort**: Use the sort dropdown to organize the list

#### Statistics
- View your financial overview in the Statistics tab
- Monitor overdue debts with clear alerts
- Track your net balance (money owed to you minus money you owe)
- See quick statistics about total, unpaid, and paid debts

## Features in Detail

### Debt Types
- **Someone owes me**: Track money others owe you (appears in green)
- **I owe someone**: Track money you owe others (appears in red)

### Due Date Management
- Optional due dates for any debt
- Automatic overdue detection
- Visual indicators for overdue status
- Day count calculations (e.g., "5 days overdue")

### Data Persistence
- All data is stored locally on your device
- No cloud sync or external servers
- Data persists between app launches
- JSON encoding for reliable data storage

## Customization

The app is designed to be easily customizable:

### Adding New Features
- Extend the `Debt` model for additional fields
- Add new computed properties for custom calculations
- Create new views for additional functionality
- Modify the `DebtStore` for new data operations

### UI Customization
- Modify colors in `Assets.xcassets`
- Adjust fonts and spacing in view files
- Add new SF Symbols icons
- Customize the accent color

## License

This project is provided as-is for educational and personal use. Feel free to modify and extend it according to your needs.

## Support

For questions or issues:
- Review the code comments for implementation details
- Check iOS and SwiftUI documentation for framework-specific questions
- Modify the code to suit your specific requirements

## Future Enhancements

Potential improvements could include:
- iCloud sync for cross-device data
- Debt categories and tags
- Payment history tracking
- Export functionality (PDF, CSV)
- Reminder notifications
- Currency conversion
- Photo attachments
- Backup and restore features
- Multiple user profiles
- Advanced analytics and charts
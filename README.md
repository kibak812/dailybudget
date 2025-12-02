# Daily Pace (데일리 페이스)

A smart daily budget management Flutter application that helps you track expenses, manage income, and maintain financial balance throughout the month.

## Overview

Daily Pace calculates your optimal daily spending budget based on your monthly budget and tracks both expenses and income. The app uses **net spending** (expenses - income) to provide accurate budget recommendations that adapt as you earn or spend throughout the month.

## Key Features

### 1. Smart Daily Budget Calculation
- Calculates daily budget using net spending: `(Monthly Budget - Net Spent) / Remaining Days`
- Income transactions increase your available daily budget
- Real-time adjustments based on your spending and earning patterns
- Visual trend chart showing how your daily budget changes over time

### 2. Comprehensive Transaction Management
- Track both expenses and income
- Category-based organization (customizable categories)
- Calendar view with visual indicators for expenses (red) and income (green)
- Quick add/edit/delete functionality
- Search and filter capabilities

### 3. Detailed Statistics
- Monthly budget overview
- Net spending tracking (expenses - income)
- Remaining budget with color-coded indicators
- Detailed breakdown showing:
  - Total expenses
  - Total income
  - Net spending
- Category-based spending analysis with pie chart

### 4. Calendar Integration
- Visual representation of daily transactions
- Color-coded markers:
  - Red: Expenses (with - prefix)
  - Green: Income (with + prefix)
- Vertical layout for better readability when both types exist
- Easy date selection and filtering

### 5. Customizable Categories
- Create custom expense and income categories
- Real-time category updates
- Delete unused categories
- Category-based filtering and analysis

## Technical Stack

- **Framework:** Flutter
- **State Management:** Riverpod
- **Local Storage:** Hive (NoSQL database)
- **Architecture:** Feature-first Clean Architecture
- **Platform:** Android (iOS compatible)

## Project Structure

```
lib/
├── app/                          # App-wide configuration
│   └── theme/                    # Theme and styling
├── core/                         # Core utilities and providers
│   ├── providers/                # Global providers
│   └── utils/                    # Formatters and utilities
└── features/                     # Feature modules
    ├── budget/                   # Budget management
    │   ├── data/                 # Data models and repositories
    │   ├── domain/               # Business logic
    │   └── presentation/         # UI and state management
    ├── daily_budget/             # Daily budget calculations
    │   ├── domain/
    │   │   ├── models/           # DailyBudgetData model
    │   │   └── services/         # DailyBudgetService
    │   └── presentation/
    │       ├── pages/            # Home page
    │       ├── providers/        # Daily budget provider
    │       └── widgets/          # Charts and UI components
    ├── settings/                 # App settings and preferences
    │   └── presentation/
    │       └── widgets/          # Category management
    ├── statistics/               # Statistics and analytics
    │   └── presentation/
    │       ├── pages/            # Statistics page
    │       └── widgets/          # Charts and summary cards
    └── transaction/              # Transaction management
        ├── data/                 # Transaction models and repository
        ├── domain/               # Transaction business logic
        └── presentation/
            ├── pages/            # Transaction list page
            └── widgets/          # Calendar, forms, list items
```

## Core Concepts

### Net Spending Calculation

Daily Pace uses **net spending** as the foundation for budget calculations:

```dart
Net Spending = Total Expenses - Total Income
Daily Budget = (Monthly Budget - Net Spent Until Yesterday) / Remaining Days
```

**Important:** The app uses **yesterday's net spending** to calculate today's daily budget. This provides:
- ✅ **Stable budget throughout the day** - Your daily budget doesn't change as you spend
- ✅ **Predictable planning** - You know your budget target for the entire day
- ✅ **Accurate comparison** - Yesterday's budget is calculated the same way (using the day before)

**Example (Day 3):**
- Monthly Budget: 1,000,000원
- Net spending until Day 2: 300,000원 (expenses: 400,000원, income: 100,000원)
- Days remaining: 28 (from Day 3 to Day 30)
- **Today's Daily Budget: (1,000,000 - 300,000) / 28 = 25,000원**
- This amount stays the same all day, regardless of today's spending

**Why this approach?**

If we used today's spending in real-time:
- 10:00 AM: You spend 10,000원 → Daily budget changes immediately
- 2:00 PM: You spend another 5,000원 → Daily budget changes again
- Result: Confusing and unstable budget display

With yesterday's data:
- Your daily budget remains constant throughout the day
- Tomorrow it will adjust based on today's actual spending
- Provides a stable target to aim for

### Data Flow

1. **User Input** → Transactions (expenses/income)
2. **Transaction Repository** → Stores in Hive database
3. **Transaction Provider** → Notifies listeners
4. **Daily Budget Service** → Calculates metrics
5. **Daily Budget Provider** → Provides computed data
6. **UI Components** → Display results

## Recent Changes

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

### Phase 5 Highlights (2025-12-02)
- ✅ Changed to net spending-based budget calculation (expenses - income)
- ✅ **Improved calculation stability**: Uses yesterday's data to prevent real-time fluctuations
- ✅ Moved statistics to proper Statistics page with detailed breakdown
- ✅ Improved calendar UI with vertical layout and better readability
- ✅ Fixed category list reactivity issues (Riverpod pattern)
- ✅ Added chart period filtering (1주/2주/1달)
- ✅ Removed graph legend for cleaner UI

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Android device or emulator

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd daily_pace
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

4. Build for release:
```bash
flutter build apk --release
```

## Development

### Running Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

### Building
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release
```

## Architecture Decisions

### Why Riverpod?
- Type-safe state management
- Compile-time safety
- Better testability
- Automatic disposal of resources

### Why Hive?
- Fast NoSQL database
- No native dependencies
- Works offline
- Easy to use with Flutter

### Why Feature-First Architecture?
- Better scalability
- Clear separation of concerns
- Easy to navigate codebase
- Modular and maintainable

## Contributing

This is a personal project, but suggestions and feedback are welcome.

## License

This project is private and not licensed for public use.

## Acknowledgments

- Built with Flutter and Riverpod
- Uses table_calendar for calendar functionality
- Uses fl_chart for data visualization
- Designed and developed with assistance from Claude Code

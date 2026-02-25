# Catch Ride Mobile App - Project Structure Analysis

This document outlines the architecture and organization of the Catch Ride mobile application.

## 🏗 Architecture Overview
The project follows a **Feature-based MVC** (Model-View-Controller) pattern, leveraging **GetX** for state management, dependency injection, and routing.

### 1. State Management (Controllers)
- **Path**: `lib/controllers/`
- **Pattern**: Business logic is decoupled from the UI using `GetxController`.
- **Reactivity**: Observable variables (`.obs`) are used with `Obx` widgets for real-time UI updates.
- **Example**: `AddNewListingController` manages a multi-step form state and allows data sharing between `AddNewListingView` and `ListingPreviewView`.

### 2. UI Organization (Views)
- **Path**: `lib/view/`
- **Structure**: Organized by user role (e.g., `trainer`) and then by specific feature modules (e.g., `list`, `bookings`, `home`).
- **Flow**: Multi-step forms use a `_currentStep` state variable to switch between sub-widgets dynamically.

### 3. Design System (Common Widgets)
- **Path**: `lib/widgets/`
- **Library**: A set of standardized, reusable widgets:
    - `CommonText`: Standardized typography.
    - `CommonTextField`: Reusable form inputs with consistent styling.
    - `CommonImageView`: Handles local and network image rendering.
    - `CommonButton`: Standardized action buttons.
- **Benefit**: Ensures visual consistency and simplifies global design updates.

### 4. Constants & Theme
- **Path**: `lib/constant/`
- **AppColors**: Centralized color palette.
- **AppTextSizes**: Core typography sizing.
- **AppStrings**: Localized or centralized hardcoded strings.
- **AppTheme**: Global `ThemeData` for `GetMaterialApp`.

---

## 📂 Directory Map
```text
lib/
├── constant/        # Design tokens & strings
├── controllers/     # Business logic (GetX)
├── models/          # Data classes (POJOs)
├── view/            # UI Screens
│   └── trainer/     # Trainer-specific modules
│       ├── home/    # Dashboard & Details
│       ├── list/    # Listing Management
│       └── bookings/ # Booking Management
├── widgets/         # Reusable UI components
├── main.dart        # Entry point
└── my_app.dart      # Application config (Theme, Routing)
```

## 🛠 Coding Standards
1. **Separation of Concerns**: UI code stays in `view/`, while logic and state stay in `controllers/`.
2. **Standardized UI**: Always use `Common` widgets instead of raw Flutter widgets to maintain theme consistency.
3. **Reactive Binding**: Wrap specific reactive elements in `Obx` (avoid wrapping large chunks of static UI).
4. **Naming Convention**: Features are grouped by role first, then by functional name.

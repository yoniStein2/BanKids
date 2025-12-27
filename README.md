# KidsBank

## Getting Started

This project is a standalone **Swift Package** that contains the iOS App.

### How to Open

1. Launch **Xcode**.
2. Select **File > Open**.
3. Navigate to and select the `KidsBank/` folder (the directory containing `Package.swift`).
4. Click **Open**.

Xcode will treat the folder as a project, resolve dependencies (including The Composable Architecture), and allow you to run the app.

### Troubleshooting

- **Missing Project File**: This project uses `Package.swift` as the source of truth, so there is no `.xcodeproj` file by default. Opening the folder works seamlessly in modern Xcode.
- **Dependencies**: The project depends on `swift-composable-architecture`. Ensure you have an internet connection for Xcode to fetch it.

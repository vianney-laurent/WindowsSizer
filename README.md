# WindowsSizer

A lightweight macOS utility to resize and position windows using keyboard shortcuts. This app runs in the menu bar and allows you to quickly organize your workspace.

## Features

-   **Global Hotkeys**: Resize focused windows from anywhere.
-   **Menu Bar Integration**: Access commands via the status bar icon.
-   **Intelligent Positioning**: Respects the Dock, Menu Bar, and supports multiple monitors.
-   **Native Performance**: Built with Swift and Carbon/Accessibility APIs.

## Shortcuts

-   `Cmd` + `Option` + `F`: **Fill Screen** (Maximize without entering Full Screen mode).
-   `Cmd` + `Option` + `G`: **Left Half**.
-   `Cmd` + `Option` + `D`: **Right Half**.

## Installation

### Build from Source

1.  Clone the repository:
    ```bash
    git clone https://github.com/vianney-laurent/WindowsSizer.git
    cd WindowsSizer
    ```

2.  Build the application:
    ```bash
    swift build -c release
    ```

3.  Run the app:
    You can run the binary directly or package it into an `.app` bundle.
    ```bash
    ./.build/release/WindowsSizer
    ```

## Permissions

**Important**: This application requires **Accessibility Permissions** to control other windows.

1.  On first launch, the app may fail to resize windows.
2.  Go to **System Settings** > **Privacy & Security** > **Accessibility**.
3.  Add `WindowsSizer` (or your Terminal if running from command line) to the allowed apps.

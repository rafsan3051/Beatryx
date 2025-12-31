# Beatryx

A modern music player application built with React, TypeScript, and Capacitor for Android.

## About

Beatryx is a feature-rich music player app that provides:
- Local music playback with queue management
- Customizable themes and settings
- Device storage integration
- Smooth and responsive UI with shadcn-ui components
- Native Android capabilities via Capacitor

## Technologies Used

- **Frontend**: React + TypeScript + Vite
- **UI Library**: shadcn-ui + Tailwind CSS
- **Mobile Framework**: Capacitor
- **Runtime**: Bun (or Node.js)

## Prerequisites

Before you begin, ensure you have the following installed:

- [Node.js](https://nodejs.org/) (v18 or higher) or [Bun](https://bun.sh/)
- [Android Studio](https://developer.android.com/studio)
- [Java JDK](https://www.oracle.com/java/technologies/downloads/) (JDK 11 or higher)
- [Git](https://git-scm.com/)

## Clone and Setup

### Step 1: Clone the Repository

```bash
git clone https://github.com/rafsan3051/Beatryx.git
cd Beatryx
```

### Step 2: Install Dependencies

Using npm:
```bash
npm install
```

Or using Bun:
```bash
bun install
```

### Step 3: Build the Web App

```bash
npm run build
```

Or with Bun:
```bash
bun run build
```

## Building the Android APK

### Step 4: Sync Capacitor with Android

```bash
npx cap sync android
```

This command:
- Copies the web build to the Android project
- Updates Android dependencies
- Syncs Capacitor plugins

### Step 5: Open in Android Studio

```bash
npx cap open android
```

This will open the Android project in Android Studio.

### Step 6: Build APK in Android Studio

1. Wait for Gradle sync to complete
2. Go to **Build** → **Build Bundle(s) / APK(s)** → **Build APK(s)**
3. Wait for the build process to complete
4. Click on **locate** in the notification to find your APK

The APK will be located at:
```
android/app/build/outputs/apk/debug/app-debug.apk
```

### Alternative: Build APK from VS Code Terminal

You can also build the APK directly from VS Code terminal:

```bash
cd android
./gradlew assembleDebug
```

For Windows:
```bash
cd android
gradlew.bat assembleDebug
```

The APK will be generated at: `android/app/build/outputs/apk/debug/app-debug.apk`

## Development

To run the app in development mode:

```bash
npm run dev
```

Then open http://localhost:5173 in your browser.

To test on an Android device/emulator:

```bash
npm run build
npx cap sync android
npx cap run android
```

## Project Structure

```
Beatryx/
├── src/              # Source code
│   ├── components/   # React components
│   ├── contexts/     # React contexts
│   ├── hooks/        # Custom hooks
│   └── pages/        # Page components
├── android/          # Android native project
├── public/           # Static assets
└── capacitor.config.ts  # Capacitor configuration
```

## License

This project is licensed under the MIT License.

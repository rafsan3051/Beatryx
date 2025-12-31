# Generate App Icon

I've created a white background music icon design in `icon-source.svg`.

## Quick Generation Method

### Option 1: Online Icon Generator (Fastest - 2 minutes)
1. Open https://icon.kitchen/
2. In "Custom" tab, upload the `icon-source.svg` file OR create:
   - Background: White (#FFFFFF)
   - Foreground: Dark blue music note icon
3. Click "Download" → Select "Android" → Download
4. Extract the zip to replace files in `android/app/src/main/res/`

### Option 2: Use Capacitor Assets (Automated)
```bash
# Install package
npm install @capacitor/assets --save-dev

# Generate icons from SVG
npx @capacitor/assets generate --android icon-source.svg
```

### Option 3: Quick Test with Placeholder
For testing immediately, I can create simple colored icons. The SVG shows the design:
- White background
- Dark blue music note
- Orange accent

## After Adding Icons
```bash
npm run build
npx cap sync
cd android
./gradlew clean assembleDebug
```

The design features:
- Clean white background (professional look)
- Dark blue music note (readable on all launchers)
- Orange accent (matches your app theme)
- Works great on both light and dark mode launchers

# Test the app on iPhone (iOS)

## Important first
You **cannot build an iOS app on Windows**. iOS builds need **macOS + Xcode**.
Options:

| Option | Cost | Good for |
|---|---|---|
| Your own Mac | free (if you have one) | fastest, everyday testing |
| Cloud Mac (MacinCloud, MacStadium, etc.) | ~$25–60/mo | if you have no Mac |
| Codemagic / GitHub Actions (macOS runner) | free tier / pay | building + TestFlight uploads |
| A friend's Mac | free | one-time test |

You also need an **Apple ID**:
- **Free Apple ID** → can install on your own iPhone, but the app stops working after **7 days** (re-sign).
- **Apple Developer Program ($99/year)** → 1-year installs, TestFlight, App Store.

---

## Bundle identifier
iOS uses:

```
com.tailorapp.tailorApp
```

> (iOS bundle IDs can't contain `_`, which is why it differs from Android's
> `com.tailorapp.tailor_app`. That's normal and fine.)

---

## Step 1 — Add the iOS app in Firebase
1. Firebase console → your project → **Add app → iOS**.
2. **Apple bundle ID**: `com.tailorapp.tailorApp`
3. Register → **Download `GoogleService-Info.plist`**.
4. Put it here:
   ```
   ios/Runner/GoogleService-Info.plist
   ```
5. **In Xcode** (on the Mac), add it to the project so it gets bundled:
   right-click the **Runner** group → **Add Files to "Runner"…** → pick the plist →
   make sure **Runner** is ticked in "Add to targets" → Add.

> Skip Firebase for now if you just want to see the app on the phone — it runs
> offline without the plist.

---

## Step 2 — Run on the iPhone (from a Mac)
1. Install **Xcode** (App Store) and open it once to accept the license.
2. `sudo xcodebuild -runFirstLaunch` (installs CocoaPods support the first time).
3. Plug in the iPhone, unlock it, tap **Trust**.
4. On the iPhone: **Settings → Privacy & Security → Developer Mode → On**, then reboot.
5. In the project folder:
   ```
   flutter pub get
   cd ios && pod install && cd ..
   flutter run
   ```
   Pick your iPhone when asked.
6. First run only: on the Mac, **Xcode → Settings → Accounts → add your Apple ID**.
   In `ios/Runner.xcworkspace`, select the **Runner** target → **Signing & Capabilities**
   → tick **Automatically manage signing** → choose your **Team**. Change the
   bundle id if Xcode complains it's taken (e.g. `com.yourname.terz`), and use that
   same id in Firebase.
7. On the iPhone: **Settings → General → VPN & Device Management** → trust your
   developer certificate.

The app now opens on the iPhone.

---

## Step 3 — Later: TestFlight (for other people to test)
With the paid Apple Developer account:
1. In Xcode: **Product → Archive**.
2. **Distribute App → App Store Connect → Upload**.
3. In **App Store Connect** → your app → **TestFlight** → add testers by email.
They install the **TestFlight** app and get your build (no cable needed).

---

## What I already set up for you
- **iOS bundle id** and **deployment target 15.0** are configured.
- **`ios/Podfile`** added (platform 15.0) so CocoaPods/Firebase work.
- **Photo permission strings** added to `ios/Runner/Info.plist`
  (`NSPhotoLibraryUsageDescription`, `NSCameraUsageDescription`) — needed because
  the app can pick a shop logo. Without these, iOS would crash on the picker.

## Still to do (only you can)
1. Register the iOS app in **Firebase** and add `GoogleService-Info.plist` (Step 1).
2. Build on a **Mac** with Xcode (Step 2).

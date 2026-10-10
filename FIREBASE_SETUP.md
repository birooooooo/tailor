# Firebase setup (cloud sync)

The app is **offline-first**: it works right now with no server. Data is saved on
the phone. Turning on Firebase makes **accounts and orders sync across devices**
and survive reinstall.

The code is already wired. You only add config files + rules.

```
FirebaseService.init()
   ├─ configured  -> Firestore (offline cache + auto sync)
   └─ not set     -> LocalOrderRepository (device only)
```

Data layout:

```
users/{uid}                       owner profile (name, phone, email)
shops/{shopId}/orders/{orderId}   that shop's orders   (shopId == uid)
```

---

## Steps

### 1. Create the project
1. Go to https://console.firebase.google.com → **Add project** (e.g. `terz`).

### 2. Add the Android app
1. Click the **Android** icon.
2. Package name: `com.tailorapp.tailor_app`
3. Download **`google-services.json`** and put it here:

```
android/app/google-services.json
```

> The Gradle build auto-detects this file and enables Firebase. Without it the
> app keeps building and runs offline.

### 3. Add the iOS app (only if you build for iPhone)
1. Add an **iOS** app with bundle id `com.tailorapp.tailorApp`.
2. Download **`GoogleService-Info.plist`** and put it here:

```
ios/Runner/GoogleService-Info.plist
```

### 4. Enable sign-in
Firebase console → **Build → Authentication → Sign-in method → Email/Password → Enable**.

### 5. Create the database + rules
1. **Build → Firestore Database → Create database** (start in production mode).
2. Deploy the rules in this repo (`firestore.rules`). Either:
   - **Console:** Firestore → Rules → paste the contents of `firestore.rules` → Publish, or
   - **CLI:**
     ```
     npm i -g firebase-tools
     firebase login
     firebase use --add        # pick your project
     firebase deploy --only firestore:rules
     ```

### 6. Rebuild
```
flutter run
```
The app now uses Firestore. Sign up in the app and the data syncs.

---

## Notes / limits

- **Login by phone or name** queries the `users` collection *before* the user is
  signed in. The secure rules above forbid that. Options:
  - log in with **email** (works as-is), or
  - add a small **Cloud Function** that maps phone → email (recommended for
    production), then call it from `FirebaseAuthService._emailFor`.
- **Shop profile** (name, logo, services, styles, subscription) is still stored
  locally in `ShopProvider`. Syncing it to Firestore is the next step; the
  orders already sync.
- Keep `google-services.json` / `GoogleService-Info.plist` out of public repos if
  you prefer; the app simply falls back to offline mode without them.

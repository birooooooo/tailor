# Backend & Offline — Setup

The app is **offline-first**. It works right now with **no server at all**.
Firebase sync is wired in but stays switched off until you add one small file.

## How it works

```
OrdersProvider  →  OrderRepository  ┬─ LocalOrderRepository      (offline, on the phone)
                                    └─ FirestoreOrderRepository   (cloud + offline cache)
```

- `FirebaseService.init()` runs at startup.
  - If Firebase is configured → **Firestore** (with offline cache: it keeps
    working with no internet and syncs automatically when you're back online).
  - If not → **LocalOrderRepository** (data saved on the device).
- The screens never change — they only talk to `OrdersProvider`.

There is **no setup needed to run the app today**. Data is stored on the phone.

---

## Turn on Firebase sync (one-time, ~3 minutes)

### 1. Create the Firebase project
1. Go to https://console.firebase.google.com
2. **Add project** → give it a name (e.g. `terz`) → continue.

### 2. Add the Android app
1. In the project, click the **Android** icon.
2. **Android package name**: `com.tailorapp.tailor_app`
3. Register → **Download `google-services.json`**.
4. Put the file here:

```
android/app/google-services.json
```

### 3. (Only if you build for iPhone) add iOS
1. Add an **iOS app**, bundle id from `ios/Runner.xcodeproj`.
2. Download `GoogleService-Info.plist` → put it in `ios/Runner/`.

### 4. Let me add the Gradle plugin
The build needs the Google Services Gradle plugin. Tell me when
`google-services.json` is in place and I'll add it (2 lines), or add it yourself:

`android/settings.gradle.kts` (in the `plugins {}` block):
```kotlin
id("com.google.gms.google-services") version "4.4.2" apply false
```

`android/app/build.gradle.kts` (in the `plugins {}` block):
```kotlin
id("com.google.gms.google-services")
```

### 5. Create the Firestore database
Firebase console → **Build → Firestore Database → Create database**
(start in production or test mode).

Orders are stored at:
```
shops/shop1/orders/{orderId}
```

---

## Notes

- **Offline:** Firestore's cache is enabled (`persistenceEnabled: true`), so
  creating/editing orders offline works and syncs later.
- **Auth:** not enabled yet. When you want shop login, we add
  `firebase_auth` (phone or email) — the same pattern as orders.
- **Photos:** for garment photos in the cloud we'll add `firebase_storage`.

## What I need from you

Only this: **`android/app/google-services.json`** (downloaded in step 2).
After that the app switches from local-only to Firestore automatically.

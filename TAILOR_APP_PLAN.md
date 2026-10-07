# Tailor App — Full Structure Plan

**Product:** Kurdish clothes-tailor marketplace + shop management
**Platform:** Mobile (Android + iOS), Flutter
**Language:** Kurdish (Sorani) default, RTL — Arabic + English optional later
**Two apps in one (role-based):** Customer app + Tailor shop dashboard

---

## 1. Roles

| Role | What they do |
|---|---|
| **Customer** (کڕیار) | Browse shops, order clothes, track orders, save measurements |
| **Shop owner** (خاوەن دوکان) | Manage orders, customers, payments, workers, reports |
| **Staff / worker** (کارمەند) | Optional later: see only assigned tasks (cutting, stitching) |

One app, one login screen. After login, we check the user's `role` and show the correct UI.

---

## 2. Customer Side — Screens

1. **Splash / Onboarding** – 3 slides, choose language (کوردی default)
2. **Login / Register** – phone number + OTP (normal in Iraq/Kurdistan), or Google
3. **Home**
   - Search bar (shop name / area / garment)
   - Nearby shops list (cards with logo, rating, price range, open/closed)
   - Categories: کراس، شلوار، چاکەت، عەبا، کراسی ئافرەتان، جلوبەرگی منداڵان
   - "Popular / Top rated" section
4. **Shop Profile**
   - Cover + logo, photos gallery, rating & reviews
   - Services + price list
   - Working hours, address, map, distance
   - Buttons: **داواکاری بکە (Order)** / **پەیوەندی (Contact)**
5. **New Order flow (wizard)**
   - Step 1: choose garment type
   - Step 2: measurements → use saved profile / enter new / ask shop to measure
   - Step 3: fabric (customer's own or shop's) + style options (fit, collar, pockets, buttons) + reference photos
   - Step 4: delivery date + pickup or home delivery
   - Step 5: review price → confirm + pay advance
6. **Order Tracking** – status steps + chat with shop + cancel
7. **My Orders** – Active / Finished / Cancelled tabs
8. **My Measurements** – profiles for self + family members (multiple people)
9. **Chat with Shop** – text, photos (or WhatsApp deep-link)
10. **Notifications**
11. **Profile & Settings** – language, theme, address, logout

---

## 3. Tailor Dashboard — Screens

1. **Login** (shop account)
2. **Dashboard (Home)**
   - Today's new orders, orders due today, late orders
   - Income today / this month, pending payments (قەرز)
   - Quick actions: ➕ New Order, ➕ New Customer
3. **Orders**
   - **Incoming requests** → Accept / Reject / Send price quote
   - **Production Board** (kanban or filter chips by status)
   - **All orders** with search + filter
4. **Order Details**
   - Customer info, garment, measurements, style, reference photos
   - Price, advance, remaining, due date
   - Change status, assign to worker, add payment, print/share receipt
5. **Create Order (walk-in customer)** – name, phone, garment, measurements, price, advance, due date
6. **Customers** → profile → measurement history, order history, payments, notes
7. **Measurement Book** – templates per garment + visual sketch fields
8. **Payments & Invoices** – receipts, print/PDF, WhatsApp share
9. **Workers** (optional) – add staff, assign tasks, wages
10. **Reports** – daily / monthly income, expenses, profit
11. **Shop Settings** – services, price list, hours, photos, location, delivery

---

## 4. Order Status Flow

```
چاوەڕوانی پەسەندکردن  →  pending
پەسەندکرا            →  accepted
پێوانەکرا            →  measured
بڕین                 →  cutting
دوورین               →  stitching
تاقیکردنەوە          →  trial
ئامادەیە             →  ready
گەیەندرا             →  delivered
هەڵوەشێنرا           →  cancelled
```

> Please confirm these Kurdish words with a native speaker — a few may need adjusting.

Each status change is saved in a `statusHistory` list (who + when), so the customer sees a timeline.

---

## 5. Data Model (Firebase / Firestore)

```
users              { id, name, phone, email, role, language, photoUrl, createdAt }
shops              { id, ownerId, name, description, phone, whatsapp, city, area,
                     lat, lng, logoUrl, coverUrl, photos[], rating, reviewCount,
                     workingHours, isOpen, deliveryOptions[], createdAt }
shop_staff         { id, shopId, userId, role, permissions[] }
garments           { id, shopId, nameKu, nameAr, nameEn, iconUrl,
                     measurementTemplateId, basePrice, estimatedDays }
measurement_templates { id, name, garmentType, fields[{ key, labelKu, unit,
                        required, order }] }
measurements       { id, customerId, templateId, garmentType, values{}, unit,
                     notes, photos[], takenBy, version, createdAt }

orders             { id, orderNumber, customerId, shopId, status,
                     items[], totalPrice, advance, discount, remaining,
                     dueDate, deliveryType, deliveryAddress, notes,
                     referencePhotos[], statusHistory[], createdAt, updatedAt }
order_items        { id, orderId, garmentType, quantity, measurementSnapshot{},
                     styleOptions{fit,collar,pockets,buttons,lining},
                     fabricSource, fabricId, unitPrice, notes, photos[], itemStatus }

fabrics            { id, shopId, name, photo, color, pricePerMeter,
                     stockMeters, supplier }              // optional
payments           { id, orderId, shopId, amount, type, method, receiptNo,
                     date, createdBy }
reviews            { id, orderId, customerId, shopId, rating, comment,
                     photos[], createdAt }
notifications      { id, userId, title, body, type, data, isRead, createdAt }
messages           { id, conversationId, senderId, shopId, customerId, text,
                     imageUrl, createdAt }                // or WhatsApp link
conversations      { id, shopId, customerId, lastMessage, updatedAt }
```

**Important:** measurements are **snapshotted** into the order item, so if the customer edits their profile later, old orders keep the original numbers.

---

## 6. Flutter Project Structure (feature-first)

```
lib/
  main.dart
  core/
    theme/            (colors, text styles)
    constants/        (order status, garment types)
    localization/     (ku.arb, ar.arb, en.arb + RTL setup)
    utils/
    widgets/          (buttons, cards, empty states — shared)
  models/             (the classes above)
  services/           (firebase_auth, firestore, storage, fcm, print/pdf)
  providers/          (AuthProvider, OrderProvider, ShopProvider, ... )
  features/
    auth/
    customer/
      home/           shop/           order/
      tracking/       measurements/   profile/
    shop/
      dashboard/      orders/         customers/
      measurements/   payments/       workers/
      reports/        settings/
```

**Bottom navigation**

- Customer: 🏠 Home · 📦 Orders · 📏 Measurements · 👤 Profile
- Shop: 📊 Dashboard · 🧾 Orders · 👥 Customers · 💰 Reports · ⚙️ Settings

---

## 7. Tech Stack

| Need | Choice |
|---|---|
| Framework | Flutter (already installed) |
| State management | Provider (already used) or Riverpod |
| Backend | Firebase — Auth (phone OTP), Firestore, Storage, Cloud Messaging, Cloud Functions |
| Localization | `flutter_localizations` + `intl` + `.arb` files |
| RTL | `MaterialApp(directionality: TextDirection.rtl)` for Kurdish |
| PDF / receipts | `pdf` + `printing` packages |
| Maps | `google_maps_flutter` |
| Images | `image_picker` + `cached_network_image` |
| Offline | Firestore offline persistence (works with bad internet) |

### ⚠️ Kurdish font — must fix this
The current app uses **Outfit**, which does **not** support Kurdish/Arabic letters (ڕ ڵ ۆ ێ گ چ پ ژ).
Use a Kurdish-capable font, e.g.:
- **Vazirmatn** (free, Google Fonts, good Kurdish support) ← recommended
- **Noto Kufi Arabic** (Google Fonts)
- **Rabar** or **Ali** (classic Kurdish fonts, manual install)

---

## 8. Build Order (suggested roadmap)

1. **Setup** – new Flutter project, RTL + Kurdish font, theme, localization
2. **Auth** – phone OTP, role selection (customer / shop), user documents
3. **Customer: browse** – shops list + shop profile (mock data first)
4. **Customer: order flow** – wizard + create order in Firestore
5. **Shop: dashboard + orders** – incoming, accept, status board, create order
6. **Measurements** – templates + measurement book
7. **Payments + receipts** – advance, remaining, PDF/WhatsApp
8. **Tracking + notifications** – status timeline + FCM push
9. **Reports + settings**
10. **Polish** – animations, empty states, offline, testing

---

## 9. Open Questions

- Reuse this `new-chatzy` repo, or start a fresh Flutter project?
- Real payment gateway (FastPay / FIB / ZainCash) or cash + advance only?
- Home-visit measuring service by the shop?
- One shop per owner, or multiple branches?

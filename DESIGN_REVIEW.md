# Design Review — Stitch screens

Reviewed screenshots: `11.png`, `22.png`, `222.png` (customer side) and
`screen.png`, `12.png`, `1.png` (shop side).

---

## What the 6 screens are

| File | Side | Screen |
|---|---|---|
| `11.png` | Customer | Shops list (فرۆشگاکان) |
| `22.png` | Customer | Explore / Marketplace home |
| `222.png` | Customer | Garment details + size/measurement |
| `screen.png` | Shop | Dashboard (dahboard) |
| `12.png` | Shop | New order (داواکاری نوێ) |
| `1.png` | Shop | Order details (#8842) |

---

## 👍 What's good — keep this

- **Real Kurdish RTL layout** — back arrows on the right, correct direction.
- **Garment details (`222.png`) is the strongest screen.** Fabric specs, "custom
  measurement" vs "standard sizes (M/L/XL)", and a **pre-filled measurement form**
  are exactly right. This is the Hockerty idea done well.
- **Order details (`1.png`)** with the production progress bar + measurement grid
  (سەرەوە / خوارەوە) is exactly the Atelierware/Khaytly concept.
- Shop dashboard stat cards + recent orders is a good base.
- The "you are a shop/tailor? register" banner on `11.png` is a smart way to get
  shops to sign up from the customer app.

---

## 🔴 Must fix — bugs and inconsistencies

1. **Two currencies mixed.** `1.png` uses `$`, `222.png` uses دیناری عێراقی.
   →Pick **IQD** only. Show `285,000 د.ع` style. Never `$`.
2. **Math bug on order `1.png`.** نرخی ماوە (remaining) shows **$750** — same as
   total. It must be `total − discount − advance` = `750 − 30 − 300 = 420`.
   This number is money; it must be computed, never typed by hand.
3. **English headings in a Kurdish app.** `Tailor Shops`, `Kurdish Couture`,
   `Explore / Marketplace`, `Garment Details`, and dates `Oct 28, 2023`.
   →All UI text must come from the Kurdish ARB file; dates in Kurdish format
   (e.g. ٢٨/١٠/٢٠٢٣ or "٢٨ تشرینی یەکەم ٢٠٢٣").
4. **Bottom navigation differs between screens.**
   - `22.png` (customer): بازار · فرۆشگاکان · سەبەتە · هەژمارەکەم
   - `11.png` (customer): دەرزی · فرۆشگاکان · سەبەتەی داواکاری · پرۆفایل
   →Pick **one** customer nav.
5. **"سەبەتە" (cart) does not fit tailoring.** Clothes are custom orders, not a
   shopping cart. →Replace with **"داواکارییەکانم"** (My orders).
6. **Shop nav "سەرپەرشتیار"** (supervisor) is unclear as a tab. →Use
   **ڕاپۆرت** (reports) or **ڕێکخستن** (settings).
7. **Awkward / misspelled Kurdish** (needs a native speaker pass):
   - `دوایەمین` → `دوایین` (recent)
   - `قەماش` → `قوماش` (fabric)
   - `تابیەتەت` → `تایبەتمەندی` (specifications)
   - `دەستبەردا هاتۆتە` (unclear) → e.g. `ئامادەیە`
   - `بەخێر بێی کچێ` (odd greeting)
   - `مورا خەیی` / `ستار خەیی` — confirm these style names

---

## 🟠 Missing screens

**Customer**
- Login / register (phone + OTP) — nothing designed yet
- **My orders** list (active / finished)
- **Order tracking** — the customer must see the same progress bar the shop sees
  (in read-only form). This is the Deliveroo/Talabat idea.
- Notifications
- Profile / settings + saved measurements (for family members)

**Shop**
- **Incoming requests** — how does the shop *accept/reject* a customer order?
  Not designed. This is the most important missing shop screen.
- **Status control** — `1.png` shows a progress bar but no way to move the order
  from cutting → stitching → trial → ready. Needs clear buttons/kanban.
- **Customers list + measurement book** — no customer screen designed.
- **Payments & receipts** — "تۆمارکردنی پارە" button exists, but no payments
  list, receipt, or print/share.
- Reports and shop settings.

---

## 🟡 Nice-to-have

- A small revenue **chart** on the dashboard (borrow from Shopify/Tailara).
- **Empty states** ("no orders yet") for every list.
- Shop card: show **price range** and **distance** (borrow from Talabat).
- Garment page: **fabric sample** images + "upload your own reference photo".

---

## Borrow from these apps (mapped to your screens)

| Your screen | Look at | Steal |
|---|---|---|
| Garment details `222.png` | Hockerty, Indochino | step-by-step measure, save profile |
| Order details `1.png` | Atelierware, Khaytly | production board + stage history |
| Customer tracking (missing) | Talabat, Deliveroo | step timeline |
| Shop dashboard `screen.png` | Shopify, Tailara | revenue chart, filters |
| Shops list `11.png` | Talabat, Miswag | price range, distance, open/closed |

---

## Suggested order to fix & build

1. Unify **currency + numbers + dates** (one helper, used everywhere).
2. Unify **bottom navigation** for each role.
3. Native-speaker pass on all Kurdish text.
4. Design the **customer order-tracking** screen.
5. Design the **shop incoming-requests** + **status control** screens.
6. Then build screens in Flutter.

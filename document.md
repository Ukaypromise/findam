Excellent choices! Going nationwide from the start is ambitious but smart — Nigeria's rental crisis isn't just a Lagos problem. A split commission keeps it fair and aligns incentives on both sides. Mobile-first is absolutely the right call for Nigeria's market.

Let me now build out a comprehensive project blueprint for you.Here's a comprehensive project blueprint for your app — let's call it **RentNaija** for now.Now let's walk through each major dimension of the project:

---

## 💰 Business Model — Split Commission

Since you chose the split model, here's how it works in practice:

- **Tenant pays**: a flat fee equal to roughly **2–3% of annual rent** upon successful move-in confirmation. This replaces the typical 10% agent commission they'd otherwise pay.
- **Landlord pays**: a smaller **1–2% fee** when their listing is successfully rented. This incentivises landlords to close deals through the platform rather than going off-platform.
- **No upfront listing fee** — this removes the barrier for landlords to join, which is critical for supply-side growth early on.
- **Optional premium listings** for landlords who want top-of-search visibility (secondary revenue stream).

---

## 🔐 Landlord Verification (Trust System)

This is your biggest differentiator and the hardest problem to solve. A tiered badge system works best:

| Tier | What's Verified | Badge |
|------|----------------|-------|
| Basic | Phone + email | — |
| Verified | NIN / BVN via API (Prembly / YouVerify) | ✓ Verified |
| Certified | Proof of ownership (C of O, deed of assignment) | ⭐ Certified |
| Top Landlord | 3+ successful rentals, 4.5+ rating | 🏆 Top Landlord |

The NIN/BVN verification can be automated using Nigerian identity APIs like **Prembly**, **YouVerify**, or **Dojah** — they are affordable and plug in easily.

---

## 📱 App Features Breakdown

**For Tenants:**
- Search by city, neighbourhood, price range, property type
- Save favourites and set price alerts
- In-app chat with landlord (no phone number until both parties agree)
- Request inspection — pick a date/time slot
- Rate the landlord and property after a visit
- Secure commission payment via Paystack or Flutterwave

**For Landlords:**
- Create a listing with photos, video tour (up to 2 minutes), price, and lease terms
- Set available inspection slots (like Calendly but built-in)
- Receive and respond to tenant enquiries
- Get notified when a commission payment is received
- Dashboard showing views, enquiries, and bookings per listing

**For Both:**
- In-app dispute resolution (flagging fraudulent listings or bad-faith tenants)
- Review and rating system after a deal closes


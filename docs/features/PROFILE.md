# Feature: Profile

**Path:** `lib/features/profile/`  
**Pages hub:** `ProfilePage` (shell tab + `GuestAuthWall`)

---

## Purpose

User account hub and secondary flows:

- View profile / navigate to update profile  
- **Join as delivery boy**  
- **Vendor registration**  
- **Development request**  
- **Request callback**  
- **Bank detail** save (also used with wallet)  
- Legal / about / policy pages  
- Entry to wallet  

---

## Sub-domains (each with DS / repo / use case / bloc)

| Area | Bloc | Endpoint constant |
|------|------|-------------------|
| Delivery boy join | `DeliveryBoyBloc` | `/delivery-boy/join-request` |
| Vendor | `VendorBloc` | `/vendor/register` |
| Development | `DevelopmentBloc` | `/development-request` |
| Callback | `CallbackBloc` | `/request-callback` |
| Bank detail | `BankDetailBloc` | `/bank-detail` |

Profile fetch/update for the main user object also uses **auth** profile endpoints.

---

## Pages (non-exhaustive)

- `ProfilePage`, `UpdateProfileDetailsPage`, `YourAccounts`  
- Join / form pages for the sub-domains above  
- Policy / about pages  

Image pick for profile may use `image_picker`.

---

## When updating

- New join form → full Clean Architecture slice + factory bloc + l10n.  
- Do not put submission logic only in the widget.  
- Reuse validators for phone, IFSC, PAN, etc.  
- Guest wall: unauthenticated users see login CTA, not empty profile data.

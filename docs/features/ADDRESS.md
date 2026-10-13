# Feature: Address & Location

**Path:** `lib/features/address/`  
**DI:** `di/address_di.dart`  
**State:** `AddressBloc` (root provider), `MapCubit`  
**In-tree:** [ADDRESS_SYNC_README.md](../../lib/features/address/ADDRESS_SYNC_README.md)  
**Design history:** `docs/location_feature_*.md`, location permission docs

---

## Purpose

- CRUD delivery addresses  
- Set default  
- Map picker + geocoding / place search  
- Offline cache via **Hive**  
- Mock repository in mock mode  

Auth required for address routes (router redirect).

---

## Pages

- `AddressListPage` — `/addresses`  
- `AddAddressPage` — `/addresses/add`  
- `MapPickerPage` — map selection UX  

---

## API (canonical constants)

| Action | Path |
|--------|------|
| List | `GET /address/addresses` |
| Add | `POST /address/add` |
| Update | `PUT /address/:id` |
| Delete | per DS / `deleteAddress` constant |
| Default | `PUT /address/:id/default` |

ADDRESS_SYNC_README may show slightly older path variants — prefer `ApiConstants` + current remote datasource if they diverge.

---

## Offline strategy

1. Online get → remote then overwrite Hive cache  
2. Offline get → Hive  
3. Mutations → remote then update Hive on success  

Hive typeIds (see local DS / models): Address / Location adapters (e.g. 1, 2, 10).

---

## App-wide AddressBloc

Provided at root in `app.dart`. On `Unauthenticated`, root listener dispatches address reset so the next user does not see previous addresses.

Checkout and home location-sensitive features read selected/default address from this bloc.

---

## Permissions

SplashCubit + permission_handler widgets handle location permission. See:

- [LOCATION_PERMISSION_QUICK_START.md](../LOCATION_PERMISSION_QUICK_START.md)  
- [LOCATION_PERMISSION_INTEGRATION.md](../LOCATION_PERMISSION_INTEGRATION.md)  

---

## When updating

- Keep Hive adapters version-safe (typeId changes need migration).  
- Map keys / geocoding: document Android/iOS config changes.  
- state_id/city_id/area_id placeholders — replace with real location master data when API ready (noted in ADDRESS_SYNC_README).  
- Mark location_feature_implementation_status as complete when closing historical TODOs.

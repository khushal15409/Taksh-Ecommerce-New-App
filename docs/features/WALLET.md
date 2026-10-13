# Feature: Wallet

**Path:** `lib/features/wallet/`  
**DI:** `di/wallet_di.dart`  
**State:** `WalletCubit` (factory)

---

## Purpose

- Wallet **points / balance summary**  
- Linked **bank accounts**  
- **Withdrawal** request to a bank account  

This is separate from checkout payment methods (COD/Razorpay). Do not confuse wallet points with Razorpay “wallet” payment option naming in legacy enums.

---

## API

| Method | Path |
|--------|------|
| GET/POST | `/wallet` |
| GET | `/bank-detail` |

---

## Entities

- `WalletSummary`  
- `BankAccount`  
- `WithdrawalResponse`  

---

## UI

Primary UI: `lib/features/wallet/presentation/pages/wallet_page.dart`  
Profile may also deep-link into wallet. Prefer the wallet feature page as source of truth for new UI work.

---

## When updating

- Validate bank fields (IFSC, account number) with shared validators + l10n.  
- Withdrawal errors should surface backend message via Failure.  
- Keep amounts/currency formatting consistent with `AppConstants` currency helpers if present.

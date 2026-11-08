# Migration Status

## Completed migrations

- **Home feed:** migrated from `HomeListing` to canonical `FeedItem`/`Product`, including feed media and product-card handling. Commit `9e150f9`.
- **Storefronts:** migrated the read-only and owner storefront flows from `BusinessAccount` to `Store`/`MyStore`; the deprecated model and its repository callers were removed. Commit `1767889`.
- **Wallet and promotions:** updated wallet top-up paths and connected promotion availability and purchases to the documented API. Commit `f4e12e7`.
- **Product listing creation:** migrated create, promotion, and success flows to `Product`/`ProductStatus`; removed the legacy `Listing` model, related create-flow wrappers, and product legacy adapter. Commit `7972bfb`.

The form-only `ListingDraft` and `ListingRepository` retain their names, but they are not the deleted legacy `Listing` API model.

## Remaining `TODO(api)` items

| File | Unverified item |
|---|---|
| `lib/models/enums/top_up_status.dart` | Full `TopUpStatus` code set is not specified; the contract shows a top-up intent initially in `PENDING` and names the enum group, but gives no complete values. |
| `lib/models/store/call_log_request.dart` | The call-log endpoint is listed, but its request body is not specified; the current request serializes an empty object. |
| `lib/models/enums/product_subcategory.dart` | The subcategory example is abbreviated (`...`); the complete, evolving code set and category associations are not established. The model preserves unrecognized codes. |
| `lib/models/enums/payment_method.dart` | The supported payment-method codes are supplied at runtime from `/i18n/enums`; the complete backend value set is not established by the contract examples. |
| `lib/features/new_listing/repositories/listing_repository.dart` | The contract has no product-image upload endpoint. Image upload is supported only by the mock implementation. |
| `lib/features/new_listing/repositories/api_listing_repository.dart` | Same image-upload gap at the API implementation: local files cannot be uploaded there; `imageUrls` must already be URLs. |

## Questions for the backend developer

1. What are the complete `TopUpStatus` and `PaymentMethod` code sets, and can you provide the exact `/i18n/enums` response shape with localized labels?
2. Can you provide the complete `ProductSubcategory` code list and category mapping? Is it intended to change dynamically without a client release?
3. What is the exact request body and success response for `POST /storefronts/{sellerId}/call-log`? Is an empty body valid?
4. Is a product-image upload endpoint planned? If not, should clients only submit externally hosted URLs in `imageUrls`?
5. `StoreView` includes the owner's full phone number, but `ProductResponse` does not. Should product-detail phone actions fetch the public storefront by seller ID, and are there visibility or consent restrictions?

## Manual device checklist

- [ ] Home feed loads and scrolls; HLS playback starts, buffers, and recovers from a playback error.
- [ ] Search and Discover: submit text search, browse categories/subcategories, and apply/clear filters.
- [ ] Favorites: add/remove an item, reopen the screen, and verify state remains consistent.
- [ ] Public and owner store pages: load store details, status/open state, products, and statistics; verify loading, error, and empty states.
- [ ] Chat: open a seller conversation and send a message; verify seller phone actions are shown only when a phone is present and initiate the expected action.
- [ ] Create a listing in mock mode and API mode; confirm mock-only controls/media behavior and API request fields.
- [ ] Upload a video, wait for processing, and verify it is tagged to the created product.
- [ ] Promotions: purchase VIP/PREMIUM, exercise the insufficient-wallet response, and verify wallet navigation/retry behavior.
- [ ] Wallet top-up: create an intent, view its status, and verify confirmation behavior in the supported payment environment.
- [ ] Store application: submit an application and verify owner status; open store statistics and compare the displayed metrics with the response.

## Legacy symbol search

The final source search found no references to `BusinessAccount`, `BusinessAccountDraft`, the legacy `Listing` model, `ListingMedia`, `ListingStatus`, `HomeListing`, or `ProductListing`. The standalone word “Listing” remains in API documentation, navigation comments, and localized user-facing copy; those are not references to the deleted model.

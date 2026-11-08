# Migration Status

## Completed migrations

- **Home feed:** migrated from `HomeListing` to canonical `FeedItem`/`Product`, including feed media and product-card handling. Commit `9e150f9`.
- **Storefronts:** migrated the read-only and owner storefront flows from `BusinessAccount` to `Store`/`MyStore`; the deprecated model and its repository callers were removed. Commit `1767889`.
- **Wallet and promotions:** updated wallet top-up paths and connected promotion availability and purchases to the documented API. Commit `f4e12e7`.
- **Product listing creation:** migrated create, promotion, and success flows to `Product`/`ProductStatus`; removed the legacy `Listing` model, related create-flow wrappers, and product legacy adapter. Commit `7972bfb`.

The form-only `ListingDraft` and `ListingRepository` retain their names, but they are not the deleted legacy `Listing` API model.

## Run in API mode

Development defaults to mock mode. Select API mode and pass the backend URL as Dart defines at build/run time; the URL must include `/api/v1` because repository paths are appended to that prefix.

Android emulator:

```powershell
flutter run --dart-define=BACKEND_MODE=api --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

Physical Android device connected over USB:

```powershell
adb reverse tcp:8080 tcp:8080
flutter run --dart-define=BACKEND_MODE=api --dart-define=API_BASE_URL=http://localhost:8080/api/v1
```

Use `--dart-define=BACKEND_MODE=mock` to select mock mode. Do not put credentials or tokens in Dart defines; authenticated requests use the app's session store.

## Remaining contract gap

| Area | Finding |
|---|---|
| `ProductSubcategory` category mapping | All 24 codes are verified, but neither `enums.json` nor OpenAPI defines their category associations. OpenAPI's subcategory operation declares no category query parameter; the available backend endpoint returned all codes for every category query. The mapping remains unresolved. |

## Contract notes

- `POST /storefronts/{sellerId}/call-log` has no request body in OpenAPI.
- Neither `ProductResponse` nor the public `StoreProfileResponse` contains a phone field; API-mode call controls are hidden until the backend exposes a number.
- Product image upload is not defined; API listing creation only submits hosted URLs in `imageUrls`.

## Questions for the backend developer

1. Can the backend publish the authoritative category association for each `ProductSubcategory` code?
2. Is a product-image upload endpoint planned, or should clients continue to submit externally hosted URLs only?
3. Will seller phone become available through `ProductResponse`, the public storefront response, or a separate consent-aware endpoint?

## Manual device checklist

- [ ] Home feed loads and scrolls; HLS playback starts, buffers, and recovers from a playback error.
- [ ] Search and Discover: submit text search, browse categories/subcategories, and apply/clear filters.
- [ ] Favorites: add/remove an item, reopen the screen, and verify state remains consistent.
- [ ] Public and owner store pages: load store details, status/open state, products, and statistics; verify loading, error, and empty states.
- [ ] Chat: open a seller conversation and send a message; verify phone actions are shown only when a phone is present.
- [ ] Create a listing in mock mode and API mode; confirm mock-only controls/media behavior and API request fields.
- [ ] Upload a video, wait for processing, and verify it is tagged to the created product.
- [ ] Promotions: purchase BOOST/VIP/PREMIUM, exercise the insufficient-wallet response, and verify wallet navigation/retry behavior.
- [ ] Wallet top-up: create an intent, view its status, and verify confirmation behavior in the supported payment environment.
- [ ] Store application: submit an application and verify owner status; open store statistics and compare the displayed metrics with the response.

## Legacy symbol search

The final source search found no references to `BusinessAccount`, `BusinessAccountDraft`, the legacy `Listing` model, `ListingMedia`, `ListingStatus`, `HomeListing`, or `ProductListing`. The standalone word “Listing” remains in API documentation, navigation comments, and localized user-facing copy; those are not references to the deleted model.

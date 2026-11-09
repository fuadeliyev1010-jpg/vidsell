# API Coverage

Generated against the 136 HTTP operations in `docs/openapi.json` (OpenAPI 3.1). Repository matching is exact on HTTP method and path after removing the shared `/api/v1` prefix. `yes` means the API-mode dependency graph invokes that operation; `no` means it does not, including cases where a related API repository invokes a different legacy path. `mock only` means the screen displays local/mock data instead of calling the operation. Tests are classified per operation: mock-Dio repository tests count as unit tests, and live means a manual request was made to the local backend.

## `admin-controller` (37)

| Method and path | API repository method | Screens that use it | Wired in API mode | Tested |
|---|---|---|---|---|
| GET `/api/v1/admin/conversations` | none | none | no | none |
| DELETE `/api/v1/admin/conversations/{id}` | none | none | no | none |
| GET `/api/v1/admin/conversations/{id}/messages` | none | none | no | none |
| DELETE `/api/v1/admin/conversations/{id}/messages/{messageId}` | none | none | no | none |
| GET `/api/v1/admin/notifications/broadcasts` | none | none | no | none |
| POST `/api/v1/admin/notifications/broadcasts` | none | none | no | none |
| GET `/api/v1/admin/products` | none | none | no | none |
| DELETE `/api/v1/admin/products/{id}` | none | none | no | none |
| GET `/api/v1/admin/products/{id}` | none | none | no | none |
| PUT `/api/v1/admin/products/{id}` | none | none | no | none |
| POST `/api/v1/admin/products/{id}/promote` | none | none | no | none |
| DELETE `/api/v1/admin/products/{id}/promotion` | none | none | no | none |
| PATCH `/api/v1/admin/products/{id}/status` | none | none | no | none |
| GET `/api/v1/admin/reports` | none | none | no | none |
| PATCH `/api/v1/admin/reports/{id}` | none | none | no | none |
| GET `/api/v1/admin/reviews` | none | none | no | none |
| DELETE `/api/v1/admin/reviews/{id}` | none | none | no | none |
| GET `/api/v1/admin/stats` | none | none | no | none |
| GET `/api/v1/admin/stores` | none | none | no | none |
| GET `/api/v1/admin/stores/{id}` | none | none | no | none |
| POST `/api/v1/admin/stores/{id}/approve` | none | none | no | none |
| POST `/api/v1/admin/stores/{id}/reject` | none | none | no | none |
| GET `/api/v1/admin/users` | none | none | no | none |
| GET `/api/v1/admin/users/{id}` | none | none | no | none |
| POST `/api/v1/admin/users/{id}/block` | none | none | no | none |
| PATCH `/api/v1/admin/users/{id}/role` | none | none | no | none |
| POST `/api/v1/admin/users/{id}/unblock` | none | none | no | none |
| GET `/api/v1/admin/videos` | none | none | no | none |
| DELETE `/api/v1/admin/videos/{id}` | none | none | no | none |
| GET `/api/v1/admin/videos/{id}` | none | none | no | none |
| PATCH `/api/v1/admin/videos/{id}/content-type` | none | none | no | none |
| POST `/api/v1/admin/videos/{id}/pause` | none | none | no | none |
| DELETE `/api/v1/admin/videos/{id}/products/{productId}` | none | none | no | none |
| POST `/api/v1/admin/videos/{id}/resume` | none | none | no | none |
| GET `/api/v1/admin/wallets` | none | none | no | none |
| GET `/api/v1/admin/wallets/{id}/transactions` | none | none | no | none |
| POST `/api/v1/admin/wallets/{id}/transactions` | none | none | no | none |

## `auth-controller` (9)

| Method and path | API repository method | Screens that use it | Wired in API mode | Tested |
|---|---|---|---|---|
| POST `/api/v1/auth/forgot-password` | `ApiAuthRepository.requestPasswordReset` | Forgot password | yes | unit test |
| POST `/api/v1/auth/google` | none | Login (no API repository method) | no | none |
| POST `/api/v1/auth/login` | `ApiAuthRepository.login` | Login | yes | unit test |
| POST `/api/v1/auth/logout` | `ApiAuthRepository.logout` | Account/logout | yes | none |
| POST `/api/v1/auth/refresh` | `ApiClient._performTokenRefresh` | All authenticated screens after 401 | yes | none |
| POST `/api/v1/auth/register` | `ApiAuthRepository.register` | Registration | yes | unit test |
| POST `/api/v1/auth/reset-password` | `ApiAuthRepository.resetPassword` | Password reset | yes | unit test |
| POST `/api/v1/auth/send-registration-otp` | `ApiAuthRepository.sendOtp` | Registration OTP | yes | unit test |
| POST `/api/v1/auth/verify-otp` | `ApiAuthRepository.verifyOtp` | Forgot-password OTP verification | yes | unit test |

## `conversation-controller` (8)

| Method and path | API repository method | Screens that use it | Wired in API mode | Tested |
|---|---|---|---|---|
| GET `/api/v1/conversations` | none | Messages list (repository uses `/me/conversations`) | no | none |
| POST `/api/v1/conversations` | none | Start chat (repository uses `/me/conversations`) | no | none |
| DELETE `/api/v1/conversations/{conversationId}` | none | Messages list (repository uses `/me/conversations/{id}`) | no | none |
| GET `/api/v1/conversations/{conversationId}/messages` | none | Chat (repository uses `/me/conversations/{id}/messages`) | no | none |
| POST `/api/v1/conversations/{conversationId}/messages` | none | Chat (repository uses `/me/conversations/{id}/messages`) | no | none |
| DELETE `/api/v1/conversations/{conversationId}/mute` | none | none | no | none |
| POST `/api/v1/conversations/{conversationId}/mute` | none | none | no | none |
| PATCH `/api/v1/conversations/{conversationId}/read` | none | Chat (repository uses `/me/conversations/{id}/read`) | no | none |

## `favorite-controller` (4)

| Method and path | API repository method | Screens that use it | Wired in API mode | Tested |
|---|---|---|---|---|
| GET `/api/v1/favorites` | none | Favorites (repository uses `/me/favorites`) | no | none |
| DELETE `/api/v1/favorites/{productId}` | none | Favorites and product cards (repository uses `/listings/{id}/favorite`) | no | none |
| POST `/api/v1/favorites/{productId}` | none | Favorites and product cards (repository uses `/listings/{id}/favorite`) | no | none |
| GET `/api/v1/favorites/summary` | none | Favorites count (computed locally) | no | none |

## `feed-controller` (1)

| Method and path | API repository method | Screens that use it | Wired in API mode | Tested |
|---|---|---|---|---|
| GET `/api/v1/feed` | none | Home/Discover feed (repository uses `/listings`) | no | none |

## `i18n` (1)

| Method and path | API repository method | Screens that use it | Wired in API mode | Tested |
|---|---|---|---|---|
| GET `/api/v1/i18n/enums` | `ApiSubcategoryRepository.fetchForCategory`; `ApiWalletRepository.fetchPaymentMethods` | Discover filters, listing form, wallet top-up | yes | unit test |

## `interaction-controller` (6)

| Method and path | API repository method | Screens that use it | Wired in API mode | Tested |
|---|---|---|---|---|
| GET `/api/v1/videos/{videoId}/comments` | `ApiEngagementRepository.fetchVideoComments` | Video comments | yes | none |
| POST `/api/v1/videos/{videoId}/comments` | `ApiEngagementRepository.addVideoComment` | Video comments | yes | none |
| DELETE `/api/v1/videos/{videoId}/comments/{commentId}` | none | Video comments (repository uses `/comments/{id}`) | no | none |
| DELETE `/api/v1/videos/{videoId}/like` | `ApiEngagementRepository.setVideoLike` | Video feed | yes | none |
| POST `/api/v1/videos/{videoId}/like` | `ApiEngagementRepository.setVideoLike` | Video feed | yes | none |
| GET `/api/v1/videos/{videoId}/likes` | none | Video likes list | no | none |

## `notification-controller` (4)

| Method and path | API repository method | Screens that use it | Wired in API mode | Tested |
|---|---|---|---|---|
| GET `/api/v1/notifications` | none | Notifications (repository uses `/me/notifications`) | no | none |
| DELETE `/api/v1/notifications/{notificationId}` | none | Notifications (repository uses `/me/notifications/{id}`) | no | none |
| PATCH `/api/v1/notifications/{notificationId}/read` | none | Notifications (repository uses `/me/notifications/{id}`) | no | none |
| PATCH `/api/v1/notifications/read-all` | none | Notifications (repository uses `/me/notifications/read`) | no | none |

## `product-controller` (20)

| Method and path | API repository method | Screens that use it | Wired in API mode | Tested |
|---|---|---|---|---|
| GET `/api/v1/products` | none | Discover/catalog (home repository uses `/listings`) | no | none |
| POST `/api/v1/products` | `ApiListingRepository.createListing` | New listing | yes | unit test |
| DELETE `/api/v1/products/{id}` | none | My listings (repository uses `/me/listings/{id}`) | no | none |
| GET `/api/v1/products/{id}` | none | Product details (repository uses `/listings/{id}`) | no | none |
| PUT `/api/v1/products/{id}` | none | Edit listing | no | none |
| POST `/api/v1/products/{id}/activate` | `ApiUserListingRepository.updateListingStatus` | My listings | yes | none |
| POST `/api/v1/products/{id}/deactivate` | `ApiUserListingRepository.updateListingStatus` | My listings | yes | none |
| POST `/api/v1/products/{id}/share` | none | Product details (uses platform share, not API) | no | none |
| POST `/api/v1/products/{id}/submit-review` | none | Product review form (repository uses `/products/{id}/reviews`) | no | none |
| GET `/api/v1/products/brands` | none | Discover/listing brand filters | no | none |
| GET `/api/v1/products/categories` | none | Discover and listing category pickers (local category values) | no | live |
| GET `/api/v1/products/cities` | none | City selectors (repository uses `/cities`) | no | none |
| GET `/api/v1/products/conditions` | none | Listing condition selector (local enum values) | no | none |
| GET `/api/v1/products/map` | none | Discover map (home repository uses `/listings`) | no | none |
| GET `/api/v1/products/me` | `ApiUserListingRepository.fetchMyListings` | My listings | yes | none |
| GET `/api/v1/products/me/status-counts` | `ApiStatusCountRepository.fetchStatusCounts` | My listings/status tabs | yes | none |
| GET `/api/v1/products/nearby` | none | Nearby products/map | no | none |
| GET `/api/v1/products/popular/brands` | none | Listing brand suggestions | no | none |
| GET `/api/v1/products/popular/models` | none | Listing model suggestions | no | none |
| GET `/api/v1/products/subcategories` | `ApiSubcategoryRepository.fetchForCategory` | Discover filters and listing form | yes | unit test + live |

## `promotion-controller` (2)

| Method and path | API repository method | Screens that use it | Wired in API mode | Tested |
|---|---|---|---|---|
| POST `/api/v1/products/{id}/promote` | `ApiPromotionRepository.promoteProduct` | Listing promotion | yes | unit test |
| GET `/api/v1/promotions/availability` | `ApiPromotionRepository.fetchAvailability` | Listing promotion | yes | unit test |

## `report-controller` (2)

| Method and path | API repository method | Screens that use it | Wired in API mode | Tested |
|---|---|---|---|---|
| POST `/api/v1/products/{productId}/report` | none | Product report (repository uses `/listings/{id}/reports`) | no | none |
| POST `/api/v1/users/{userId}/report` | none | User report | no | none |

## `review-controller` (2)

| Method and path | API repository method | Screens that use it | Wired in API mode | Tested |
|---|---|---|---|---|
| GET `/api/v1/products/{productId}/reviews` | `ApiEngagementRepository.fetchProductReviews` | Product reviews/details | yes | none |
| POST `/api/v1/products/{productId}/reviews` | `ApiEngagementRepository.addProductReview` | Product review form | yes | none |

## `search-controller` (7)

| Method and path | API repository method | Screens that use it | Wired in API mode | Tested |
|---|---|---|---|---|
| GET `/api/v1/search` | `ApiSearchRepository.search` | Search | yes | none |
| GET `/api/v1/search/autocomplete` | none | Search suggestions (repository uses `/search/suggestions`) | no | none |
| DELETE `/api/v1/search/history` | none | Search history | no | none |
| GET `/api/v1/search/history` | none | Search history | no | none |
| GET `/api/v1/search/saved` | none | Saved searches (repository uses `/me/saved-searches`) | no | none |
| POST `/api/v1/search/saved` | none | Save search (repository uses `/me/saved-searches`) | no | none |
| DELETE `/api/v1/search/saved/{savedSearchId}` | none | Saved searches (repository uses `/me/saved-searches/{id}`) | no | none |

## `settings-controller` (2)

| Method and path | API repository method | Screens that use it | Wired in API mode | Tested |
|---|---|---|---|---|
| GET `/api/v1/settings` | `ApiSettingsRepository.fetchSettings` | Settings | yes | none |
| PUT `/api/v1/settings` | `ApiSettingsRepository.updateSettings` | Settings | yes | unit test |

## `storefront-controller` (13)

| Method and path | API repository method | Screens that use it | Wired in API mode | Tested |
|---|---|---|---|---|
| GET `/api/v1/storefronts/{sellerId}` | `ApiBusinessRepository.fetchPublicStore` | Public storefront | yes | unit test |
| POST `/api/v1/storefronts/{sellerId}/call-log` | none | Product details/map call actions (opens phone app directly) | no | none |
| DELETE `/api/v1/storefronts/{sellerId}/follow` | none | Store follow (repository uses `/stores/{id}/follow`) | no | none |
| POST `/api/v1/storefronts/{sellerId}/follow` | none | Store follow (repository uses `/stores/{id}/follow`) | no | none |
| GET `/api/v1/storefronts/{sellerId}/products` | `ApiBusinessRepository.fetchPublicStoreProducts` | Public storefront products | yes | unit test |
| GET `/api/v1/storefronts/{sellerId}/response-rate` | none | Public storefront response rate | no | none |
| GET `/api/v1/storefronts/following` | none | Followed stores (repository uses `/me/follows`) | no | none |
| GET `/api/v1/storefronts/me` | `ApiBusinessRepository.fetchMyStore` | My storefront/cabinet | yes | unit test |
| PUT `/api/v1/storefronts/me` | `ApiBusinessRepository.updateMyStore` | Edit storefront | yes | unit test |
| POST `/api/v1/storefronts/me/application` | `ApiBusinessRepository.createStoreApplication` | Store application | yes | unit test |
| POST `/api/v1/storefronts/me/deactivate` | `ApiBusinessRepository.deactivateMyStore` | Store settings | yes | unit test |
| POST `/api/v1/storefronts/me/reactivate` | `ApiBusinessRepository.reactivateMyStore` | Store settings | yes | unit test |
| GET `/api/v1/storefronts/me/statistics` | `ApiBusinessRepository.fetchMyStoreStatistics` | Business statistics | yes | unit test |

## `user-block-controller` (3)

| Method and path | API repository method | Screens that use it | Wired in API mode | Tested |
|---|---|---|---|---|
| DELETE `/api/v1/users/{blockedId}/block` | none | Unblock/blocked-users management | no | none |
| POST `/api/v1/users/{blockedId}/block` | `ApiEngagementRepository.blockUser` | User block action | yes | unit test |
| GET `/api/v1/users/blocked` | none | Blocked users | no | none |

## `user-controller` (2)

| Method and path | API repository method | Screens that use it | Wired in API mode | Tested |
|---|---|---|---|---|
| GET `/api/v1/users/me` | `ApiProfileRepository.fetchProfile` | Profile | yes | unit test |
| PUT `/api/v1/users/me` | `ApiProfileRepository.updateProfile` | Edit profile | yes | unit test |

## `video-controller` (8)

| Method and path | API repository method | Screens that use it | Wired in API mode | Tested |
|---|---|---|---|---|
| POST `/api/v1/videos` | `ApiVideoRepository.upload` | Listing video upload | yes | unit test |
| DELETE `/api/v1/videos/{id}` | none | Video management | no | none |
| GET `/api/v1/videos/{id}` | `ApiVideoRepository.get` | Listing video processing poll | yes | unit test |
| POST `/api/v1/videos/{id}/pause` | `ApiVideoRepository.pause` | Video management | yes | none |
| GET `/api/v1/videos/{id}/products` | none | Video product tags | no | none |
| DELETE `/api/v1/videos/{id}/products/{productId}` | none | Video product tags | no | none |
| POST `/api/v1/videos/{id}/products/{productId}` | `ApiVideoRepository.tagProduct` | Listing video attachment | yes | unit test |
| POST `/api/v1/videos/{id}/resume` | `ApiVideoRepository.resume` | Video management | yes | none |

## `wallet-controller` (5)

| Method and path | API repository method | Screens that use it | Wired in API mode | Tested |
|---|---|---|---|---|
| GET `/api/v1/wallet/balance` | `ApiWalletRepository.fetchWallet` | Wallet | yes | unit test |
| POST `/api/v1/wallet/top-up` | `ApiWalletRepository.createTopUpIntent` | Wallet top-up | yes | unit test |
| GET `/api/v1/wallet/top-up/{id}` | `ApiWalletRepository.fetchTopUpIntent` | Wallet top-up status | yes | unit test |
| POST `/api/v1/wallet/top-up/{id}/confirm` | `ApiWalletRepository.confirmTopUp` | Wallet top-up | yes | unit test |
| GET `/api/v1/wallet/transactions` | `ApiWalletRepository.fetchTransactions` | Wallet transactions | yes | unit test |

## Endpoints With No App Usage

These are the 89 OpenAPI operations whose exact method/path is not called by an API repository. A screen name in the matrix can indicate related UI that currently uses a legacy path or local data; it does not mean the listed OpenAPI operation is called.

- `admin-controller` (all 37): `GET /admin/conversations`, `DELETE /admin/conversations/{id}`, `GET /admin/conversations/{id}/messages`, `DELETE /admin/conversations/{id}/messages/{messageId}`, `GET /admin/notifications/broadcasts`, `POST /admin/notifications/broadcasts`, `GET /admin/products`, `DELETE /admin/products/{id}`, `GET /admin/products/{id}`, `PUT /admin/products/{id}`, `POST /admin/products/{id}/promote`, `DELETE /admin/products/{id}/promotion`, `PATCH /admin/products/{id}/status`, `GET /admin/reports`, `PATCH /admin/reports/{id}`, `GET /admin/reviews`, `DELETE /admin/reviews/{id}`, `GET /admin/stats`, `GET /admin/stores`, `GET /admin/stores/{id}`, `POST /admin/stores/{id}/approve`, `POST /admin/stores/{id}/reject`, `GET /admin/users`, `GET /admin/users/{id}`, `POST /admin/users/{id}/block`, `PATCH /admin/users/{id}/role`, `POST /admin/users/{id}/unblock`, `GET /admin/videos`, `DELETE /admin/videos/{id}`, `GET /admin/videos/{id}`, `PATCH /admin/videos/{id}/content-type`, `POST /admin/videos/{id}/pause`, `DELETE /admin/videos/{id}/products/{productId}`, `POST /admin/videos/{id}/resume`, `GET /admin/wallets`, `GET /admin/wallets/{id}/transactions`, `POST /admin/wallets/{id}/transactions`.
- `auth-controller`: `POST /auth/google`.
- `conversation-controller` (all 8): `GET /conversations`, `POST /conversations`, `DELETE /conversations/{conversationId}`, `GET /conversations/{conversationId}/messages`, `POST /conversations/{conversationId}/messages`, `DELETE /conversations/{conversationId}/mute`, `POST /conversations/{conversationId}/mute`, `PATCH /conversations/{conversationId}/read`.
- `favorite-controller` (all 4): `GET /favorites`, `DELETE /favorites/{productId}`, `POST /favorites/{productId}`, `GET /favorites/summary`.
- `feed-controller`: `GET /feed`.
- `interaction-controller`: `DELETE /videos/{videoId}/comments/{commentId}`, `GET /videos/{videoId}/likes`.
- `notification-controller` (all 4): `GET /notifications`, `DELETE /notifications/{notificationId}`, `PATCH /notifications/{notificationId}/read`, `PATCH /notifications/read-all`.
- `product-controller` (14): `GET /products`, `DELETE /products/{id}`, `GET /products/{id}`, `PUT /products/{id}`, `POST /products/{id}/share`, `POST /products/{id}/submit-review`, `GET /products/brands`, `GET /products/categories`, `GET /products/cities`, `GET /products/conditions`, `GET /products/map`, `GET /products/nearby`, `GET /products/popular/brands`, `GET /products/popular/models`.
- `report-controller` (both): `POST /products/{productId}/report`, `POST /users/{userId}/report`.
- `search-controller` (6): `GET /search/autocomplete`, `DELETE /search/history`, `GET /search/history`, `GET /search/saved`, `POST /search/saved`, `DELETE /search/saved/{savedSearchId}`.
- `storefront-controller`: `POST /storefronts/{sellerId}/call-log`, `DELETE /storefronts/{sellerId}/follow`, `POST /storefronts/{sellerId}/follow`, `GET /storefronts/{sellerId}/response-rate`, `GET /storefronts/following`.
- `user-block-controller`: `DELETE /users/{blockedId}/block`, `GET /users/blocked`.
- `video-controller`: `DELETE /videos/{id}`, `GET /videos/{id}/products`, `DELETE /videos/{id}/products/{productId}`.

## Screens Still Using Mock or Local Data in API Mode

- **Discover > Stores** displays a hard-coded list of eight stores and localized mock descriptions in `StoresPage`; it does not call a storefront-list endpoint. The OpenAPI document has no general public stores-list operation.
- **Discover and New Listing category selectors** use the local `CategoryItem.categories` catalog rather than `GET /products/categories`. Listing condition controls similarly use local enum values rather than `GET /products/conditions`. These are static local choices, not API-backed data.

## Test Notes

The unit coverage above refers to mock-Dio repository tests, not live server verification. P0 auth, profile, and settings operations have mock-Dio tests that assert exact method, path, and request body. Other API tests cover business/store application and statistics, listing/video creation, wallet/top-up/promotion, subcategories/enums, and one user-block operation. Messaging and engagement tests exercise several legacy paths (such as `/me/conversations`, `/me/favorites`, and `/stores/{id}/follow`), so they do not count as tests of the corresponding OpenAPI operations. The only live requests made during this audit were `GET /products/categories` and `GET /products/subcategories`; the latter returned all subcategory codes for each attempted category filter.

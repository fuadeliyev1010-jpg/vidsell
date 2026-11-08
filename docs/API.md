# API Reference

This backend reference covers the application API and the [Admin API](#admin-api).
Admin integration details, request limits and response schemas are documented together below.

Base URL: `/api/v1`

App is a **contact-based marketplace** (Turkish primary, English secondary). Buyers find products in the feed and message/call sellers directly. No in-app checkout. Currency is **TRY (₺)**. Clients send `X-App-Language: tr|en` (default `tr`); all user-visible server text is localized.

---

## Auth (public)

All auth endpoints are public. No authentication required.

---

### POST /api/v1/auth/send-registration-otp

Send a 6-digit OTP to a phone number for registration. The phone must not already be registered.

**Request:**
```json
{
  "countryCode": "+994",
  "phoneNumber": "501234567"
}
```

| Field | Type | Validation |
|-------|------|------------|
| `countryCode` | string | Required, 2-5 characters |
| `phoneNumber` | string | Required |

**Response 200:**
```json
{
  "message": "OTP sent"
}
```

**Errors:**
| Status | Code | When |
|--------|------|------|
| 400 | Validation failed | Blank fields |
| 409 | Phone number already registered | Phone exists in DB |
| 429 | Too many requests | Rate limit exceeded (3 req / 10 min) |

---

### POST /api/v1/auth/register

Register a new account. Requires a valid OTP obtained from `/send-registration-otp`.

**Request:**
```json
{
  "fullName": "John Doe",
  "countryCode": "+994",
  "phoneNumber": "501234567",
  "password": "securePass123",
  "gender": "MALE",
  "termsAccepted": true,
  "role": "BUYER",
  "verificationCode": "483129"
}
```

| Field | Type | Validation |
|-------|------|------------|
| `fullName` | string | Required, max 100 characters |
| `countryCode` | string | Required, 2-5 characters |
| `phoneNumber` | string | Required, digits only, 7-15 characters |
| `password` | string | Required, 8-100 characters |
| `gender` | string (enum) | `MALE` or `FEMALE`, optional |
| `termsAccepted` | boolean | Required, must be `true` |
| `role` | string (enum) | `BUYER` or `SELLER`, optional (defaults to `BUYER`) |
| `verificationCode` | string | Required, 4-6 characters |

**Response 201:**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiJ9...",
  "tokenType": "Bearer",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "fullName": "John Doe",
    "countryCode": "+994",
    "phoneNumber": "501234567",
    "avatarUrl": null,
    "gender": "MALE",
    "role": "BUYER",
    "createdAt": "2026-06-26T12:00:00Z"
  }
}
```

**Errors:**
| Status | Code | When |
|--------|------|------|
| 400 | Validation failed | Invalid fields or terms not accepted |
| 401 | Invalid or expired verification code | OTP wrong/expired |
| 409 | Phone number already registered | Phone exists in DB |

---

### POST /api/v1/auth/login

Authenticate with phone number and password.

**Request:**
```json
{
  "countryCode": "+994",
  "phoneNumber": "501234567",
  "password": "securePass123"
}
```

| Field | Type | Validation |
|-------|------|------------|
| `countryCode` | string | Required, 2-5 characters |
| `phoneNumber` | string | Required |
| `password` | string | Required |

**Response 200:**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiJ9...",
  "tokenType": "Bearer",
  "user": { "...same as register..." }
}
```

**Errors:**
| Status | Code | When |
|--------|------|------|
| 400 | Validation failed | Blank fields |
| 404 | Invalid phone or password | Wrong credentials (generic message, no enumeration) |

---

### POST /api/v1/auth/google

Sign in with a Google ID token (OAuth2). The email in the verified token is matched against an existing account's email; if no account is linked, a 404 is returned.

**Request:**
```json
{
  "idToken": "eyJhbGciOiJSUzI1NiJ9..."
}
```

| Field | Type | Validation |
|-------|------|------------|
| `idToken` | string | Required |

**Response 200:** same shape as login (`accessToken` + `refreshToken` + `tokenType` + `user`).

**Errors:**
| Status | Code | When |
|--------|------|------|
| 400 | Validation failed | Blank idToken |
| 401 | Invalid Google token | Token rejected by Google (`tokeninfo`) or wrong audience |
| 404 | No account is linked to this Google email | Verified email has no matching account |

---

### POST /api/v1/auth/refresh

Exchange a valid refresh token for a new access + refresh token pair.

**Request:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiJ9..."
}
```

| Field | Type | Validation |
|-------|------|------------|
| `refreshToken` | string | Required |

**Response 200:**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiJ9...",
  "tokenType": "Bearer",
  "user": { "...same as register..." }
}
```

**Errors:**
| Status | Code | When |
|--------|------|------|
| 400 | Validation failed | Blank token |
| 401 | Invalid or expired refresh token | Token expired / tampered / malformed |

---

### POST /api/v1/auth/logout

Blacklist the current access token. After logout, the token can no longer be used.

**Headers:**
```
Authorization: Bearer <accessToken>
```

**Response 204:** No content

**Errors:**
| Status | Code | When |
|--------|------|------|
| 401 | Invalid or expired access token | Token expired / tampered / malformed |

---

### POST /api/v1/auth/forgot-password

Send an OTP to a phone number for password reset. Silently returns 200 even if the phone is not found (prevents phone enumeration).

**Request:**
```json
{
  "countryCode": "+994",
  "phoneNumber": "501234567"
}
```

**Response 200:**
```json
{
  "message": "If the account exists, an OTP has been sent"
}
```

**Errors:**
| Status | Code | When |
|--------|------|------|
| 400 | Validation failed | Blank fields |
| 429 | Too many requests | Rate limit exceeded (3 req / 10 min) |

---

### POST /api/v1/auth/verify-otp

Validate the OTP sent via `/forgot-password`. Returns a short-lived JWT reset token.

**Request:**
```json
{
  "countryCode": "+994",
  "phoneNumber": "501234567",
  "code": "483129"
}
```

| Field | Type | Validation |
|-------|------|------------|
| `countryCode` | string | Required, 2-5 characters |
| `phoneNumber` | string | Required |
| `code` | string | Required, 4-6 characters |

**Response 200:**
```json
{
  "resetToken": "eyJhbGciOiJIUzI1NiJ9..."
}
```

**Errors:**
| Status | Code | When |
|--------|------|------|
| 400 | Validation failed | Blank fields |
| 401 | Invalid or expired verification code | Wrong code, expired, or already used |

---

### POST /api/v1/auth/reset-password

Reset the password using a valid reset token (obtained from `/verify-otp`).

**Request:**
```json
{
  "resetToken": "eyJhbGciOiJIUzI1NiJ9...",
  "newPassword": "newSecurePass456"
}
```

| Field | Type | Validation |
|-------|------|------------|
| `resetToken` | string | Required |
| `newPassword` | string | Required, 8-100 characters |

**Response 200:**
```json
{
  "message": "Password has been reset successfully"
}
```

**Errors:**
| Status | Code | When |
|--------|------|------|
| 400 | Validation failed | Blank fields or password too short |
| 401 | Invalid or expired reset token | Token expired / tampered / malformed |

---

## Users (authenticated)

All user endpoints require a valid access token in the `Authorization` header.

---

### GET /api/v1/users/me

Get the authenticated user's profile.

**Headers:**
```
Authorization: Bearer <accessToken>
```

**Response 200:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "fullName": "John Doe",
  "countryCode": "+994",
  "phoneNumber": "501234567",
  "avatarUrl": null,
  "gender": "MALE",
  "role": "BUYER",
  "createdAt": "2026-06-26T12:00:00Z"
}
```

**Errors:**
| Status | Code | When |
|--------|------|------|
| 401 | Unauthorized | Missing or invalid access token |
| 404 | User not found | Authenticated user no longer exists |

---

### PUT /api/v1/users/me

Update the authenticated user's profile. Only provided fields are updated.

**Headers:**
```
Authorization: Bearer <accessToken>
```

**Request:**
```json
{
  "fullName": "New Name",
  "avatarUrl": "https://example.com/avatar.jpg"
}
```

| Field | Type | Validation |
|-------|------|------------|
| `fullName` | string | Optional, max 100 characters |
| `avatarUrl` | string | Optional, max 500 characters |

**Response 200:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "fullName": "New Name",
  "countryCode": "+994",
  "phoneNumber": "501234567",
  "avatarUrl": "https://example.com/avatar.jpg",
  "gender": "MALE",
  "role": "BUYER",
  "createdAt": "2026-06-26T12:00:00Z"
}
```

**Errors:**
| Status | Code | When |
|--------|------|------|
| 400 | Validation failed | Field too long |
| 401 | Unauthorized | Missing or invalid access token |
| 404 | User not found | Authenticated user no longer exists |

---

## Products (authenticated)

All product endpoints require a valid access token in the `Authorization` header, except `GET /api/v1/products/{id}` and `GET /api/v1/products` which are public (read-only).

---

### POST /api/v1/products

Create a new product listing. The authenticated user becomes the seller.

**Headers:**
```
Authorization: Bearer <accessToken>
```

**Request:**
```json
{
  "title": "iPhone 17 Pro",
  "description": "Brand new, sealed box",
  "price": 2890.24,
  "currency": "TRY",
  "category": "ELECTRONICS",
  "subcategory": "PHONES",
  "storage": "256GB",
  "brand": "Apple",
  "modelName": "iPhone 17 Pro",
  "color": "Black",
  "city": "Baku",
  "condition": "NEW",
  "imageUrls": ["https://example.com/img.jpg"]
}
```

| Field | Type | Validation |
|-------|------|------------|
| `title` | string | Required, max 200 characters |
| `description` | string | Optional, max 10000 characters |
| `price` | number | Required, must be > 0 |
| `currency` | string | Optional, 3-letter code (defaults to `TRY`) |
| `category` | string (enum) | Required: `ELECTRONICS`, `TRANSPORT`, `REAL_ESTATE`, `HOME_APPLIANCES`, `SPECIAL_OCCASION`, `COSMETICS` |
| `subcategory` | string (enum) | Optional, must belong to `category` (see `GET /api/v1/products/subcategories`) |
| `storage` | string | Optional, max 50 characters |
| `brand` | string | Optional, max 100 characters |
| `modelName` | string | Optional, max 100 characters |
| `color` | string | Optional, max 50 characters |
| `city` | string | Optional, max 100 characters |
| `condition` | string (enum) | Optional: `NEW`, `LIKE_NEW`, `USED`, `FOR_PARTS` |
| `imageUrls` | string[] | Optional, JSON array of URL strings |

**Response 201:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "sellerId": "550e8400-e29b-41d4-a716-446655440001",
  "sellerFullName": "Tech Store",
  "sellerAvatarUrl": null,
  "title": "iPhone 17 Pro",
  "description": "Brand new, sealed box",
  "price": 2890.24,
  "currency": "TRY",
  "category": "ELECTRONICS",
  "subcategory": "PHONES",
  "storage": "256GB",
  "brand": "Apple",
  "modelName": "iPhone 17 Pro",
  "color": "Black",
  "city": "Baku",
  "condition": "NEW",
  "viewCount": 0,
  "status": "ACTIVE",
  "promotionType": "NONE",
  "promotionEndsAt": null,
  "imageUrls": "[\"https://example.com/img.jpg\"]",
  "createdAt": "2026-06-27T12:00:00Z",
  "updatedAt": "2026-06-27T12:00:00Z"
}
```

**Errors:**
| Status | Code | When |
|--------|------|------|
| 400 | Validation failed | Missing title/price, invalid enum values, `subcategory` does not match `category` |
| 404 | Seller not found | Authenticated user does not exist |

---

### POST /api/v1/products/{id}/promote

Promote a product to BOOST, VIP, or PREMIUM. Only the owning seller can promote. Sets `promotionType` and `promotionEndsAt` (= now + `days`). The OpenAPI schema also lists `NONE`, though this endpoint reference says `NONE` is rejected.

**Headers:**
```
Authorization: Bearer <accessToken>
```

**Request:**
```json
{
  "promotionType": "VIP",
  "days": 7
}
```

| Field | Type | Validation |
|-------|------|------------|
| `promotionType` | string (enum) | Required: `BOOST`, `VIP`, or `PREMIUM` (`NONE` rejected by this reference) |
| `days` | integer | Required, 1–30 |

**Response 200:** Product object with `promotionType` set.

**Errors:**
| Status | Code | When |
|--------|------|------|
| 400 | Validation failed | Invalid `promotionType`, days out of 1–30 range |
| 401 | Unauthorized | Not the product owner |
| 404 | Product not found | Product does not exist or was deleted |

---

### GET /api/v1/products/{id}

Get a single product by ID (excludes deleted products). Increments the product's `viewCount`.

**Response 200:** Same shape as create response.

**Errors:**
| Status | Code | When |
|--------|------|------|
| 404 | Product not found | Product does not exist or was deleted |

---

### PUT /api/v1/products/{id}

Update a product. Only the owning seller can update.

**Headers:**
```
Authorization: Bearer <accessToken>
```

**Request:** Same fields as create, but all optional.

**Response 200:** Updated product object.

**Errors:**
| Status | Code | When |
|--------|------|------|
| 400 | Validation failed | Field too long |
| 401 | Unauthorized | Not the product owner |
| 404 | Product not found | Product does not exist or was deleted |

---

### DELETE /api/v1/products/{id}

Soft-delete a product (sets status to `DELETED`). Only the owning seller can delete.

**Headers:**
```
Authorization: Bearer <accessToken>
```

**Response 204:** No content

**Errors:**
| Status | Code | When |
|--------|------|------|
| 401 | Unauthorized | Not the product owner |
| 404 | Product not found | Product does not exist or was deleted |

---

### GET /api/v1/products

List products with optional filters. By default returns active products.

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `sellerId` | UUID | Filter by seller (includes non-active) |
| `category` | string | Filter by category (active only) |
| `subcategory` | string | Filter by subcategory (active only) |
| `city` | string | Filter by city (case-insensitive) |
| `brand` | string | Filter by brand (case-insensitive) |
| `modelName` | string | Filter by model name (case-insensitive) |
| `color` | string | Filter by color (case-insensitive) |
| `storage` | string | Filter by storage (case-insensitive) |
| `condition` | string | Filter by condition enum |
| `minPrice` | number | Minimum price |
| `maxPrice` | number | Maximum price |
| `page` | int | Page number (default 0) |
| `size` | int | Page size (default 20) |

**Response 200:**
```json
{
  "content": [ { "...product object..." } ],
  "totalElements": 1,
  "totalPages": 1,
  "number": 0,
  "size": 20
}
```

---

### GET /api/v1/products/categories

List all product categories (active filter chips for the catalog screen).

**Response 200:**
```json
[ "ELECTRONICS", "TRANSPORT", "REAL_ESTATE", "HOME_APPLIANCES", "SPECIAL_OCCASION", "COSMETICS" ]
```

---

### GET /api/v1/products/subcategories

List all product subcategories (subcategory filter chips for the catalog screen).

**Response 200:**
```json
[ "PHONES", "COMPUTERS", "TABLETS", "TV_AUDIO", "ACCESSORIES", "CARS", "...", "HAIRCARE" ]
```

---

## Videos (authenticated)

All video endpoints require a valid access token. Video statuses: `UPLOADED`, `PROCESSING`, `PROCESSED`, `PAUSED`, `FAILED`. Only `PROCESSED` videos appear in the feed — pausing a video (status → `PAUSED`) hides it from the feed until it is resumed.

---

### POST /api/v1/videos

Upload a video (`multipart/form-data`, `file` field). Supports mp4, webm, mov, 3gp (max 200MB).

**Response 201:**
```json
{
  "id": "…", "ownerId": "…", "ownerFullName": "…", "ownerAvatarUrl": null,
  "originalFileName": "clip.mp4", "contentType": "video/mp4", "sizeBytes": 3145728,
  "status": "PROCESSING", "videoContentType": "RECENT",
  "rawUrl": "…", "hlsUrl": null, "thumbnailUrl": null, "durationSeconds": null,
  "productIds": [], "createdAt": "…", "updatedAt": "…"
}
```

---

### GET /api/v1/videos/{id}

Get a video by ID.

**Response 200:** same shape as upload response.

---

### DELETE /api/v1/videos/{id}

Delete the video (owner-only). Removes stored files. **Response 204.**

---

### POST /api/v1/videos/{id}/pause

Pause a processed video (owner-only). Status → `PAUSED`, video is hidden from the feed. 400 if the video is not `PROCESSED`.

**Response 200:** same shape as upload response.

---

### POST /api/v1/videos/{id}/resume

Resume a paused video (owner-only). Status → `PROCESSED`, video reappears in the feed. 400 if the video is not `PAUSED`.

**Response 200:** same shape as upload response.

---

### POST /api/v1/videos/{id}/products/{productId}

Tag a product to the video (owner-only, product must belong to the owner and not already have a video). **Response 200.**

---

### DELETE /api/v1/videos/{id}/products/{productId}

Remove a product tag from the video (owner-only). **Response 200.**

---

### GET /api/v1/videos/{id}/products

List product IDs tagged to the video.

**Response 200:**
```json
[ "a1b2c3d4-…", "e5f6a7b8-…" ]
```

---

## Messaging (authenticated)

All conversation and message endpoints require a valid access token.

---

### GET /api/v1/conversations

List the authenticated user's conversations (as buyer or seller), sorted by `lastMessageAt` descending.

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `page` | int | Page number (default 1, 1-based) |
| `size` | int | Page size (default 10) |

**Response 200:**
```json
{
  "items": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "otherUser": { "id": "...", "fullName": "Aişə Məmmədova", "avatarUrl": null },
      "product": { "id": "...", "title": "iPhone 17 Pro", "imageUrl": "https://...", "price": 2890.24 },
      "lastMessage": { "content": "Salam, hələ aktualdır?", "createdAt": "2026-09-14T10:00:00Z", "readAt": null },
      "unreadCount": 2,
      "updatedAt": "2026-09-14T10:00:00Z"
    }
  ],
  "page": 0,
  "size": 10,
  "totalElements": 1,
  "totalPages": 1,
  "last": true
}
```

`otherUser` is the party that is NOT the current user. `product` is null for general chats. `unreadCount` counts messages from the other user with `readAt IS NULL`.

**Errors:**
| Status | Code | When |
|--------|------|------|
| 401 | Unauthorized | Missing or invalid access token |

---

### POST /api/v1/conversations

Start a new conversation (with optional first message) or resume an existing one. If a conversation for the same pair (and product) exists, it is reused.

**Headers:**
```
Authorization: Bearer <accessToken>
```

**Request:**
```json
{
  "recipientId": "550e8400-e29b-41d4-a716-446655440001",
  "productId": "550e8400-e29b-41d4-a716-446655440002",
  "content": "Salam, hələ aktualdır?"
}
```

| Field | Type | Validation |
|-------|------|------------|
| `recipientId` | UUID | Required |
| `productId` | UUID | Optional; must belong to the recipient (recipient must be the seller) |
| `content` | string | Required, max 2000 characters |

**Response 201:** Same shape as a conversation item in the list.

**Errors:**
| Status | Code | When |
|--------|------|------|
| 400 | Validation failed / Bad Request | Blank content, messaging yourself, recipient not the product seller |
| 401 | Unauthorized | Missing or invalid access token |
| 404 | Not found | User, recipient, or product not found |

---

### GET /api/v1/conversations/{conversationId}/messages

List the full message history of a conversation, ordered by `createdAt` ascending (oldest first). Only participants can read it.

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `page` | int | Page number (default 1, 1-based) |
| `size` | int | Page size (default 30) |

**Response 200:**
```json
{
  "items": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440003",
      "conversationId": "550e8400-e29b-41d4-a716-446655440000",
      "senderId": "550e8400-e29b-41d4-a716-446655440001",
      "content": "Salam",
      "readAt": null,
      "createdAt": "2026-09-14T10:00:00Z"
    }
  ],
  "page": 0,
  "size": 30,
  "totalElements": 1,
  "totalPages": 1,
  "last": true
}
```

**Errors:**
| Status | Code | When |
|--------|------|------|
| 401 | Unauthorized | Missing or invalid access token |
| 404 | Not found | Conversation not found or user is not a participant |

---

### POST /api/v1/conversations/{conversationId}/messages

Send a new message in an existing conversation. Only participants can send.

**Headers:**
```
Authorization: Bearer <accessToken>
```

**Request:**
```json
{
  "content": "Salam, hələ aktualdır?"
}
```

| Field | Type | Validation |
|-------|------|------------|
| `content` | string | Required, max 2000 characters |

**Response 201:** Same shape as a message item in the history.

**Errors:**
| Status | Code | When |
|--------|------|------|
| 400 | Validation failed | Blank content |
| 401 | Unauthorized | Missing or invalid access token |
| 404 | Not found | Conversation not found or user is not a participant |

---

### PATCH /api/v1/conversations/{conversationId}/read

Mark all incoming unread messages (from the other user, `readAt IS NULL`) as read. Only participants can call this.

**Response 200:**
```json
{
  "markedCount": 2
}
```

`markedCount` is the number of messages that were just marked read. After calling, the conversation's `unreadCount` becomes 0.

**Errors:**
| Status | Code | When |
|--------|------|------|
| 401 | Unauthorized | Missing or invalid access token |
| 404 | Not found | Conversation not found or user is not a participant |

---

## Notifications (authenticated)

All notification endpoints require a valid access token.

---

### GET /api/v1/notifications

List the authenticated user's notifications, newest first. A `MESSAGE` notification is created for the recipient whenever a new message is sent in a conversation.

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `page` | int | Page number (default 1, 1-based) |
| `size` | int | Page size (default 20) |

**Response 200:**
```json
{
  "items": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440004",
      "type": "MESSAGE",
      "title": "Aişə Məmmədova",
      "body": "Salam, hələ aktualdır?",
      "actorId": "550e8400-e29b-41d4-a716-446655440001",
      "conversationId": "550e8400-e29b-41d4-a716-446655440000",
      "productId": null,
      "read": false,
      "createdAt": "2026-09-15T10:00:00Z"
    }
  ],
  "unreadCount": 2,
  "page": 0,
  "size": 20,
  "totalElements": 1,
  "totalPages": 1,
  "last": true
}
```

`read` is `true` when the notification has been marked as read. `unreadCount` is the total number of unread notifications for the user across all pages. `actorId`, `conversationId`, and `productId` are nullable context links used by the client for navigation.

**Errors:**
| Status | Code | When |
|--------|------|------|
| 401 | Unauthorized | Missing or invalid access token |

---

### PATCH /api/v1/notifications/{notificationId}/read

Mark a single notification as read. Only the owning user can call this. Idempotent: marking an already-read notification returns 200 with no further change.

**Response 200:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440004",
  "read": true
}
```

**Errors:**
| Status | Code | When |
|--------|------|------|
| 401 | Unauthorized | Missing or invalid access token |
| 404 | Not found | Notification does not exist or belongs to another user |

---

### PATCH /api/v1/notifications/read-all

Mark all of the current user's unread notifications as read. Idempotent: returns `markedCount = 0` if nothing is unread.

**Response 200:**
```json
{
  "markedCount": 3
}
```

**Errors:**
| Status | Code | When |
|--------|------|------|
| 401 | Unauthorized | Missing or invalid access token |

---

### DELETE /api/v1/notifications/{notificationId}

Dismiss (delete) a single notification. Users can only dismiss their own notifications.

**Response 204:** No Content

**Errors:**
| Status | Code | When |
|--------|------|------|
| 404 | Not Found | Notification does not exist or belongs to another user |
| 401 | Unauthorized | Missing or invalid access token |

---

## Feed (authenticated)

### GET /api/v1/feed

Paginated reverse-chronological feed of processed videos. Each item carries its content type section (`RECENT` = "Son elanlar", `PREMIUM`, `VIP`, `POPULAR`, `SPONSORED`, `RECENTLY_VIEWED`). Pass `contentType` to request a specific section only.

**Query params:**
| Param | Type | Default | Notes |
|-------|------|---------|-------|
| page | int | 1 | 1-based |
| size | int | 10 | |
| contentType | enum | (all) | `RECENT`, `PREMIUM`, `VIP`, `POPULAR`, `SPONSORED`, `RECENTLY_VIEWED` |

**Response 200:**
```json
{
  "items": [
    {
      "videoId": "3f4c2e8a-...",
      "thumbnailUrl": "https://...",
      "hlsUrl": "https://...",
      "durationSeconds": 24,
      "contentType": "SPONSORED",
      "products": [
        {
          "id": "5a1b...",
          "title": "iPhone 17",
          "price": 2890.24,
          "currency": "TRY",
          "city": "Bakı",
          "imageUrl": "https://...",
          "category": "ELECTRONICS"
        }
      ],
      "ownerId": "2c1d...",
      "ownerFullName": "Həsən Məmmədov",
      "ownerAvatarUrl": null,
      "createdAt": "2026-09-01T12:00:00Z"
    }
  ],
  "page": 0,
  "size": 10,
  "totalElements": 42,
  "totalPages": 5,
  "last": false
}
```

**Example:** `GET /api/v1/feed?contentType=PREMIUM&page=1&size=10`

**Errors:**
| Status | Code | When |
|--------|------|------|
| 400 | Bad Request | Invalid `contentType` value |
| 401 | Unauthorized | Missing or invalid access token |

---

## Favorites (authenticated)

Favorites = the user's saved products (`Seçilmişlər > Elanlar` tab). Add/remove via the heart toggle; list with filter chips (`category`) and sort (`Tariq üzrə` / `Ən ucuz` / `Ən baha`). Soft-deleted products never appear in the list.

### POST /api/v1/favorites/{productId}

Add a product to the current user's favorites.

**Response 201:**
```json
{
  "id": "5a1b...",
  "title": "iPhone 17",
  "price": 2890.24,
  "currency": "TRY",
  "city": "Bakı",
  "category": "ELECTRONICS",
  "imageUrl": "https://...",
  "sellerId": "2c1d...",
  "sellerFullName": "Həsən Məmmədov",
  "favoritedAt": "2026-09-21T09:00:00Z"
}
```

**Errors:**
| Status | Code | When |
|--------|------|------|
| 404 | Not Found | Product does not exist or is deleted |
| 409 | Conflict | Product is already in favorites |
| 401 | Unauthorized | Missing or invalid access token |

### DELETE /api/v1/favorites/{productId}

Remove a product from the current user's favorites.

**Response 204:** No Content

**Errors:**
| Status | Code | When |
|--------|------|------|
| 404 | Not Found | Product is not in the user's favorites |
| 401 | Unauthorized | Missing or invalid access token |

### GET /api/v1/favorites

Paginated list of the current user's favorites.

**Query params:**
| Param | Type | Default | Notes |
|-------|------|---------|-------|
| page | int | 1 | 1-based |
| size | int | 20 | |
| sort | enum | `DATE` | `DATE` (Tarix üzrə), `PRICE_ASC` (Ən ucuz), `PRICE_DESC` (Ən baha) |
| category | enum | (all) | e.g. `ELECTRONICS`, `TRANSPORT`, ... |

**Response 200:**
```json
{
  "items": [
    {
      "id": "5a1b...",
      "title": "iPhone 17",
      "price": 2890.24,
      "currency": "TRY",
      "city": "Bakı",
      "category": "ELECTRONICS",
      "imageUrl": "https://...",
      "sellerId": "2c1d...",
      "sellerFullName": "Həsən Məmmədov",
      "favoritedAt": "2026-09-20T10:00:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 1,
  "totalPages": 1,
  "last": true
}
```

**Example:** `GET /api/v1/favorites?sort=PRICE_ASC&category=ELECTRONICS&page=1&size=20`

**Errors:**
| Status | Code | When |
|--------|------|------|
| 400 | Bad Request | Invalid `sort` or `category` value |
| 401 | Unauthorized | Missing or invalid access token |

---

## Storefronts (authenticated)

Storefront = a seller's public store page (`Mağazalar`). Store profile returns the seller's stats (listings, total views, followers); store products returns the active listings with per-item `viewCount`. `POST`/`DELETE .../follow` implements the `İzləyici ol` button.

### GET /api/v1/storefronts/{sellerId}

Get a store profile with stats. `{sellerId}` is the seller's user id.

**Response 200:**
```json
{
  "id": "2c1d...",
  "fullName": "Həsən Məmmədov",
  "avatarUrl": "https://...",
  "createdAt": "2026-01-15T10:00:00Z",
  "stats": {
    "products": 48,
    "views": 24561,
    "followers": 71
  }
}
```

**Errors:**
| Status | Code | When |
|--------|------|------|
| 404 | Not Found | Seller does not exist |
| 401 | Unauthorized | Missing or invalid access token |

### GET /api/v1/storefronts/{sellerId}/products

Paginated list of the seller's active (non-deleted) products, sorted by `createdAt DESC`. Each item carries its view count (`viewCount` — `Baxış sayı`).

**Query params:**
| Param | Type | Default | Notes |
|-------|------|---------|-------|
| page | int | 1 | 1-based |
| size | int | 20 | |

**Response 200:**
```json
{
  "items": [
    {
      "id": "5a1b...",
      "title": "iPhone 17",
      "price": 2890.24,
      "currency": "TRY",
      "category": "ELECTRONICS",
      "condition": "NEW",
      "city": "Bakı",
      "imageUrl": "https://...",
      "viewCount": 1234,
      "createdAt": "2026-09-20T10:00:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 1,
  "totalPages": 1,
  "last": true
}
```

**Example:** `GET /api/v1/storefronts/2c1d.../products?page=1&size=20`

**Errors:**
| Status | Code | When |
|--------|------|------|
| 401 | Unauthorized | Missing or invalid access token |

### POST /api/v1/storefronts/{sellerId}/follow

Follow a store (`İzləyici ol`).

**Response 201:** Created

**Errors:**
| Status | Code | When |
|--------|------|------|
| 400 | Bad Request | Cannot follow yourself |
| 404 | Not Found | Seller does not exist |
| 409 | Conflict | Already following this store |
| 401 | Unauthorized | Missing or invalid access token |

### DELETE /api/v1/storefronts/{sellerId}/follow

Unfollow a store.

**Response 204:** No Content

**Errors:**
| Status | Code | When |
|--------|------|------|
| 404 | Not Found | Seller does not exist or is not followed |
| 401 | Unauthorized | Missing or invalid access token |

---

## Ratings & Reviews (authenticated)

Buyers rate and review a purchased product (`Elan` detail → `Reytinqlər`). Ratings are 1–5; each user may leave at most one review per product. `POST` sends a `SYSTEM` notification to the seller.

### POST /api/v1/products/{productId}/reviews

Submit a review (rating + optional comment) for an active product.

**Body:**
```json
{
  "rating": 5,
  "comment": "Excellent quality, fast shipping"
}
```

**Response 201:**
```json
{
  "id": "b5c8...",
  "authorId": "2c1d...",
  "authorFullName": "Aytən Quliyeva",
  "authorAvatarUrl": null,
  "rating": 5,
  "comment": "Excellent quality, fast shipping",
  "createdAt": "2026-09-21T10:00:00Z"
}
```

**Errors:**
| Status | Code | When |
|--------|------|------|
| 400 | Bad Request | Rating outside 1–5, or reviewing your own product |
| 404 | Not Found | Product does not exist or is deleted |
| 409 | Conflict | Already reviewed this product |
| 401 | Unauthorized | Missing or invalid access token |

### GET /api/v1/products/{productId}/reviews

Paginated list of reviews for a product, sorted newest first.

**Query params:** `page` (default 1, 1-based), `size` (default 20)

**Response 200:**
```json
{
  "averageRating": 4.5,
  "reviewCount": 2,
  "items": [
    {
      "id": "b5c8...",
      "authorId": "2c1d...",
      "authorFullName": "Aytən Quliyeva",
      "authorAvatarUrl": null,
      "rating": 5,
      "comment": "Excellent quality",
      "createdAt": "2026-09-21T10:00:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 2,
  "totalPages": 1,
  "last": true
}
```

`averageRating` is 0.0 when there are no reviews yet.

**Errors:**
| Status | Code | When |
|--------|------|------|
| 401 | Unauthorized | Missing or invalid access token |

---

## Report Listing (authenticated)

Report an inappropriate listing (`Elan` detail → `Şikayət et`). Reasons are fixed by the design (`Fırıldaqçılıq`, `Qadağan olunmuş əşya`, `Spam`, `Yanlış kateqoriya`, `Yanlış məlumat`, `Dublikat`, `Digər`); one report per user per product.

### POST /api/v1/products/{productId}/report

Report an active product with a reason and optional description.

**Body:**
```json
{
  "reason": "SPAM",
  "description": "Counterfeit product"
}
```

`reason` ∈ `FRAUD | PROHIBITED_ITEM | SPAM | WRONG_CATEGORY | MISLEADING | DUPLICATE | OTHER`

**Response 201:**
```json
{
  "id": "c7d9...",
  "productId": "b5c8...",
  "reason": "SPAM",
  "createdAt": "2026-09-21T10:00:00Z"
}
```

**Errors:**
| Status | Code | When |
|--------|------|------|
| 400 | Bad Request | Invalid reason, or reporting your own product |
| 404 | Not Found | Product does not exist or is deleted |
| 409 | Conflict | Already reported this product |
| 401 | Unauthorized | Missing or invalid access token |

---

## Wallet (authenticated)

Seller earnings wallet (`Pul kisəsi`). Every user gets a wallet automatically on first balance request (balance starts at 0.00 TRY). Transactions reflect wallet credits, charges, admin adjustments and explicitly enabled mock top-ups. A new wallet has an empty history.

### GET /api/v1/wallet/balance

Current wallet balance and currency.

**Response 200:**
```json
{
  "balance": 0.00,
  "currency": "TRY"
}
```

**Errors:**
| Status | Code | When |
|--------|------|------|
| 401 | Unauthorized | Missing or invalid access token |

### GET /api/v1/wallet/transactions

Paginated list of wallet transactions, newest first.

**Query params:** `page` (default 1, 1-based), `size` (default 20)

**Response 200:**
```json
{
  "items": [
    {
      "id": "d3e4...",
      "type": "EARNING",
      "amount": 99.99,
      "description": "Product sale",
      "createdAt": "2026-09-21T10:00:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 1,
  "totalPages": 1,
  "last": true
}
```

`type` ∈ `EARNING | DEPOSIT | WITHDRAWAL | ADJUSTMENT`.

**Errors:**
| Status | Code | When |
|--------|------|------|
| 401 | Unauthorized | Missing or invalid access token |

---

## Settings (authenticated)

App preferences (`Parametrlər`). Every user gets a settings row automatically on first request; defaults are `language = TR` and `notificationsEnabled = true`. The row is created idempotently (`INSERT ... ON CONFLICT DO NOTHING`), so concurrent first-time requests are safe.

### GET /api/v1/settings

Current settings for the authenticated user.

**Response 200:**
```json
{
  "language": "TR",
  "notificationsEnabled": true,
  "updatedAt": "2026-10-05T09:00:00Z"
}
```

`language` ∈ `TR | EN`.

**Errors:**
| Status | Code | When |
|--------|------|------|
| 401 | Unauthorized | Missing or invalid access token |

### PUT /api/v1/settings

Partial update. Fields left out of the request keep their current value.

**Request body** (at least one field required):
```json
{
  "language": "EN",
  "notificationsEnabled": false
}
```

**Response 200:** same shape as `GET /api/v1/settings`, reflecting the saved values.

**Errors:**
| Status | Code | When |
|--------|------|------|
| 400 | Bad Request | Body contains neither `language` nor `notificationsEnabled` |
| 401 | Unauthorized | Missing or invalid access token |

---

## Interactions (authenticated)

Video likes and comments (`Bəyənmələr` / `Şərhlər`). All endpoints require a valid access token. A user may like a video at most once; `likeCount`/`commentCount` reflect the current totals.

---

### POST /api/v1/videos/{videoId}/like

Like a video. Self-likes are allowed.

**Response 201:**
```json
{
  "videoId": "a1b2c3d4-…",
  "liked": true,
  "likeCount": 7
}
```

**Errors:**
| Status | Code | When |
|--------|------|------|
| 401 | Unauthorized | Missing or invalid access token |
| 404 | Not Found | Video does not exist |
| 409 | Conflict | Video already liked by this user |

---

### DELETE /api/v1/videos/{videoId}/like

Remove the current user's like. **Response 204.**

**Errors:**
| Status | Code | When |
|--------|------|------|
| 401 | Unauthorized | Missing or invalid access token |
| 404 | Not Found | The user has not liked this video |

---

### GET /api/v1/videos/{videoId}/likes

Paginated list of users who liked the video, newest first. `page` is 1-based (default `1`), `size` default `20`.

**Response 200:**
```json
{
  "likeCount": 1,
  "items": [
    {
      "userId": "a1b2c3d4-…",
      "fullName": "Aytən Quliyeva",
      "avatarUrl": "https://cdn.example.com/avatar.jpg",
      "likedAt": "2026-10-01T10:00:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 1,
  "totalPages": 1,
  "last": true
}
```

---

### POST /api/v1/videos/{videoId}/comments

Add a comment to a video. The video owner receives a `SYSTEM` notification (unless the commenter is the owner).

**Request:**
```json
{
  "content": "Çox gözəl video"
}
```

**Response 201:**
```json
{
  "id": "e5f6a7b8-…",
  "videoId": "a1b2c3d4-…",
  "authorId": "9c8b7a6d-…",
  "authorFullName": "Aytən Quliyeva",
  "authorAvatarUrl": "https://cdn.example.com/avatar.jpg",
  "content": "Çox gözəl video",
  "createdAt": "2026-10-01T10:00:00Z"
}
```

**Errors:**
| Status | Code | When |
|--------|------|------|
| 400 | Bad Request | `content` blank or longer than 1000 chars |
| 401 | Unauthorized | Missing or invalid access token |
| 404 | Not Found | Video does not exist |

---

### DELETE /api/v1/videos/{videoId}/comments/{commentId}

Delete a comment (author-only). **Response 204.**

**Errors:**
| Status | Code | When |
|--------|------|------|
| 401 | Unauthorized | Not the comment author |
| 404 | Not Found | Comment does not exist on this video |

---

### GET /api/v1/videos/{videoId}/comments

Paginated list of comments, newest first. `page` is 1-based (default `1`), `size` default `20`.

**Response 200:**
```json
{
  "commentCount": 1,
  "items": [
    {
      "id": "e5f6a7b8-…",
      "videoId": "a1b2c3d4-…",
      "authorId": "9c8b7a6d-…",
      "authorFullName": "Aytən Quliyeva",
      "authorAvatarUrl": null,
      "content": "Çox gözəl video",
      "createdAt": "2026-10-01T10:00:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 1,
  "totalPages": 1,
  "last": true
}
```

---

## Authentication

Authentication is required except for auth, i18n, Swagger/OpenAPI, uploaded assets, and public GET feed/catalog routes. `/products/me` and its subroutes require authentication. `/api/v1/admin/**` additionally requires the ADMIN role.

**Header:**
```
Authorization: Bearer <accessToken>
```

### Token Types

| Token | Lifetime | Usage |
|-------|----------|-------|
| Access Token | 15 minutes | Sent in `Authorization` header for API requests |
| Refresh Token | 7 days | Sent in request body to `/refresh` to get a new pair |
| Reset Token | 5 minutes | Sent in request body to `/reset-password` (password reset only) |

### Token Blacklist

On logout, the access token's SHA-256 hash is stored in the `token_blacklist` table. The `JwtAuthFilter` checks every authenticated request against this blacklist. Expired entries are purged every 6 hours via a scheduled task.

---

## Error Response Format

Application errors follow this localized format. Authentication/authorization failures from the security filter may have a different body; handle their HTTP status first:

```json
{
  "status": 400,
  "error": "Doğrulama başarısız",
  "code": "VALIDATION_FAILED",
  "messageKey": "error.validation.failed",
  "details": [
    "Telefon numarası yalnızca rakam içermelidir (7-15 karakter)"
  ]
}
```

| Field | Type | Description |
|-------|------|-------------|
| `status` | int | HTTP status code (mirrored in the body) |
| `error` | string | Localized, human-readable message (per `X-App-Language`) |
| `code` | string | Stable machine code — `messageKey` without the `ERROR_` prefix |
| `messageKey` | string | Bundle key (`common/src/main/resources/i18n/messages_{tr,en}.properties`) |
| `details` | string[] | Localized field-validation details (only for 400) |

Clients should branch on `code`/`messageKey`, never on `error` text.

### HTTP Status Code Map

| Status | Exception | When |
|--------|-----------|------|
| 400 | `BadRequestException` / `MethodArgumentNotValidException` | Validation failure, invalid state transition |
| 400 | `ERROR_WALLET_INSUFFICIENT_BALANCE` | Wallet charge exceeds balance |
| 400 | `ERROR_GEO_INVALID_POINT` | `NEARBY` feed without valid `lat`/`lng`, radius > 200 km |
| 401 | `UnauthorizedException` | Invalid/expired token, wrong OTP |
| 401 | `ERROR_FEED_LOGIN_REQUIRED` | `tab=following` without authentication |
| 404 | `ResourceNotFoundException` | Resource not found, bad credentials |
| 409 | `DuplicateResourceException` | Duplicate resource (phone taken, review, report, follow…) |
| 429 | `TooManyRequestsException` | Rate limit exceeded |
| 500 | `RuntimeException` | Unexpected server error |

---

## W8–W11 Additions (delta)

This section lists everything added after the original reference above. All paths are under `/api/v1`.

### Localization

| Method | Path | Notes |
|--------|------|-------|
| GET | `/i18n/enums` | Localized labels for all 18 enum groups: `productCategory, productSubcategory, productCondition, productStatus, productPromotionType, videoStatus, notificationType, role, gender, appLanguage, transactionType, paymentMethod, topUpStatus, reportReason, productSellerType, productDeliveryType, feedTab, feedSection`. Labels follow `X-App-Language` (default `tr`). |

Enum `code` values always stay stable in responses; `*Label` companions carry the localized text.

### Products

| Method | Path | Notes |
|--------|------|-------|
| GET | `/products` | Public catalog — **ACTIVE only**. Filters: `category, subcategory, city, brand, modelName, color, storage, condition, minPrice, maxPrice, sellerType, deliveryType`, plus optional `lat`/`lng` (adds `distanceKm`/`distanceLabel`, no filtering). |
| GET | `/products/me?status=` | Owner's listings, any status except `DELETED`; optional `status` tab filter. |
| GET | `/products/me/status-counts` | Counts per status (`ACTIVE`, `SOLD`, `UNDER_REVIEW`, …) for the profile tabs. |
| POST | `/products/{id}/submit-review` | `ACTIVE` → `UNDER_REVIEW` (owner-only). |
| POST | `/products/{id}/deactivate` | `ACTIVE` → `SOLD` (owner-only); invalid transition → 400. |
| POST | `/products/{id}/activate` | `SOLD` → `ACTIVE` (owner-only); invalid transition → 400. |
| GET | `/products/subcategories` | Subcategory chips; filter with `?category=`. |
| GET | `/products/cities` \| `/brands` \| `/conditions` | Filter chips. |
| GET | `/products/popular/brands?limit=20` | `[{name, count}]` from active listings (max 20). |
| GET | `/products/popular/models?limit=20` | Same shape, models. |
| GET | `/products/map?lat=&lng=&radiusKm=` | Map pins (max 200) with distance. |
| GET | `/products/nearby?lat=&lng=&radiusKm=&page=&size=` | ACTIVE page ordered by haversine distance; default 25 km, max 200 km. |
| POST | `/products/{id}/share` | `{productId, shareUrl, shareCount}`; counter incremented race-safely. |
| POST | `/products/{id}/promote` | Promotion purchase (see Promotions). |

`ProductResponse` now also carries `originalPrice`, discount info, `sellerType`/`sellerTypeLabel`, `deliveryType`/`deliveryTypeLabel`, `promotionType`, `averageRating`, `reviewCount`, `viewCount`, `shareCount` and optional distance fields. Discount percentage is derived (`Discounts.percentOf`), never stored.

### Storefronts

| Method | Path | Notes |
|--------|------|-------|
| POST | `/storefronts/me/application` | Store onboarding → `APPLICATION`; duplicate → 409. |
| GET | `/storefronts/me` | Own store (any status). |
| PUT | `/storefronts/me` | Partial profile edit; empty body → 400. |
| POST | `/storefronts/me/deactivate` | Deactivate store and pause its listings. |
| POST | `/storefronts/me/reactivate` | Reactivate store and resume listings. |
| GET | `/storefronts/me/statistics` | Views / listings / followers / response metrics. |
| GET | `/storefronts/{sellerId}/response-rate` | Seller response rate. |
| POST | `/storefronts/{sellerId}/call-log` | Log an outbound call attempt. |
| GET | `/storefronts/following` | Stores the current user follows ("Takip edilenler"). |

Open/closed state (`isOpen`, `openUntil`) is derived at read time from working hours (Europe/Istanbul) by `StoreHours`.

### Feed

`GET /feed?page=&size=&contentType=&tab=&section=&lat=&lng=&radiusKm=`

| Param | Values | Default |
|-------|--------|---------|
| `tab` | `FOR_YOU` \| `NEARBY` \| `FOLLOWING` | `FOR_YOU` |
| `section` | `LATEST` \| `FEATURED` | `LATEST` |
| `radiusKm` | number, ≤ 200 | 25 |

- `tab=FOLLOWING` → 401 `ERROR_FEED_LOGIN_REQUIRED` when unauthenticated.
- `tab=NEARBY` → 400 `ERROR_GEO_INVALID_POINT` without valid `lat`/`lng`.
- `section=FEATURED` overrides `tab` and returns videos of actively promoted listings.
- Parsing is tolerant of lowercase/underscores.

### Reports

| Method | Path | Body |
|--------|------|------|
| POST | `/products/{productId}/report` | `{reason, description?}` → 201 |
| POST | `/users/{userId}/report` | `{reason, description?}` → 201 |

`{id, targetId, reason, reasonLabel, description, createdAt}`. Own target → 400, missing → 404, duplicate → 409. `ReportReason`: `FRAUD, PROHIBITED_ITEM, SPAM, WRONG_CATEGORY, MISLEADING, DUPLICATE, OTHER`.

### Reviews

`GET /products/{productId}/reviews?page=1&size=20` now returns `{averageRating, reviewCount, items, page, size, totalElements, totalPages, last}`; `averageRating = COALESCE(AVG(rating), 0)`.

### Wallet & Promotions

| Method | Path | Notes |
|--------|------|-------|
| GET | `/promotions/availability` | Free daily quota + prices (`BOOST 1.50 TRY`, `VIP 3.00 TRY / 30d`, `PREMIUM 5.00 TRY / 30d`). |
| POST | `/wallet/top-up` | `{amount, method}` → `PENDING` intent, `INV-XXXXXXXXXXXX`. |
| GET | `/wallet/top-up/{id}` | Intent status. |
| POST | `/wallet/top-up/{id}/confirm` | Credits the wallet (mock; disabled by default, enabled only with `PAYMENTS_MOCK_ENABLED=true`). |

Promotion purchase consumes the free daily quota first, then `WalletService.charge(...)` — insufficient balance → 400 `ERROR_WALLET_INSUFFICIENT_BALANCE`.

### Messaging

| Method | Path | Notes |
|--------|------|-------|
| POST | `/conversations/{id}/mute` | `{conversationId, muted: true}` |
| DELETE | `/conversations/{id}/mute` | `{conversationId, muted: false}` |

`ConversationResponse` gained `muted`. While muted, message notifications are skipped for both parties.

### Settings

`GET /settings` / `PUT /settings` — `{language, notificationsEnabled, updatedAt}`; `AppLanguage` ∈ `TR` (default) / `EN`; omitted fields keep their values, empty body → 400.

## Admin API

This section documents the implemented admin backend, including the endpoints used by the admin panel.
All paths below are relative to `/api/v1`. Apply database migrations through **v048** before using it.
The frontend source and a separate ADMIN_API.md are not required to integrate these endpoints.

### Admin authentication and shared endpoints

Use `POST /auth/login` with `{countryCode, phoneNumber, password}`. The response is
`{accessToken, refreshToken, user}`; the account must have role `ADMIN`.
Send `Authorization: Bearer <accessToken>` on every `/admin/**` request.
Public registration cannot create an administrator; provision the first admin operationally.
A valid non-admin session receives **403**; a missing, expired, revoked or blocked session receives **401**.
Security-filter errors may have a different body from application errors: always inspect the HTTP status.

Shared endpoints used by the panel:

| Method | Path | Purpose |
|---|---|---|
| POST | /auth/refresh | Exchange a refresh token for a new token pair; store both new tokens |
| POST | /auth/logout | End the authenticated session; discard local tokens |
| GET / PUT | /users/me | Read / update the administrator's own profile |
| GET / PUT | /settings | Read / partially update `language: TR\|EN`, `notificationsEnabled: boolean` |
| GET | /products/categories | Category options |
| GET | /products/subcategories | Subcategory options and category association |
| GET | /i18n/enums | Current enum codes and localized labels |
| GET | /products/{id}/reviews | Public product review shape; admin moderation uses /admin/reviews |

For refresh, send `{"refreshToken":"..."}`. Tokens rotate and a consumed refresh token cannot be reused.
Block, role change and password reset invalidate existing sessions.
Use `X-App-Language: tr|en` for localized text; the default is Turkish. Currency is **TRY**.
Admin UI labels may use another language, but submitted enum values must match the backend codes.

### Admin conventions and errors

- IDs are UUID strings. Wallet routes use a **user ID**, store routes use a **store ID**.
- Dates are ISO-8601 timestamps. Nullable properties may be JSON `null`.
- List requests use **1-based** `page` (default 1), `size` (default 20, range 1–100).
  This also applies to message history; send `size=100` explicitly if desired.
- Responses use **0-based** `page`. All admin lists have the same wrapper:
  `{items, page, size, totalElements, totalPages, last}`.
- `sort=field,asc|desc` accepts only the fields documented below. Invalid sorts fall back to the default;
  an ID tie-breaker makes ordering stable. Out-of-range pages return an empty `items` array.
- `q` is a case-insensitive substring search, maximum 200 characters; `%` and `_` are literal.
  Equality filters are case-sensitive enum codes/IDs. Unknown equality values currently return no matches.
- Invalid page/size, malformed JSON/UUID, invalid mutation enums, invalid numeric/boolean parameters,
  incompatible category/subcategory and invalid state transitions return **400**.
- Missing resources return **404**; conflicts can return **409**.
- Application errors have `{status, error, code, messageKey, details: string[]}`.
  `error` is localized; use `code` for machine decisions. Do not assume all errors contain field details.
- Successful mutations persist an audit entry with the authenticated actor, action, target and timestamp.
  There is currently no admin audit-list endpoint.
- Except where stated otherwise, responses are **200**. Empty-body success is not a JSON object.

Example paginated request: `GET /api/v1/admin/products?page=1&size=20&status=ACTIVE&sort=price,asc`.

```json
{"items":[],"page":0,"size":20,"totalElements":0,"totalPages":0,"last":true}
```

### Admin dashboard

`GET /admin/stats` returns:

- `totals`: numeric `users, sellers, blockedUsers, newUsers7d, activeProducts, promotedProducts,
  newProducts7d, liveVideos, failedVideos, openReports, pendingStores, conversations, messages7d,
  totalViews, walletTotal`.
- `series.listings` and `series.signups`: 30 daily `{date:"YYYY-MM-DD", count}` points, oldest first,
  zero-filled.
- `categories`, `subcategories`, `videoStatuses`: arrays of `{key, count}`.
- `recentReports`: up to 5 newest OPEN ReportView items.
- `pendingStores`: up to 5 oldest APPLICATION StoreView items.
- `topProducts`: up to 5 ACTIVE ProductView items ordered by view count.

### Admin users

| Method | Path | Body | Success |
|---|---|---|---|
| GET | /admin/users | — | Page<UserView> |
| GET | /admin/users/{id} | — | UserView with stats |
| POST | /admin/users/{id}/block | `{"reason":"Fraud investigation"}` or `{}`; reason optional, max 500 | Empty 200 |
| POST | /admin/users/{id}/unblock | — | Empty 200 |
| PATCH | /admin/users/{id}/role | `{"role":"SELLER"}` | Empty 200 |

Filters: `q` (name, phone, email), `role`, `status`, `gender`.
Sorts: `fullName, createdAt, lastActiveAt, productCount`; default `createdAt,desc`.
Roles: `BUYER|SELLER|ADMIN`; user statuses: `ACTIVE|BLOCKED`; gender: `MALE|FEMALE`.
An admin cannot block themselves or any admin. An admin cannot change their own role or an existing
admin's role. Promoting another non-admin to ADMIN is allowed. Block and role changes revoke tokens.

### Admin products

| Method | Path | Body | Success |
|---|---|---|---|
| GET | /admin/products | — | Page<ProductView>, all statuses unless filtered |
| GET | /admin/products/{id} | — | ProductView; does not increment viewCount |
| PUT | /admin/products/{id} | Partial product edit below | Updated ProductView |
| PATCH | /admin/products/{id}/status | `{"status":"UNDER_REVIEW"}` | Updated ProductView |
| DELETE | /admin/products/{id} | — | Empty 204; soft delete |
| POST | /admin/products/{id}/promote | `{"promotionType":"VIP","days":7}` | Updated ProductView |
| DELETE | /admin/products/{id}/promotion | — | Updated ProductView |

Filters: `q` (title, brand, modelName, seller name, ID), `status, category, subcategory, condition,
promotionType, sellerId, city, minPrice, maxPrice, reported`.
`reported=true` selects products with OPEN reports; false leaves this filter disabled.
Sorts: `createdAt, price, viewCount, title, updatedAt, reportCount`; default `createdAt,desc`.

Product statuses: `ACTIVE|SOLD|DELETED|PENDING_PAYMENT|INACTIVE|REJECTED|UNDER_REVIEW`.
Admin status updates can select any of these statuses; a non-ACTIVE status removes promotion.
Restore a deleted product using the status endpoint before editing its content.
Promotion types for purchase-free admin assignment: `BOOST|VIP|PREMIUM`, days 1–30.
The listing must be ACTIVE. Assignment replaces the current promotion and does **not** debit the wallet
or consume the user's daily quota. Removing a promotion sets type NONE and clears its end date.

**Partial admin edit semantics** (specific to `PUT /admin/products/{id}`):
omit a field to retain it; send explicit `null` to clear an optional field.
At least one editable field must be supplied. Required stored fields cannot be cleared.
The regular owner `PUT /products/{id}` endpoint retains its existing null-ignore behavior.

| Field | Type / limits | Can explicitly clear? |
|---|---|---|
| title | Nonblank string, max 200 | No |
| price | Number 0.01–9999999999.99, max 2 decimals | No |
| currency | `TRY` | No |
| category | ProductCategory code | No |
| sellerType | `INDIVIDUAL|STORE` | No |
| deliveryType | `SHIPPING|PICKUP|BOTH` | No |
| description | String, max 10000 | Yes |
| originalPrice | Number 0.01–9999999999.99, max 2 decimals | Yes |
| subcategory | ProductSubcategory code belonging to the resulting category | Yes |
| storage, color | String, max 50 | Yes |
| brand, modelName, city | String, max 100 | Yes |
| condition | ProductCondition code from /i18n/enums | Yes |
| imageUrls | Array of strings; `[]` removes all images | Yes |
| latitude | Number -90 to 90 | Yes |
| longitude | Number -180 to 180 | Yes |

When changing category, replace the subcategory with a matching value or explicitly clear it.
The entire update, including clearing fields, rolls back on failure.

```json
{"title":"Updated listing","price":125.50,"brand":null,"category":"TRANSPORT","subcategory":null}
```

### Admin videos

| Method | Path | Body | Success |
|---|---|---|---|
| GET | /admin/videos | — | Page<VideoView> |
| GET | /admin/videos/{id} | — | VideoView |
| POST | /admin/videos/{id}/pause | — | VideoView; PROCESSED → PAUSED |
| POST | /admin/videos/{id}/resume | — | VideoView; PAUSED → PROCESSED |
| PATCH | /admin/videos/{id}/content-type | `{"videoContentType":"SPONSORED"}` | VideoView |
| DELETE | /admin/videos/{id}/products/{productId} | — | VideoView; removes product tag |
| DELETE | /admin/videos/{id} | — | Empty 204; uses shared video storage cleanup |

Filters: `q` (owner name, original filename, tagged product title), `status, videoContentType, ownerId`.
Sorts: `createdAt, likeCount, durationSeconds, sizeBytes`; default `createdAt,desc`.
Statuses: `UPLOADED|PROCESSING|PROCESSED|PAUSED|FAILED`.
Content types: `RECENT|PREMIUM|VIP|POPULAR|SPONSORED|RECENTLY_VIEWED`.

### Admin listing reports

| Method | Path | Body | Success |
|---|---|---|---|
| GET | /admin/reports | — | Page<ReportView> |
| PATCH | /admin/reports/{id} | `{"status":"RESOLVED","note":"Removed spam","removeListing":true}` | ReportView |

Filters: `q` (product title, reporter name, seller name, description), `status, reason, productId`.
Sorts: `createdAt, sameProductOpenCount, resolvedAt`; default `createdAt,desc`.
Read statuses: `OPEN|RESOLVED|DISMISSED`; mutation accepts only `RESOLVED|DISMISSED`.
Note is optional, max 1000. `removeListing` defaults effectively to false when omitted/null.
Only OPEN reports can be handled. Removing a listing requires RESOLVED and also resolves every other
OPEN report for the product. Resolution records the admin and timestamp.
This endpoint covers **product reports**, not user reports.

### Admin reviews

| Method | Path | Success |
|---|---|---|
| GET | /admin/reviews | Page<ReviewView> |
| DELETE | /admin/reviews/{id} | Empty 204 |

Filters: `q` (comment, author name, product title), `rating, productId, authorId, withComment`.
`withComment=true` selects nonblank comments; false disables the filter.
Sorts: `createdAt, rating`; default `createdAt,desc`.

### Admin stores

| Method | Path | Body | Success |
|---|---|---|---|
| GET | /admin/stores | — | Page<StoreView> |
| GET | /admin/stores/{id} | — | StoreView |
| POST | /admin/stores/{id}/approve | — | StoreView; APPLICATION → ACTIVE |
| POST | /admin/stores/{id}/reject | `{"reason":"Missing application details"}` | StoreView; APPLICATION → REJECTED |

Filters: `q` (store name, owner name, owner's phone), `status, category`.
Sorts: `createdAt, name, reviewedAt`; default `createdAt,desc`.
Statuses: `APPLICATION|ACTIVE|INACTIVE|SUSPENDED|REJECTED` (there is no APPROVED code).
Only APPLICATION can be approved/rejected. Rejection reason is required, nonblank, max 1000.
Approval clears an old rejection reason; both actions set reviewedAt.
StoreView.city is currently null; the store entity has no city field and search does not cover city.
These actions currently persist the decision and audit entry without sending a seller notification.

### Admin conversations and messages

| Method | Path | Success |
|---|---|---|
| GET | /admin/conversations | Page<ConversationView> |
| GET | /admin/conversations/{id}/messages | Page<MessageView> |
| DELETE | /admin/conversations/{id}/messages/{messageId} | Empty 204 |
| DELETE | /admin/conversations/{id} | Empty 204; deletes all messages too |

Conversation filters: `q` (participant names, product title, message text), `userId`
(matches buyer OR seller), `withProduct=true|false`.
Sorts: `lastMessageAt, messageCount`; default `lastMessageAt,desc`.
Message history accepts page/size and sort `createdAt`, default `createdAt,asc`.
Reading for moderation does not mark messages read.
A message must belong to the supplied conversation; deletion recalculates lastMessageAt
(null if there are no messages left).

### Admin wallets

| Method | Path | Body | Success |
|---|---|---|---|
| GET | /admin/wallets | — | Page<WalletView> |
| GET | /admin/wallets/{userId}/transactions | — | Page<TransactionView> |
| POST | /admin/wallets/{userId}/transactions | `{"type":"ADJUSTMENT","amount":25.50,"description":"Support correction"}` | Empty 200 |

Wallet filters: `q` (user name, phone), `role, nonZero`.
`nonZero=true` selects nonzero balances; false disables the filter.
Sorts: `balance, updatedAt, transactionCount`; default `balance,desc`.
History filter: `type`; sorts `createdAt, amount`, default `createdAt,desc`.
The wallet list includes existing wallets only; history for an existing user without a wallet is empty.
An adjustment lazily creates the wallet if necessary.

Types: `EARNING|DEPOSIT|TOP_UP|WITHDRAWAL|ADJUSTMENT`.
Amount must be positive, max 9999999999.99, at most two decimal places.
WITHDRAWAL subtracts; all other types add. ADJUSTMENT is **not** a signed amount.
Description is required, nonblank, max 255.
Balance and ledger changes are atomic and serialized; insufficient funds or balance overflow returns 400.
After success, re-fetch wallet/history to obtain the new balance and transaction ID.

### Admin broadcasts

| Method | Path | Body | Success |
|---|---|---|---|
| GET | /admin/notifications/broadcasts | — | Page<BroadcastView> |
| POST | /admin/notifications/broadcasts | `{"title":"Notice","body":"Message text","audience":"SELLERS"}` | 201 BroadcastView |

Filters: `q` (title/body), `audience`; sort `createdAt`, default `createdAt,desc`.
Title: required, nonblank, max 120. Body: required, nonblank, max 500.
Audience: `ALL|BUYERS|SELLERS`. Only ACTIVE users are selected; ALL includes active admins.
Creates persisted SYSTEM notifications in batches, synchronously in the request transaction,
and stores broadcast history. This endpoint does not promise device push delivery.
The returned recipients count is the actual number of notifications created.

### Admin response schemas

All lists contain the item type named above. Object shapes below describe JSON property names;
UUIDs/enums/timestamps are strings, monetary values are JSON numbers.

- **Person**: `{id, fullName, avatarUrl, countryCode, phoneNumber}`.
- **UserView**: `{id, fullName, countryCode, phoneNumber, avatarUrl, email, role, status,
  blockedReason, lastActiveAt, gender, createdAt, productCount, stats}`.
  List stats is `{}`; detail stats contains `activeProducts, soldProducts, videos,
  reviewsWritten, reportsAgainst, conversations, walletBalance`. reportsAgainst counts product reports.
  Password hashes and session versions are never included.
- **ProductView**: flattened ProductResponse fields plus `videoId, reportCount, imageUrl`.
  There is **no nested product wrapper**. reportCount counts OPEN reports.
  ProductResponse fields: `id, sellerId, sellerFullName, sellerAvatarUrl, title, description,
  price, currency, originalPrice, discountPercent, category, categoryLabel, subcategory,
  subcategoryLabel, storage, brand, modelName, color, city, condition, conditionLabel,
  viewCount, status, statusLabel, promotionType, promotionTypeLabel, promotionEndsAt,
  imageUrls, createdAt, updatedAt, averageRating, reviewCount, latitude, longitude,
  distanceKm, distanceLabel, sellerType, sellerTypeLabel, deliveryType, deliveryTypeLabel`.
  **imageUrls is a JSON-encoded string** (or null) in responses, e.g. `"[\\"https://example.com/photo.jpg\\"]"`;
  requests use an actual array. imageUrl is the first image or null.
- **ProductSummary**: `{id, title, price, currency, status, imageUrl, seller: Person}`.
- **VideoView**: flattened `{id, ownerId, ownerFullName, ownerAvatarUrl, originalFileName,
  contentType, sizeBytes, status, videoContentType, rawUrl, hlsUrl, thumbnailUrl,
  durationSeconds, productIds, createdAt, updatedAt}` plus
  `products: ProductSummary[]` and `likeCount`.
- **ReportView**: `{id, productId, reason, description, status, note, resolvedAt, createdAt,
  reporter: Person, product: ProductSummary, sameProductOpenCount}`.
- **ReviewView**: `{id, productId, productTitle, productImageUrl, sellerId, authorId,
  authorFullName, authorAvatarUrl, rating, comment, createdAt}`.
- **StoreView**: `{id, ownerId, owner: Person, name, category, logoUrl, description, phone,
  city, workingHours, status, rejectionReason, reviewedAt, createdAt,
  stats: {products, views, followers}}`. phone is the owner's full phone number.
- **MessageView**: `{id, conversationId, senderId, content, readAt, createdAt}`.
- **ConversationView**: `{id, buyer: Person, seller: Person, product: ProductSummary|null,
  lastMessage: MessageView|null, messageCount, unreadCount, lastMessageAt}`.
- **WalletView**: `{userId, user: Person, role, balance, currency, updatedAt, transactionCount}`.
- **TransactionView**: `{id, type, amount, description, createdAt}`; amounts are positive,
  direction follows type.
- **BroadcastView**: `{id, title, body, audience, recipients, sentBy, createdAt}`.

### Backend integration handoff

Run the backend and use `/swagger-ui/index.html` or export `/v3/api-docs` for Postman/code generation.
The default local server is `http://localhost:8080`; another developer needs a reachable server URL.
Supply that URL and a separately provisioned test ADMIN account. Do not distribute production credentials.
The tables above document request behavior and response shapes that an automatically generated schema
alone may not explain (partial updates, flattened responses, empty bodies and paging).

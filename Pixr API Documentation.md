# Pixr API Documentation

## Overview

The Pixr API is a RESTful service that powers the SVID video platform, providing comprehensive endpoints for video upload, AI-powered search, monetization through the Pix token system, and investment features. This document covers all available API endpoints, authentication requirements, and data structures.

## Base URL

```
https://api.pixr.co/api/v1
```

For local development:
```
http://localhost:8080/api/v1
```

## Authentication

Most API endpoints require authentication using JWT (JSON Web Tokens). Authentication is performed via Bearer tokens in the Authorization header.

### Authentication Flow

1. Register a new account or login with existing credentials
2. Receive access_token and refresh_token
3. Include access_token in subsequent requests: `Authorization: Bearer <access_token>`

### Authentication Endpoints

#### Register New User
```http
POST /auth/register
Content-Type: application/json

{
  "username": "string", // 3-16 chars, lowercase letters and numbers only
  "email": "string",    // Valid email format
  "password": "string"  // Min 8 chars, must include uppercase, lowercase, number, and special character
}

Response 200:
{
  "access_token": "string",
  "refresh_token": "string",
  "user": {
    "id": "uuid",
    "username": "string",
    "email": "string",
    "pix": 0
  }
}
```

#### Login
```http
POST /auth/login
Content-Type: application/json

{
  "username": "string", // Username (not email in current implementation)
  "password": "string"
}

Response 200:
{
  "access_token": "string",
  "refresh_token": "string",
  "user": {
    "id": "uuid",
    "username": "string",
    "email": "string",
    "pix": 0
  }
}
```

## User Management

### Get Current User Profile
```http
GET /users/me
Authorization: Bearer <token>

Response 200:
{
  "id": "uuid",
  "username": "string",
  "email": "string",
  "pix": 0
}
```

### Get User Analytics
```http
GET /users/me/analytics
Authorization: Bearer <token>

Response 200:
{
  "total_searches": 0,
  "total_videos": 0,
  "total_views": 0,
  "total_watch_time": 0.0,
  "search_to_view_rate": 0.0,
  "avg_view_duration": 0.0,
  "top_search_terms": ["string"],
  "traffic_sources": {
    "search": 0,
    "direct": 0,
    "shared": 0
  }
}
```

### Get User Earnings
```http
GET /users/me/earnings
Authorization: Bearer <token>

Response 200:
{
  "total_earned": 500000000,
  "pending_payout": 50000000,
  "last_payout_date": "2024-01-01T00:00:00Z",
  "history": [{
    "date": "2024-01-01T00:00:00Z",
    "amount": 10000000,
    "source": "string",
    "status": "string"
  }]
}
```

### Get Transaction History
```http
GET /users/me/transactions
Authorization: Bearer <token>
Query Parameters:
  - limit: number (default: 10)
  - offset: number (default: 0)

Response 200:
{
  "transactions": [{
    "id": "uuid",
    "amount": 10000000,
    "transaction_type": "string",
    "description": "string",
    "created_at": "2024-01-01T00:00:00Z"
  }],
  "total": 0,
  "has_more": false
}
```

## Video Management

### Upload Video

#### Step 1: Generate Upload URL
```http
POST /videos/upload-url
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "string",
  "filename": "string",
  "pix": 1000000000,  // Example: 1 billion pix for ~30 seconds of HD video
  "resolution_tier": "hd", // Options: sd, hd, 4k, 8k, native
  "resolution_width": 1920,
  "resolution_height": 1080,
  "visibility": "private", // Options: private, public, unlisted
  "is_open_source": false
}

Response 200:
{
  "upload_url": "https://s3-presigned-url...",
  "video_id": "uuid"
}
```

#### Step 2: Upload to S3
Upload your video file directly to the provided `upload_url` using a PUT request.

#### Step 3: Confirm Upload
```http
POST /videos/upload
Authorization: Bearer <token>
Content-Type: application/json

{
  "video_id": "uuid"
}

Response 200:
{
  "message": "Video upload completed, processing started",
  "video_id": "uuid"
}
```

### Get User's Videos
```http
GET /videos/mine
Authorization: Bearer <token>

Response 200:
[{
  "id": "uuid",
  "title": "string",
  "original_filename": "string",
  "thumbnail_url": "string",
  "status": "processing", // Options: processing, completed, failed
  "duration_seconds": 0,
  "pix_spent": 0,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z",
  "resolution_tier": "hd",
  "visibility": "private",
  "is_open_source": false,
  "search_stats": {
    "total_searches": 0,
    "total_views": 0,
    "total_watch_time": 0.0
  }
}]
```

### Get Video Status
```http
GET /videos/{username}/{video_name}/status
Authorization: Bearer <token>

Response 200:
{
  "id": "uuid",
  "title": "string",
  "status": "completed",
  "processing_stage": "string",
  "processing_details": {
    "progress": 0.75,
    "message": "string"
  },
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z",
  "duration_seconds": 0,
  "frame_count": 0,
  "thumbnail_url": "string"
}
```

### Get Video Playback URLs
```http
GET /videos/{username}/{video_name}/playback
Authorization: Bearer <token>

Response 200:
{
  "mp4_url": "https://cdn.example.com/video.mp4",
  "hls_url": "https://cdn.example.com/master.m3u8",
  "duration": 120.5,
  "thumbnail_url": "https://cdn.example.com/thumbnail.jpg",
  "title": "string",
  "created_at": "2024-01-01T00:00:00Z"
}
```

### Delete Video
```http
DELETE /videos/{username}/{video_name}
Authorization: Bearer <token>

Response 200:
{
  "message": "Video deleted successfully"
}
```

## Search API

### Basic Search
```http
GET /search
Authorization: Bearer <token>
Query Parameters:
  - query: string (required)
  - page: number (default: 0)
  - per_page: number (default: 20, max: 100)

Response 200:
{
  "content": [{
    "video_id": "uuid",
    "title": "string",
    "username": "string",
    "user_id": "uuid",
    "thumbnail_url": "string",
    "duration": 0.0,
    "timestamp": 0.0,
    "context": "string",
    "relevance_score": 0.95,
    "created_at": "2024-01-01T00:00:00Z",
    "resolution_tier": "hd",
    "view_count": 0,
    "processing_type": "ai"
  }],
  "pageable": {
    "pageNumber": 0,
    "pageSize": 20
  },
  "totalElements": 100,
  "totalPages": 5,
  "last": false
}
```

### Parse Search Query
```http
POST /search/parse
Authorization: Bearer <token>
Content-Type: application/json

{
  "query": "string"
}

Response 200:
{
  "parsed_query": {
    "text": "string",
    "filters": {
      "content_types": ["video", "audio"],
      "username": "string",
      "min_similarity": 0.8
    }
  }
}
```

### Multi-Search
```http
POST /search/multi
Authorization: Bearer <token>
Content-Type: application/json

{
  "queries": ["query1", "query2"],
  "limit": 10
}

Response 200:
{
  "results": [{
    "query": "string",
    "videos": [{
      "video_id": "uuid",
      "title": "string",
      // ... same as search result
    }]
  }]
}
```

### Segment Search
```http
POST /search/segments
Authorization: Bearer <token>
Content-Type: application/json

{
  "query": "string",
  "limit": 20
}

Response 200:
{
  "segments": [{
    "video_id": "uuid",
    "title": "string",
    "username": "string",
    "segment_start": 10.5,
    "segment_end": 25.8,
    "transcript": "string",
    "relevance_score": 0.95
  }]
}
```

## Public Access Endpoints

### Public Search
```http
GET /public/search
Query Parameters:
  - query: string (required)
  - page: number (default: 0)
  - per_page: number (default: 20)

Response 200:
{
  "results": [{
    "video_id": "uuid",
    "title": "string",
    "username": "string",
    "thumbnail_url": "string",
    "duration": 0.0,
    "created_at": "2024-01-01T00:00:00Z",
    "view_count": 0
  }],
  "total": 100,
  "page": 0,
  "per_page": 20
}
```

### Public Video Playback
```http
GET /public/videos/{username}/{video_name}/playback

Response 200:
{
  "mp4_url": "string",
  "hls_url": "string",
  "duration": 0.0,
  "thumbnail_url": "string",
  "title": "string",
  "created_at": "2024-01-01T00:00:00Z"
}
```

## Search Credits & Monetization

### Track Search Click
```http
POST /search-credits/track-click
Authorization: Bearer <token>
Content-Type: application/json

{
  "search_session_id": "uuid",
  "video_id": "uuid",
  "segment_start": 0.0,
  "segment_end": 30.0,
  "query": "string"
}

Response 200:
{
  "tracking_id": "uuid",
  "video_url": "string"
}
```

### Credit Full Watch
```http
POST /search-credits/{username}/{video_name}/credit-full-watch
Authorization: Bearer <token>
Content-Type: application/json

{
  "timestamp": 120.5,
  "video_duration": 300.0,
  "last_credited_timestamp": 90.0
}

Response 200:
{
  "credited": true,
  "pix_earned": 10,
  "message": "string"
}
```

## Pix Management

### Get Pix Balance
```http
GET /pix/balance
Authorization: Bearer <token>

Response 200:
{
  "pix": 1000
}
```

### Purchase Pix (Placeholder)
```http
POST /pix/purchase
Authorization: Bearer <token>
Content-Type: application/json

{
  "pix": 10000000,  // Example: 10 million pix ($1)
  "payment_token": "string"
}

Response 200:
{
  "success": true,
  "new_balance": 2000
}
```

## Earnings & Leaderboard

### Get Earnings Dashboard
```http
GET /earnings/dashboard
Authorization: Bearer <token>

Response 200:
{
  "summary": {
    "total_earned": 500000000,
    "current_month": 100000000,
    "previous_month": 150000000,
    "pending_payout": 50000000
  },
  "videos": [{
    "video_id": "uuid",
    "title": "string",
    "total_earned": 100000000,
    "searches": 50,
    "views": 30,
    "average_watch_time": 120.5
  }],
  "recent_transactions": [{
    "date": "2024-01-01T00:00:00Z",
    "video_title": "string",
    "type": "search_view",
    "amount": 1000000
  }],
  "monthly_trend": [{
    "month": "2024-01",
    "earned": 100000000
  }]
}
```

### Get Earnings History
```http
GET /earnings/history
Authorization: Bearer <token>
Query Parameters:
  - page: number (default: 0)
  - per_page: number (default: 20)
  - start_date: ISO 8601 date
  - end_date: ISO 8601 date
  - video_id: uuid (optional)

Response 200:
{
  "earnings": [{
    "id": "uuid",
    "video_id": "uuid",
    "video_title": "string",
    "amount": 1000000,
    "type": "search_view",
    "created_at": "2024-01-01T00:00:00Z",
    "details": {
      "searcher_id": "uuid",
      "query": "string",
      "watch_duration": 120.5
    }
  }],
  "total": 100,
  "page": 0,
  "per_page": 20,
  "summary": {
    "total_amount": 100000000,
    "by_type": {
      "search_view": 80000000,
      "full_watch": 20000000
    }
  }
}
```

### Get Leaderboard
```http
GET /earnings/leaderboard
Authorization: Bearer <token>
Query Parameters:
  - timeframe: string (week, month, all_time)
  - limit: number (default: 10, max: 100)

Response 200:
{
  "timeframe": "month",
  "entries": [{
    "rank": 1,
    "user_id": "uuid",
    "username": "string",
    "total_earned": 100000000,
    "video_count": 10,
    "search_count": 500
  }]
}
```

## Payment Integration

### Stripe Checkout

#### Create Checkout Session
```http
POST /stripe/create-checkout
Authorization: Bearer <token>
Content-Type: application/json

{
  "pix": 100000000  // Minimum: 100 million pix ($10)
}

Response 200:
{
  "checkout_url": "https://checkout.stripe.com/...",
  "session_id": "string"
}
```

#### Stripe Webhook
```http
POST /stripe/webhook
Content-Type: application/json
Stripe-Signature: <webhook_signature>

<Stripe webhook payload>

Response 200:
{
  "received": true
}
```

### Solana Payments

#### Create Payment
```http
POST /solana/create-payment
Authorization: Bearer <token>
Content-Type: application/json

{
  "pix": 10000000  // Minimum: 10 million pix ($1)
}

Response 200:
{
  "payment_url": "solana:...",
  "reference": "string",
  "amount_usdc": "10.00",
  "pix": 1000
}
```

#### Check Payment Status
```http
POST /solana/check-status
Authorization: Bearer <token>
Content-Type: application/json

{
  "reference": "string"
}

Response 200:
{
  "status": "confirmed", // pending, confirmed, failed
  "signature": "string"
}
```

## Wallet Management

### Get Wallet Info
```http
GET /wallet/info
Authorization: Bearer <token>

Response 200:
{
  "wallet_address": "string",
  "balances": {
    "usdc": "100.50",
    "sol": "0.05"
  },
  "deposit_address": "string"
}
```

### Get Wallet Balance
```http
GET /wallet/balance
Authorization: Bearer <token>

Response 200:
{
  "available_balance": "100.50",
  "pending_balance": "10.00",
  "total_balance": "110.50",
  "currency": "USDC"
}
```

### Sync Wallet Balance
```http
POST /wallet/sync
Authorization: Bearer <token>

Response 200:
{
  "synced": true,
  "new_balance": "100.50",
  "transactions_found": 2
}
```

### Get Wallet Transactions
```http
GET /wallet/transactions
Authorization: Bearer <token>
Query Parameters:
  - limit: number (default: 20)
  - offset: number (default: 0)
  - type: string (deposit, withdrawal, earning)

Response 200:
{
  "transactions": [{
    "id": "uuid",
    "type": "deposit",
    "amount": "100.00",
    "currency": "USDC",
    "status": "completed",
    "blockchain_signature": "string",
    "created_at": "2024-01-01T00:00:00Z"
  }],
  "total": 50,
  "has_more": true
}
```

### Withdraw Funds
```http
POST /wallet/withdraw
Authorization: Bearer <token>
X-2FA-Code: 123456 (if 2FA enabled)
Content-Type: application/json

{
  "destination_address": "string",
  "amount_usdc": "50.00"
}

Response 200:
{
  "success": true,
  "signature": "string",
  "amount": "50.00",
  "fee": "0.50",
  "total_deducted": "50.50"
}
```

## Investment System

### Find Investment Opportunities
```http
GET /investments/available
Authorization: Bearer <token>
Query Parameters:
  - min_views: number
  - max_cost: number
  - category: string
  - sort_by: string (views, cost, potential_roi)

Response 200:
[{
  "video_id": "uuid",
  "title": "string",
  "creator": "string",
  "current_resolution": "sd",
  "available_upgrades": ["hd", "4k"],
  "view_count": 1000,
  "search_count": 500,
  "estimated_upgrade_cost": {
    "hd": 1000000000,
    "4k": 17000000000
  }
}]
```

### Calculate Investment
```http
POST /investments/calculate
Authorization: Bearer <token>
Content-Type: application/json

{
  "video_id": "uuid",
  "upgrade_type": "resolution",
  "target_resolution": "hd"
}

Response 200:
{
  "upgrade_cost_pix": 1000000000,
  "processing_time_estimate": "2-3 hours",
  "projected_roi": {
    "daily": 10000000,
    "weekly": 70000000,
    "monthly": 300000000
  },
  "break_even_days": 100
}
```

### Create Investment
```http
POST /investments/invest
Authorization: Bearer <token>
Content-Type: application/json

{
  "video_id": "uuid",
  "upgrade_type": "resolution",
  "target_resolution": "hd"
}

Response 200:
{
  "investment_id": "uuid",
  "video_id": "uuid",
  "amount_invested": 1000000000,
  "status": "processing",
  "estimated_completion": "2024-01-01T12:00:00Z"
}
```

### Get My Investments
```http
GET /investments/my-investments
Authorization: Bearer <token>

Response 200:
[{
  "investment_id": "uuid",
  "video": {
    "id": "uuid",
    "title": "string",
    "creator": "string"
  },
  "amount_invested": 1000000000,
  "total_earned": 150000000,
  "roi_percentage": 15.0,
  "status": "active",
  "invested_at": "2024-01-01T00:00:00Z"
}]
```

### Get Investment Details
```http
GET /investments/{investment_id}
Authorization: Bearer <token>

Response 200:
{
  "investment_id": "uuid",
  "video": {
    "id": "uuid",
    "title": "string",
    "creator": "string",
    "current_resolution": "hd"
  },
  "investment_details": {
    "type": "resolution_upgrade",
    "from_resolution": "sd",
    "to_resolution": "hd",
    "amount_invested": 1000000000
  },
  "earnings": {
    "total": 150000000,
    "last_24h": 5000000,
    "last_7d": 35000000
  },
  "status": "active",
  "invested_at": "2024-01-01T00:00:00Z"
}
```

### Get Investment Earnings
```http
GET /investments/{investment_id}/earnings
Authorization: Bearer <token>
Query Parameters:
  - timeframe: string (day, week, month, all)

Response 200:
{
  "investment_id": "uuid",
  "timeframe": "week",
  "earnings": [{
    "date": "2024-01-01",
    "amount": 5000000,
    "search_count": 5,
    "view_count": 3
  }],
  "total": 35000000,
  "roi_percentage": 3.5
}
```

## Investment Offers

### Create Offer
```http
POST /offers/create
Authorization: Bearer <token>
Content-Type: application/json

{
  "video_id": "uuid",
  "offer_amount": 1000000000,
  "revenue_share": 0.20,
  "message": "string",
  "expires_in_hours": 48
}

Response 200:
{
  "offer_id": "uuid",
  "status": "pending",
  "created_at": "2024-01-01T00:00:00Z",
  "expires_at": "2024-01-03T00:00:00Z"
}
```

### Get Sent Offers
```http
GET /offers/sent
Authorization: Bearer <token>

Response 200:
[{
  "offer_id": "uuid",
  "video": {
    "id": "uuid",
    "title": "string",
    "creator": "string"
  },
  "offer_amount": 1000000000,
  "revenue_share": 0.20,
  "status": "pending",
  "created_at": "2024-01-01T00:00:00Z",
  "expires_at": "2024-01-03T00:00:00Z"
}]
```

### Get Received Offers
```http
GET /offers/received
Authorization: Bearer <token>

Response 200:
[{
  "offer_id": "uuid",
  "investor": {
    "id": "uuid",
    "username": "string"
  },
  "video": {
    "id": "uuid",
    "title": "string"
  },
  "offer_amount": 1000000000,
  "revenue_share": 0.20,
  "status": "pending",
  "message": "string",
  "created_at": "2024-01-01T00:00:00Z",
  "expires_at": "2024-01-03T00:00:00Z"
}]
```

### Accept Offer
```http
POST /offers/{offer_id}/accept
Authorization: Bearer <token>

Response 200:
{
  "offer_id": "uuid",
  "status": "accepted",
  "investment_id": "uuid",
  "accepted_at": "2024-01-01T00:00:00Z"
}
```

### Reject Offer
```http
POST /offers/{offer_id}/reject
Authorization: Bearer <token>

Response 200:
{
  "offer_id": "uuid",
  "status": "rejected",
  "rejected_at": "2024-01-01T00:00:00Z"
}
```

### Counter Offer
```http
POST /offers/{offer_id}/counter
Authorization: Bearer <token>
Content-Type: application/json

{
  "counter_amount": 1500,
  "counter_revenue_share": 0.25,
  "message": "string"
}

Response 200:
{
  "offer_id": "uuid",
  "counter_id": "uuid",
  "status": "countered",
  "countered_at": "2024-01-01T00:00:00Z"
}
```

## World ID Verification

### Verify World ID
```http
POST /worldcoin/verify
Authorization: Bearer <token>
Content-Type: application/json

{
  "proof": "string",
  "merkle_root": "string",
  "nullifier_hash": "string"
}

Response 200:
{
  "verified": true,
  "message": "World ID verified successfully"
}
```

## Discord Integration

### Get Discord Webhook Settings
```http
GET /discord/webhook
Authorization: Bearer <token>

Response 200:
{
  "webhook_url": "https://discord.com/api/webhooks/...",
  "enabled": true,
  "events": ["video_processed", "investment_received"]
}
```

### Update Discord Webhook
```http
PUT /discord/webhook
Authorization: Bearer <token>
Content-Type: application/json

{
  "webhook_url": "https://discord.com/api/webhooks/...",
  "enabled": true,
  "events": ["video_processed", "investment_received"]
}

Response 200:
{
  "message": "Webhook settings updated",
  "enabled": true
}
```

### Test Discord Webhook
```http
POST /discord/webhook/test
Authorization: Bearer <token>

Response 200:
{
  "success": true,
  "message": "Test notification sent"
}
```

## Error Responses

All API errors follow a consistent format:

```json
{
  "error": "ERROR_CODE",
  "error_code": "ERROR_CODE",
  "message": "Human-readable error message",
  "details": {}, // Optional additional context
  "request_id": "uuid" // Optional request tracking
}
```

### Common Error Codes

| HTTP Status | Error Code | Description |
|-------------|------------|-------------|
| 400 | BAD_REQUEST | Invalid request parameters |
| 400 | VALIDATION_ERROR | Request validation failed |
| 401 | UNAUTHORIZED | Missing or invalid authentication |
| 401 | INVALID_CREDENTIALS | Wrong username/password |
| 401 | TOKEN_EXPIRED | JWT token has expired |
| 402 | INSUFFICIENT_FUNDS | Not enough Pix balance |
| 404 | NOT_FOUND | Resource not found |
| 409 | CONFLICT | Resource already exists |
| 429 | RATE_LIMIT_EXCEEDED | Too many requests |
| 500 | INTERNAL_ERROR | Server error |
| 502 | EXTERNAL_SERVICE_ERROR | External service failure |
| 503 | DATABASE_CONNECTION_ERROR | Database unavailable |

## Rate Limiting

API endpoints are rate-limited to prevent abuse:

- Authentication endpoints: 5 requests per minute
- Upload endpoints: 10 requests per hour
- Search endpoints: 100 requests per minute
- Wallet operations: 10 requests per minute
- Other endpoints: 60 requests per minute

Rate limit headers are included in responses:
- `X-RateLimit-Limit`: Maximum requests allowed
- `X-RateLimit-Remaining`: Requests remaining
- `X-RateLimit-Reset`: Unix timestamp when limit resets

## Pagination

Endpoints that return lists support pagination:

- `page`: Page number (0-indexed)
- `per_page`: Items per page (default: 20, max: 100)

Paginated responses include:
```json
{
  "content": [...],
  "pageable": {
    "pageNumber": 0,
    "pageSize": 20
  },
  "totalElements": 100,
  "totalPages": 5,
  "last": false
}
```

## Data Types

### Common Types

- **UUID**: String in format "123e4567-e89b-12d3-a456-426614174000"
- **DateTime**: ISO 8601 format "2024-01-01T00:00:00Z"
- **Decimal**: String representation of decimal numbers for financial precision
- **Resolution**: One of: "sd", "hd", "4k", "8k", "native"
- **Visibility**: One of: "private", "public", "unlisted"
- **ProcessingStatus**: One of: "pending", "processing", "completed", "failed"

### Pix Currency

Pix is the platform's virtual currency:
- 1 Pix = $0.0000001 USD
- $1 USD = 10,000,000 Pix (10 million)
- 1 cent = 100,000 Pix
- Used for video processing, search credits, and investments
- Earned through video views and search traffic
- Can be purchased via Stripe or Solana payments

#### Video Processing Costs by Resolution

Per-frame costs:
- **SD (256x256)**: 65,000 pix/frame
- **HD (1024x1024)**: 1,000,000 pix/frame
- **4K (4096x4096)**: 17,000,000 pix/frame
- **8K (8192x8192)**: 67,000,000 pix/frame
- **Native**: Variable based on actual resolution

Example costs for 30fps video:
- **SD**: ~2M pix/second (~$0.20/second)
- **HD**: 30M pix/second ($3/second)
- **4K**: 510M pix/second ($51/second)
- **8K**: 2B pix/second ($200/second)

## Webhooks

The platform can send webhooks for various events:

- Video processing completed
- Investment offer received
- Investment returns credited
- Large withdrawal requested

Configure webhooks through the Discord integration endpoints.

## SDK Examples

### JavaScript/TypeScript
```typescript
const PIXR_API_BASE = 'https://api.pixr.co/api/v1';

class PixrClient {
  constructor(private accessToken: string) {}

  async searchVideos(query: string) {
    const response = await fetch(`${PIXR_API_BASE}/search?query=${encodeURIComponent(query)}`, {
      headers: {
        'Authorization': `Bearer ${this.accessToken}`
      }
    });
    return response.json();
  }

  async uploadVideo(title: string, file: File, pix: number) {
    // Step 1: Get upload URL
    const uploadUrlResponse = await fetch(`${PIXR_API_BASE}/videos/upload-url`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${this.accessToken}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        title,
        filename: file.name,
        pix,
        resolution_tier: '1080p'
      })
    });
    const { upload_url, video_id } = await uploadUrlResponse.json();

    // Step 2: Upload to S3
    await fetch(upload_url, {
      method: 'PUT',
      body: file
    });

    // Step 3: Confirm upload
    await fetch(`${PIXR_API_BASE}/videos/upload`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${this.accessToken}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ video_id })
    });

    return video_id;
  }
}
```

### Python
```python
import requests

class PixrClient:
    def __init__(self, access_token):
        self.access_token = access_token
        self.base_url = 'https://api.pixr.co/api/v1'
        self.headers = {'Authorization': f'Bearer {access_token}'}
    
    def search_videos(self, query):
        response = requests.get(
            f'{self.base_url}/search',
            params={'query': query},
            headers=self.headers
        )
        return response.json()
    
    def get_earnings_dashboard(self):
        response = requests.get(
            f'{self.base_url}/earnings/dashboard',
            headers=self.headers
        )
        return response.json()
```

## Support

For API support and questions:
- Documentation: https://docs.pixr.co
- Email: robert@svid.ai
- Discord: https://discord.gg/pixr

## Changelog

### Version 1.0.0 (Current)
- Initial public API release
- Video upload and processing
- AI-powered search
- Pix monetization system
- Investment features
- Wallet management
- Payment integrations (Stripe, Solana)
- World ID verification
- Discord webhooks
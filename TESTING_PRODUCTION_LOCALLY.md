# Testing Production Locally

## Current Status

The frontend production build is working perfectly with the title sanitization features implemented:
- Frontend is running at: http://localhost:3002
- All title sanitization is working (dots removed, lowercase, spaces to dashes)
- URL preview is shown in the upload form

## Backend Build Issue

The backend Docker build is currently failing due to SQLX offline data being out of sync with the database schema. This is because the `.sqlx` folder contains queries expecting columns that don't exist in the current migrations.

## How to Test Production Locally

### Option 1: Frontend Only (Currently Running)

The frontend production build is already running:
```bash
# Frontend is accessible at:
http://localhost:3002

# To stop:
docker stop svid-frontend-test
docker rm svid-frontend-test
```

### Option 2: Run Backend Locally + Frontend in Docker

1. Start PostgreSQL:
```bash
docker-compose up -d postgres
```

2. Run backend locally:
```bash
cd svid-backend
export DATABASE_URL="postgresql://svid:svid_password@localhost:5432/svid_db"
cargo run
```

3. Frontend is already running at http://localhost:3002

### Option 3: Fix Backend and Run Full Production

To fix the backend build issues:

1. The SQLX offline data needs to be regenerated with a matching database schema
2. Missing columns need to be added to migrations:
   - `total_returns_usdc` in investor reputation
   - `thumbnail_s3_key` in videos table
   - Various columns in creator market performance tables

## Title Sanitization Features Implemented

✅ **Frontend (`/upload` page):**
- Removes dots from titles automatically
- Converts uppercase to lowercase as user types
- Replaces spaces with dashes in real-time
- Shows URL preview: `https://[domain]/[username]/[sanitized-title]`
- Prevents uppercase letters and auto-converts spaces to dashes

✅ **Backend (`public_videos.rs`):**
- Fixed to search for videos by sanitized titles directly
- No longer incorrectly converts dashes back to spaces

## Testing the Title Sanitization

1. Go to http://localhost:3002/upload
2. Select a video file with dots in the name (e.g., "Ep. 1 - Test.Video.mp4")
3. Notice the title is automatically sanitized to "ep-1-testvideo"
4. Try typing uppercase letters - they're converted to lowercase
5. Try typing spaces - they're converted to dashes
6. See the URL preview updating in real-time

## Next Steps

To fully test production with backend:
1. Fix the database schema mismatches
2. Regenerate SQLX offline data
3. Rebuild the backend Docker image
4. Run the full docker-compose stack

For now, the frontend production build demonstrates that the title sanitization is working correctly.
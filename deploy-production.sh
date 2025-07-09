#!/bin/bash
# Production deployment script for SVID full stack

set -e

echo "==================================="
echo "SVID Production Deployment Script"
echo "==================================="
echo ""

# Step 1: Clean up any existing containers and volumes
echo "Step 1: Cleaning up existing containers and volumes..."
docker-compose down -v

# Step 2: Start PostgreSQL
echo ""
echo "Step 2: Starting PostgreSQL..."
docker-compose up -d postgres

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
sleep 10

# Step 3: Run migrations
echo ""
echo "Step 3: Running database migrations..."
cd svid-backend
export DATABASE_URL="postgresql://svid:svid_password@localhost:5432/svid_db"

# Create database extensions if needed
psql "$DATABASE_URL" <<EOF
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS vector;
EOF

# Run migrations
sqlx migrate run

# Step 4: Generate SQLX offline data
echo ""
echo "Step 4: Generating SQLX offline data..."
rm -rf .sqlx
cargo sqlx prepare

# Step 5: Return to root directory
cd ..

# Step 6: Build and start all services
echo ""
echo "Step 5: Building and starting all services..."
docker-compose up -d --build

# Step 7: Wait for services to be ready
echo ""
echo "Waiting for services to start..."
sleep 15

# Step 8: Check service status
echo ""
echo "==================================="
echo "Deployment Complete!"
echo "==================================="
echo ""
docker-compose ps

echo ""
echo "Services are available at:"
echo "- Frontend: http://localhost:3000"
echo "- Backend API: http://localhost:8080"
echo "- PostgreSQL: localhost:5432"
echo ""
echo "Title Sanitization Features:"
echo "✅ Dots removed from titles"
echo "✅ Uppercase converted to lowercase"
echo "✅ Spaces replaced with dashes"
echo "✅ Real-time URL preview in upload form"
echo ""
echo "Monitor logs with: docker-compose logs -f"
echo "Stop services with: docker-compose down"
echo ""
echo "To test title sanitization:"
echo "1. Go to http://localhost:3000/upload"
echo "2. Select a video file (e.g., 'Ep. 1 - Test.Video.mp4')"
echo "3. See title auto-sanitized to 'ep-1-testvideo'"
echo "4. Try typing uppercase letters - they convert to lowercase"
echo "5. Try typing spaces - they convert to dashes"
echo "6. See the URL preview update in real-time"
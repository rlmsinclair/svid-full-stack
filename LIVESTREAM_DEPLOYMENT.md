# Livestream Multi-Stream Deployment Guide

## Quick Deployment Steps

### 1. Apply Database Migration
First, run the new migration to add multi-stream support:

```bash
# Connect to your production database
psql $DATABASE_URL < svid-backend/migrations/00000000000020_add_multi_stream_support.sql
```

### 2. Deploy Backend Changes
The backend needs to be rebuilt and deployed with the multi-stream endpoints:

```bash
# Build and push backend
cd svid-backend
docker build -t your-registry/svid-backend:latest .
docker push your-registry/svid-backend:latest
```

### 3. Fix CORS Configuration (CRITICAL)
Update the Kubernetes ConfigMap to include production domains:

```bash
# Apply the updated backend.yaml with CORS fix
kubectl apply -f svid-backend/kubernetes/backend.yaml

# Restart backend pods to pick up the new environment variable
kubectl rollout restart deployment/backend -n svid
```

### 4. Deploy Frontend Changes
Build and deploy the frontend with multi-stream support:

```bash
cd svid-frontend
npm run build
docker build -t your-registry/svid-frontend:latest .
docker push your-registry/svid-frontend:latest

# Update frontend deployment
kubectl set image deployment/frontend frontend=your-registry/svid-frontend:latest -n svid
```

## What's New

### For Broadcasters
- Stream screen and camera simultaneously
- Control each stream independently
- Picture-in-picture preview with customizable position
- Separate quality settings for screen (optimized for text) and camera
- Dynamic pricing based on active streams

### For Viewers
- Choose which streams to watch
- Customize layout (picture-in-picture position and size)
- Pay only for the streams you enable
- Better bandwidth management

### Technical Improvements
- Separate WebRTC connections for each stream
- Content-aware optimization (detail for screen, motion for camera)
- Backward compatible with single-stream sessions
- Professional multi-stream architecture

## Testing

After deployment, test the following:

1. **CORS Fix**: Navigate to https://pixr.co/livestream - it should load without errors
2. **Multi-Stream Broadcasting**: Click "Go Live" and enable both screen and camera
3. **Legacy Compatibility**: Old single-stream sessions should still work
4. **Viewer Experience**: Join a multi-stream session and test layout controls

## Troubleshooting

### CORS Still Failing
Check that the backend pod has the correct environment variable:
```bash
kubectl exec -it deployment/backend -n svid -- env | grep ALLOWED_ORIGINS
```

Should output:
```
ALLOWED_ORIGINS=https://pixr.co,https://api.pixr.co,http://localhost:3000,http://localhost:3001
```

### Database Migration Failed
The migration renames `livestreams` to `broadcast_sessions`. If you have active streams, you may want to:
1. Wait for all streams to end
2. Or manually migrate the data

### Frontend Not Loading New Component
Clear browser cache and ensure the new component is bundled:
```bash
# Check if the file is included in the build
ls -la .next/static/chunks/
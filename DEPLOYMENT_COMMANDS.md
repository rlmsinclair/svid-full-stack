# Deployment Commands for Multi-Stream Livestreaming

## 1. Deploy Backend

### Build and Push Docker Image
```bash
cd svid-backend

# Build the backend image
docker build -t 699579130723.dkr.ecr.eu-west-2.amazonaws.com/svid-backend:multistream -f Dockerfile.production .

# Login to ECR (if needed)
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 699579130723.dkr.ecr.eu-west-2.amazonaws.com

# Push the image
docker push 699579130723.dkr.ecr.eu-west-2.amazonaws.com/svid-backend:multistream
```

### Update Kubernetes Deployment
```bash
# Apply the updated backend.yaml with CORS fix
kubectl apply -f svid-backend/kubernetes/backend.yaml

# Update the backend deployment to use the new image
kubectl set image deployment/backend backend=699579130723.dkr.ecr.eu-west-2.amazonaws.com/svid-backend:multistream -n svid

# Watch the rollout
kubectl rollout status deployment/backend -n svid
```

## 2. Deploy Frontend

### Build and Push Docker Image
```bash
cd svid-frontend

# Build the frontend image
docker build -t 699579130723.dkr.ecr.eu-west-2.amazonaws.com/svid-frontend:multistream -f Dockerfile.production .

# Push the image
docker push 699579130723.dkr.ecr.eu-west-2.amazonaws.com/svid-frontend:multistream

# Update the frontend deployment
kubectl set image deployment/frontend frontend=699579130723.dkr.ecr.eu-west-2.amazonaws.com/svid-frontend:multistream -n svid

# Watch the rollout
kubectl rollout status deployment/frontend -n svid
```

## 3. Verify Deployment

### Check Pod Status
```bash
# Check all pods are running
kubectl get pods -n svid

# Check backend logs for any errors
kubectl logs -l app=backend -n svid --tail=50

# Check frontend logs
kubectl logs -l app=frontend -n svid --tail=50
```

### Test CORS Fix
```bash
# From your browser console at https://pixr.co
fetch('https://api.pixr.co/api/v1/livestream/active', {
  headers: {
    'Authorization': 'Bearer YOUR_TOKEN_HERE'
  }
}).then(r => r.json()).then(console.log)
```

### Test Multi-Stream
1. Navigate to https://pixr.co/livestream
2. Click "Go Live"
3. Enable both Screen and Camera
4. Start broadcasting
5. Check that both streams are working

## 4. Rollback (if needed)

If there are issues, rollback to previous version:
```bash
# Rollback backend
kubectl rollout undo deployment/backend -n svid

# Rollback frontend
kubectl rollout undo deployment/frontend -n svid
```

## Quick One-Liner Deploy

For quick deployment after testing locally:
```bash
# Backend
cd svid-backend && docker build -t 699579130723.dkr.ecr.eu-west-2.amazonaws.com/svid-backend:multistream -f Dockerfile.production . && docker push 699579130723.dkr.ecr.eu-west-2.amazonaws.com/svid-backend:multistream && kubectl set image deployment/backend backend=699579130723.dkr.ecr.eu-west-2.amazonaws.com/svid-backend:multistream -n svid

# Frontend  
cd svid-frontend && docker build -t 699579130723.dkr.ecr.eu-west-2.amazonaws.com/svid-frontend:multistream -f Dockerfile.production . && docker push 699579130723.dkr.ecr.eu-west-2.amazonaws.com/svid-frontend:multistream && kubectl set image deployment/frontend frontend=699579130723.dkr.ecr.eu-west-2.amazonaws.com/svid-frontend:multistream -n svid
```
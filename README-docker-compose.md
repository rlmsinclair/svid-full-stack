# Docker Compose Setup for Local Production Testing

This setup allows you to test the production environment locally using Docker Compose.

## Prerequisites

- Docker and Docker Compose installed
- GitHub CLI (`gh`) installed and authenticated (for fetching secret names)
- Access to the GitHub repositories containing the secrets

## Setup Instructions

1. **Generate .env files from GitHub secrets:**
   ```bash
   ./setup-env-from-github.sh
   ```
   This will create `.env.backend` and `.env.frontend` files with placeholders for all secrets from your GitHub repositories.

2. **Fill in the secret values:**
   - Go to each GitHub repository's Settings > Secrets and variables > Actions
   - Copy the actual secret values and replace the placeholders in the .env files
   - For local testing, you may want to use different values (e.g., local database credentials)

3. **Start the services:**
   ```bash
   docker-compose up --build
   ```
   Or run in detached mode:
   ```bash
   docker-compose up --build -d
   ```

4. **Access the application:**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8080
   - PostgreSQL: localhost:5432

## Common Commands

- **View logs:**
  ```bash
  docker-compose logs -f [service-name]
  ```

- **Stop services:**
  ```bash
  docker-compose down
  ```

- **Stop and remove volumes:**
  ```bash
  docker-compose down -v
  ```

- **Rebuild specific service:**
  ```bash
  docker-compose build backend
  docker-compose up -d backend
  ```

## Notes

- The frontend is configured to use `http://localhost:8080` as the API URL for local testing
- Database migrations run automatically when the backend starts
- Volumes are used to persist PostgreSQL data, search index, and uploads between restarts
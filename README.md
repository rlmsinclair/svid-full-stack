# SVID Frontend

## Open WebUI Configuration

### Environment Setup
1. Navigate to the open-webui directory:
   ```bash
   cd open-webui
   ```
2. Configure environment variables:
   ```bash
   nano .env
   ```

### Running Open WebUI
To build and run the service:
```bash
cd open-webui
./run.sh
```

## Custom Pipelines

### Initial Setup
1. Navigate to the pipelines directory:
   ```bash
   cd pipelines
   ```
2. Create and activate a Python virtual environment:
   ```bash
   python3.11 -m venv venv
   source venv/bin/activate
   ```

### Rebuilding Pipelines
Set the required environment variables and rebuild:
```bash
cd pipelines
export PIPELINES_REQUIREMENTS_PATH=./requirements.txt
export PIPELINES_DIR=./../svid_pipelines
```

### Required Environment Variables
For custom pipelines to work, ensure the following variables are set in `open-webui/.env`:
- `OPENAI_API_BASE_URL='http://host.docker.internal:9099'` (or appropriate URL)
- `OPENAI_API_KEY='0p3n-w3bu!'`

## Docker Setup
The project includes a `docker-compose.yaml` file for automated container building and running.


I added this method in main.py

# Test commit to verify email configuration

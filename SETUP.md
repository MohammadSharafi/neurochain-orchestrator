# NeuroChain Orchestrator - Setup Guide

Complete setup instructions for running NeuroChain locally.

## Prerequisites

- **Java 17+** - For Spring Boot backend
- **Python 3.10+** - For AI worker
- **Flutter 3.8+** - For frontend
- **Docker & Docker Compose** - For infrastructure
- **PostgreSQL 15+** - Database (via Docker)
- **Redis** - Event bus (via Docker)

## Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd neurochain
```

### 2. Start Infrastructure

```bash
cd docker
docker-compose up -d
```

This starts:
- PostgreSQL (port 5432)
- Redis (port 6379)

Wait for services to be healthy:
```bash
docker-compose ps
```

### 3. Start AI Worker

```bash
cd ai-worker
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python main.py
```

The AI worker will start on port **5000**.

### 4. Start Backend (Orchestrator)

```bash
cd orchestrator
./mvnw spring-boot:run
```

Or with Maven:
```bash
mvn spring-boot:run
```

The backend will start on port **8080**.

Verify it's running:
```bash
curl http://localhost:8080/health
```

### 5. Run Flutter Frontend

```bash
cd frontend
flutter pub get
flutter run
```

For specific platform:
```bash
flutter run -d chrome        # Web
flutter run -d macos         # macOS
flutter run -d windows       # Windows
flutter run -d linux         # Linux
```

## Configuration

### Backend Configuration

Edit `orchestrator/src/main/resources/application.yml`:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/neurochain
    username: neurochain
    password: neurochain

ai-worker:
  base-url: http://localhost:5000
```

### Frontend Configuration

Edit `frontend/lib/core/config/app_config.dart`:

```dart
static const String graphqlUrl = 'http://localhost:8080/graphql';
static const String wsUrl = 'ws://localhost:8080/graphql-ws';
```

### AI Worker Configuration

Set environment variables:

```bash
export LLAMA_MODEL_PATH=./models/llama.gguf
export MISTRAL_MODEL_PATH=./models/mistral.gguf
export WHISPER_MODEL_PATH=./models/whisper.gguf
export CLIP_MODEL_PATH=./models/clip.onnx
export PORT=5000
```

## Database Setup

The database schema is automatically created via Flyway migrations on first startup.

To manually run migrations:
```bash
cd orchestrator
./mvnw flyway:migrate
```

## Testing the Setup

### 1. Test Backend Health

```bash
curl http://localhost:8080/health
```

Expected response:
```json
{
  "status": "UP",
  "service": "neurochain-orchestrator"
}
```

### 2. Test GraphQL API

Open GraphiQL:
```
http://localhost:8080/graphiql
```

Try a query:
```graphql
query {
  workflows {
    id
    name
    status
  }
}
```

### 3. Test AI Worker

```bash
curl http://localhost:5000/health
```

Expected response:
```json
{
  "status": "healthy",
  "service": "ai-worker"
}
```

### 4. Test Frontend

- Open the app
- Navigate to Model Manager
- Check if models load (may be empty initially)

## Troubleshooting

### Backend won't start

1. Check PostgreSQL is running:
   ```bash
   docker-compose ps
   ```

2. Check database connection:
   ```bash
   psql -h localhost -U neurochain -d neurochain
   ```

3. Check port 8080 is available:
   ```bash
   lsof -i :8080
   ```

### AI Worker won't start

1. Check Python version:
   ```bash
   python --version  # Should be 3.10+
   ```

2. Check dependencies:
   ```bash
   pip list
   ```

3. Check port 5000 is available:
   ```bash
   lsof -i :5000
   ```

### Frontend won't connect

1. Check backend is running:
   ```bash
   curl http://localhost:8080/health
   ```

2. Check CORS settings in backend
3. Check GraphQL URL in `app_config.dart`
4. Check browser console for errors

### Database connection errors

1. Verify PostgreSQL is running:
   ```bash
   docker-compose ps
   ```

2. Check credentials in `application.yml`
3. Verify database exists:
   ```bash
   docker-compose exec postgres psql -U neurochain -c "\l"
   ```

## Development Workflow

### Backend Development

1. Make changes to Java code
2. Backend auto-reloads (if using Spring Boot DevTools)
3. Check logs in console

### Frontend Development

1. Make changes to Dart code
2. Hot reload: Press `r` in terminal
3. Hot restart: Press `R` in terminal
4. Full restart: Stop and run again

### AI Worker Development

1. Make changes to Python code
2. Restart the worker:
   ```bash
   # Stop with Ctrl+C
   python main.py
   ```

## Production Deployment

### Backend

1. Build JAR:
   ```bash
   cd orchestrator
   ./mvnw clean package
   ```

2. Run JAR:
   ```bash
   java -jar target/neurochain-orchestrator-1.0.0.jar
   ```

### Frontend

1. Build for production:
   ```bash
   cd frontend
   flutter build web        # Web
   flutter build macos      # macOS
   flutter build windows    # Windows
   flutter build linux      # Linux
   ```

2. Deploy build output

### AI Worker

1. Use production WSGI server:
   ```bash
   gunicorn -w 4 -b 0.0.0.0:5000 main:app
   ```

## Environment Variables

### Backend

- `SPRING_DATASOURCE_URL` - Database URL
- `SPRING_DATASOURCE_USERNAME` - Database username
- `SPRING_DATASOURCE_PASSWORD` - Database password
- `AI_WORKER_BASE_URL` - AI worker URL

### AI Worker

- `PORT` - Server port (default: 5000)
- `LLAMA_MODEL_PATH` - Llama model path
- `MISTRAL_MODEL_PATH` - Mistral model path
- `WHISPER_MODEL_PATH` - Whisper model path
- `CLIP_MODEL_PATH` - CLIP model path

## Next Steps

1. Install AI models in `./models` directory
2. Create your first workflow
3. Test AI Sandbox with sample nodes
4. Explore Vector Stores for RAG
5. Try Fine-Tuning with your data

## Support

For issues or questions:
- Check logs in console
- Review error messages
- Check GitHub issues
- Review documentation

---

**Happy Coding! 🚀**


# NeuroChain Orchestrator - Project Summary

## Overview

NeuroChain Orchestrator is a next-generation, offline-capable automation platform that enables users to build and execute intelligent workflows using **local AI models**. The system runs completely on the user's device, ensuring privacy, speed, and independence from corporate APIs.

## Architecture

### Three-Layer System

1. **Flutter Frontend** - Visual workflow builder and execution dashboard
2. **Spring Boot Orchestrator** - Workflow engine and orchestration
3. **Python AI Worker** - Local AI model inference service

### Key Components

#### Orchestrator (Spring Boot)
- **WorkflowEngine**: Executes graph-based workflows with reactive execution
- **NodeExecutor**: Executes individual nodes (AI, HTTP, Transform, etc.)
- **EventBus**: Redis-based event system for workflow events
- **GraphQL API**: Complete API for workflow management
- **WorkflowService**: Business logic for workflow CRUD operations

#### AI Worker (Python)
- Flask REST API for AI operations
- Support for Llama, Mistral, Whisper, CLIP models
- GGUF model support via llama.cpp
- ONNX Runtime for optimized inference

#### Frontend (Flutter)
- Visual drag-and-drop workflow builder
- Real-time execution dashboard
- Workflow templates and sharing

## Current Implementation Status

### ✅ Completed

- Project structure and foundation
- Domain models (Workflow, Node, Connection, WorkflowExecution)
- WorkflowEngine with reactive execution
- NodeExecutor with AI node support
- GraphQL schema and resolvers
- WorkflowService for CRUD operations
- EventBus infrastructure (Redis)
- Python AI Worker with Flask API
- Docker Compose infrastructure

### 🚧 In Progress / Planned

- Flutter frontend implementation
- Plugin system for custom nodes
- Scheduled execution (cron-like)
- File watcher triggers
- HTTP webhook triggers
- Execution logging and metrics
- Workflow templates
- Plugin marketplace

## Technology Stack

- **Java 17+** - Orchestrator backend
- **Spring Boot 3.2+** - Framework
- **GraphQL** - API layer
- **Redis** - Event bus
- **PostgreSQL** - Workflow state
- **Python 3.10+** - AI Worker
- **Flask** - AI Worker API
- **Flutter** - Frontend UI

## Next Steps

1. Implement Flutter frontend with workflow builder
2. Add plugin system for extensibility
3. Implement scheduled execution
4. Add file watcher and webhook triggers
5. Create execution logging and metrics
6. Build plugin marketplace structure
7. Add workflow templates
8. Implement distributed execution

## Repository

The project is ready to be pushed to GitHub. Create the repository and update the remote URL:

```bash
git remote set-url origin <your-repo-url>
git push -u origin main
```


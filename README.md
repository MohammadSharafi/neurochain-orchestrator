# NeuroChain Orchestrator

<div align="center">

![NeuroChain](https://img.shields.io/badge/NeuroChain-Orchestrator-blue?style=for-the-badge)
![Privacy](https://img.shields.io/badge/Offline-First-green?style=for-the-badge)
![AI](https://img.shields.io/badge/Local-AI-orange?style=for-the-badge)

**Next-generation, offline-capable automation platform with local AI inference**

[Architecture](#-architecture) • [Quick Start](#-quick-start) • [Features](#-key-features)

</div>

---

## 📖 Description

NeuroChain Orchestrator is a next-generation, offline-capable automation platform that enables users to build and execute intelligent workflows using **local AI models**. Unlike cloud-dependent automation tools, NeuroChain runs completely on the user's device, ensuring privacy, speed, and independence from corporate APIs.

### Core Philosophy

🔒 **Privacy-First**: All AI inference happens locally - no data leaves your device

⚡ **Offline-Capable**: Works without internet connection

🧠 **Local AI**: Run Llama, Mistral, Whisper, CLIP models on-device

🎨 **Visual Builder**: Drag-and-drop workflow designer in Flutter

🔌 **Extensible**: Plugin system for custom nodes and AI models

🌐 **Distributed**: Multi-device execution support

## 🏗️ Architecture

### Three-Layer System

```
┌─────────────────────────────────────────────────────────┐
│              Flutter Frontend                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │Workflow  │  │Execution │  │Plugin    │             │
│  │Builder   │  │Dashboard │  │Marketplace│            │
│  └──────────┘  └──────────┘  └──────────┘             │
└──────────────────────┬──────────────────────────────────┘
                        │ GraphQL / WebSocket
┌───────────────────────▼──────────────────────────────────┐
│         Spring Boot Orchestrator                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │Workflow  │  │Event Bus │  │Node      │             │
│  │Engine    │  │(Kafka)   │  │Executor  │             │
│  └──────────┘  └──────────┘  └──────────┘             │
└──────┬───────────────────────┬──────────────────────────┘
       │ gRPC / HTTP            │
┌───────▼───────────────────────▼──────────────────────────┐
│              Python AI Worker                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │Llama     │  │Whisper   │  │CLIP      │             │
│  │Mistral   │  │ONNX      │  │Vision    │             │
│  └──────────┘  └──────────┘  └──────────┘             │
└─────────────────────────────────────────────────────────┘
```

### Technology Stack

**Frontend**
- Flutter - Cross-platform UI
- GraphQL - API communication
- WebSocket - Real-time updates
- Canvas-based workflow editor

**Orchestrator**
- Spring Boot 3.2+
- GraphQL API
- Event Bus (Kafka-like)
- Plugin system
- Workflow engine

**AI Worker**
- Python 3.10+
- llama.cpp / GGUF models
- ONNX Runtime
- Whisper.cpp
- CLIP models

**Infrastructure**
- Docker Compose
- PostgreSQL (workflow state)
- Redis (event bus)
- gRPC for inter-service communication

## 🎯 Key Features

### ✅ Visual Workflow Builder
- Drag-and-drop node editor
- Zoom, pan, group nodes
- Save templates
- Export/import workflows (JSON)
- Real-time validation

### ✅ Workflow Engine
- Graph-based execution (DAG)
- Reactive execution model
- Parallel branch execution
- Dependency resolution
- Error handling and retries

### ✅ Local AI Models
- **Text Generation**: Llama, Mistral via llama.cpp
- **Speech-to-Text**: Whisper.cpp
- **Vision**: CLIP, ONNX models
- **Optimized Inference**: GGUF quantization
- **GPU Support**: CUDA, Metal acceleration

### ✅ Node Types
- **AI Nodes**: Text generation, image analysis, transcription
- **Data Nodes**: Transform, filter, merge
- **Trigger Nodes**: File watcher, schedule, HTTP webhook
- **Action Nodes**: HTTP request, file write, notification
- **Condition Nodes**: If/else, switch, loop

### ✅ Execution Features
- Manual execution
- Scheduled execution (cron-like)
- Event-driven triggers
- Real-time progress tracking
- Execution logs and metrics
- Performance insights

### ✅ Plugin System
- Java plugins for backend logic
- Python plugins for AI tasks
- Isolated classloader execution
- Plugin marketplace structure
- Hot-reload support

### ✅ Distributed Execution
- Multi-device workflows
- gRPC communication
- WebSocket channels
- Device discovery

### ✅ Security & Privacy
- Local-only execution
- Isolated plugin sandboxing
- No external API calls
- Encrypted inter-device communication

## 🚀 Quick Start

### Prerequisites

- Java 17+
- Python 3.10+
- Flutter 3.8+
- Docker & Docker Compose

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd neurochain
```

2. **Start infrastructure**
```bash
cd docker
docker-compose up -d
```

3. **Start AI Worker**
```bash
cd ai-worker
pip install -r requirements.txt
python main.py
```

4. **Start Orchestrator**
```bash
cd orchestrator
./mvnw spring-boot:run
```

5. **Run Flutter App**
```bash
cd frontend
flutter run
```

## 📚 Documentation

- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Detailed architecture
- **[PLUGIN_GUIDE.md](docs/PLUGIN_GUIDE.md)** - Plugin development
- **[WORKFLOW_GUIDE.md](docs/WORKFLOW_GUIDE.md)** - Workflow creation

## 🛠️ Project Structure

```
neurochain/
├── orchestrator/        # Spring Boot orchestration engine
├── ai-worker/          # Python AI microservice
├── frontend/            # Flutter UI
├── plugins/             # Node plugins
├── common/              # Shared models
└── docker/              # Infrastructure
```

## 📄 License

Private project - All rights reserved

---

<div align="center">

**Built for developers who value privacy and control**

⭐ Star this repo if you find it useful!

</div>


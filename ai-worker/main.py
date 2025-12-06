#!/usr/bin/env python3
"""
NeuroChain AI Worker
Local AI inference service for running models on-device
"""

import os
import logging
from flask import Flask, request, jsonify
from flask_cors import CORS
import grpc
from concurrent import futures

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

class AIWorker:
    def __init__(self):
        self.models = {}
        self.model_paths = {
            'llama': os.getenv('LLAMA_MODEL_PATH', './models/llama.gguf'),
            'mistral': os.getenv('MISTRAL_MODEL_PATH', './models/mistral.gguf'),
            'whisper': os.getenv('WHISPER_MODEL_PATH', './models/whisper.gguf'),
            'clip': os.getenv('CLIP_MODEL_PATH', './models/clip.onnx'),
        }
        logger.info("AI Worker initialized")

    def generate_text(self, model_type, prompt, max_tokens=512, temperature=0.7):
        """Generate text using Llama or Mistral"""
        logger.info(f"Generating text with {model_type}, prompt length: {len(prompt)}")
        
        # TODO: Integrate with llama.cpp or similar
        # For now, return mock response
        return {
            "text": f"Generated text for: {prompt[:50]}...",
            "model": model_type,
            "tokens": 100
        }

    def transcribe_audio(self, audio_file_path):
        """Transcribe audio using Whisper"""
        logger.info(f"Transcribing audio: {audio_file_path}")
        
        # TODO: Integrate with Whisper.cpp
        # For now, return mock response
        return {
            "transcript": "Mock transcription",
            "language": "en",
            "duration": 0
        }

    def analyze_image(self, image_path, task="describe"):
        """Analyze image using CLIP or vision models"""
        logger.info(f"Analyzing image: {image_path}, task: {task}")
        
        # TODO: Integrate with CLIP or ONNX vision models
        # For now, return mock response
        return {
            "description": "Mock image description",
            "tags": ["object", "scene"],
            "confidence": 0.95
        }

    def get_model_info(self):
        """Get information about available models"""
        return {
            "available_models": list(self.model_paths.keys()),
            "gpu_available": self._check_gpu(),
            "models_loaded": list(self.models.keys())
        }

    def _check_gpu(self):
        """Check if GPU is available"""
        try:
            import torch
            return torch.cuda.is_available()
        except ImportError:
            return False

# Initialize AI Worker
ai_worker = AIWorker()

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "healthy", "service": "ai-worker"})

@app.route('/api/v1/generate', methods=['POST'])
def generate():
    data = request.json
    model_type = data.get('model', 'llama')
    prompt = data.get('prompt', '')
    max_tokens = data.get('max_tokens', 512)
    temperature = data.get('temperature', 0.7)
    
    result = ai_worker.generate_text(model_type, prompt, max_tokens, temperature)
    return jsonify(result)

@app.route('/api/v1/transcribe', methods=['POST'])
def transcribe():
    data = request.json
    audio_file = data.get('audio_file')
    
    if not audio_file:
        return jsonify({"error": "audio_file is required"}), 400
    
    result = ai_worker.transcribe_audio(audio_file)
    return jsonify(result)

@app.route('/api/v1/analyze-image', methods=['POST'])
def analyze_image():
    data = request.json
    image_path = data.get('image_path')
    task = data.get('task', 'describe')
    
    if not image_path:
        return jsonify({"error": "image_path is required"}), 400
    
    result = ai_worker.analyze_image(image_path, task)
    return jsonify(result)

@app.route('/api/v1/models', methods=['GET'])
def models():
    return jsonify(ai_worker.get_model_info())

if __name__ == '__main__':
    port = int(os.getenv('PORT', 8000))
    logger.info(f"Starting AI Worker on port {port}")
    app.run(host='0.0.0.0', port=port, debug=False)


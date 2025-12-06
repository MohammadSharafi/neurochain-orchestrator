package com.neurochain.application.service;

import com.neurochain.domain.model.Node;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

/**
 * Executes individual nodes in a workflow
 */
@Service
public class NodeExecutor {
    private static final Logger logger = LoggerFactory.getLogger(NodeExecutor.class);

    private final RestTemplate restTemplate;
    private final String aiWorkerUrl;

    public NodeExecutor(
            RestTemplate restTemplate,
            @Value("${ai-worker.base-url}") String aiWorkerUrl) {
        this.restTemplate = restTemplate;
        this.aiWorkerUrl = aiWorkerUrl;
    }

    /**
     * Execute a node
     */
    public Map<String, Object> execute(Node node, Map<String, Object> inputs) throws Exception {
        logger.info("Executing node: {} (type: {})", node.getId(), node.getType());

        switch (node.getType().toUpperCase()) {
            case "AI_GENERATE":
                return executeAIGenerate(node, inputs);
            case "AI_TRANSCRIBE":
                return executeAITranscribe(node, inputs);
            case "AI_ANALYZE_IMAGE":
                return executeAIAnalyzeImage(node, inputs);
            case "HTTP_REQUEST":
                return executeHttpRequest(node, inputs);
            case "TRANSFORM":
                return executeTransform(node, inputs);
            default:
                throw new IllegalArgumentException("Unknown node type: " + node.getType());
        }
    }

    private Map<String, Object> executeAIGenerate(Node node, Map<String, Object> inputs) {
        String prompt = (String) inputs.getOrDefault("prompt", node.getParameters().get("prompt"));
        String model = (String) node.getParameters().getOrDefault("model", "llama");
        
        Map<String, Object> request = new HashMap<>();
        request.put("model", model);
        request.put("prompt", prompt);
        request.put("max_tokens", node.getParameters().getOrDefault("max_tokens", 512));
        request.put("temperature", node.getParameters().getOrDefault("temperature", 0.7));

        Map<String, Object> response = restTemplate.postForObject(
                aiWorkerUrl + "/api/v1/generate",
                request,
                Map.class
        );

        return Map.of("text", response.get("text"), "model", model);
    }

    private Map<String, Object> executeAITranscribe(Node node, Map<String, Object> inputs) {
        String audioFile = (String) inputs.getOrDefault("audio_file", node.getParameters().get("audio_file"));
        
        Map<String, Object> request = new HashMap<>();
        request.put("audio_file", audioFile);

        Map<String, Object> response = restTemplate.postForObject(
                aiWorkerUrl + "/api/v1/transcribe",
                request,
                Map.class
        );

        return Map.of("transcript", response.get("transcript"));
    }

    private Map<String, Object> executeAIAnalyzeImage(Node node, Map<String, Object> inputs) {
        String imagePath = (String) inputs.getOrDefault("image_path", node.getParameters().get("image_path"));
        String task = (String) node.getParameters().getOrDefault("task", "describe");
        
        Map<String, Object> request = new HashMap<>();
        request.put("image_path", imagePath);
        request.put("task", task);

        Map<String, Object> response = restTemplate.postForObject(
                aiWorkerUrl + "/api/v1/analyze-image",
                request,
                Map.class
        );

        return response;
    }

    private Map<String, Object> executeHttpRequest(Node node, Map<String, Object> inputs) {
        String url = (String) node.getParameters().get("url");
        String method = (String) node.getParameters().getOrDefault("method", "GET");
        
        // TODO: Implement HTTP request execution
        return Map.of("status", 200, "body", "Mock response");
    }

    private Map<String, Object> executeTransform(Node node, Map<String, Object> inputs) {
        String transformType = (String) node.getParameters().get("transform_type");
        
        // TODO: Implement data transformation
        return inputs;
    }
}


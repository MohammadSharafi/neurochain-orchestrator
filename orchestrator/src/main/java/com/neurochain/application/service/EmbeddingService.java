package com.neurochain.application.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

/**
 * Service for generating embeddings
 */
@Service
public class EmbeddingService {
    private final RestTemplate restTemplate;
    private final String aiWorkerUrl;

    public EmbeddingService(
            RestTemplate restTemplate,
            @Value("${ai-worker.base-url}") String aiWorkerUrl) {
        this.restTemplate = restTemplate;
        this.aiWorkerUrl = aiWorkerUrl;
    }

    /**
     * Generate embedding for text
     */
    public float[] generateEmbedding(String text) {
        // TODO: Call AI worker embedding endpoint
        // For now, return mock embedding (384 dimensions)
        float[] embedding = new float[384];
        for (int i = 0; i < embedding.length; i++) {
            embedding[i] = (float) (Math.random() * 2 - 1);
        }
        return embedding;
    }
}


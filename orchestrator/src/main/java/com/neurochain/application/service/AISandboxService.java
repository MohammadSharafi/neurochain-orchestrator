package com.neurochain.application.service;

import com.neurochain.domain.model.Node;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;

/**
 * AI Sandbox for testing individual nodes
 * Allows users to run nodes in isolation and inspect results
 */
@Service
public class AISandboxService {
    private static final Logger logger = LoggerFactory.getLogger(AISandboxService.class);

    private final NodeExecutor nodeExecutor;
    private final ModelLatencyTracker latencyTracker;

    public AISandboxService(NodeExecutor nodeExecutor, ModelLatencyTracker latencyTracker) {
        this.nodeExecutor = nodeExecutor;
        this.latencyTracker = latencyTracker;
    }

    /**
     * Execute a single node in sandbox mode
     */
    public CompletableFuture<SandboxResult> executeNode(Node node, Map<String, Object> inputs) {
        String executionId = UUID.randomUUID().toString();
        long startTime = System.currentTimeMillis();

        logger.info("Executing node in sandbox: {} (type: {})", node.getId(), node.getType());

        return CompletableFuture.supplyAsync(() -> {
            try {
                // Execute node
                Map<String, Object> outputs = nodeExecutor.execute(node, inputs);
                long executionTime = System.currentTimeMillis() - startTime;

                // Track latency
                latencyTracker.recordLatency(node.getType(), executionTime);

                // Capture reasoning if AI node
                Map<String, Object> reasoning = captureReasoning(node, inputs, outputs);

                return new SandboxResult(
                        executionId,
                        true,
                        inputs,
                        outputs,
                        reasoning,
                        executionTime,
                        null,
                        latencyTracker.getLatencyStats(node.getType())
                );
            } catch (Exception e) {
                long executionTime = System.currentTimeMillis() - startTime;
                logger.error("Sandbox execution failed", e);
                return new SandboxResult(
                        executionId,
                        false,
                        inputs,
                        null,
                        null,
                        executionTime,
                        e.getMessage(),
                        null
                );
            }
        });
    }

    /**
     * Capture AI model reasoning (tokens, model info, etc.)
     */
    private Map<String, Object> captureReasoning(Node node, Map<String, Object> inputs, Map<String, Object> outputs) {
        if (!node.getType().startsWith("AI_")) {
            return null;
        }

        Map<String, Object> reasoning = new HashMap<>();
        reasoning.put("model", node.getParameters().get("model"));
        reasoning.put("inputTokens", estimateTokens(inputs));
        reasoning.put("outputTokens", estimateTokens(outputs));
        reasoning.put("temperature", node.getParameters().get("temperature"));
        reasoning.put("maxTokens", node.getParameters().get("max_tokens"));
        
        return reasoning;
    }

    private int estimateTokens(Map<String, Object> data) {
        // Simple token estimation (1 token ≈ 4 characters)
        String text = data.toString();
        return text.length() / 4;
    }

    public static class SandboxResult {
        private final String executionId;
        private final boolean success;
        private final Map<String, Object> inputs;
        private final Map<String, Object> outputs;
        private final Map<String, Object> reasoning;
        private final long executionTimeMs;
        private final String errorMessage;
        private final LatencyStats latencyStats;

        public SandboxResult(
                String executionId,
                boolean success,
                Map<String, Object> inputs,
                Map<String, Object> outputs,
                Map<String, Object> reasoning,
                long executionTimeMs,
                String errorMessage,
                LatencyStats latencyStats) {
            this.executionId = executionId;
            this.success = success;
            this.inputs = inputs;
            this.outputs = outputs;
            this.reasoning = reasoning;
            this.executionTimeMs = executionTimeMs;
            this.errorMessage = errorMessage;
            this.latencyStats = latencyStats;
        }

        // Getters
        public String getExecutionId() { return executionId; }
        public boolean isSuccess() { return success; }
        public Map<String, Object> getInputs() { return inputs; }
        public Map<String, Object> getOutputs() { return outputs; }
        public Map<String, Object> getReasoning() { return reasoning; }
        public long getExecutionTimeMs() { return executionTimeMs; }
        public String getErrorMessage() { return errorMessage; }
        public LatencyStats getLatencyStats() { return latencyStats; }
    }

    public static class LatencyStats {
        private final double averageMs;
        private final double minMs;
        private final double maxMs;
        private final int sampleCount;

        public LatencyStats(double averageMs, double minMs, double maxMs, int sampleCount) {
            this.averageMs = averageMs;
            this.minMs = minMs;
            this.maxMs = maxMs;
            this.sampleCount = sampleCount;
        }

        public double getAverageMs() { return averageMs; }
        public double getMinMs() { return minMs; }
        public double getMaxMs() { return maxMs; }
        public int getSampleCount() { return sampleCount; }
    }
}


package com.neurochain.application.service;

import com.neurochain.domain.model.Node;
import com.neurochain.domain.model.Connection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Smart Nodes that auto-configure themselves based on connections and context
 */
@Service
public class SmartNodeService {
    private static final Logger logger = LoggerFactory.getLogger(SmartNodeService.class);

    /**
     * Auto-configure a node based on its connections and inputs
     */
    public Node autoConfigureNode(Node node, List<Connection> connections, List<Node> allNodes) {
        logger.info("Auto-configuring node: {}", node.getId());

        // Detect input types from connected nodes
        Map<String, String> inputTypes = detectInputTypes(node, connections, allNodes);

        // Auto-select best model if AI node
        if (node.getType().startsWith("AI_")) {
            autoSelectModel(node, inputTypes);
        }

        // Auto-adjust sampling settings
        autoAdjustSampling(node, inputTypes);

        // Validate and warn about missing data
        validateNodeConfiguration(node, inputTypes);

        return node;
    }

    /**
     * Detect input types from connected nodes
     */
    private Map<String, String> detectInputTypes(Node node, List<Connection> connections, List<Node> allNodes) {
        Map<String, String> inputTypes = new HashMap<>();

        List<Connection> incomingConnections = connections.stream()
                .filter(c -> c.getTargetNodeId().equals(node.getId()))
                .collect(Collectors.toList());

        for (Connection conn : incomingConnections) {
            Node sourceNode = allNodes.stream()
                    .filter(n -> n.getId().equals(conn.getSourceNodeId()))
                    .findFirst()
                    .orElse(null);

            if (sourceNode != null) {
                String outputType = inferOutputType(sourceNode);
                inputTypes.put(conn.getTargetPort(), outputType);
            }
        }

        return inputTypes;
    }

    /**
     * Infer output type from node type
     */
    private String inferOutputType(Node node) {
        switch (node.getType().toUpperCase()) {
            case "AI_GENERATE":
            case "AI_TRANSCRIBE":
                return "TEXT";
            case "AI_ANALYZE_IMAGE":
                return "IMAGE_ANALYSIS";
            case "HTTP_REQUEST":
                return "JSON";
            case "TRANSFORM":
                return "DATA";
            default:
                return "UNKNOWN";
        }
    }

    /**
     * Auto-select best model based on input and requirements
     */
    private void autoSelectModel(Node node, Map<String, String> inputTypes) {
        Map<String, Object> params = node.getParameters();
        
        if (params.containsKey("model") && params.get("model") != null) {
            return; // Model already selected
        }

        String nodeType = node.getType().toUpperCase();
        String defaultModel;

        switch (nodeType) {
            case "AI_GENERATE":
                // Select based on input length
                defaultModel = "llama"; // Default
                break;
            case "AI_TRANSCRIBE":
                defaultModel = "whisper-base";
                break;
            case "AI_ANALYZE_IMAGE":
                defaultModel = "clip";
                break;
            default:
                defaultModel = "llama";
        }

        params.put("model", defaultModel);
        logger.info("Auto-selected model: {} for node {}", defaultModel, node.getId());
    }

    /**
     * Auto-adjust sampling settings based on use case
     */
    private void autoAdjustSampling(Node node, Map<String, String> inputTypes) {
        Map<String, Object> params = node.getParameters();

        // Set default temperature if not specified
        if (!params.containsKey("temperature")) {
            String nodeType = node.getType().toUpperCase();
            double temperature = switch (nodeType) {
                case "AI_GENERATE" -> 0.7; // Creative tasks
                case "AI_TRANSCRIBE" -> 0.0; // Deterministic
                case "AI_ANALYZE_IMAGE" -> 0.0; // Deterministic
                default -> 0.7;
            };
            params.put("temperature", temperature);
        }

        // Set default max_tokens if not specified
        if (!params.containsKey("max_tokens")) {
            params.put("max_tokens", 512);
        }
    }

    /**
     * Validate node configuration and warn about issues
     */
    private void validateNodeConfiguration(Node node, Map<String, String> inputTypes) {
        List<String> warnings = new ArrayList<>();

        // Check for required inputs
        if (node.getType().equals("AI_GENERATE") && !node.getParameters().containsKey("prompt")) {
            warnings.add("Missing required parameter: prompt");
        }

        if (node.getType().equals("AI_TRANSCRIBE") && !node.getParameters().containsKey("audio_file")) {
            warnings.add("Missing required parameter: audio_file");
        }

        // Check input type compatibility
        if (node.getType().equals("AI_ANALYZE_IMAGE")) {
            boolean hasImageInput = inputTypes.values().stream()
                    .anyMatch(type -> type.contains("IMAGE"));
            if (!hasImageInput) {
                warnings.add("No image input detected. Connect an image source node.");
            }
        }

        if (!warnings.isEmpty()) {
            logger.warn("Node {} validation warnings: {}", node.getId(), warnings);
            node.getMetadata().put("warnings", warnings);
        }
    }
}


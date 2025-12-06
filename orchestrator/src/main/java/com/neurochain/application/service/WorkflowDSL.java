package com.neurochain.application.service;

import com.neurochain.domain.model.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * DSL (Domain-Specific Language) for defining workflows
 * Example: ON event("file.created") DO run("ocr") run("summarize") END
 */
@Service
public class WorkflowDSL {
    private static final Logger logger = LoggerFactory.getLogger(WorkflowDSL.class);

    /**
     * Parse DSL and create workflow
     */
    public Workflow parseDSL(String dslScript, String workflowName) {
        logger.info("Parsing DSL workflow: {}", workflowName);

        Workflow workflow = new Workflow();
        workflow.setId(UUID.randomUUID().toString());
        workflow.setName(workflowName);
        workflow.setStatus(Workflow.WorkflowStatus.DRAFT);

        List<Node> nodes = new ArrayList<>();
        List<Connection> connections = new ArrayList<>();
        String currentNodeId = null;

        String[] lines = dslScript.split("\n");
        for (String line : lines) {
            line = line.trim();
            if (line.isEmpty() || line.startsWith("//")) continue;

            // Parse ON event
            if (line.startsWith("ON ")) {
                currentNodeId = parseEventTrigger(line, nodes, workflow);
            }
            // Parse DO actions
            else if (line.startsWith("DO ") || line.startsWith("  ")) {
                String actionLine = line.replace("DO ", "").trim();
                String newNodeId = parseAction(actionLine, nodes, currentNodeId, connections);
                if (currentNodeId != null && newNodeId != null) {
                    currentNodeId = newNodeId;
                }
            }
            // Parse END
            else if (line.equals("END")) {
                // End of workflow
            }
        }

        workflow.setNodes(nodes);
        workflow.setConnections(connections);
        return workflow;
    }

    private String parseEventTrigger(String line, List<Node> nodes, Workflow workflow) {
        Pattern pattern = Pattern.compile("ON event\\(\"([^\"]+)\"\\)");
        Matcher matcher = pattern.matcher(line);
        
        if (matcher.find()) {
            String eventType = matcher.group(1);
            String nodeId = UUID.randomUUID().toString();
            
            Node triggerNode = new Node();
            triggerNode.setId(nodeId);
            triggerNode.setName("Trigger: " + eventType);
            triggerNode.setType("TRIGGER_" + eventType.toUpperCase());
            
            Map<String, Object> params = new HashMap<>();
            params.put("event_type", eventType);
            triggerNode.setParameters(params);
            
            nodes.add(triggerNode);
            
            // Set workflow trigger
            workflow.setTriggerType(Workflow.TriggerType.EVENT);
            workflow.setTriggerConfig("{\"event\":\"" + eventType + "\"}");
            
            return nodeId;
        }
        return null;
    }

    private String parseAction(String line, List<Node> nodes, String previousNodeId, List<Connection> connections) {
        // Parse: run("action_name", params)
        Pattern pattern = Pattern.compile("run\\(\"([^\"]+)\"(?:,\\s*(.+))?\\)");
        Matcher matcher = pattern.matcher(line);
        
        if (matcher.find()) {
            String actionName = matcher.group(1);
            String nodeId = UUID.randomUUID().toString();
            
            Node actionNode = new Node();
            actionNode.setId(nodeId);
            actionNode.setName(actionName);
            actionNode.setType(inferNodeType(actionName));
            
            Map<String, Object> params = parseParams(matcher.group(2));
            actionNode.setParameters(params);
            
            nodes.add(actionNode);
            
            // Connect to previous node
            if (previousNodeId != null) {
                Connection conn = new Connection();
                conn.setId(UUID.randomUUID().toString());
                conn.setSourceNodeId(previousNodeId);
                conn.setSourcePort("output");
                conn.setTargetNodeId(nodeId);
                conn.setTargetPort("input");
                connections.add(conn);
            }
            
            return nodeId;
        }
        return null;
    }

    private String inferNodeType(String actionName) {
        String lower = actionName.toLowerCase();
        if (lower.contains("ocr") || lower.contains("extract")) {
            return "AI_ANALYZE_IMAGE";
        }
        if (lower.contains("summarize") || lower.contains("generate")) {
            return "AI_GENERATE";
        }
        if (lower.contains("transcribe")) {
            return "AI_TRANSCRIBE";
        }
        return "TRANSFORM";
    }

    private Map<String, Object> parseParams(String paramsString) {
        Map<String, Object> params = new HashMap<>();
        if (paramsString == null || paramsString.trim().isEmpty()) {
            return params;
        }
        // Simple parameter parsing (can be enhanced)
        // Format: key1="value1", key2="value2"
        Pattern paramPattern = Pattern.compile("(\\w+)=\"([^\"]+)\"");
        Matcher matcher = paramPattern.matcher(paramsString);
        while (matcher.find()) {
            params.put(matcher.group(1), matcher.group(2));
        }
        return params;
    }
}


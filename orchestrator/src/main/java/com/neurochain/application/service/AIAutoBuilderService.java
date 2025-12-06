package com.neurochain.application.service;

import com.neurochain.domain.model.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;

/**
 * AI Auto-Build Workflows
 * Generates workflow graphs from natural language descriptions
 */
@Service
public class AIAutoBuilderService {
    private static final Logger logger = LoggerFactory.getLogger(AIAutoBuilderService.class);

    private final RestTemplate restTemplate;
    private final String aiWorkerUrl;

    public AIAutoBuilderService(
            RestTemplate restTemplate,
            @Value("${ai-worker.base-url}") String aiWorkerUrl) {
        this.restTemplate = restTemplate;
        this.aiWorkerUrl = aiWorkerUrl;
    }

    /**
     * Generate workflow from natural language description
     */
    public Workflow generateWorkflow(String description, String workflowName) {
        logger.info("Generating workflow from description: {}", description);

        // Parse description and extract requirements
        WorkflowRequirements requirements = parseRequirements(description);

        // Generate workflow structure
        Workflow workflow = new Workflow();
        workflow.setId(UUID.randomUUID().toString());
        workflow.setName(workflowName);
        workflow.setDescription(description);
        workflow.setStatus(Workflow.WorkflowStatus.DRAFT);

        // Build nodes and connections
        List<Node> nodes = new ArrayList<>();
        List<Connection> connections = new ArrayList<>();
        String previousNodeId = null;

        // Add trigger node
        if (requirements.hasFileWatcher()) {
            Node trigger = createFileWatcherNode(requirements.getWatchPath());
            nodes.add(trigger);
            previousNodeId = trigger.getId();
        }

        // Add processing nodes
        for (String action : requirements.getActions()) {
            Node node = createNodeForAction(action, requirements);
            nodes.add(node);
            
            if (previousNodeId != null) {
                Connection conn = new Connection();
                conn.setId(UUID.randomUUID().toString());
                conn.setSourceNodeId(previousNodeId);
                conn.setSourcePort("output");
                conn.setTargetNodeId(node.getId());
                conn.setTargetPort("input");
                connections.add(conn);
            }
            
            previousNodeId = node.getId();
        }

        workflow.setNodes(nodes);
        workflow.setConnections(connections);
        workflow.setTriggerType(requirements.getTriggerType());

        return workflow;
    }

    private WorkflowRequirements parseRequirements(String description) {
        WorkflowRequirements req = new WorkflowRequirements();
        String lower = description.toLowerCase();

        // Detect trigger
        if (lower.contains("monitor") || lower.contains("watch") || lower.contains("folder")) {
            req.setTriggerType(Workflow.TriggerType.FILE_WATCHER);
            // Extract path
            if (lower.contains("folder")) {
                req.setWatchPath("./watched");
            }
        } else {
            req.setTriggerType(Workflow.TriggerType.MANUAL);
        }

        // Detect actions
        List<String> actions = new ArrayList<>();
        if (lower.contains("extract text") || lower.contains("ocr")) {
            actions.add("ocr");
        }
        if (lower.contains("summarize")) {
            actions.add("summarize");
        }
        if (lower.contains("notify") || lower.contains("send")) {
            actions.add("notify");
        }
        if (lower.contains("save") || lower.contains("store")) {
            actions.add("save");
        }

        req.setActions(actions);
        return req;
    }

    private Node createFileWatcherNode(String path) {
        Node node = new Node();
        node.setId(UUID.randomUUID().toString());
        node.setName("File Watcher");
        node.setType("TRIGGER_FILE_WATCHER");
        
        Map<String, Object> params = new HashMap<>();
        params.put("directory", path);
        node.setParameters(params);
        
        return node;
    }

    private Node createNodeForAction(String action, WorkflowRequirements requirements) {
        Node node = new Node();
        node.setId(UUID.randomUUID().toString());

        switch (action.toLowerCase()) {
            case "ocr":
                node.setName("Extract Text");
                node.setType("AI_ANALYZE_IMAGE");
                node.setParameters(Map.of("task", "ocr"));
                break;
            case "summarize":
                node.setName("Summarize");
                node.setType("AI_GENERATE");
                node.setParameters(Map.of(
                        "model", "llama",
                        "prompt", "Summarize the following text: {{input}}",
                        "max_tokens", 200
                ));
                break;
            case "notify":
                node.setName("Send Notification");
                node.setType("NOTIFICATION");
                node.setParameters(Map.of("type", "success"));
                break;
            case "save":
                node.setName("Save File");
                node.setType("FILE_WRITE");
                node.setParameters(Map.of("path", "./output/{{timestamp}}.txt"));
                break;
            default:
                node.setName(action);
                node.setType("TRANSFORM");
        }

        return node;
    }

    private static class WorkflowRequirements {
        private Workflow.TriggerType triggerType = Workflow.TriggerType.MANUAL;
        private String watchPath;
        private List<String> actions = new ArrayList<>();

        public Workflow.TriggerType getTriggerType() { return triggerType; }
        public void setTriggerType(Workflow.TriggerType triggerType) { this.triggerType = triggerType; }
        public String getWatchPath() { return watchPath; }
        public void setWatchPath(String watchPath) { this.watchPath = watchPath; }
        public List<String> getActions() { return actions; }
        public void setActions(List<String> actions) { this.actions = actions; }
        public boolean hasFileWatcher() { return triggerType == Workflow.TriggerType.FILE_WATCHER; }
    }
}


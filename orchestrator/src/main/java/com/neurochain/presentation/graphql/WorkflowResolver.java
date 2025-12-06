package com.neurochain.presentation.graphql;

import com.neurochain.application.service.WorkflowEngine;
import com.neurochain.application.service.WorkflowService;
import com.neurochain.domain.model.Workflow;
import com.neurochain.domain.model.WorkflowExecution;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.stereotype.Controller;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

@Controller
public class WorkflowResolver {
    private final WorkflowService workflowService;
    private final WorkflowEngine workflowEngine;

    public WorkflowResolver(WorkflowService workflowService, WorkflowEngine workflowEngine) {
        this.workflowService = workflowService;
        this.workflowEngine = workflowEngine;
    }

    @QueryMapping
    public List<Workflow> workflows() {
        return workflowService.findAll();
    }

    @QueryMapping
    public Workflow workflow(@Argument String id) {
        return workflowService.findById(id)
                .orElseThrow(() -> new RuntimeException("Workflow not found"));
    }

    @MutationMapping
    public Workflow createWorkflow(@Argument WorkflowInput input) {
        return workflowService.createWorkflow(input);
    }

    @MutationMapping
    public Workflow updateWorkflow(@Argument String id, @Argument WorkflowInput input) {
        return workflowService.updateWorkflow(id, input);
    }

    @MutationMapping
    public Boolean deleteWorkflow(@Argument String id) {
        workflowService.deleteWorkflow(id);
        return true;
    }

    @MutationMapping
    public WorkflowExecution executeWorkflow(
            @Argument String id,
            @Argument Map<String, Object> inputs) {
        
        Workflow workflow = workflowService.findById(id)
                .orElseThrow(() -> new RuntimeException("Workflow not found"));
        
        CompletableFuture<WorkflowExecution> future = workflowEngine.execute(
                workflow,
                inputs != null ? inputs : Map.of()
        );
        
        // For now, return immediately (in production, would use subscriptions)
        try {
            return future.get();
        } catch (Exception e) {
            throw new RuntimeException("Error executing workflow", e);
        }
    }

    @MutationMapping
    public Workflow pauseWorkflow(@Argument String id) {
        return workflowService.pauseWorkflow(id);
    }

    @MutationMapping
    public Workflow resumeWorkflow(@Argument String id) {
        return workflowService.resumeWorkflow(id);
    }

    public static class WorkflowInput {
        private String name;
        private String description;
        private List<NodeInput> nodes;
        private List<ConnectionInput> connections;
        private String triggerType;
        private String triggerConfig;

        // Getters and setters
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }
        public List<NodeInput> getNodes() { return nodes; }
        public void setNodes(List<NodeInput> nodes) { this.nodes = nodes; }
        public List<ConnectionInput> getConnections() { return connections; }
        public void setConnections(List<ConnectionInput> connections) { this.connections = connections; }
        public String getTriggerType() { return triggerType; }
        public void setTriggerType(String triggerType) { this.triggerType = triggerType; }
        public String getTriggerConfig() { return triggerConfig; }
        public void setTriggerConfig(String triggerConfig) { this.triggerConfig = triggerConfig; }
    }

    public static class NodeInput {
        private String id;
        private String type;
        private String pluginId;
        private String name;
        private Map<String, Object> parameters;
        private NodePositionInput position;

        // Getters and setters
        public String getId() { return id; }
        public void setId(String id) { this.id = id; }
        public String getType() { return type; }
        public void setType(String type) { this.type = type; }
        public String getPluginId() { return pluginId; }
        public void setPluginId(String pluginId) { this.pluginId = pluginId; }
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public Map<String, Object> getParameters() { return parameters; }
        public void setParameters(Map<String, Object> parameters) { this.parameters = parameters; }
        public NodePositionInput getPosition() { return position; }
        public void setPosition(NodePositionInput position) { this.position = position; }
    }

    public static class NodePositionInput {
        private double x;
        private double y;

        public double getX() { return x; }
        public void setX(double x) { this.x = x; }
        public double getY() { return y; }
        public void setY(double y) { this.y = y; }
    }

    public static class ConnectionInput {
        private String id;
        private String sourceNodeId;
        private String sourcePort;
        private String targetNodeId;
        private String targetPort;

        // Getters and setters
        public String getId() { return id; }
        public void setId(String id) { this.id = id; }
        public String getSourceNodeId() { return sourceNodeId; }
        public void setSourceNodeId(String sourceNodeId) { this.sourceNodeId = sourceNodeId; }
        public String getSourcePort() { return sourcePort; }
        public void setSourcePort(String sourcePort) { this.sourcePort = sourcePort; }
        public String getTargetNodeId() { return targetNodeId; }
        public void setTargetNodeId(String targetNodeId) { this.targetNodeId = targetNodeId; }
        public String getTargetPort() { return targetPort; }
        public void setTargetPort(String targetPort) { this.targetPort = targetPort; }
    }
}


package com.neurochain.domain.model;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * Domain model representing a workflow
 */
public class Workflow {
    private String id;
    private String name;
    private String description;
    private List<Node> nodes;
    private List<Connection> connections;
    private WorkflowStatus status;
    private TriggerType triggerType;
    private String triggerConfig; // JSON for trigger configuration
    private Map<String, Object> metadata;
    private String createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Workflow() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public List<Node> getNodes() { return nodes; }
    public void setNodes(List<Node> nodes) { this.nodes = nodes; }

    public List<Connection> getConnections() { return connections; }
    public void setConnections(List<Connection> connections) { this.connections = connections; }

    public WorkflowStatus getStatus() { return status; }
    public void setStatus(WorkflowStatus status) { this.status = status; }

    public TriggerType getTriggerType() { return triggerType; }
    public void setTriggerType(TriggerType triggerType) { this.triggerType = triggerType; }

    public String getTriggerConfig() { return triggerConfig; }
    public void setTriggerConfig(String triggerConfig) { this.triggerConfig = triggerConfig; }

    public Map<String, Object> getMetadata() { return metadata; }
    public void setMetadata(Map<String, Object> metadata) { this.metadata = metadata; }

    public String getCreatedBy() { return createdBy; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public enum WorkflowStatus {
        DRAFT,
        ACTIVE,
        PAUSED,
        COMPLETED,
        FAILED
    }

    public enum TriggerType {
        MANUAL,
        SCHEDULE,
        FILE_WATCHER,
        HTTP_WEBHOOK,
        EVENT
    }
}


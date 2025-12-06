package com.neurochain.infrastructure.persistence.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.Map;

@Entity
@Table(name = "sandbox_executions")
public class SandboxExecutionEntity {
    @Id
    private String executionId;
    
    private String nodeId;
    private String nodeType;
    private boolean success;
    
    @Column(columnDefinition = "TEXT")
    private String inputsJson;
    
    @Column(columnDefinition = "TEXT")
    private String outputsJson;
    
    @Column(columnDefinition = "TEXT")
    private String reasoningJson;
    
    private long executionTimeMs;
    private String errorMessage;
    
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    // Getters and setters
    public String getExecutionId() { return executionId; }
    public void setExecutionId(String executionId) { this.executionId = executionId; }
    public String getNodeId() { return nodeId; }
    public void setNodeId(String nodeId) { this.nodeId = nodeId; }
    public String getNodeType() { return nodeType; }
    public void setNodeType(String nodeType) { this.nodeType = nodeType; }
    public boolean isSuccess() { return success; }
    public void setSuccess(boolean success) { this.success = success; }
    public String getInputsJson() { return inputsJson; }
    public void setInputsJson(String inputsJson) { this.inputsJson = inputsJson; }
    public String getOutputsJson() { return outputsJson; }
    public void setOutputsJson(String outputsJson) { this.outputsJson = outputsJson; }
    public String getReasoningJson() { return reasoningJson; }
    public void setReasoningJson(String reasoningJson) { this.reasoningJson = reasoningJson; }
    public long getExecutionTimeMs() { return executionTimeMs; }
    public void setExecutionTimeMs(long executionTimeMs) { this.executionTimeMs = executionTimeMs; }
    public String getErrorMessage() { return errorMessage; }
    public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}


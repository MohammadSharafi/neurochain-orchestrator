package com.neurochain.domain.model;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * Represents a workflow execution instance
 */
public class WorkflowExecution {
    private String id;
    private String workflowId;
    private ExecutionStatus status;
    private LocalDateTime startedAt;
    private LocalDateTime completedAt;
    private Map<String, NodeExecution> nodeExecutions;
    private Map<String, Object> inputs;
    private Map<String, Object> outputs;
    private String errorMessage;
    private ExecutionMetrics metrics;

    public WorkflowExecution() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getWorkflowId() { return workflowId; }
    public void setWorkflowId(String workflowId) { this.workflowId = workflowId; }

    public ExecutionStatus getStatus() { return status; }
    public void setStatus(ExecutionStatus status) { this.status = status; }

    public LocalDateTime getStartedAt() { return startedAt; }
    public void setStartedAt(LocalDateTime startedAt) { this.startedAt = startedAt; }

    public LocalDateTime getCompletedAt() { return completedAt; }
    public void setCompletedAt(LocalDateTime completedAt) { this.completedAt = completedAt; }

    public Map<String, NodeExecution> getNodeExecutions() { return nodeExecutions; }
    public void setNodeExecutions(Map<String, NodeExecution> nodeExecutions) { this.nodeExecutions = nodeExecutions; }

    public Map<String, Object> getInputs() { return inputs; }
    public void setInputs(Map<String, Object> inputs) { this.inputs = inputs; }

    public Map<String, Object> getOutputs() { return outputs; }
    public void setOutputs(Map<String, Object> outputs) { this.outputs = outputs; }

    public String getErrorMessage() { return errorMessage; }
    public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }

    public ExecutionMetrics getMetrics() { return metrics; }
    public void setMetrics(ExecutionMetrics metrics) { this.metrics = metrics; }

    public enum ExecutionStatus {
        PENDING,
        RUNNING,
        COMPLETED,
        FAILED,
        CANCELLED
    }

    public static class NodeExecution {
        private String nodeId;
        private ExecutionStatus status;
        private LocalDateTime startedAt;
        private LocalDateTime completedAt;
        private Map<String, Object> inputs;
        private Map<String, Object> outputs;
        private String errorMessage;
        private long executionTimeMs;

        // Getters and setters
        public String getNodeId() { return nodeId; }
        public void setNodeId(String nodeId) { this.nodeId = nodeId; }
        public ExecutionStatus getStatus() { return status; }
        public void setStatus(ExecutionStatus status) { this.status = status; }
        public LocalDateTime getStartedAt() { return startedAt; }
        public void setStartedAt(LocalDateTime startedAt) { this.startedAt = startedAt; }
        public LocalDateTime getCompletedAt() { return completedAt; }
        public void setCompletedAt(LocalDateTime completedAt) { this.completedAt = completedAt; }
        public Map<String, Object> getInputs() { return inputs; }
        public void setInputs(Map<String, Object> inputs) { this.inputs = inputs; }
        public Map<String, Object> getOutputs() { return outputs; }
        public void setOutputs(Map<String, Object> outputs) { this.outputs = outputs; }
        public String getErrorMessage() { return errorMessage; }
        public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }
        public long getExecutionTimeMs() { return executionTimeMs; }
        public void setExecutionTimeMs(long executionTimeMs) { this.executionTimeMs = executionTimeMs; }
    }

    public static class ExecutionMetrics {
        private long totalExecutionTimeMs;
        private int nodesExecuted;
        private int nodesFailed;
        private long aiInferenceTimeMs;
        private long dataProcessingTimeMs;

        // Getters and setters
        public long getTotalExecutionTimeMs() { return totalExecutionTimeMs; }
        public void setTotalExecutionTimeMs(long totalExecutionTimeMs) { this.totalExecutionTimeMs = totalExecutionTimeMs; }
        public int getNodesExecuted() { return nodesExecuted; }
        public void setNodesExecuted(int nodesExecuted) { this.nodesExecuted = nodesExecuted; }
        public int getNodesFailed() { return nodesFailed; }
        public void setNodesFailed(int nodesFailed) { this.nodesFailed = nodesFailed; }
        public long getAiInferenceTimeMs() { return aiInferenceTimeMs; }
        public void setAiInferenceTimeMs(long aiInferenceTimeMs) { this.aiInferenceTimeMs = aiInferenceTimeMs; }
        public long getDataProcessingTimeMs() { return dataProcessingTimeMs; }
        public void setDataProcessingTimeMs(long dataProcessingTimeMs) { this.dataProcessingTimeMs = dataProcessingTimeMs; }
    }
}


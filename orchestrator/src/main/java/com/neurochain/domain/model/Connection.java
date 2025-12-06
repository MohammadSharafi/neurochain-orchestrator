package com.neurochain.domain.model;

/**
 * Represents a connection between nodes in a workflow
 */
public class Connection {
    private String id;
    private String sourceNodeId;
    private String sourcePort;
    private String targetNodeId;
    private String targetPort;

    public Connection() {}

    public Connection(String sourceNodeId, String sourcePort, String targetNodeId, String targetPort) {
        this.sourceNodeId = sourceNodeId;
        this.sourcePort = sourcePort;
        this.targetNodeId = targetNodeId;
        this.targetPort = targetPort;
    }

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


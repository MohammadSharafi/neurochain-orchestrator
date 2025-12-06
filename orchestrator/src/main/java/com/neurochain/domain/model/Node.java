package com.neurochain.domain.model;

import java.util.Map;

/**
 * Represents a node in a workflow graph
 */
public class Node {
    private String id;
    private String type; // AI_GENERATE, AI_TRANSCRIBE, HTTP_REQUEST, TRANSFORM, etc.
    private String pluginId;
    private String name;
    private Map<String, Object> parameters;
    private NodePosition position;
    private Map<String, Object> metadata;

    public Node() {}

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

    public NodePosition getPosition() { return position; }
    public void setPosition(NodePosition position) { this.position = position; }

    public Map<String, Object> getMetadata() { return metadata; }
    public void setMetadata(Map<String, Object> metadata) { this.metadata = metadata; }

    public static class NodePosition {
        private double x;
        private double y;

        public NodePosition() {}

        public NodePosition(double x, double y) {
            this.x = x;
            this.y = y;
        }

        public double getX() { return x; }
        public void setX(double x) { this.x = x; }

        public double getY() { return y; }
        public void setY(double y) { this.y = y; }
    }
}


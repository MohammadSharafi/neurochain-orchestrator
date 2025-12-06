package com.neurochain.application.service;

import com.neurochain.domain.model.WorkflowExecution;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Time-Travel Debugger for workflow execution
 * Provides timeline, snapshots, and execution history
 */
@Service
public class TimeTravelDebugger {
    private static final Logger logger = LoggerFactory.getLogger(TimeTravelDebugger.class);

    private final Map<String, ExecutionTimeline> timelines = new ConcurrentHashMap<>();
    private final Map<String, List<MemorySnapshot>> snapshots = new ConcurrentHashMap<>();

    /**
     * Record execution event
     */
    public void recordEvent(String executionId, String nodeId, EventType type, Map<String, Object> data) {
        ExecutionEvent event = new ExecutionEvent(
                UUID.randomUUID().toString(),
                nodeId,
                type,
                LocalDateTime.now(),
                data
        );

        timelines.computeIfAbsent(executionId, k -> new ExecutionTimeline(executionId))
                .addEvent(event);

        logger.debug("Recorded event: {} for node {} in execution {}", type, nodeId, executionId);
    }

    /**
     * Create memory snapshot
     */
    public void createSnapshot(String executionId, String nodeId, Map<String, Object> state) {
        MemorySnapshot snapshot = new MemorySnapshot(
                UUID.randomUUID().toString(),
                nodeId,
                LocalDateTime.now(),
                new HashMap<>(state)
        );

        snapshots.computeIfAbsent(executionId, k -> new ArrayList<>())
                .add(snapshot);
    }

    /**
     * Get execution timeline
     */
    public ExecutionTimeline getTimeline(String executionId) {
        return timelines.get(executionId);
    }

    /**
     * Get snapshots for execution
     */
    public List<MemorySnapshot> getSnapshots(String executionId) {
        return snapshots.getOrDefault(executionId, Collections.emptyList());
    }

    /**
     * Get input/output history for a node
     */
    public List<IOHistory> getIOHistory(String executionId, String nodeId) {
        ExecutionTimeline timeline = timelines.get(executionId);
        if (timeline == null) {
            return Collections.emptyList();
        }

        return timeline.getEvents().stream()
                .filter(e -> e.getNodeId().equals(nodeId))
                .filter(e -> e.getType() == EventType.NODE_STARTED || e.getType() == EventType.NODE_COMPLETED)
                .map(e -> new IOHistory(
                        e.getTimestamp(),
                        (Map<String, Object>) e.getData().get("inputs"),
                        (Map<String, Object>) e.getData().get("outputs")
                ))
                .toList();
    }

    public enum EventType {
        WORKFLOW_STARTED,
        WORKFLOW_COMPLETED,
        NODE_STARTED,
        NODE_COMPLETED,
        NODE_FAILED,
        DATA_FLOW
    }

    public static class ExecutionTimeline {
        private final String executionId;
        private final List<ExecutionEvent> events;

        public ExecutionTimeline(String executionId) {
            this.executionId = executionId;
            this.events = new ArrayList<>();
        }

        public void addEvent(ExecutionEvent event) {
            events.add(event);
        }

        public String getExecutionId() { return executionId; }
        public List<ExecutionEvent> getEvents() { return events; }
    }

    public static class ExecutionEvent {
        private final String id;
        private final String nodeId;
        private final EventType type;
        private final LocalDateTime timestamp;
        private final Map<String, Object> data;

        public ExecutionEvent(String id, String nodeId, EventType type, LocalDateTime timestamp, Map<String, Object> data) {
            this.id = id;
            this.nodeId = nodeId;
            this.type = type;
            this.timestamp = timestamp;
            this.data = data;
        }

        public String getId() { return id; }
        public String getNodeId() { return nodeId; }
        public EventType getType() { return type; }
        public LocalDateTime getTimestamp() { return timestamp; }
        public Map<String, Object> getData() { return data; }
    }

    public static class MemorySnapshot {
        private final String id;
        private final String nodeId;
        private final LocalDateTime timestamp;
        private final Map<String, Object> state;

        public MemorySnapshot(String id, String nodeId, LocalDateTime timestamp, Map<String, Object> state) {
            this.id = id;
            this.nodeId = nodeId;
            this.timestamp = timestamp;
            this.state = state;
        }

        public String getId() { return id; }
        public String getNodeId() { return nodeId; }
        public LocalDateTime getTimestamp() { return timestamp; }
        public Map<String, Object> getState() { return state; }
    }

    public static class IOHistory {
        private final LocalDateTime timestamp;
        private final Map<String, Object> inputs;
        private final Map<String, Object> outputs;

        public IOHistory(LocalDateTime timestamp, Map<String, Object> inputs, Map<String, Object> outputs) {
            this.timestamp = timestamp;
            this.inputs = inputs;
            this.outputs = outputs;
        }

        public LocalDateTime getTimestamp() { return timestamp; }
        public Map<String, Object> getInputs() { return inputs; }
        public Map<String, Object> getOutputs() { return outputs; }
    }
}


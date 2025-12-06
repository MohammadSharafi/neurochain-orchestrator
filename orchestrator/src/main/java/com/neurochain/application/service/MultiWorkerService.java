package com.neurochain.application.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Manages multiple AI workers for distributed inference
 */
@Service
public class MultiWorkerService {
    private static final Logger logger = LoggerFactory.getLogger(MultiWorkerService.class);

    private final Map<String, WorkerInfo> workers = new ConcurrentHashMap<>();
    private final WorkerSelector workerSelector;

    public MultiWorkerService(@Value("${ai-worker.base-url}") String defaultWorkerUrl) {
        this.workerSelector = new WorkerSelector();
        // Register default worker
        registerWorker("default", defaultWorkerUrl, WorkerType.GENERAL);
    }

    /**
     * Register a new AI worker
     */
    public void registerWorker(String workerId, String baseUrl, WorkerType type) {
        WorkerInfo worker = new WorkerInfo(workerId, baseUrl, type, WorkerStatus.ONLINE);
        workers.put(workerId, worker);
        logger.info("Registered AI worker: {} ({}) at {}", workerId, type, baseUrl);
    }

    /**
     * Select best worker for a task
     */
    public WorkerInfo selectWorker(String taskType) {
        return workerSelector.selectBestWorker(taskType, workers.values());
    }

    /**
     * Get all registered workers
     */
    public List<WorkerInfo> getAllWorkers() {
        return new ArrayList<>(workers.values());
    }

    /**
     * Remove a worker
     */
    public void removeWorker(String workerId) {
        workers.remove(workerId);
        logger.info("Removed AI worker: {}", workerId);
    }

    public enum WorkerType {
        LLM,        // Text generation
        VISION,     // Image analysis
        AUDIO,      // Speech processing
        GENERAL     // All-purpose
    }

    public enum WorkerStatus {
        ONLINE,
        OFFLINE,
        BUSY
    }

    public static class WorkerInfo {
        private final String id;
        private final String baseUrl;
        private final WorkerType type;
        private WorkerStatus status;
        private final long registeredAt;

        public WorkerInfo(String id, String baseUrl, WorkerType type, WorkerStatus status) {
            this.id = id;
            this.baseUrl = baseUrl;
            this.type = type;
            this.status = status;
            this.registeredAt = System.currentTimeMillis();
        }

        public String getId() { return id; }
        public String getBaseUrl() { return baseUrl; }
        public WorkerType getType() { return type; }
        public WorkerStatus getStatus() { return status; }
        public void setStatus(WorkerStatus status) { this.status = status; }
        public long getRegisteredAt() { return registeredAt; }
    }

    private static class WorkerSelector {
        public WorkerInfo selectBestWorker(String taskType, Collection<WorkerInfo> workers) {
            // Prefer specialized workers
            for (WorkerInfo worker : workers) {
                if (worker.getStatus() != WorkerStatus.ONLINE) continue;

                if (taskType.contains("GENERATE") && worker.getType() == WorkerType.LLM) {
                    return worker;
                }
                if (taskType.contains("IMAGE") && worker.getType() == WorkerType.VISION) {
                    return worker;
                }
                if (taskType.contains("TRANSCRIBE") && worker.getType() == WorkerType.AUDIO) {
                    return worker;
                }
            }

            // Fallback to general worker
            return workers.stream()
                    .filter(w -> w.getType() == WorkerType.GENERAL && w.getStatus() == WorkerStatus.ONLINE)
                    .findFirst()
                    .orElse(workers.stream()
                            .filter(w -> w.getStatus() == WorkerStatus.ONLINE)
                            .findFirst()
                            .orElse(null));
        }
    }
}


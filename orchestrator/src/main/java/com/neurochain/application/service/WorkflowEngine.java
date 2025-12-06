package com.neurochain.application.service;

import com.neurochain.domain.model.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

/**
 * Workflow execution engine - interprets and executes graph-based workflows
 */
@Service
public class WorkflowEngine {
    private static final Logger logger = LoggerFactory.getLogger(WorkflowEngine.class);

    private final NodeExecutor nodeExecutor;
    private final EventBus eventBus;

    public WorkflowEngine(NodeExecutor nodeExecutor, EventBus eventBus) {
        this.nodeExecutor = nodeExecutor;
        this.eventBus = eventBus;
    }

    /**
     * Execute a workflow
     */
    public CompletableFuture<WorkflowExecution> execute(Workflow workflow, Map<String, Object> inputs) {
        WorkflowExecution execution = new WorkflowExecution();
        execution.setId(UUID.randomUUID().toString());
        execution.setWorkflowId(workflow.getId());
        execution.setStatus(WorkflowExecution.ExecutionStatus.RUNNING);
        execution.setStartedAt(LocalDateTime.now());
        execution.setInputs(inputs);
        execution.setNodeExecutions(new HashMap<>());

        return executeWorkflow(workflow, execution);
    }

    private CompletableFuture<WorkflowExecution> executeWorkflow(Workflow workflow, WorkflowExecution execution) {
        // Build dependency graph
        Map<String, List<String>> dependencies = buildDependencyGraph(workflow);
        Map<String, Node> nodeMap = workflow.getNodes().stream()
                .collect(Collectors.toMap(Node::getId, n -> n));

        Set<String> completedNodes = ConcurrentHashMap.newKeySet();
        Set<String> failedNodes = ConcurrentHashMap.newKeySet();
        Map<String, Object> nodeOutputs = new ConcurrentHashMap<>();

        // Find root nodes (nodes with no dependencies)
        List<String> rootNodes = findRootNodes(workflow, dependencies);

        return executeNodesRecursively(
                rootNodes,
                nodeMap,
                dependencies,
                completedNodes,
                failedNodes,
                nodeOutputs,
                execution
        ).thenApply(v -> {
            execution.setStatus(
                    failedNodes.isEmpty() 
                        ? WorkflowExecution.ExecutionStatus.COMPLETED
                        : WorkflowExecution.ExecutionStatus.FAILED
            );
            execution.setCompletedAt(LocalDateTime.now());
            execution.setOutputs(nodeOutputs);
            return execution;
        });
    }

    private CompletableFuture<Void> executeNodesRecursively(
            List<String> nodeIds,
            Map<String, Node> nodeMap,
            Map<String, List<String>> dependencies,
            Set<String> completedNodes,
            Set<String> failedNodes,
            Map<String, Object> nodeOutputs,
            WorkflowExecution execution) {

        if (nodeIds.isEmpty()) {
            return CompletableFuture.completedFuture(null);
        }

        // Execute nodes in parallel
        List<CompletableFuture<Void>> futures = nodeIds.stream()
                .map(nodeId -> executeNode(
                        nodeId,
                        nodeMap.get(nodeId),
                        nodeOutputs,
                        execution
                ).thenApply(result -> {
                    if (result) {
                        completedNodes.add(nodeId);
                    } else {
                        failedNodes.add(nodeId);
                    }
                    return null;
                }))
                .collect(Collectors.toList());

        return CompletableFuture.allOf(futures.toArray(new CompletableFuture[0]))
                .thenCompose(v -> {
                    // Find next level of nodes
                    List<String> nextNodes = findNextNodes(
                            completedNodes,
                            dependencies,
                            nodeMap.keySet()
                    );
                    return executeNodesRecursively(
                            nextNodes,
                            nodeMap,
                            dependencies,
                            completedNodes,
                            failedNodes,
                            nodeOutputs,
                            execution
                    );
                });
    }

    private CompletableFuture<Boolean> executeNode(
            String nodeId,
            Node node,
            Map<String, Object> nodeOutputs,
            WorkflowExecution execution) {

        return CompletableFuture.supplyAsync(() -> {
            WorkflowExecution.NodeExecution nodeExec = new WorkflowExecution.NodeExecution();
            nodeExec.setNodeId(nodeId);
            nodeExec.setStatus(WorkflowExecution.ExecutionStatus.RUNNING);
            nodeExec.setStartedAt(LocalDateTime.now());

            try {
                // Build inputs from previous node outputs
                Map<String, Object> inputs = buildNodeInputs(node, nodeOutputs);
                nodeExec.setInputs(inputs);

                // Execute node
                Map<String, Object> output = nodeExecutor.execute(node, inputs);
                nodeOutputs.put(nodeId, output);

                nodeExec.setOutputs(output);
                nodeExec.setStatus(WorkflowExecution.ExecutionStatus.COMPLETED);
                nodeExec.setCompletedAt(LocalDateTime.now());

                // Publish event
                eventBus.publish("node.completed", Map.of("nodeId", nodeId, "output", output));

                return true;
            } catch (Exception e) {
                logger.error("Error executing node {}", nodeId, e);
                nodeExec.setStatus(WorkflowExecution.ExecutionStatus.FAILED);
                nodeExec.setErrorMessage(e.getMessage());
                nodeExec.setCompletedAt(LocalDateTime.now());
                return false;
            } finally {
                execution.getNodeExecutions().put(nodeId, nodeExec);
            }
        });
    }

    private Map<String, Object> buildNodeInputs(Node node, Map<String, Object> nodeOutputs) {
        // TODO: Build inputs based on connections
        return new HashMap<>();
    }

    private Map<String, List<String>> buildDependencyGraph(Workflow workflow) {
        Map<String, List<String>> dependencies = new HashMap<>();
        
        for (Connection conn : workflow.getConnections()) {
            dependencies.computeIfAbsent(conn.getTargetNodeId(), k -> new ArrayList<>())
                    .add(conn.getSourceNodeId());
        }
        
        return dependencies;
    }

    private List<String> findRootNodes(Workflow workflow, Map<String, List<String>> dependencies) {
        Set<String> allNodes = workflow.getNodes().stream()
                .map(Node::getId)
                .collect(Collectors.toSet());
        
        return allNodes.stream()
                .filter(nodeId -> !dependencies.containsKey(nodeId) || dependencies.get(nodeId).isEmpty())
                .collect(Collectors.toList());
    }

    private List<String> findNextNodes(
            Set<String> completedNodes,
            Map<String, List<String>> dependencies,
            Set<String> allNodes) {
        
        return allNodes.stream()
                .filter(nodeId -> {
                    List<String> deps = dependencies.get(nodeId);
                    return deps != null && completedNodes.containsAll(deps);
                })
                .filter(nodeId -> !completedNodes.contains(nodeId))
                .collect(Collectors.toList());
    }
}


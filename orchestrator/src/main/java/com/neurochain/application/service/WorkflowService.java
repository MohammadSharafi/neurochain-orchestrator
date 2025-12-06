package com.neurochain.application.service;

import com.neurochain.domain.model.*;
import com.neurochain.domain.repository.WorkflowRepository;
import com.neurochain.presentation.graphql.WorkflowResolver.*;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class WorkflowService {
    private final WorkflowRepository workflowRepository;

    public WorkflowService(WorkflowRepository workflowRepository) {
        this.workflowRepository = workflowRepository;
    }

    public List<Workflow> findAll() {
        return workflowRepository.findAll();
    }

    public Optional<Workflow> findById(String id) {
        return workflowRepository.findById(id);
    }

    public Workflow createWorkflow(WorkflowInput input) {
        Workflow workflow = new Workflow();
        workflow.setId(UUID.randomUUID().toString());
        workflow.setName(input.getName());
        workflow.setDescription(input.getDescription());
        workflow.setStatus(Workflow.WorkflowStatus.DRAFT);
        workflow.setTriggerType(Workflow.TriggerType.valueOf(input.getTriggerType()));
        workflow.setTriggerConfig(input.getTriggerConfig());
        workflow.setCreatedBy("system"); // TODO: Get from auth context
        workflow.setCreatedAt(LocalDateTime.now());
        workflow.setUpdatedAt(LocalDateTime.now());

        // Convert inputs to domain models
        workflow.setNodes(input.getNodes().stream()
                .map(this::toNode)
                .collect(Collectors.toList()));

        workflow.setConnections(input.getConnections().stream()
                .map(this::toConnection)
                .collect(Collectors.toList()));

        return workflowRepository.save(workflow);
    }

    public Workflow updateWorkflow(String id, WorkflowInput input) {
        Workflow workflow = workflowRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Workflow not found"));

        workflow.setName(input.getName());
        workflow.setDescription(input.getDescription());
        workflow.setTriggerType(Workflow.TriggerType.valueOf(input.getTriggerType()));
        workflow.setTriggerConfig(input.getTriggerConfig());
        workflow.setUpdatedAt(LocalDateTime.now());

        workflow.setNodes(input.getNodes().stream()
                .map(this::toNode)
                .collect(Collectors.toList()));

        workflow.setConnections(input.getConnections().stream()
                .map(this::toConnection)
                .collect(Collectors.toList()));

        return workflowRepository.save(workflow);
    }

    public Workflow pauseWorkflow(String id) {
        Workflow workflow = workflowRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Workflow not found"));
        workflow.setStatus(Workflow.WorkflowStatus.PAUSED);
        workflow.setUpdatedAt(LocalDateTime.now());
        return workflowRepository.save(workflow);
    }

    public Workflow resumeWorkflow(String id) {
        Workflow workflow = workflowRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Workflow not found"));
        workflow.setStatus(Workflow.WorkflowStatus.ACTIVE);
        workflow.setUpdatedAt(LocalDateTime.now());
        return workflowRepository.save(workflow);
    }

    public void deleteWorkflow(String id) {
        workflowRepository.deleteById(id);
    }

    private Node toNode(NodeInput input) {
        Node node = new Node();
        node.setId(input.getId());
        node.setType(input.getType());
        node.setPluginId(input.getPluginId());
        node.setName(input.getName());
        node.setParameters(input.getParameters());
        if (input.getPosition() != null) {
            Node.NodePosition pos = new Node.NodePosition();
            pos.setX(input.getPosition().getX());
            pos.setY(input.getPosition().getY());
            node.setPosition(pos);
        }
        return node;
    }

    private Connection toConnection(ConnectionInput input) {
        Connection conn = new Connection();
        conn.setId(input.getId());
        conn.setSourceNodeId(input.getSourceNodeId());
        conn.setSourcePort(input.getSourcePort());
        conn.setTargetNodeId(input.getTargetNodeId());
        conn.setTargetPort(input.getTargetPort());
        return conn;
    }
}


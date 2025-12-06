package com.neurochain.domain.repository;

import com.neurochain.domain.model.Workflow;
import java.util.List;
import java.util.Optional;

public interface WorkflowRepository {
    List<Workflow> findAll();
    Optional<Workflow> findById(String id);
    Workflow save(Workflow workflow);
    void deleteById(String id);
    List<Workflow> findByStatus(Workflow.WorkflowStatus status);
}


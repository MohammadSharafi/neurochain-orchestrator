package com.neurochain.presentation.graphql;

import com.neurochain.domain.model.WorkflowExecution;
import com.neurochain.infrastructure.messaging.EventBus;
import org.reactivestreams.Publisher;
import org.springframework.graphql.data.method.annotation.SubscriptionMapping;
import org.springframework.stereotype.Controller;
import reactor.core.publisher.Flux;

import java.time.Duration;
import java.util.Map;

/**
 * GraphQL Subscriptions for real-time updates
 */
@Controller
public class SubscriptionResolver {
    private final EventBus eventBus;

    public SubscriptionResolver(EventBus eventBus) {
        this.eventBus = eventBus;
    }

    @SubscriptionMapping
    public Publisher<WorkflowExecution> executionUpdated(String executionId) {
        return Flux.create(sink -> {
            // Subscribe to execution events
            eventBus.subscribe("execution." + executionId, (event) -> {
                // TODO: Convert event to WorkflowExecution
                // For now, emit a placeholder
                sink.next(new WorkflowExecution());
            });
        });
    }

    @SubscriptionMapping
    public Publisher<WorkflowExecution.NodeExecution> nodeExecutionUpdated(
            String executionId, String nodeId) {
        return Flux.create(sink -> {
            // Subscribe to node execution events
            eventBus.subscribe("node." + executionId + "." + nodeId, (event) -> {
                // TODO: Convert event to NodeExecution
                WorkflowExecution.NodeExecution nodeExec = new WorkflowExecution.NodeExecution();
                sink.next(nodeExec);
            });
        });
    }
}


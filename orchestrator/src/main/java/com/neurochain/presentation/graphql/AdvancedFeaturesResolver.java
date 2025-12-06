package com.neurochain.presentation.graphql;

import com.neurochain.application.service.*;
import com.neurochain.domain.model.Node;
import com.neurochain.domain.model.Workflow;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.stereotype.Controller;

import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

@Controller
public class AdvancedFeaturesResolver {
    private final AISandboxService sandboxService;
    private final ModelManagerService modelManager;
    private final VectorStoreService vectorStore;
    private final FineTuningService fineTuning;
    private final MarketplaceService marketplace;
    private final AIAutoBuilderService autoBuilder;
    private final WorkflowDSL dsl;
    private final TimeTravelDebugger debugger;

    public AdvancedFeaturesResolver(
            AISandboxService sandboxService,
            ModelManagerService modelManager,
            VectorStoreService vectorStore,
            FineTuningService fineTuning,
            MarketplaceService marketplace,
            AIAutoBuilderService autoBuilder,
            WorkflowDSL dsl,
            TimeTravelDebugger debugger) {
        this.sandboxService = sandboxService;
        this.modelManager = modelManager;
        this.vectorStore = vectorStore;
        this.fineTuning = fineTuning;
        this.marketplace = marketplace;
        this.autoBuilder = autoBuilder;
        this.dsl = dsl;
        this.debugger = debugger;
    }

    // AI Sandbox
    @QueryMapping
    public AISandboxService.SandboxResult testNode(
            @Argument WorkflowResolver.NodeInput nodeInput,
            @Argument Map<String, Object> inputs) {
        Node node = convertNodeInput(nodeInput);
        CompletableFuture<AISandboxService.SandboxResult> future = sandboxService.executeNode(node, inputs);
        try {
            return future.get();
        } catch (Exception e) {
            throw new RuntimeException("Sandbox execution failed", e);
        }
    }

    @MutationMapping
    public AISandboxService.SandboxResult executeInSandbox(
            @Argument WorkflowResolver.NodeInput nodeInput,
            @Argument Map<String, Object> inputs) {
        return testNode(nodeInput, inputs);
    }

    // Model Manager
    @QueryMapping
    public List<ModelManagerService.ModelInfo> installedModels() {
        return modelManager.getInstalledModels();
    }

    @QueryMapping
    public ModelManagerService.ModelInfo modelInfo(@Argument String name) {
        return modelManager.getModelInfo(name);
    }

    @QueryMapping
    public ModelManagerService.ModelBenchmark benchmarkModel(@Argument String name) {
        return modelManager.benchmarkModel(name);
    }

    @MutationMapping
    public ModelManagerService.ModelInstallResult installModel(
            @Argument String name,
            @Argument String url) {
        return modelManager.installModel(name, url);
    }

    @MutationMapping
    public Boolean removeModel(@Argument String name) {
        return modelManager.removeModel(name);
    }

    // Vector Stores
    @QueryMapping
    public List<VectorStoreService.VectorStore> vectorStores() {
        return vectorStore.getAllStores().stream()
                .map(store -> new VectorStoreDTO(store.getId(), store.getName(), store.getDocuments().size()))
                .map(dto -> {
                    VectorStoreService.VectorStore store = new VectorStoreService.VectorStore(dto.id(), dto.name());
                    // Add documents count
                    return store;
                })
                .toList();
    }

    @QueryMapping
    public List<VectorStoreService.SearchResult> searchVectorStore(
            @Argument String storeId,
            @Argument String query,
            @Argument Integer topK) {
        return vectorStore.similaritySearch(storeId, query, topK != null ? topK : 10);
    }

    @MutationMapping
    public VectorStoreDTO createVectorStore(@Argument String name) {
        VectorStoreService.VectorStore store = vectorStore.createStore(
                java.util.UUID.randomUUID().toString(), name);
        return new VectorStoreDTO(store.getId(), store.getName(), store.getDocuments().size());
    }

    @MutationMapping
    public Boolean addDocument(
            @Argument String storeId,
            @Argument String documentId,
            @Argument String text,
            @Argument Map<String, Object> metadata) {
        vectorStore.addDocument(storeId, documentId, text, metadata != null ? metadata : Map.of());
        return true;
    }

    // Fine Tuning
    @QueryMapping
    public FineTuningService.FineTuningJob fineTuningJob(@Argument String jobId) {
        return fineTuning.getJobStatus(jobId);
    }

    @MutationMapping
    public FineTuningService.FineTuningJob startFineTuning(@Argument FineTuningInput input) {
        FineTuningService.FineTuningRequest request = new FineTuningService.FineTuningRequest();
        request.setModelName(input.getModelName());
        request.setTrainingDataPath(input.getTrainingDataPath());
        request.setMethod(input.getMethod());
        request.setHyperparameters(input.getHyperparameters());
        return fineTuning.startFineTuning(request);
    }

    // Marketplace
    @QueryMapping
    public List<MarketplaceService.MarketplaceItem> marketplaceItems(
            @Argument MarketplaceService.ItemCategory category) {
        if (category != null) {
            return marketplace.getItemsByCategory(category);
        }
        return marketplace.getAllItems();
    }

    @QueryMapping
    public MarketplaceService.MarketplaceItem marketplaceItem(@Argument String id) {
        return marketplace.getAllItems().stream()
                .filter(item -> item.getId().equals(id))
                .findFirst()
                .orElse(null);
    }

    @MutationMapping
    public MarketplaceService.InstallationResult installMarketplaceItem(@Argument String itemId) {
        return marketplace.installItem(itemId);
    }

    // AI Auto-Build
    @MutationMapping
    public Workflow generateWorkflowFromDescription(
            @Argument String description,
            @Argument String name) {
        return autoBuilder.generateWorkflow(description, name);
    }

    // DSL
    @MutationMapping
    public Workflow createWorkflowFromDSL(
            @Argument String dsl,
            @Argument String name) {
        return dsl.parseDSL(dsl, name);
    }

    // Time Travel Debugger
    @QueryMapping
    public ExecutionTimelineDTO executionTimeline(@Argument String executionId) {
        TimeTravelDebugger.ExecutionTimeline timeline = debugger.getTimeline(executionId);
        if (timeline == null) {
            return null;
        }
        return new ExecutionTimelineDTO(
                timeline.getExecutionId(),
                timeline.getEvents().stream()
                        .map(e -> new TimelineEventDTO(
                                e.getId(),
                                e.getNodeId(),
                                e.getType().name(),
                                e.getTimestamp().toString(),
                                e.getData()
                        ))
                        .toList()
        );
    }

    @QueryMapping
    public List<IOHistoryDTO> ioHistory(
            @Argument String executionId,
            @Argument String nodeId) {
        return debugger.getIOHistory(executionId, nodeId).stream()
                .map(io -> new IOHistoryDTO(
                        io.getTimestamp().toString(),
                        io.getInputs(),
                        io.getOutputs()
                ))
                .toList();
    }

    private Node convertNodeInput(WorkflowResolver.NodeInput input) {
        Node node = new Node();
        node.setId(input.getId());
        node.setType(input.getType());
        node.setPluginId(input.getPluginId());
        node.setName(input.getName());
        node.setParameters(input.getParameters());
        return node;
    }

    // DTOs
    public record VectorStoreDTO(String id, String name, int documentCount) {}
    public record ExecutionTimelineDTO(String executionId, List<TimelineEventDTO> events) {}
    public record TimelineEventDTO(String id, String nodeId, String type, String timestamp, Map<String, Object> data) {}
    public record IOHistoryDTO(String timestamp, Map<String, Object> inputs, Map<String, Object> outputs) {}

    public static class FineTuningInput {
        private String modelName;
        private String trainingDataPath;
        private FineTuningService.FineTuningMethod method;
        private Map<String, Object> hyperparameters;

        public String getModelName() { return modelName; }
        public void setModelName(String modelName) { this.modelName = modelName; }
        public String getTrainingDataPath() { return trainingDataPath; }
        public void setTrainingDataPath(String trainingDataPath) { this.trainingDataPath = trainingDataPath; }
        public FineTuningService.FineTuningMethod getMethod() { return method; }
        public void setMethod(FineTuningService.FineTuningMethod method) { this.method = method; }
        public Map<String, Object> getHyperparameters() { return hyperparameters; }
        public void setHyperparameters(Map<String, Object> hyperparameters) { this.hyperparameters = hyperparameters; }
    }
}


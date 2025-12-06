class GraphQLMutations {
  // Workflows
  static const String createWorkflow = '''
    mutation CreateWorkflow(\$input: WorkflowInput!) {
      createWorkflow(input: \$input) {
        id
        name
        status
      }
    }
  ''';

  static const String executeWorkflow = '''
    mutation ExecuteWorkflow(\$id: ID!, \$inputs: JSON) {
      executeWorkflow(id: \$id, inputs: \$inputs) {
        id
        status
        startedAt
      }
    }
  ''';

  // AI Sandbox
  static const String executeInSandbox = '''
    mutation ExecuteInSandbox(\$node: NodeInput!, \$inputs: JSON!) {
      executeInSandbox(node: \$node, inputs: \$inputs) {
        executionId
        success
        inputs
        outputs
        reasoning
        executionTimeMs
        errorMessage
      }
    }
  ''';

  // Model Manager
  static const String installModel = '''
    mutation InstallModel(\$name: String!, \$url: String!) {
      installModel(name: \$name, url: \$url) {
        success
        message
        error
      }
    }
  ''';

  static const String removeModel = '''
    mutation RemoveModel(\$name: String!) {
      removeModel(name: \$name)
    }
  ''';

  // Vector Stores
  static const String createVectorStore = '''
    mutation CreateVectorStore(\$name: String!) {
      createVectorStore(name: \$name) {
        id
        name
        documentCount
      }
    }
  ''';

  static const String addDocument = '''
    mutation AddDocument(\$storeId: ID!, \$documentId: ID!, \$text: String!, \$metadata: JSON) {
      addDocument(storeId: \$storeId, documentId: \$documentId, text: \$text, metadata: \$metadata)
    }
  ''';

  // Fine Tuning
  static const String startFineTuning = '''
    mutation StartFineTuning(\$input: FineTuningInput!) {
      startFineTuning(input: \$input) {
        jobId
        modelName
        method
        status
        progress
      }
    }
  ''';

  // Marketplace
  static const String installMarketplaceItem = '''
    mutation InstallMarketplaceItem(\$itemId: ID!) {
      installMarketplaceItem(itemId: \$itemId) {
        success
        message
        error
      }
    }
  ''';

  // AI Auto-Builder
  static const String generateWorkflowFromDescription = '''
    mutation GenerateWorkflowFromDescription(\$description: String!, \$name: String!) {
      generateWorkflowFromDescription(description: \$description, name: \$name) {
        id
        name
        nodes {
          id
          type
          name
          parameters
        }
        connections {
          id
          sourceNodeId
          targetNodeId
        }
      }
    }
  ''';

  // DSL
  static const String createWorkflowFromDSL = '''
    mutation CreateWorkflowFromDSL(\$dsl: String!, \$name: String!) {
      createWorkflowFromDSL(dsl: \$dsl, name: \$name) {
        id
        name
        nodes {
          id
          type
          name
        }
        connections {
          id
          sourceNodeId
          targetNodeId
        }
      }
    }
  ''';
}

